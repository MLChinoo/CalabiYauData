local GuideTaskPage = class("GuideTaskPage", PureMVC.ViewComponentPage)
function GuideTaskPage:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideTaskMediator")
  }
end
return GuideTaskPage
