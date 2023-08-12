local RoleWarmUpExchangeRewardPageMediator = require("Business/Activities/MeredithRoleWarmUp/Mediators/RoleWarmUpExchangeRewardPageMediator")
local RoleWarmUpExchangeRewardPage = class("RoleWarmUpExchangeRewardPage", PureMVC.ViewComponentPage)
local RoleWarmUpProxy
function RoleWarmUpExchangeRewardPage:ListNeededMediators()
  return {RoleWarmUpExchangeRewardPageMediator}
end
function RoleWarmUpExchangeRewardPage:InitializeLuaEvent()
end
function RoleWarmUpExchangeRewardPage:OnOpen(luaOpenData, nativeOpenData)
  self.data = luaOpenData
  self.minEnergyNum = 1
  RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.EntryRewardExchangePage, 0)
  end
  self.CancelBtn.OnClickEvent:Add(self, self.OnClickCloseBtn)
  self.ItemNumMinusBtn.OnClicked:Add(self, self.OnClickItemNumMinusBtn)
  self.ItemNumAddBtn.OnClicked:Add(self, self.OnClickItemNumAddBtn)
  self.ItemNumMaxBtn.OnClicked:Add(self, self.OnClickItemNumMaxBtn)
  self.ConfirmExchangeRewardBtn.OnClickEvent:Add(self, self.OnClickConfirmExchangeRewardBtn)
  self.Slider_ExchangeReward.OnValueChanged:Add(self, self.OnExchangeNumValueChanged)
  self:UpdataExchangeRewardUI()
end
function RoleWarmUpExchangeRewardPage:OnClose()
  self.CancelBtn.OnClickEvent:Remove(self, self.OnClickCloseBtn)
  self.ItemNumMinusBtn.OnClicked:Remove(self, self.OnClickItemNumMinusBtn)
  self.ItemNumAddBtn.OnClicked:Remove(self, self.OnClickItemNumAddBtn)
  self.ItemNumMaxBtn.OnClicked:Remove(self, self.OnClickItemNumMaxBtn)
  self.ConfirmExchangeRewardBtn.OnClickEvent:Remove(self, self.OnClickConfirmExchangeRewardBtn)
  self.Slider_ExchangeReward.OnValueChanged:Remove(self, self.OnExchangeNumValueChanged)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.QuitRewardExchangePage, 0)
  end
end
function RoleWarmUpExchangeRewardPage:OnExchangeNumValueChanged(value)
  LogDebug("OnClickConfirmExchangeRewardBtn", "OnExchangeNumValueChanged  value = " .. tostring(value))
  if self.SumEnergyNum > self.minEnergyNum then
    if value < self.minEnergyNum and self.minEnergyNum < self.SumEnergyNum then
      self.currentEnergyNum = self.minEnergyNum
    elseif value < self.minEnergyNum and self.minEnergyNum > self.SumEnergyNum then
      self.currentEnergyNum = self.SumEnergyNum
    else
      self.currentEnergyNum = math.floor(value)
    end
  else
    self.currentEnergyNum = 0
  end
  self:SetProgressUI()
end
function RoleWarmUpExchangeRewardPage:OnClickItemNumMinusBtn()
  LogDebug("RoleWarmUpExchangeRewardPage", "OnClickItemNumMinusBtn")
  if self.SumEnergyNum < self.minEnergyNum then
    return
  end
  if self.currentEnergyNum - self.minEnergyNum >= self.minEnergyNum then
    self.currentEnergyNum = self.currentEnergyNum - self.minEnergyNum
  end
  self:SetProgressUI()
end
function RoleWarmUpExchangeRewardPage:OnClickItemNumAddBtn()
  LogDebug("RoleWarmUpExchangeRewardPage", "OnClickItemNumAddBtn")
  if self.SumEnergyNum < self.minEnergyNum then
    return
  end
  if self.minEnergyNum + self.currentEnergyNum <= self.SumEnergyNum then
    self.currentEnergyNum = self.currentEnergyNum + self.minEnergyNum
  end
  self:SetProgressUI()
end
function RoleWarmUpExchangeRewardPage:OnClickItemNumMaxBtn()
  LogDebug("RoleWarmUpExchangeRewardPage", "OnClickItemNumMaxBtn")
  if self.SumEnergyNum < self.minEnergyNum then
    return
  end
  self.currentEnergyNum = math.floor(self.SumEnergyNum / self.minEnergyNum) * self.minEnergyNum
  self:SetProgressUI()
