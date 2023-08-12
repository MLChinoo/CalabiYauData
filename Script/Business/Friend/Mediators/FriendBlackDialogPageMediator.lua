local FriendBlackDialogPageMediator = class("FriendBlackDialogPageMediator", PureMVC.Mediator)
function FriendBlackDialogPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmdType.SetShieldUserInfo
  }
end
function FriendBlackDialogPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmdType.SetShieldUserInfo then
    self:SetBlackID(notify:GetBody().playerId, notify:GetBody().nick)
  end
end
function FriendBlackDialogPageMediator:OnRegister()
  self:GetViewComponent().actionOnShow:Add(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Add(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Add(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Add(self.OnClickESC, self)
  self.blackID = nil
  self.nick = nil
end
function FriendBlackDialogPageMediator:OnRemove()
  self:GetViewComponent().actionOnShow:Remove(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Remove(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Remove(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Remove(self.OnClickESC, self)
end
function FriendBlackDialogPageMediator:OnShow()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_OpenPage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendBlackDialogPageMediator:OnClose()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_ClosePage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendBlackDialogPageMediator:SetBlackID(inPlayerID, inPlayerName)
  self.blackID = inPlayerID
  self.nick = inPlayerName
  if self:GetViewComponent().Text_PlayerName then
    self:GetViewComponent().Text_PlayerName:SetText(inPlayerName)
  end
end
function FriendBlackDialogPageMediator:OnClickConfirm()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ShieldPlayer(self.blackID)
  end
  ViewMgr:ClosePage(self:GetViewComponent())
end
function FriendBlackDialogPageMediator:OnClickESC()
  ViewMgr:ClosePage(self:GetViewComponent())
end
return FriendBlackDialogPageMediator
