local FriendDeleteGroupDialogPageMediator = class("FriendDeleteGroupDialogPageMediator", PureMVC.Mediator)
function FriendDeleteGroupDialogPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmd
  }
end
function FriendDeleteGroupDialogPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmd and notify:GetType() == NotificationDefines.FriendCmdType.SetDeleteGroupID then
    self:SetDeleteID(notify:GetBody().inGroupID, notify:GetBody().inGroupName)
  end
end
function FriendDeleteGroupDialogPageMediator:OnRegister()
  self:GetViewComponent().actionOnClickConfirm:Add(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickEsc:Add(self.OnClickEsc, self)
end
function FriendDeleteGroupDialogPageMediator:OnRemove()
  self:GetViewComponent().actionOnClickConfirm:Remove(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickEsc:Remove(self.OnClickEsc, self)
end
function FriendDeleteGroupDialogPageMediator:OnClickConfirm()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ReqFriendGroupDel(self.deleteGroupID)
  end
  ViewMgr:ClosePage(self:GetViewComponent(), "FriendDeleteGroupConfirmPage")
end
function FriendDeleteGroupDialogPageMediator:OnClickEsc()
  ViewMgr:ClosePage(self:GetViewComponent(), "FriendDeleteGroupConfirmPage")
end
function FriendDeleteGroupDialogPageMediator:SetDeleteID(inGroupID, inGroupName)
  self.deleteGroupID = inGroupID
  self.groupName = inGroupName
  if self:GetViewComponent().Text_GroupName then
    self:GetViewComponent().Text_GroupName:SetText(inGroupName)
  end
end
return FriendDeleteGroupDialogPageMediator
