local HermesHotListSingleProductPanel = class("HermesHotListSingleProductPanel", PureMVC.ViewComponentPanel)
local HermesHotListSingleProductMediator = require("Business/Hermes/Mediators/HotList/SingleProductMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local HermesProxy, Valid
function HermesHotListSingleProductPanel:Init(InData)
  if InData then
    self.StoreId = InData.StoreId
    if nil == HermesProxy then
      HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
    end
    local StorePriceData = HermesProxy and HermesProxy:GetStoreGoodsPriceData(self.StoreId)
    if nil == StorePriceData or nil == StorePriceData.priceList then
      return nil
    end
    self.bIsPackage = HermesProxy:GetStoreGoodsIsPackage(self.StoreId)
    local bIsOwned, bIsOwnedPart = HermesProxy:GetStoreGoodsOwned(self.StoreId)
    self.bIsOwned = bIsOwned
    self.bIsOwnedPart = bIsOwnedPart
    local IsNeedShowDiscount = StorePriceData.bHasDiscount[1]
    Valid = IsNeedShowDiscount and self.DiscountNum and self.DiscountNum:SetText(StorePriceData.DiscountNum[1] or 0)
    Valid = self.Discount and self.Discount:SetVisibility(IsNeedShowDiscount and SelfHitTestInvisible or Collapsed)
    Valid = self.Image_Quality and self.Image_Quality:SetColorAndOpacity(InData.QualityColor)
    Valid = self.ItemName and self.ItemName:SetText(InData.ItemName)
    Valid = self.Currency_Img and self:SetImageByTexture2D(self.Currency_Img, InData.Currency_Img)
    self.PriceData = StorePriceData.Price
    local PriceText = UE4.UKismetTextLibrary.Conv_IntToText(tonumber(StorePriceData.priceList[1].currencyNum or 0))
    Valid = self.Price and self.Price:SetText(PriceText)
    Valid = self.Time and self.Time:SetText(StorePriceData.TimeLeft)
    Valid = self.ProductImage and self:SetImageByTexture2D(self.ProductImage, InData.ProductImgTexture)
    Valid = self.BuyButton and self.BuyButton:SetIsEnabled(not bIsOwned)
    local ContentIndex = 0
    if self.bIsPackage then
      ContentIndex = 2
    end
    if bIsOwned then
      ContentIndex = 1
    end
    Valid = self.WidgetSwitcher_BuyContent and self.WidgetSwitcher_BuyContent:SetActiveWidgetIndex(ContentIndex)
  end
end
function HermesHotListSingleProductPanel:UpdateButton()
  local bIsOwned, bIsOwnedPart = HermesProxy and HermesProxy:GetStoreGoodsOwned(self.StoreId)
  self.bIsOwned = bIsOwned
  self.bIsOwnedPart = bIsOwnedPart
  Valid = self.BuyButton and self.BuyButton:SetIsEnabled(not bIsOwned)
  Valid = self.WidgetSwitcher_BuyContent and self.WidgetSwitcher_BuyContent:SetActiveWidgetIndex(bIsOwned and 1 or 0)
end
function HermesHotListSingleProductPanel:Construct()
  HermesHotListSingleProductPanel.super.Construct(self)
  HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  Valid = self.BuyButton and self.BuyButton.OnClicked:Add(self, self.ClickedBuy)
  Valid = self.Button_Hovered and self.Button_Hovered.OnClicked:Add(self, self.ClickedProductImage)
  Valid = self.Button_Hovered and self.Button_Hovered.OnHovered:Add(self, self.HoverdProductImage)
  Valid = self.Button_Hovered and self.Button_Hovered.OnUnhovered:Add(self, self.UnHoveredProductImage)
  self:HideUWidget(self.Img_Hovered)
end
function HermesHotListSingleProductPanel:Destruct()
  Valid = self.BuyButton
  self.BuyButton.OnClicked:Remove(self, self.ClickedBuy)
  Valid = self.Button_Hovered
  self.Button_Hovered.OnClicked:Remove(self, self.ClickedProductImage)
  Valid = self.Button_Hovered
  self.Button_Hovered.OnHovered:Remove(self, self.HoverdProductImage)
  Valid = self.Button_Hovered
  self.Button_Hovered.OnUnhovered:Remove(self, self.UnHoveredProductImage)
  HermesHotListSingleProductPanel.super.Destruct(self)
end
function HermesHotListSingleProductPanel:ListNeededMediators()
  return {HermesHotListSingleProductMediator}
end
function HermesHotListSingleProductPanel:ClickedBuy()
  if self.bIsPackage then
    self:ClickedProductImage()
  else
    local Data = {
      StoreId = self.StoreId,
      PageName = UIPageNameDefine.HermesHotListPage
    }
    Valid = self.StoreId and ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchaseGoodsPage, nil, Data)
    GameFacade:RetrieveProxy(ProxyNames.HermesTLogProxy):SendTLogData(self.StoreId, self.bIsOwned, self.bIsOwnedPart)
  end
end
function HermesHotListSingleProductPanel:ClickedProductImage()
  Valid = self.StoreId and ViewMgr:OpenPage(self, UIPageNameDefine.HermesGoodsDetailPage, nil, self.StoreId)
  GameFacade:RetrieveProxy(ProxyNames.HermesTLogProxy):SendTLogData(self.StoreId, self.bIsOwned, self.bIsOwnedPart)
end
function HermesHotListSingleProductPanel:HoverdProductImage()
  Valid = self.Img_Hovered and self:ShowUWidget(self.Img_Hovered)
end
function HermesHotListSingleProductPanel:UnHoveredProductImage()
  Valid = self.Img_Hovered and self:HideUWidget(self.Img_Hovered)
end
return HermesHotListSingleProductPanel
