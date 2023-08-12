local HermesPurchaseGoodsMediator = class("HermesPurchaseGoodsMediator", PureMVC.Mediator)
local HermesPurchaseGoodsPage
function HermesPurchaseGoodsMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.HermesPurchaseGoodsUpdate, luaData)
end
function HermesPurchaseGoodsMediator:ListNotificationInterests()
  return {
    NotificationDefines.HermesPurchaseGoodsNtf,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed
  }
end
function HermesPurchaseGoodsMediator:HandleNotification(notification)
  HermesPurchaseGoodsPage = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.HermesPurchaseGoodsNtf then
    HermesPurchaseGoodsPage:Init(Body)
  elseif Name == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed then
    ViewMgr:ClosePage(HermesPurchaseGoodsPage, UIPageNameDefine.PendingPage)
    if Body.IsSuccessed then
      self:CloseSelf()
    else
      if 3 == Body.CurrencyId then
        local pageData = {}
        pageData.contentTxt = Body.Message
        pageData.source = self
        pageData.cb = self.JumpToBuyCrystal
        ViewMgr:OpenPage(HermesPurchaseGoodsPage, UIPageNameDefine.MsgDialogPage, false, pageData)
      end
      HermesPurchaseGoodsPage:SetBuyButtonIsEnabled()
    end
  end
end
function HermesPurchaseGoodsMediator:JumpToBuyCrystal(IsClickedTrue)
  if IsClickedTrue then
    local NavBarBodyTable = {
      pageType = UE4.EPMFunctionTypes.Shop,
      secondIndex = 2
    }
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
    GameFacade:SendNotification(NotificationDefines.HermesJumpToBuyCrystal)
    self:CloseSelf()
  end
end
function HermesPurchaseGoodsMediator:CloseSelf()
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):ResetCurPage()
  HermesPurchaseGoodsPage:ClosePage()
end
function HermesPurchaseGoodsMediator:OnRegister()
end
return HermesPurchaseGoodsMediator
