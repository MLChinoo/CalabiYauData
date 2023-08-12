local ReturnLetterPageMediator = class("ReturnLetterPageMediator", PureMVC.Mediator)
function ReturnLetterPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.RetrunLetterPage.HideLetter
  }
end
function ReturnLetterPageMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local type = notification:GetType()
  local data = notification:GetBody()
  if NtfName == NotificationDefines.RetrunLetterPage.HideLetter then
    self:HideLetterPage()
  end
end
function ReturnLetterPageMediator:HideLetterPage()
  self:GetViewComponent().CanvasPanel_Main:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ReturnLetterPageMediator:OnRegister()
  self.super:OnRegister()
end
function ReturnLetterPageMediator:OnRemove()
  self.super:OnRemove()
  self:ClearSequenceStopDelegate()
end
function ReturnLetterPageMediator:OnSequenceStopCallBack()
  self:ClearSequenceStopDelegate()
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self:GetViewComponent(), false)
end
function ReturnLetterPageMediator:ClearSequenceStopDelegate()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr and self.CloisterFragmentStopDelegate then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self.CloisterFragmentStopDelegate)
    self.CloisterFragmentStopDelegate = nil
  end
end
return ReturnLetterPageMediator
