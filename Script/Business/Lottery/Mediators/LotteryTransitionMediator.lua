local LotteryTransitionMediator = class("LotteryTransitionMediator", PureMVC.Mediator)
function LotteryTransitionMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.OnLotteryEffectFinished
  }
end
function LotteryTransitionMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.OnLotteryEffectFinished then
    self:GetViewComponent():EnterEndProcess()
  end
end
function LotteryTransitionMediator:OnRegister()
  LogDebug("LotteryTransitionMediator", "On register")
  LotteryTransitionMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnStartTransition:Add(self.StartTransition, self)
  self:GetViewComponent().actionOnSkip:Add(self.SkipLotteryProcess, self)
end
function LotteryTransitionMediator:OnRemove()
  self:GetViewComponent().actionOnStartTransition:Remove(self.StartTransition, self)
  self:GetViewComponent().actionOnSkip:Remove(self.SkipLotteryProcess, self)
  self:ClearDelegate()
  LotteryTransitionMediator.super.OnRemove(self)
end
function LotteryTransitionMediator:StartTransition(sequenceId)
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StartLotteryEffect()
  self.SequenceStopDelegate = DelegateMgr:AddDelegate(GetGlobalDelegateManager().OnSequenceStopGlobalDelegate, self, "OnSequenceStopCallBack")
  UE4.UCySequenceManager.Get(LuaGetWorld()):PlaySequence(sequenceId)
end
function LotteryTransitionMediator:SkipLotteryProcess()
  UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SkipLotteryProcess()
  local lotteryResults = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryObtained()
  local bHasHighQuality = false
  for key, value in pairs(lotteryResults) do
    if value.quality and value.quality >= UE4.ECyItemQualityType.Orange then
      bHasHighQuality = true
    end
  end
  if bHasHighQuality then
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.ResultDisplayPage)
  else
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.LotteryResultPage)
  end
end
function LotteryTransitionMediator:OnSequenceStopCallBack(sequenceId, reasonType)
  LogInfo("LotteryTransitionMediator", "On sequence stop call back")
  self:ClearDelegate()
end
function LotteryTransitionMediator:ClearDelegate()
  if self.SequenceStopDelegate then
    LogInfo("LotteryTransitionMediator", "Clear call back")
    DelegateMgr:RemoveDelegate(GetGlobalDelegateManager().OnSequenceStopGlobalDelegate, self.SequenceStopDelegate)
    self.SequenceStopDelegate = nil
  end
end
return LotteryTransitionMediator
