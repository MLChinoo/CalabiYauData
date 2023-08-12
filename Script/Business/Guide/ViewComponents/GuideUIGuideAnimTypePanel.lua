local GuideUIGuideAnimTypePanel = class("GuideUIGuideAnimTypePanel", PureMVC.ViewComponentPanel)
function GuideUIGuideAnimTypePanel:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideUIGuideAnimTypeMediator")
  }
end
function GuideUIGuideAnimTypePanel:InitializeLuaEvent()
  self.OnInitPanelEvent = LuaEvent.new()
end
function GuideUIGuideAnimTypePanel:InitPanel(InData)
  if self.OnInitPanelEvent then
    self.OnInitPanelEvent(InData)
  end
end
return GuideUIGuideAnimTypePanel
