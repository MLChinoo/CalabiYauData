local ExchangePosPageMediator = class("ExchangePosPageMediator", PureMVC.Mediator)
function ExchangePosPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.OnRoomSwitchNtf,
    NotificationDefines.TeamRoom.OnRoomSwitchClickItemNtf
  }
end
function ExchangePosPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.TeamRoom.OnRoomSwitchNtf then
    self:AddSwitchPanel(notify:GetBody().inPlayer, notify:GetBody().inRoomID)
  elseif notify:GetName() == NotificationDefines.TeamRoom.OnRoomSwitchClickItemNtf then
    self:GetViewComponent():OnSelectPlayer(notify:GetBody())
  end
end
function ExchangePosPageMediator:OnRegister()
  self:GetViewComponent().actionLuaHandleKeyEvent:Add(self.LuaHandleKeyEvent, self)
  self:GetViewComponent().actionConfirm:Add(self.OnClickY, self)
  self:GetViewComponent().actionRefuse:Add(self.OnClickN, self)
  self:GetViewComponent().actionKeepIgnore:Add(self.OnCheckStateChangedKeepIgnore, self)
end
function ExchangePosPageMediator:OnRemove()
  self:GetViewComponent().actionLuaHandleKeyEvent:Remove(self.LuaHandleKeyEvent, self)
  self:GetViewComponent().actionConfirm:Remove(self.OnClickY, self)
  self:GetViewComponent().actionRefuse:Remove(self.OnClickN, self)
  self:GetViewComponent().actionKeepIgnore:Remove(self.OnCheckStateChangedKeepIgnore, self)
end
function ExchangePosPageMediator:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return
  end
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Y" then
    self:OnClickY()
    return true
  elseif UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "N" then
    self:OnClickN()
    return true
  end
  return false
end
function ExchangePosPageMediator:AddSwitchPanel(inInfo, inRoomID)
  self.roomId = inRoomID
  local singleData = {}
  singleData.PlayerNickName = inInfo.nick
  local avatarId = tonumber(inInfo.icon)
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(avatarId)
  singleData.PlayerIcon = avatarIcon
  singleData.PlayerID = inInfo.playerId
  singleData.pos = inInfo.pos
  singleData.stars = inInfo.stars
  for i, v in ipairs(self:GetViewComponent().WBP_ApplyPlayerItemList.itemArr) do
    if singleData.PlayerID == v.infoData.PlayerID then
      return
    end
  end
  self:GetViewComponent():AddPlayerItem(singleData)
end
function ExchangePosPageMediator:OnClickY()
  self:RoomSwitch(true)
end
function ExchangePosPageMediator:OnClickN()
  self:RoomSwitch(false)
end
function ExchangePosPageMediator:RoomSwitch(bSwitch)
  local selectItem = self:GetViewComponent().WBP_ApplyPlayerItemList._selectItem
  if bSwitch and selectItem then
    local playerInfo = selectItem.infoData
    local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
    roomDataProxy:ReqRoomSwitchAnswer(self.roomId, playerInfo.PlayerID, playerInfo.pos, bSwitch)
    ViewMgr:ClosePage(self:GetViewComponent())
  elseif not bSwitch and selectItem then
    self:GetViewComponent():RemoveEntryItem(selectItem)
    if 0 == #self:GetViewComponent().WBP_ApplyPlayerItemList.itemArr then
      ViewMgr:ClosePage(self:GetViewComponent())
    else
      self:GetViewComponent().WBP_ApplyPlayerItemList:SetSelectedByIndex(1)
    end
  end
end
function ExchangePosPageMediator:OnCheckStateChangedKeepIgnore(bIsChecked)
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomProxy then
    roomProxy:SetKeepIgnoreExchangePositionReq(bIsChecked)
  end
end
return ExchangePosPageMediator
