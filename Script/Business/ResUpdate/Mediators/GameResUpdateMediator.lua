local GameResUpdateMediator = class("GameResUpdateMediator", PureMVC.Mediator)
function GameResUpdateMediator:OnRegister()
  self.ResUpdatePage = self:GetViewComponent()
  self:InitModule()
end
function GameResUpdateMediator:OnRemove()
  if self.ShowMsgBoxDelegateHandler then
    DelegateMgr:UnbindDelegate(self.DolphinSubSystem.ShowMsgBoxDelegate, self.ShowMsgBoxDelegateHandler)
    self.ShowMsgBoxDelegateHandler = nil
  end
  if self.UpdateErrorDelegateHandler then
    DelegateMgr:UnbindDelegate(self.DolphinSubSystem.UpdateErrorDelegate, self.UpdateErrorDelegateHandler)
    self.UpdateErrorDelegateHandler = nil
  end
  if self.UpdateProgressDelegateHandler then
    DelegateMgr:UnbindDelegate(self.DolphinSubSystem.UpdateProgressDelegate, self.UpdateProgressDelegateHandler)
    self.UpdateProgressDelegateHandler = nil
  end
  if self.VersionInfoDelegateHandler then
    DelegateMgr:UnbindDelegate(self.DolphinSubSystem.VersionInfoDelegate, self.VersionInfoDelegateHandler)
    self.VersionInfoDelegateHandler = nil
  end
  if self.UpdateCompleteDelegateHandler then
    DelegateMgr:UnbindDelegate(self.DolphinSubSystem.UpdateCompleteDelegate, self.UpdateCompleteDelegateHandler)
    self.UpdateCompleteDelegateHandler = nil
  end
end
function GameResUpdateMediator:InitModule()
  self.DolphinSubSystem = UE4.UPMDolphinSubSystem.GetInst(LuaGetWorld())
  if not self.DolphinSubSystem then
    LogInfo("GameResUpdateMediator", "GameResUpdateMediator:InitModule, DolphinSubSystem is nil")
    return
  end
  self.ShowMsgBoxDelegateHandler = DelegateMgr:BindDelegate(self.DolphinSubSystem.ShowMsgBoxDelegate, self, GameResUpdateMediator.OnShowMsgBox)
  self.UpdateErrorDelegateHandler = DelegateMgr:BindDelegate(self.DolphinSubSystem.UpdateErrorDelegate, self, GameResUpdateMediator.OnUpdateError)
  self.UpdateProgressDelegateHandler = DelegateMgr:BindDelegate(self.DolphinSubSystem.UpdateProgressDelegate, self, GameResUpdateMediator.OnUpdateProgress)
  self.VersionInfoDelegateHandler = DelegateMgr:BindDelegate(self.DolphinSubSystem.VersionInfoDelegate, self, GameResUpdateMediator.OnUpdateVersionInfo)
  self.UpdateCompleteDelegateHandler = DelegateMgr:BindDelegate(self.DolphinSubSystem.UpdateCompleteDelegate, self, GameResUpdateMediator.OnUpdateComplete)
end
function GameResUpdateMediator:OnShowMsgBox(msg, errCode)
  self.ResUpdatePage:ShowMsgBox(msg, errCode)
end
function GameResUpdateMediator:OnUpdateError(curState, errorCode)
  self.ResUpdatePage:SetUpdateError(curState, errorCode)
end
function GameResUpdateMediator:OnUpdateProgress(curState, totalSize, curSize)
  self.ResUpdatePage:SetUpdateProgress(curState, totalSize, curSize)
end
function GameResUpdateMediator:OnUpdateVersionInfo(UpdateType, UpdateVersion, UpdateSize, UpdateDesc, CustomDesc)
  self.ResUpdatePage:UpdateVersionInfo(UpdateType, UpdateVersion, UpdateSize, UpdateDesc, CustomDesc)
end
function GameResUpdateMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfResUpdatePlayerChoice
  }
end
function GameResUpdateMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.NtfResUpdatePlayerChoice then
    self:ProcessPlayerChoice(Body)
  end
end
function GameResUpdateMediator:ProcessPlayerChoice(isConfirm)
  if isConfirm then
    self.DolphinSubSystem:OnSelectConfirm()
  else
    self.DolphinSubSystem:OnSelectCancel()
  end
end
function GameResUpdateMediator:OnUpdateComplete()
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.GameResUpdatePage)
end
return GameResUpdateMediator
