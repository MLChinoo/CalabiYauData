local DSDisconnectMediator = class("DSDisconnectMediator", PureMVC.Mediator)
function DSDisconnectMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmd
  }
end
function DSDisconnectMediator:OnRegister()
  LogDebug("DSDisconnectMediator", "OnRegister...")
  self:GetViewComponent().actionOnReconnectDS:Add(self.OnReconnectToDS, self)
  self:GetViewComponent().actionOnGotoLobby:Add(self.OnGotoLobby, self)
end
function DSDisconnectMediator:OnViewComponentPagePreOpen()
  local luaOpenData = self:GetViewComponent():GetOpenData()
  local title = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "DisconnectToDS")
  local content = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "IfTryReconnectToDS")
  local yesBtn = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "TryReconnect")
  local noBtn = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ReturnMainMenu")
  local roomPrxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomstr = "0"
  if roomPrxy then
    roomstr = roomPrxy.roomId
  end
  content = string.format([[
%s
Room:%s ErrorCode:%s]], content, roomstr, luaOpenData.Code)
  if not GameUtil:IsBuildShipingOrTest() then
    content = content .. [[

Dev Info:]] .. luaOpenData.ExtraErrorString
  end
  self:GetViewComponent():RefreshData(title, content, yesBtn, noBtn)
end
function DSDisconnectMediator:OnRemove()
  self:GetViewComponent().actionOnReconnectDS:Remove(self.OnReconnectToDS, self)
  self:GetViewComponent().actionOnGotoLobby:Remove(self.OnGotoLobby, self)
end
function DSDisconnectMediator:OnReconnectToDS()
  LogDebug("DSDisconnectMediator", "OnReconnectToDS...")
  GameFacade:SendNotification(NotificationDefines.ReConnectToDS, nil, NotificationDefines.ReConnectToDSType.UserTrigger)
end
function DSDisconnectMediator:OnGotoLobby()
end
return DSDisconnectMediator