end
function RoleWarmUpExchangeRewardPage:OnClickConfirmExchangeRewardBtn()
  LogDebug("RoleWarmUpExchangeRewardPage", "OnClickConfirmExchangeRewardBtn self.ConvertTime =" .. tostring(self.ConvertTime))
  if self.currentEnergyNum >= self.minEnergyNum and RoleWarmUpProxy then
    RoleWarmUpProxy:ReqExchangeReward(RoleWarmUpProxy:GetActivityId(), self.ConvertTime)
  end
end
function RoleWarmUpExchangeRewardPage:OnClickCloseBtn()
  LogDebug("RoleWarmUpExchangeRewardPage", "OnClickCloseBtn")
  ViewMgr:ClosePage(self)
end
function RoleWarmUpExchangeRewardPage:SetProgressUI()
  local ratio = self.currentEnergyNum / self.SumEnergyNum
  self.ProgressBar_ExchangeReward:SetPercent(ratio)
  self.Slider_ExchangeReward:SetValue(self.currentEnergyNum)
  self.ConvertTime = math.floor(self.currentEnergyNum / self.minEnergyNum)
  if 0 == self.ConvertTime then
    self.CurrentEnergyText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NotExchangeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CurrentEnergyText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NotExchangeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CurrentEnergyText:SetText(self.ConvertTime)
  end
  self.ConvertTimesText:SetText(math.floor(self.SumEnergyNum / self.minEnergyNum))
  local ItemCount
  if 0 == self.currentEnergyNum then
    ItemCount = math.floor(self.RewardTB[1].ItemCount)
  else
    ItemCount = math.floor(self.ConvertTime * self.RewardTB[1].ItemCount)
  end
  self.RewardItem:UpdataRewardItem({
    ItemId = self.RewardTB[1].ItemId,
    ItemCount = ItemCount
  })
end
function RoleWarmUpExchangeRewardPage:UpdataExchangeRewardUI()
  if RoleWarmUpProxy then
    self.SumEnergyNum = RoleWarmUpProxy:GetCurrentEnergy()
    self.minEnergyNum = RoleWarmUpProxy:GetConsumeNumWhileExchange()
    self.currentEnergyNum = self.minEnergyNum
    self.RewardTB = RoleWarmUpProxy:GetRedeemRewardTB()
  end
  self.SumEnergyText:SetText(tostring(self.SumEnergyNum))
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if ItemsProxy then
    local ItemName = ItemsProxy:GetAnyItemName(self.RewardTB[1].ItemId)
    self.ItemNameText:SetText(ItemName)
    local ItemDesc = ItemsProxy:GetAnyItemDesc(self.RewardTB[1].ItemId)
    self.ItemDescText:SetText(ItemDesc)
  end
  if RoleWarmUpProxy then
    local ItemCount = math.floor(self.RewardTB[1].ItemCount)
    self.RewardItem:UpdataRewardItem({
      ItemId = self.RewardTB[1].ItemId,
      ItemCount = ItemCount
    })
  end
  self.ConsumeOnceNumText:SetText(tostring(self.minEnergyNum))
  if self.SumEnergyNum >= self.minEnergyNum then
    self.ConfirmExchangeRewardBtn:SetButtonIsEnabled(true)
    self.Slider_ExchangeReward:SetMinValue(0)
    self.Slider_ExchangeReward:SetMaxValue(self.SumEnergyNum)
    self.Slider_ExchangeReward:SetStepSize(self.minEnergyNum)
    local ratio = self.currentEnergyNum / self.SumEnergyNum
    self.ProgressBar_ExchangeReward:SetPercent(ratio)
    self.Slider_ExchangeReward:SetValue(self.currentEnergyNum)
    self.Slider_ExchangeReward:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemNumAddBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemNumMinusBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemNumMaxBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ConvertTime = math.floor(self.currentEnergyNum / self.minEnergyNum)
    self.CurrentEnergyText:SetText(tostring(self.ConvertTime))
    self.CurrentEnergyText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NotExchangeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ConvertTimesText:SetText(math.floor(self.SumEnergyNum / self.minEnergyNum))
  else
    self.ProgressBar_ExchangeReward:SetPercent(0)
    self.Slider_ExchangeReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemNumAddBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemNumMinusBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemNumMaxBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CurrentEnergyText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CurrentEnergyText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NotExchangeText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ConvertTime = 0
    self.ConfirmExchangeRewardBtn:SetButtonIsEnabled(false)
    self.ConvertTimesText:SetText("0")
  end
end
function RoleWarmUpExchangeRewardPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickCloseBtn()
    end
    return true
  else
    return false
  end
end
return RoleWarmUpExchangeRewardPage
