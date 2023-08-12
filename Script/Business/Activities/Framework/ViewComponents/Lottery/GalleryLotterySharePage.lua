local GalleryLotterySharePage = class("GalleryLotterySharePage", PureMVC.ViewComponentPage)
function GalleryLotterySharePage:ListNeededMediators()
  return {}
end
function GalleryLotterySharePage:InitializeLuaEvent()
  self.Button_Confirm.OnClicked:Add(self, GalleryLotterySharePage.OnClickConfirm)
end
function GalleryLotterySharePage:OnOpen(luaOpenData, nativeOpenData)
end
function GalleryLotterySharePage:OnClickConfirm()
  ViewMgr:ClosePage(self, UIPageNameDefine.GalleryLotterySharePage)
end
function GalleryLotterySharePage:OnClickCancel()
  self:DoCancel()
end
function GalleryLotterySharePage:DoConfirm()
  if self.OkCallfunc then
    self.OkCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function GalleryLotterySharePage:DoCancel()
  if self.CancelCallfunc then
    self.CancelCallfunc()
  end
end
function GalleryLotterySharePage:OnClose()
  self.CancelCallfunc = nil
  self.OkCallfunc = nil
end
return GalleryLotterySharePage
