local LoginDataProxy = class("LoginDataProxy", PureMVC.Proxy)
local LoginWelcomVoiceCfg = {}
function LoginDataProxy:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function LoginDataProxy:OnRegister()
  self.super.OnRegister(self)
  self:InitCfgs()
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGIN_QUEUE_RES, FuncSlot(self.OnReceiveLoginQueueRes, self))
end
function LoginDataProxy:InitCfgs()
  local tempWelcomCfg = ConfigMgr:GetLoginWelcomeVoiceTableRow()
  if not tempWelcomCfg then
    return
  end
  tempWelcomCfg = tempWelcomCfg:ToLuaTable()
  for key, value in pairs(tempWelcomCfg) do
    LoginWelcomVoiceCfg[tonumber(key)] = value
  end
end
function LoginDataProxy:RandomRoleWelcomeVoiceId()
  local totalVoice = #LoginWelcomVoiceCfg
  local row = UE4.UKismetMathLibrary.RandomIntegerInRange(1, totalVoice)
  local voiceCfg = LoginWelcomVoiceCfg[row]
  if not voiceCfg then
    return
  end
  return voiceCfg.VoiceId
end
function LoginDataProxy:ReqLoginQueue()
  local LoginSubSystem = UE.UPMLoginSubSystem.GetInstance(LuaGetWorld())
  local data = {
    open_id = LoginSubSystem:GetLoginOpenId(),
    oper_id = 0
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_LOGIN_QUEUE_REQ, pb.encode(Pb_ncmd_cs_lobby.login_queue_req, data))
end
function LoginDataProxy:ReqQuitQueue()
  local LoginSubSystem = UE.UPMLoginSubSystem.GetInstance(LuaGetWorld())
  local data = {
    open_id = LoginSubSystem:GetLoginOpenId(),
    oper_id = 1
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_LOGIN_QUEUE_REQ, pb.encode(Pb_ncmd_cs_lobby.login_queue_req, data))
end
function LoginDataProxy:OnReceiveLoginRes(data)
  local login_res = DeCode(Pb_ncmd_cs_lobby.login_res, data)
  if login_res.code == 3072 then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.LoginQueuePage)
  end
end
function LoginDataProxy:OnReceiveLoginQueueRes(data)
  local login_queue_res = DeCode(Pb_ncmd_cs_lobby.login_queue_res, data)
  if 0 ~= login_queue_res.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTip, login_queue_res.code)
    return nil
  end
  local body = {}
  body.info = login_queue_res
  if 0 == login_queue_res.rank then
    LogInfo("LoginDataProxy:OnReceiveLoginQueueRes", "login_queue_res.rank == 0, LoginQueue Success! , ReqLobbyLogin(), CloseLoginQueuePage")
    body.IsCanIn = true
  elseif 1 == login_queue_res.oper_id then
    LogInfo("LoginDataProxy:OnReceiveLoginQueueRes", "login_queue_res.oper_id == 1, LoginQueue Quit!")
    return nil
  else
    body.IsCanIn = false
  end
  GameFacade:SendNotification(NotificationDefines.Login.RefreshLoginQueueInfo, body)
end
return LoginDataProxy
