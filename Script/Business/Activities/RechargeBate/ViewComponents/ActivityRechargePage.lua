local ActivityRechargePage = class("ActivityRechargePage", PureMVC.ViewComponentPage)
local ActivityRechargeMediator = require("Business/Activities/RechargeBate/Mediators/ActivityRechargeMediator")
local Valid
local Gear = {
  6,
  200,
  1000,
  3000
}
function ActivityRechargePage:ListNeededMediators()
  return {ActivityRechargeMediator}
end
function ActivityRechargePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClose()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
function ActivityRechargePage:InitializeLuaEvent()
end
function ActivityRechargePage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.OnClickClose, self)
  Valid = self.Button_TopUp and self.Button_TopUp.OnClickEvent:Add(self, self.OnClickTopUp)
  Valid = self.Btn_Tips and self.Btn_Tips.OnClicked:Add(self, self.OnClickTip)
end
function ActivityRechargePage:OnClose()
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.OnClickClose, self)
  Valid = self.Button_TopUp and self.Button_TopUp.OnClickEvent:Remove(self, self.OnClickTopUp)
  Valid = self.Btn_Tips and self.Btn_Tips.OnClicked:Remove(self, self.OnClickTip)
end
function ActivityRechargePage:Init(PageData)
  if PageData then
    Valid = PageData.ChargeNum and self.Text_RMB and self.Text_RMB:SetText(PageData.ChargeNum)
    Valid = PageData.RebateNum and self.Text_ReBeta and self.Text_ReBeta:SetText(PageData.RebateNum)
    local CurPercent = 1
    local LastGearNum = 0
    for i, CurGearNum in pairs(Gear) do
      if CurGearNum > PageData.ChargeNum then
        CurPercent = (PageData.ChargeNum - LastGearNum) / (CurGearNum - LastGearNum) * (1 / table.count(Gear)) + (i - 1) / table.count(Gear)
        break
      end
      LastGearNum = CurGearNum
    end
    local ProgressPercent = math.clamp(CurPercent, 0, 1)
    Valid = self.ProgressBar and self.ProgressBar:SetPercent(ProgressPercent)
    Valid = self.SizeBox_Particle and self.SizeBox_Particle:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.ParticleSystemWidget and self.ParticleSystemWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
    if ProgressPercent < 1 then
      Valid = self.SizeBox_Particle and self.SizeBox_Particle:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      local horizontalSlot = self.SizeBox_Particle and UE4.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(self.SizeBox_Particle)
      if horizontalSlot then
        local sizeRule = UE4.FSlateChildSize()
        sizeRule.SizeRule = UE4.ESlateSizeRule.Fill
        sizeRule.Value = ProgressPercent
        horizontalSlot:SetSize(sizeRule)
      end
      local horizontalSlot2 = self.Spacer_Particle and UE4.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(self.Spacer_Particle)
      if horizontalSlot2 then
        local sizeRule = UE4.FSlateChildSize()
        sizeRule.SizeRule = UE4.ESlateSizeRule.Fill
        sizeRule.Value = 1 - ProgressPercent
        horizontalSlot2:SetSize(sizeRule)
      end
    else
      Valid = self.ParticleSystemWidget and self.ParticleSystemWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    Valid = PageData.LeftTimeText and self.Text_LeftTime and self.Text_LeftTime:SetText(PageData.LeftTimeText)
    Valid = PageData.OpenTimeText and self.Text_OpenTime and self.Text_OpenTime:SetText(PageData.OpenTimeText)
    self.OpenTimeText = PageData.OpenTimeText
  end
end
function ActivityRechargePage:OnClickClose()
  ViewMgr:ClosePage(self)
end
function ActivityRechargePage:OnClickTopUp()
  local NavBarBodyTable = {
    pageType = UE4.EPMFunctionTypes.Shop,
    secondIndex = 2
  }
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
  self:OnClickClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.ActivityEntryListPage)
end
function ActivityRechargePage:OnClickTip()
  ViewMgr:OpenPage(self, UIPageNameDefine.ActivityRechargeTipPage, nil, self.OpenTimeText)
end
return ActivityRechargePage
