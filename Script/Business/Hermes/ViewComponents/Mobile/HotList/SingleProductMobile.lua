local HermesHotListSingleProductPanelMB = class("HermesHotListSingleProductPanel", PureMVC.ViewComponentPanel)
local HermesHotListSingleProductMediator = require("Business/Hermes/Mediators/HotList/SingleProductMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesHotListSingleProductPanelMB:Init(InData)
  if nil == InData then
    return
  end
  self.StoreId = InData.StoreId
  self.GoodsId = InData.GoodsId
  Valid = self.Discount and self.Discount:SetVisibility(InData.IsNeedShowDiscount and SelfHitTestInvisible or Collapsed)
  Valid = InData.IsNeedShowDiscount and self.DiscountNum and self.DiscountNum:SetText(InData.DiscountNum)
  Valid = self.Image_Quality and self.Image_Quality:SetColorAndOpacity(InData.QualityColor)
  Valid = self.ItemName and self.ItemName:SetText(InData.ItemName)
  Valid = self.Currency_Img and self:SetImageByTexture2D(self.Currency_Img, InData.Currency_Img)
  self.PriceData = InData.Price
  local PriceText = UE4.UKismetTextLibrary.Conv_IntToText(tonumber(InData.Price[1].currency_amount))
  Valid = self.Price
  self.Price:SetText(PriceText)
  Valid = self.Time
  self.Time:SetText(InData.Time)
  Valid = self.ProductImage
  self:SetImageByTexture2D(self.ProductImage, InData.ProductImgTexture)
  Valid = self.LimitatedBox and self.LimitatedBox:SetVisibility(InData.IsLimited and SelfHitTestInvisible or Collapsed)
  Valid = InData.IsLimited and self.BuyButton and self.BuyButton:SetIsEnabled(false)
  Valid = InData.IsLimited and self.BuyButton1 and self.BuyButton1:SetIsEnabled(false)
  Valid = self.PriceBox and self.PriceBox:SetVisibility(InData.IsLimited and Collapsed or SelfHitTestInvisible)
end
function HermesHotListSingleProductPanelMB:Construct()
  HermesHotListSingleProductPanelMB.super.Construct(self)
  Valid = self.BuyButton and self.BuyButton.OnClicked:Add(self, self.ClickedBuy)
  Valid = self.BuyButton1 and self.BuyButton1.OnClicked:Add(self, self.ClickedBuy)
  Valid = self.Button_Hovered and self.Button_Hovered.OnClicked:Add(self, self.ClickedProductImage)
end
function HermesHotListSingleProductPanelMB:Destruct()
  Valid = self.BuyButton and self.BuyButton.OnClicked:Remove(self, self.ClickedBuy)
  Valid = self.BuyButton1 and self.BuyButton1.OnClicked:Remove(self, self.ClickedBuy)
  Valid = self.Button_Hovered and self.Button_Hovered.OnClicked:Remove(self, self.ClickedProductImage)
  HermesHotListSingleProductPanelMB.super.Destruct(self)
end
function HermesHotListSingleProductPanelMB:ListNeededMediators()
  return {HermesHotListSingleProductMediator}
end
function HermesHotListSingleProductPanelMB:ClickedBuy()
  local Data = {
    StoreId = self.StoreId,
    PageName = UIPageNameDefine.HermesHotListPage
  }
  Valid = self.StoreId and ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchaseGoodsPage, nil, Data)
end
function HermesHotListSingleProductPanelMB:ClickedProductImage()
  Valid = self.StoreId and ViewMgr:PushPage(self, UIPageNameDefine.HermesGoodsDetailPage, self.StoreId)
end
return HermesHotListSingleProductPanelMB
