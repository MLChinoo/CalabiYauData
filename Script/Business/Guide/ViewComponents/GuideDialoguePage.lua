local GuideDialoguePage = class("GuideDialoguePage", PureMVC.ViewComponentPage)
function GuideDialoguePage:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideDialogueMediator")
  }
end
return GuideDialoguePage
