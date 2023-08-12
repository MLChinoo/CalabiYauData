local GuideSubTaskTipsPanel = class("GuideSubTaskTipsPanel", PureMVC.ViewComponentPanel)
function GuideSubTaskTipsPanel:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideSubTaskTipsMediator")
  }
end
function GuideSubTaskTipsPanel:InitializeLuaEvent()
  self.OnInitPanelEvent = LuaEvent.new()
end
function GuideSubTaskTipsPanel:InitPanel(InData)
  self.OnInitPanelEvent(InData)
end
return GuideSubTaskTipsPanel
