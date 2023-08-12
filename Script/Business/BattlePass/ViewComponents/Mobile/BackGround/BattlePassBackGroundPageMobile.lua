local BattlePassBackGroundPageMobile = class("BattlePassBackGroundPageMobile", PureMVC.ViewComponentPage)
local BattlePassBackGroundMediator = require("Business/BattlePass/Mediators/BattlePassBackGroundMediator")
local viewChangeTime = 5
function BattlePassBackGroundPageMobile:ListNeededMediators()
  return {BattlePassBackGroundMediator}
end
function BattlePassBackGroundPageMobile:InitializeLuaEvent()
  self.switchContentEvent = LuaEvent.new()
  self.currentIndex = 1
  self.maxIndex = 0
  self.viewShowTime = 0
end
function BattlePassBackGroundPageMobile:OnOpen(luaOpenData, nativeOpenData)
end
function BattlePassBackGroundPageMobile:OnClose()
  self:StopTimer()
end
function BattlePassBackGroundPageMobile:StopTimer()
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
end
function BattlePassBackGroundPageMobile:StartTimer()
  if not self.timerHandler then
    self.timerHandler = TimerMgr:AddTimeTask(1, 1, 0, function()
      self:TimerChangeContent()
    end)
  end
end
function BattlePassBackGroundPageMobile:InitView(data)
  self.maxIndex = 1
  if self.Pagination and self.maxIndex > 0 then
    self.Pagination:InitView(self, self.maxIndex)
    self:SwitchContent(data[self.currentIndex])
  end
end
function BattlePassBackGroundPageMobile:InitSenior()
end
function BattlePassBackGroundPageMobile:SetVip(isVip)
end
function BattlePassBackGroundPageMobile:TimerChangeContent()
  self.viewShowTime = self.viewShowTime + 1
  if self.viewShowTime >= viewChangeTime then
    self.currentIndex = self.currentIndex + 1
    if self.currentIndex > self.maxIndex then
      self.currentIndex = 1
    end
    self.switchContentEvent(self.currentIndex)
  end
end
function BattlePassBackGroundPageMobile:PaginationClick(index)
  self.currentIndex = index
  if self.currentIndex > self.maxIndex then
    self.currentIndex = 1
  end
  self.switchContentEvent(self.currentIndex)
end
function BattlePassBackGroundPageMobile:OperateView(data)
  self.viewShowTime = 0
  self:SwitchContent(data)
  self:SwitchPagination()
end
function BattlePassBackGroundPageMobile:SwitchContent(data)
  if self.Img_BattlePassPicture then
    self.Img_BattlePassPicture:SetBrushFromSoftTexture(data.Icon)
  end
  if self.RichTextBlock_Content then
    local txt = UE4.UKismetStringLibrary.Replace(data.Content, "</br>", "\n")
    self.RichTextBlock_Content:SetText(txt)
  end
end
function BattlePassBackGroundPageMobile:SwitchPagination()
  if self.Pagination then
    self.Pagination:SwitchActive(self.currentIndex)
  end
end
function BattlePassBackGroundPageMobile:OnTouchStarted(InGeometry, InGestureEvent)
  do return end
  self:StopTimer()
  self.startTouchPoint = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InGestureEvent)
end
function BattlePassBackGroundPageMobile:OnTouchEnded(InGeometry, InGestureEvent)
  do return end
  local endTouchPoint = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InGestureEvent)
  local delta = endTouchPoint.X - self.startTouchPoint.X
  local move = false
  if delta > 5 then
    if self.currentIndex == self.maxIndex then
      self.currentIndex = 1
    else
      self.currentIndex = self.currentIndex + 1
    end
    move = true
  elseif delta < -5 then
    if 1 == self.currentIndex then
      self.currentIndex = self.maxIndex
    else
      self.currentIndex = self.currentIndex - 1
    end
    move = true
  end
  if move then
    self.switchContentEvent(self.currentIndex)
  end
  self:StartTimer()
end
function BattlePassBackGroundPageMobile:SeasonIntermission()
  if self.Img_BK then
    self.Img_BK:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.EmptyHint then
    self.EmptyHint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Img_BattlePassPicture then
    self.Img_BattlePassPicture:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Image_PaginationBg then
    self.Image_PaginationBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Pagination then
    self.Pagination:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return BattlePassBackGroundPageMobile
