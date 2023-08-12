local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local FriendBlackDialogPageMediatorMobile = class("FriendBlackDialogPageMediatorMobile", PureMVC.Mediator)
function FriendBlackDialogPageMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmdType.SetShieldUserInfo
  }
end
function FriendBlackDialogPageMediatorMobile:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmdType.SetShieldUserInfo then
    self:SetBlackID(notify:GetBody().playerId, notify:GetBody().nick)
  end
end
function FriendBlackDialogPageMediatorMobile:OnRegister()
  self:GetViewComponent().actionOnShow:Add(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Add(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Add(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Add(self.OnClickESC, self)
  self.blackID = nil
  self.nick = nil
end
function FriendBlackDialogPageMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnShow:Remove(self.OnShow, self)
  self:GetViewComponent().actionOnClose:Remove(self.OnClose, self)
  self:GetViewComponent().actionOnClickConfirm:Remove(self.OnClickConfirm, self)
  self:GetViewComponent().actionOnClickESC:Remove(self.OnClickESC, self)
end
function FriendBlackDialogPageMediatorMobile:OnShow()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_OpenPage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendBlackDialogPageMediatorMobile:OnClose()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_ClosePage, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
function FriendBlackDialogPageMediatorMobile:SetBlackID(inPlayerID, inPlayerName)
  self.blackID = inPlayerID
  self.nick = inPlayerName
  if self:GetViewComponent().Text_PlayerName then
    self:GetViewComponent().Text_PlayerName:SetText(inPlayerName)
  end
end
function FriendBlackDialogPageMediatorMobile:OnClickConfirm()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ReqFriendAdd(self.nick, self.blackID, FriendEnum.FriendType.Blacklist)
  end
  ViewMgr:ClosePage(self:GetViewComponent())
end
function FriendBlackDialogPageMediatorMobile:OnClickESC()
  ViewMgr:ClosePage(self:GetViewComponent())
end
return FriendBlackDialogPageMediatorMobile
