local BattlePassBackGroundPage = class("BattlePassBackGroundPage", PureMVC.ViewComponentPage)
local BattlePassBackGroundMediator = require("Business/BattlePass/Mediators/BattlePassBackGroundMediator")
local viewChangeTime = 5
local EViewStyle = {
  None = 0,
  Image = 1,
  Senior = 2
}
local BATTLEPASS_SENIOR_ID = "19101"
local BATTLEPASS_SENIOR_PLUS_ID = "19201"
function BattlePassBackGroundPage:ListNeededMediators()
  return {BattlePassBackGroundMediator}
end
function BattlePassBackGroundPage:InitializeLuaEvent()
  self.switchContentEvent = LuaEvent.new()
  self.purchaseChoiceEvent = LuaEvent.new()
  self.currentIndex = 1
  self.maxIndex = 0
  self.currentStyle = EViewStyle.None
  self.viewShowTime = 0
  self.switchTag = "A"
end
function BattlePassBackGroundPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Button_Senior then
    self.Button_Senior.OnClicked:Add(self, self.OnBtSeniorClick)
  end
  if self.Button_SeniorPlus then
    self.Button_SeniorPlus.OnClicked:Add(self, self.OnBtSeniorPlusBpClick)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, BattlePassBackGroundPage.OnClickClose)
  end
end
function BattlePassBackGroundPage:OnClose()
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, BattlePassBackGroundPage.OnClickClose)
  end
  if self.Button_Senior then
    self.Button_Senior.OnClicked:Remove(self, self.OnBtSeniorClick)
  end
  if self.Button_SeniorPlus then
    self.Button_SeniorPlus.OnClicked:Remove(self, self.OnBtSeniorPlusBpClick)
  end
end
function BattlePassBackGroundPage:OnHoveredImg()
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
end
function BattlePassBackGroundPage:OnUnhoveredImg()
  if not self.timerHandler then
    self.timerHandler = TimerMgr:AddTimeTask(1, 1, 0, function()
      self:TimerChangeContent()
    end)
  end
end
function BattlePassBackGroundPage:OnMouseWheel(MyGeometry, MouseEvent)
  if self.maxIndex <= 1 then
    return true
  end
  local delta = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent)
  if delta > 0 then
    if 1 == self.currentIndex then
      self.currentIndex = self.maxIndex
    else
      self.currentIndex = self.currentIndex - 1
    end
  elseif self.currentIndex == self.maxIndex then
    self.currentIndex = 1
  else
    self.currentIndex = self.currentIndex + 1
  end
  self.switchContentEvent(self.currentIndex)
  return true
end
function BattlePassBackGroundPage:InitView(data, isVip, luaOpenData)
  self.maxIndex = table.count(data)
  if isVip then
    self.maxIndex = self.maxIndex - 1
  end
  if luaOpenData then
    local showIndex = tonumber(luaOpenData)
    if showIndex then
      self.currentIndex = math.clamp(showIndex, 1, self.maxIndex)
    end
  end
  if self.Pagination and self.maxIndex > 0 then
    self.Pagination:InitView(self, self.maxIndex, self.currentIndex)
  end
  self:SetViewStyle(data[self.currentIndex], isVip)
end
function BattlePassBackGroundPage:InitSenior(data)
  local outStr = ConfigMgr:FromStringTable(StringTablePath.ST_BattlePass, "BuySenior")
  if self.Text_Senior then
    self.Text_Senior:SetText(outStr .. data.seniorCost)
  end
  if self.Text_SeniorPlus then
    self.Text_SeniorPlus:SetText(outStr .. data.seniorPlusCost)
  end
