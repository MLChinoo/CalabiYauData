local GuideUIGuideInfoTypePanel = class("GuideUIGuideInfoTypePanel", PureMVC.ViewComponentPanel)
function GuideUIGuideInfoTypePanel:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideUIGuideInfoTypeMediator")
  }
end
function GuideUIGuideInfoTypePanel:InitializeLuaEvent()
  self.OnInitPanelEvent = LuaEvent.new()
end
function GuideUIGuideInfoTypePanel:InitPanel(InData)
  if self.OnInitPanelEvent then
    self.OnInitPanelEvent(InData)
  end
end
return GuideUIGuideInfoTypePanel
