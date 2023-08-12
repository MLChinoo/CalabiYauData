local GuideUIGuideInfoTypeMediator = class("GuideUIGuideInfoTypeMediator", PureMVC.Mediator)
local ESlateVisibility = UE4.ESlateVisibility
function GuideUIGuideInfoTypeMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnInitPanelEvent:Add(self.InitUIGuide, self)
end
function GuideUIGuideInfoTypeMediator:OnRemove()
  if self.LoopAnimTask then
    self.LoopAnimTask:EndTask()
    self.LoopAnimTask = nil
  end
  if self.EndTask then
    self.EndTask:EndTask()
    self.EndTask = nil
  end
end
function GuideUIGuideInfoTypeMediator:InitUIGuide(InData)
  local viewComponent = self.viewComponent
  if not (InData and viewComponent) or not TimerMgr then
    return
  end
  LogInfo("GuideUIGuideInfoTypeMediator", "InitUIGuide")
  if viewComponent.TextBlock_Info and InData.GuideInfo then
    viewComponent.TextBlock_Info:SetText(InData.GuideInfo)
  end
  viewComponent:SetVisibility(ESlateVisibility.Collapsed)
  local BeginDelay = InData.BeginDelay and InData.BeginDelay or 0.0
  self.LoopAnimTask = TimerMgr:AddTimeTask(BeginDelay, 0.0, 1, function()
    self:OnBeginOnceUIGuide()
  end)
end
function GuideUIGuideInfoTypeMediator:OnBeginOnceUIGuide()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if viewComponent.Anim_Enter then
    viewComponent:PlayAnimation(viewComponent.Anim_Enter, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
end
return GuideUIGuideInfoTypeMediator
