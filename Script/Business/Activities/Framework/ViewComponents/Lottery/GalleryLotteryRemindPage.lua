local GalleryLotteryRemindPage = class("GalleryLotteryRemindPage", PureMVC.ViewComponentPage)
function GalleryLotteryRemindPage:ListNeededMediators()
  return {}
end
function GalleryLotteryRemindPage:InitializeLuaEvent()
  self.Button_Confirm.OnClicked:Add(self, GalleryLotteryRemindPage.OnClickConfirm)
end
function GalleryLotteryRemindPage:OnOpen(luaOpenData, nativeOpenData)
end
function GalleryLotteryRemindPage:OnClickConfirm()
  ViewMgr:ClosePage(self, UIPageNameDefine.GalleryLotteryRemindPage)
end
function GalleryLotteryRemindPage:OnClickCancel()
  self:DoCancel()
end
function GalleryLotteryRemindPage:DoConfirm()
  if self.OkCallfunc then
    self.OkCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function GalleryLotteryRemindPage:DoCancel()
  if self.CancelCallfunc then
    self.CancelCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function GalleryLotteryRemindPage:OnClose()
  self.CancelCallfunc = nil
  self.OkCallfunc = nil
end
return GalleryLotteryRemindPage
