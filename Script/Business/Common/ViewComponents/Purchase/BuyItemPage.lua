local BuyItemPage = class("BuyItemPage", PureMVC.ViewComponentPage)
local BuyItemMediator = require("Business/Hermes/Mediators/HotList/PurchaseGoodsMediator")
local Valid
function BuyItemPage:Init(GoodsData)
  if not GoodsData then
    return nil
  end
  self.goodsData = GoodsData
  self.StoreId = GoodsData.StoreId
  Valid = self.ItemBought and self.ItemBought:Init(GoodsData.GoodsId)
  Valid = self.Text_ItemName and self.Text_ItemName:SetText(GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemName(GoodsData.GoodsId))
  Valid = self.PriceCombination and self.PriceCombination:Update(GoodsData.StoreId)
  self.LimitNum = self.PriceCombination and self.PriceCombination:GetLimitNumMap()
  self.LimitNum = self.MaxNum
  Valid = self.Slider and self.Slider:SetMaxValue(self.LimitNum)
  Valid = self.Slider and self.Slider:SetMinValue(self.MinNum)
  Valid = self.Slider and self.Slider:SetStepSize(1)
  self:SetItemAmount()
  self:UpdateSlide()
end
function BuyItemPage:SetItemAmount()
  if self.itemNum and self.ItemBought then
    self.itemNum = self.itemNum < self.MinNum and self.MinNum or self.itemNum
    self.itemNum = self.itemNum > self.LimitNum and self.LimitNum or self.itemNum
    self.ItemBought:SetItemAmount(self.itemNum)
    Valid = self.PriceCombination and self.PriceCombination:FixedPriceByNum(self.itemNum)
  end
end
function BuyItemPage:UpdateSlide()
  if self.itemNum then
    local InItemNum = math.max(self.itemNum - 1, 0)
    local Lerp = 0 == self.LimitNum - 1 and 1 or math.lerp(0, 1, InItemNum / (self.LimitNum - 1))
    Valid = self.ProgressBar and self.ProgressBar:SetPercent(Lerp)
    Valid = self.Slider and self.Slider:SetValue(self.itemNum)
  end
end
function BuyItemPage:ClosePage()
  local WaitingTime = 0
  if self.Check_Pop_Close then
    self:PlayAnimationForward(self.Check_Pop_Close, 1, false)
    WaitingTime = self.Check_Pop_Close:GetEndTime()
  end
  if TimerMgr then
    if self.WaitingCloseTask then
      self.WaitingCloseTask:EndTask()
      self.WaitingCloseTask = nil
    end
    self.WaitingCloseTask = TimerMgr:AddTimeTask(WaitingTime, 0.0, 0, function()
      ViewMgr:ClosePage(self)
      self.WaitingCloseTask = nil
    end)
  end
end
function BuyItemPage:ListNeededMediators()
  return {BuyItemMediator}
end
function BuyItemPage:LuaHandleKeyEvent(key, inputEvent)
  self.Button_Buy:MonitorKeyDown(key, inputEvent)
  return self.Button_Return:MonitorKeyDown(key, inputEvent)
end
function BuyItemPage:OnOpen(luaOpenData, nativeOpenData)
  self.itemNum = 1
  self.numChangeSpeed = 1
  self.needMoreCurrency = false
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.HoldOn)
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):SetCurPage(luaOpenData.PageName)
  if luaOpenData.OriginalItemNum then
    self.itemNum = luaOpenData.OriginalItemNum
  end
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  Valid = self.Button_Buy and self.Button_Buy.OnClickEvent:Add(self, self.OnClickBuy)
  Valid = self.Check_Pop and self:PlayAnimationForward(self.Check_Pop, 1, false)
  if self.Button_Decrease then
    self.Button_Decrease.OnClicked:Add(self, self.OnClickDecrease)
    self.Button_Decrease.OnPressed:Add(self, self.OnPressDecrease)
    self.Button_Decrease.OnReleased:Add(self, self.OnReleaseDecrease)
  end
  if self.Button_Increase then
    self.Button_Increase.OnClicked:Add(self, self.OnClickIncrease)
    self.Button_Increase.OnPressed:Add(self, self.OnPressIncrease)
    self.Button_Increase.OnReleased:Add(self, self.OnReleaseIncrease)
  end
  Valid = self.Slider and self.Slider.OnValueChanged:Add(self, self.SliderValueChanged)
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):EnableOperationDesk(false)
end
function BuyItemPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.CancelHoldOn)
  self:ResetChange()
  if self.Button_Decrease then
    self.Button_Decrease.OnClicked:Remove(self, self.OnClickDecrease)
    self.Button_Decrease.OnPressed:Remove(self, self.OnPressDecrease)
    self.Button_Decrease.OnReleased:Remove(self, self.OnReleaseDecrease)
  end
  if self.Button_Increase then
    self.Button_Increase.OnClicked:Remove(self, self.OnClickIncrease)
    self.Button_Increase.OnPressed:Remove(self, self.OnPressIncrease)
    self.Button_Increase.OnReleased:Remove(self, self.OnReleaseIncrease)
  end
  Valid = self.Slider and self.Slider.OnValueChanged:Remove(self, self.SliderValueChanged)
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  Valid = self.Button_Buy and self.Button_Buy.OnClickEvent:Remove(self, self.OnClickBuy)
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):ResetCurPage()
  if GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetIsInLottery() then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):EnableOperationDesk(true)
  end
