local GuideUIGuidePage = class("GuideUIGuidePage", PureMVC.ViewComponentPage)
function GuideUIGuidePage:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideUIGuideMediator")
  }
end
function GuideUIGuidePage:InitializeLuaEvent()
  self.OnViewTargetChangedEvent = LuaEvent.new()
end
function GuideUIGuidePage:K2_OnViewTargetChanged(InViewTarget)
  if self.OnViewTargetChangedEvent then
    self.OnViewTargetChangedEvent(InViewTarget)
  end
end
return GuideUIGuidePage
