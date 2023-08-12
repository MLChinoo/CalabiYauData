local GuideUIGuideEffectTypeMediator = class("GuideUIGuideEffectTypeMediator", PureMVC.Mediator)
local ESlateVisibility = UE4.ESlateVisibility
function GuideUIGuideEffectTypeMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnInitPanelEvent:Add(self.InitUIGuide, self)
end
function GuideUIGuideEffectTypeMediator:OnRemove()
  if self.LoopAnimTask then
    self.LoopAnimTask:EndTask()
    self.LoopAnimTask = nil
  end
  if self.EndTask then
    self.EndTask:EndTask()
    self.EndTask = nil
  end
end
function GuideUIGuideEffectTypeMediator:InitUIGuide(InData)
  local viewComponent = self.viewComponent
  if not (InData and viewComponent) or not TimerMgr then
    return
  end
  LogInfo("GuideUIGuideEffectTypeMediator", "InitUIGuide")
  local AnimTime = viewComponent.LoopAnimTime and viewComponent.LoopAnimTime or 0.0
  if AnimTime <= 0.001 then
    return
  end
  viewComponent:SetVisibility(ESlateVisibility.Collapsed)
  local LoopInterval = InData.LoopInterval and InData.LoopInterval or 0.0
  if LoopInterval <= 0.001 then
    LoopInterval = AnimTime
  end
  local BeginDelay = InData.BeginDelay and InData.BeginDelay or 0.0
  local LoopTimes = InData.LoopTimes and InData.LoopTimes or 0
  self.LoopAnimTask = TimerMgr:AddTimeTask(BeginDelay, LoopInterval, LoopTimes, function()
    self:OnBeginOnceUIGuide()
  end)
  if LoopTimes > 0 then
    local TotalTime = BeginDelay + LoopInterval * LoopTimes
    self.EndTask = TimerMgr:AddTimeTask(TotalTime, 0.0, 1, function()
      self:OnEndUIGuide()
    end)
  end
end
function GuideUIGuideEffectTypeMediator:OnBeginOnceUIGuide()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if viewComponent.ParticleSystemWidget_Effect then
    viewComponent.ParticleSystemWidget_Effect:ActivateParticles(true, true)
  end
end
function GuideUIGuideEffectTypeMediator:OnEndUIGuide()
  if self.LoopAnimTask then
    self.LoopAnimTask:EndTask()
    self.LoopAnimTask = nil
  end
  self.EndTask = nil
  if self.viewComponent then
    self.viewComponent:RemoveFromViewport()
  end
end
return GuideUIGuideEffectTypeMediator
