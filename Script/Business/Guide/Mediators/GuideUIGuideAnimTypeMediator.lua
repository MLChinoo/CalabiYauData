local GuideUIGuideAnimTypeMediator = class("GuideUIGuideAnimTypeMediator", PureMVC.Mediator)
local ESlateVisibility = UE4.ESlateVisibility
function GuideUIGuideAnimTypeMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnInitPanelEvent:Add(self.InitUIGuide, self)
end
function GuideUIGuideAnimTypeMediator:OnRemove()
  if self.LoopAnimTask then
    self.LoopAnimTask:EndTask()
    self.LoopAnimTask = nil
  end
  if self.EndTask then
    self.EndTask:EndTask()
    self.EndTask = nil
  end
end
function GuideUIGuideAnimTypeMediator:InitUIGuide(InData)
  local viewComponent = self.viewComponent
  if not (InData and viewComponent) or not TimerMgr then
    return
  end
  LogInfo("GuideUIGuideAnimTypeMediator", "InitUIGuide")
  local AnimTime = viewComponent.LoopAnimTime and viewComponent.LoopAnimTime or 0.0
  if AnimTime <= 0.001 then
    return
  end
  local LoopInterval = InData.LoopInterval and InData.LoopInterval or 0.0
  if LoopInterval <= 0.001 then
    LoopInterval = AnimTime
  end
  viewComponent:SetVisibility(ESlateVisibility.Collapsed)
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
function GuideUIGuideAnimTypeMediator:OnBeginOnceUIGuide()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if viewComponent.Anim_Loop then
    viewComponent:PlayAnimation(viewComponent.Anim_Loop, 0.0, 0, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end
function GuideUIGuideAnimTypeMediator:OnEndUIGuide()
  if self.LoopAnimTask then
    self.LoopAnimTask:EndTask()
    self.LoopAnimTask = nil
  end
  self.EndTask = nil
  if self.viewComponent then
    self.viewComponent:RemoveFromViewport()
  end
end
return GuideUIGuideAnimTypeMediator
