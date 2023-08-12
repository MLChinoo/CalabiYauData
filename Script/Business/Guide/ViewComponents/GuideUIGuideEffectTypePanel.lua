local GuideUIGuideEffectTypePanel = class("GuideUIGuideEffectTypePanel", PureMVC.ViewComponentPanel)
function GuideUIGuideEffectTypePanel:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideUIGuideEffectTypeMediator")
  }
end
function GuideUIGuideEffectTypePanel:InitializeLuaEvent()
  self.OnInitPanelEvent = LuaEvent.new()
end
function GuideUIGuideEffectTypePanel:InitPanel(InData)
  if self.OnInitPanelEvent then
    self.OnInitPanelEvent(InData)
  end
end
return GuideUIGuideEffectTypePanel
