local GalleryLotteryRulePage = class("GalleryLotteryRulePage", PureMVC.ViewComponentPage)
function GalleryLotteryRulePage:ListNeededMediators()
  return {}
end
function GalleryLotteryRulePage:InitializeLuaEvent()
  self.Button_Confirm.OnClicked:Add(self, GalleryLotteryRulePage.OnClickConfirm)
end
function GalleryLotteryRulePage:OnClickConfirm()
  ViewMgr:ClosePage(self, UIPageNameDefine.GalleryLotteryRulePage)
end
return GalleryLotteryRulePage
