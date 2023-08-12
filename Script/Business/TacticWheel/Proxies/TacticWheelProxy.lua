local TacticWheelProxy = class("TacticWheelProxy", PureMVC.Proxy)
local RoleAction = {}
local RoleVoice = {}
local TableCfgInited = false
local NeedUpdate = true
local CommunicationInfoArray = {}
function TacticWheelProxy:OnRegister()
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    self.OnChangeSelectRoleIdHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnChangeSelectRoleId, self, "OnChangeRoleId")
  end
end
function TacticWheelProxy:OnRemove()
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnChangeSelectRoleId, self.OnChangeSelectRoleIdHandle)
  end
end
function TacticWheelProxy:OnChangeRoleId(PlayerState)
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(LuaGetWorld(), 0)
  local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
  if not MyPlayerState then
    return
  end
  if MyPlayerState == PlayerState then
    self:InitCommunicateInfoArray()
    NeedUpdate = true
  end
end
function TacticWheelProxy:IsNeedUpdate()
  return NeedUpdate
end
function TacticWheelProxy:SetNeedUpdate(value)
  NeedUpdate = value
end
function TacticWheelProxy:InitRoleTableCfg()
  if not TableCfgInited then
    local arrRows = ConfigMgr:GetRoleActionTableRows()
    if arrRows then
      RoleAction = arrRows:ToLuaTable()
    end
    arrRows = ConfigMgr:GetRoleVoiceTableRows()
    if arrRows then
      RoleVoice = arrRows:ToLuaTable()
    end
    TableCfgInited = true
  end
end
function TacticWheelProxy:GetRoleActionCfg()
  self:InitRoleTableCfg()
  return RoleAction
end
function TacticWheelProxy:GetRoleVoiceCfg()
  self:InitRoleTableCfg()
  return RoleVoice
end
function TacticWheelProxy:GetRoleVoiceRow(Index)
  local Cfg = TacticWheelProxy:GetRoleVoiceCfg()
  local row = Cfg[tostring(Index)]
  if not row then
    LogError("TacticWheel GetRoleVoiceRow error", "Index[%s] not found!", Index)
  end
  return row
end
function TacticWheelProxy:GetRoleActionRow(Index)
  local Cfg = TacticWheelProxy:GetRoleActionCfg()
  local row = Cfg[tostring(Index)]
  if not row then
    LogError("TacticWheel GetRoleActionRow error", "Index[%s] not found!", Index)
  end
  return row
end
function TacticWheelProxy:GetCommunicateInfoArray()
  return CommunicationInfoArray
end
function TacticWheelProxy:InitCommunicateInfoArray()
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(LuaGetWorld(), 0)
  local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
  if not MyPlayerState then
    return
  end
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  CommunicationInfoArray = RoleProxy:GetRoleEquipCommunication(MyPlayerState.SelectRoleId)
end
function TacticWheelProxy:GetCommunicateInfo(Index)
  if nil == CommunicationInfoArray or nil == next(CommunicationInfoArray) then
    return nil
  end
  return CommunicationInfoArray[Index]
end
return TacticWheelProxy
