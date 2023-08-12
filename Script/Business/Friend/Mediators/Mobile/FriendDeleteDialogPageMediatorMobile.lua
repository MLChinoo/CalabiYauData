local FriendDeleteDialogPageMediatorMobile = class("FriendDeleteDialogPageMediatorMobile", PureMVC.Mediator)
function FriendDeleteDialogPageMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmdType.SetDeleteInfo
  }
end
function FriendDeleteDialogPageMediatorMobile:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmdType.SetDeleteInfo then
    self:SetBlackID(notify:GetBody().playerId, notify:GetBody().nick, notify:GetBody().friendType)
  end
end
function FriendDeleteDialogPageMediatorMobile:OnRegister()
  self:GetViewComponent().actionOnShow:Add(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Add(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Add(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Add(self.OnClickESC, self)
  self.playerId = nil
  self.nick = nil
  self.friendType = nil
end
function FriendDeleteDialogPageMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnShow:Remove(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Remove(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Remove(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Remove(self.OnClickESC, self)
end
function FriendDeleteDialogPageMediatorMobile:OnShow()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_OpenPage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendDeleteDialogPageMediatorMobile:OnClose()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_ClosePage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendDeleteDialogPageMediatorMobile:SetBlackID(inPlayerID, inPlayerName, infriendType)
  self.playerId = inPlayerID
  self.nick = inPlayerName
  self.friendType = infriendType
  if self:GetViewComponent().Text_PlayerName then
    self:GetViewComponent().Text_PlayerName:SetText(inPlayerName)
  end
end
function FriendDeleteDialogPageMediatorMobile:OnClickConfirm()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ReqFriendDel(self.playerId, self.friendType)
    local arg1 = UE4.FFormatArgumentData()
    arg1.ArgumentName = "0"
    arg1.ArgumentValue = self.nick
    arg1.ArgumentValueType = 4
    local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
    inArgsTarry:Add(arg1)
    local playerAlreadyRemoveFriendList = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "PlayerAlreadyRemoveFriendList")
    playerAlreadyRemoveFriendList = UE4.UKismetTextLibrary.Format(playerAlreadyRemoveFriendList, inArgsTarry)
    GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, playerAlreadyRemoveFriendList)
  end
  ViewMgr:ClosePage(self:GetViewComponent())
end
function FriendDeleteDialogPageMediatorMobile:OnClickESC()
  ViewMgr:ClosePage(self:GetViewComponent())
end
return FriendDeleteDialogPageMediatorMobile