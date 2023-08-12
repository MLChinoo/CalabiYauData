local GameModeSelectProxy = class("GameModeSelectProxy", PureMVC.Proxy)
local GameModeSelectEnum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function GameModeSelectProxy:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
  self.gameModeSelectMediatorIns = nil
end
function GameModeSelectProxy:OnBackToGameRoom()
  if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    local sendData = {}
    sendData.pageType = UE4.EPMFunctionTypes.Play
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, sendData)
  elseif 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.GameModeSelectPage)
  end
end
function GameModeSelectProxy:OnRegister()
  self.super.OnRegister(self)
  self.TeamInfo = nil
  self.currentGameMode = nil
  local global_delegate_manager = GetGlobalDelegateManager()
  self.QuitGameToLobbyHandler = DelegateMgr:AddDelegate(global_delegate_manager.QuitGameToLobby, self, "OnQuitGameToLobby")
  self.BackToGameRoomHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnBackToGameRoom, self, "OnBackToGameRoom")
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_RES, FuncSlot(self.OnResTeamMode, self))
end
function GameModeSelectProxy:OnQuitGameToLobby()
  if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
  elseif 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    ViewMgr:PopPage(LuaGetWorld(), UIPageNameDefine.GameModeSelectPage)
  end
  TimerMgr:AddTimeTask(2, 0, 1, function()
    local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
    friendDataProxy:OpenFriendMsgPage()
  end)
end
function GameModeSelectProxy:OnRemove()
  local global_delegate_manager = GetGlobalDelegateManager()
  DelegateMgr:RemoveDelegate(global_delegate_manager.QuitGameToLobby, self.QuitGameToLobbyHandler)
  DelegateMgr:RemoveDelegate(global_delegate_manager.OnBackToGameRoom, self.BackToGameRoomHandler)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TEAM_MODE_RES, FuncSlot(self.OnResTeamMode, self))
end
function GameModeSelectProxy:RequestTeamCreate(gameModeType)
  local teamCreateReq = {}
  teamCreateReq.mode = gameModeType
  local req = pb.encode(Pb_ncmd_cs_lobby.team_create_req, teamCreateReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_CREATE_REQ, req)
end
function GameModeSelectProxy:RequestTeamExit(teamID)
  local teamExitReq = {}
  teamExitReq.team_id = teamID
  local req = pb.encode(Pb_ncmd_cs_lobby.team_exit_req, teamExitReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_TEAM_EXIT_REQ, req)
end
function GameModeSelectProxy:OnResTeamMode(data)
  local teamModeRes = pb.decode(Pb_ncmd_cs_lobby.team_mode_res, data)
  if self.gameModeSelectMediatorIns then
    self.gameModeSelectMediatorIns:OnResTeamMode(teamModeRes.code)
  end
  if 0 ~= teamModeRes.code then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.RestoreGameMode)
    if teamModeRes.code == 4016 then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamModeChangeNumberErrorText")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    end
  end
end
function GameModeSelectProxy:ClearData()
  self.TeamInfo = {}
  self.RoomInfo = {}
end
function GameModeSelectProxy:SetBackToHomePage(bBackToHomePage)
  self.bBackToHomePage = bBackToHomePage
end
function GameModeSelectProxy:GetBackToHomePage()
  return self.bBackToHomePage
end
function GameModeSelectProxy:GetGameModeTypeByNavBtnType(navBtnType)
  if navBtnType == GameModeSelectEnum.NavBtnType.Boomb then
    return GameModeSelectEnum.GameModeType.Boomb
  elseif navBtnType == GameModeSelectEnum.NavBtnType.Team then
    return GameModeSelectEnum.GameModeType.Team
  elseif navBtnType == GameModeSelectEnum.NavBtnType.RankBomb then
    return GameModeSelectEnum.GameModeType.RankBomb
  elseif navBtnType == GameModeSelectEnum.NavBtnType.CrystalScramble then
    return GameModeSelectEnum.GameModeType.CrystalScramble
  elseif navBtnType == GameModeSelectEnum.NavBtnType.Team5V5V5 then
    return GameModeSelectEnum.GameModeType.Team5V5V5
  elseif navBtnType == GameModeSelectEnum.NavBtnType.Custom then
    return GameModeSelectEnum.GameModeType.Room
  end
  return GameModeSelectEnum.GameModeType.None
end
return GameModeSelectProxy
