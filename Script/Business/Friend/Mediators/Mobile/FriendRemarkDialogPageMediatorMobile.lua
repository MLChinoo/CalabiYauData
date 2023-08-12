local FriendRemarkDialogPageMediatorMobile = class("FriendRemarkDialogPageMediatorMobile", PureMVC.Mediator)
function FriendRemarkDialogPageMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmdType.SetRemarkUserInfo
  }
end
function FriendRemarkDialogPageMediatorMobile:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmdType.SetRemarkUserInfo then
    self:SetPlayerID(notify:GetBody().playerId)
  end
end
function FriendRemarkDialogPageMediatorMobile:OnRegister()
  self:GetViewComponent().actionOnShow:Add(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Add(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Add(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Add(self.OnClickESC, self)
  self.PlayerID = nil
end
function FriendRemarkDialogPageMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnShow:Remove(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Remove(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Remove(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Remove(self.OnClickESC, self)
end
function FriendRemarkDialogPageMediatorMobile:OnShow()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_OpenPage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendRemarkDialogPageMediatorMobile:OnClose()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_ClosePage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendRemarkDialogPageMediatorMobile:SetPlayerID(inPlayerID)
  self.PlayerID = inPlayerID
end
function FriendRemarkDialogPageMediatorMobile:OnClickConfirm()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ReqFriendRemarks(self.PlayerID, self:GetViewComponent().InputText:GetText())
  end
  ViewMgr:ClosePage(self:GetViewComponent())
end
function FriendRemarkDialogPageMediatorMobile:OnClickESC()
  ViewMgr:ClosePage(self:GetViewComponent())
end
return FriendRemarkDialogPageMediatorMobile
