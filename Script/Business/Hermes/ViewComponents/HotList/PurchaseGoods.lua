local HermesPurchaseGoodsPage = class("HermesPurchaseGoodsPage", PureMVC.ViewComponentPage)
local HermesPurchaseGoodsMediator = require("Business/Hermes/Mediators/HotList/PurchaseGoodsMediator")
local Valid
function HermesPurchaseGoodsPage:Init(GoodsData)
  if not GoodsData then
    return nil
  end
  self.StoreId = GoodsData.StoreId
  Valid = self.TextSellDesc and self.TextSellDesc:SetText(GoodsData.SellDesc)
  Valid = self.Image_Role and GoodsData.StoreRolePaintTexture and self:SetImageByTexture2D(self.Image_Role, GoodsData.StoreRolePaintTexture)
  if GoodsData.bHiddenIcon then
    self.DynamicEntryBox:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    local Item
    for index, value in pairs(GoodsData.ItemsData or {}) do
      if self.DynamicEntryBox then
        Item = nil
        Item = self.DynamicEntryBox:BP_CreateEntry()
        Valid = Item and Item:Init(value)
      end
    end
  end
  Valid = self.PriceCombination and self.PriceCombination:Update(self.StoreId)
end
function HermesPurchaseGoodsPage:ClosePage()
  local WaitingTime = 0
  if self.Check_Pop_Close then
    self:PlayAnimationForward(self.Check_Pop_Close, 1, false)
    WaitingTime = self.Check_Pop_Close:GetEndTime()
  end
  if TimerMgr then
    self.WaitingCloseTask = TimerMgr:AddTimeTask(WaitingTime, 0.0, 0, function()
      ViewMgr:ClosePage(self)
      self.WaitingCloseTask = nil
    end)
  end
end
function HermesPurchaseGoodsPage:ListNeededMediators()
  return {HermesPurchaseGoodsMediator}
end
function HermesPurchaseGoodsPage:LuaHandleKeyEvent(key, inputEvent)
  self.Button_Buy:MonitorKeyDown(key, inputEvent)
  return self.Button_Return:MonitorKeyDown(key, inputEvent)
end
function HermesPurchaseGoodsPage:OnOpen(luaOpenData, nativeOpenData)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.HoldOn)
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):SetCurPage(luaOpenData.PageName)
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  Valid = self.Button_Buy and self.Button_Buy.OnClickEvent:Add(self, self.OnClickBuy)
  Valid = self.Check_Pop and self:PlayAnimationForward(self.Check_Pop, 1, false)
end
function HermesPurchaseGoodsPage:OnClose()
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  Valid = self.Button_Buy and self.Button_Buy.OnClickEvent:Remove(self, self.OnClickBuy)
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):ResetCurPage()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.CancelHoldOn)
end
function HermesPurchaseGoodsPage:OnClickReturn()
  self:ClosePage()
end
function HermesPurchaseGoodsPage:OnClickBuy()
  if self.Button_Buy:GetButtonIsEnabled() then
    self.Button_Buy:SetButtonIsEnabled(false)
    ViewMgr:OpenPage(self, UIPageNameDefine.PendingPage, nil, {Time = 5})
    local CurPriceData = self.PriceCombination and self.PriceCombination:GetCurPrice()
    if CurPriceData then
      local PrepareGoodsData = {
        CurrencyId = CurPriceData.currencyID,
        CurrencyNum = CurPriceData.currencyNum,
        StoreId = self.StoreId,
        PageName = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetCurPage()
      }
      Valid = GameFacade:SendNotification(NotificationDefines.Hermes.PurchaseGoods.ReqBuyGoods, PrepareGoodsData)
    end
  end
end
function HermesPurchaseGoodsPage:SetBuyButtonIsEnabled()
  self.Button_Buy:SetButtonIsEnabled(true)
end
return HermesPurchaseGoodsPage