end
function BattlePassBackGroundPage:SetVip(isVip)
  if self.Button_Senior then
    self.Button_Senior:SetVisibility(not isVip and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_SeniorPlus then
    self.Button_SeniorPlus:SetVisibility(not isVip and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function BattlePassBackGroundPage:TimerChangeContent()
  self.viewShowTime = self.viewShowTime + 1
  if self.viewShowTime >= viewChangeTime then
    self.currentIndex = self.currentIndex + 1
    if self.currentIndex > self.maxIndex then
      self.currentIndex = 1
    end
    self.switchContentEvent(self.currentIndex)
  end
end
function BattlePassBackGroundPage:PaginationClick(index)
  self.currentIndex = index
  if self.currentIndex > self.maxIndex then
    self.currentIndex = 1
  end
  self.switchContentEvent(self.currentIndex)
end
function BattlePassBackGroundPage:SetViewStyle(data, isVip)
  local inStyle = EViewStyle.Image
  if data then
    if data.Icon and 0 == data.Prize:Length() then
      inStyle = EViewStyle.Image
    elseif data.Prize:Length() > 0 and not isVip then
      inStyle = EViewStyle.Senior
    end
  else
    LogError("BattlePassBackGroundPage", "//索引%d超出了BattlePassBackGroud_通行证背景配置表范围,@策划", self.currentIndex)
  end
  if self.CP_Background then
    self.CP_Background:SetVisibility(inStyle == EViewStyle.Image and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.CP_Buy then
    self.CP_Buy:SetVisibility(inStyle == EViewStyle.Senior and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.currentStyle == EViewStyle.None then
    if inStyle == EViewStyle.Image then
      self.Img_BgA:SetBrushFromSoftTexture(data.Icon)
      if self.Anim_Background then
        self:PlayAnimation(self.Anim_Background, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
      end
    end
  elseif self.currentStyle == EViewStyle.Image and inStyle == EViewStyle.Image then
    self:PlayBgAnim(data.Icon)
  end
  if inStyle == EViewStyle.Senior then
    self:PlayAnimation(self.Anim_Character, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  else
    self:StopAnimation(self.Anim_Character)
  end
  self.currentStyle = inStyle
end
function BattlePassBackGroundPage:OperateView(data)
  self.viewShowTime = 0
  self:SetViewStyle(data)
  self:SwitchPagination()
end
function BattlePassBackGroundPage:SwitchPagination()
  if self.Pagination then
    self.Pagination:SwitchActive(self.currentIndex)
  end
end
function BattlePassBackGroundPage:PlayBgAnim(img)
  if self.Img_BgA and self.Img_BgB then
    self.Img_BgB:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:StopAnimation(self.Anim_FadeinA)
    self:StopAnimation(self.Anim_FadeoutB)
    self:StopAnimation(self.Anim_FadeinB)
    self:StopAnimation(self.Anim_FadeoutA)
    if self.switchTag == "A" then
      self.Img_BgA:SetBrushFromSoftTexture(img)
      self.switchTag = "B"
      self:PlayAnimation(self.Anim_FadeinA, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
      self:PlayAnimation(self.Anim_FadeoutB, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
      self.Img_BgB:SetBrushFromSoftTexture(img)
      self.switchTag = "A"
      self:PlayAnimation(self.Anim_FadeinB, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
      self:PlayAnimation(self.Anim_FadeoutA, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
  end
end
function BattlePassBackGroundPage:SeasonIntermission()
  if self.WidgetSwitcher_Season then
    self.WidgetSwitcher_Season:SetActiveWidgetIndex(1)
  end
end
function BattlePassBackGroundPage:OnClickClose()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function BattlePassBackGroundPage:OnBtSeniorClick()
  local showBrowser = false
  if self.CB_Browser_Buy then
    showBrowser = self.CB_Browser_Buy:IsChecked()
  end
  GameFacade:RetrieveProxy(ProxyNames.MidasProxy):BuyGoodsByID(BATTLEPASS_SENIOR_ID, showBrowser)
  self.purchaseChoiceEvent(false)
end
function BattlePassBackGroundPage:OnBtSeniorPlusBpClick()
  local showBrowser = false
  if self.CB_Browser_Buy then
    showBrowser = self.CB_Browser_Buy:IsChecked()
  end
  GameFacade:RetrieveProxy(ProxyNames.MidasProxy):BuyGoodsByID(BATTLEPASS_SENIOR_PLUS_ID, showBrowser)
  self.purchaseChoiceEvent(true)
end
return BattlePassBackGroundPage
