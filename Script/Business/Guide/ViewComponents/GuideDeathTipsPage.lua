local GuideDeathTipsPage = class("GuideDeathTipsPage", PureMVC.ViewComponentPage)
function GuideDeathTipsPage:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideDeathTipsMediator")
  }
end
function GuideDeathTipsPage:InitializeLuaEvent()
  self.OnViewTargetChangedEvent = LuaEvent.new()
end
function GuideDeathTipsPage:K2_OnViewTargetChanged(InViewTarget)
  self.OnViewTargetChangedEvent(InViewTarget)
end
return GuideDeathTipsPage