end
function BuyItemPage:SliderValueChanged(Value)
  local InItemNum = math.max(Value - 1, 0)
  local Lerp = 0 == self.LimitNum - 1 and 1 or math.lerp(0, 1, InItemNum / (self.LimitNum - 1))
  Valid = self.ProgressBar and self.ProgressBar:SetPercent(Lerp)
  self.itemNum = math.modf(Value)
  self:SetItemAmount()
end
function BuyItemPage:OnClickReturn()
  self:ClosePage()
end
function BuyItemPage:OnClickBuy()
  if self.needMoreCurrency then
    local pageData = {
      contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "NeedMoreCurrency"),
      source = self,
      cb = self.GoToRecharge
    }
    ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.PendingPage, nil, {Time = 5})
    local CurPriceData = self.PriceCombination and self.PriceCombination:GetCurPrice()
    local PrepareGoodsData = {
      CurrencyId = CurPriceData.currencyID,
      CurrencyNum = CurPriceData.currencyNum,
      StoreId = self.StoreId,
      GoodsNum = self.itemNum,
      PageName = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetCurPage()
    }
    Valid = PrepareGoodsData and GameFacade:SendNotification(NotificationDefines.Hermes.PurchaseGoods.ReqBuyGoods, PrepareGoodsData)
  end
end
function BuyItemPage:ClosePendingPage()
  self.Button_Buy:SetIsEnabled(true)
end
function BuyItemPage:SetBuyButtonIsEnabled()
  self.Button_Buy:SetButtonIsEnabled(true)
end
function BuyItemPage:GoToRecharge(bConfirm)
  if bConfirm then
    GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
      target = UIPageNameDefine.HermesHotListPage
    })
  end
end
function BuyItemPage:OnClickDecrease()
  if self.itemNum then
    self.itemNum = self.itemNum - 1
  end
  self:SetItemAmount()
  self:UpdateSlide()
end
function BuyItemPage:OnPressDecrease()
  self:StartChangeSpeed()
  self:StartChangeNum(-1)
end
function BuyItemPage:OnReleaseDecrease()
  self:ResetChange()
end
function BuyItemPage:OnClickIncrease()
  if self.itemNum then
    self.itemNum = self.itemNum + 1
  end
  self:SetItemAmount()
  self:UpdateSlide()
end
function BuyItemPage:OnPressIncrease()
  self:StartChangeSpeed()
  self:StartChangeNum(1)
end
function BuyItemPage:OnReleaseIncrease()
  self:ResetChange()
end
function BuyItemPage:StartChangeSpeed()
  self.changeSpeedTask = TimerMgr:AddTimeTask(self.ChangeSpeedInterval, self.ChangeSpeedInterval, 0, function()
    self.numChangeSpeed = self.numChangeSpeed + 2 > 30 and 30 or self.numChangeSpeed + 2
  end)
end
function BuyItemPage:StartChangeNum(delta)
  self.changeNumTask = TimerMgr:AddTimeTask(0.5, 0.1, 0, function()
    self.itemNum = self.itemNum + self.numChangeSpeed * delta
    self:SetItemAmount()
    self:UpdateSlide()
  end)
end
function BuyItemPage:ResetChange()
  if self.changeSpeedTask then
    self.changeSpeedTask:EndTask()
    self.changeSpeedTask = nil
  end
  if self.changeNumTask then
    self.changeNumTask:EndTask()
    self.changeNumTask = nil
  end
  self.numChangeSpeed = 1
end
return BuyItemPage
