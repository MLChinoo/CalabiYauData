local GalleryLotteryMainPage = class("GalleryLotteryMainPage", PureMVC.ViewComponentPage)
function GalleryLotteryMainPage:ListNeededMediators()
  return {}
end
function GalleryLotteryMainPage:InitializeLuaEvent()
  self.Button_Confirm.OnClicked:Add(self, GalleryLotteryMainPage.OnClickConfirm)
end
function GalleryLotteryMainPage:OnOpen(luaOpenData, nativeOpenData)
end
function GalleryLotteryMainPage:OnClickConfirm()
  ViewMgr:ClosePage(self, UIPageNameDefine.GalleryLotteryMainPage)
end
function GalleryLotteryMainPage:OnClickCancel()
  self:DoCancel()
end
function GalleryLotteryMainPage:DoConfirm()
  if self.OkCallfunc then
    self.OkCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function GalleryLotteryMainPage:DoCancel()
  if self.CancelCallfunc then
    self.CancelCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function GalleryLotteryMainPage:OnClose()
  self.CancelCallfunc = nil
  self.OkCallfunc = nil
end
return GalleryLotteryMainPage
