local GuideSubTaskPanel = class("GuideSubTaskPanel", PureMVC.ViewComponentPanel)
function GuideSubTaskPanel:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideSubTaskMediator")
  }
end
function GuideSubTaskPanel:InitializeLuaEvent()
  self.OnInitPanelEvent = LuaEvent.new()
end
function GuideSubTaskPanel:InitPanel(InData)
  self.OnInitPanelEvent(InData)
end
return GuideSubTaskPanel
