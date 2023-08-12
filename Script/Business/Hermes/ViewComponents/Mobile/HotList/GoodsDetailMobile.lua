local HermesGoodsDetailPageMB = class("HermesGoodsDetailPage", PureMVC.ViewComponentPage)
local HermesGoodsDetailMediator = require("Business/Hermes/Mediators/HotList/GoodsDetailMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesGoodsDetailPageMB:Init(GoodsData)
  self.StoreId = GoodsData.StoreId
  self.GoodsId = GoodsData.GoodsId
  self.Price = GoodsData.Price
  Valid = self.DiscountBox and self.DiscountBox:SetVisibility(GoodsData.IsNeedShowDiscount and SelfHitTestInvisible or Collapsed)
  Valid = GoodsData.IsNeedShowDiscount and self.NormalDiscount and self.NormalDiscount:SetText(GoodsData.DiscountNum)
  Valid = self.GoodsGridsPanel and self.GoodsGridsPanel:Update(GoodsData.ItemsData)
  Valid = self.ButtonSwitcher and self.ButtonSwitcher:SetActiveWidgetIndex(GoodsData.IsLimited and 1 or 0)
  Valid = self.Currency_Img_1 and self:SetImageByTexture2D(self.Currency_Img_1, GoodsData.Currency_Img1)
  local PriceText_1 = UE4.UKismetTextLibrary.Conv_IntToText(tonumber(GoodsData.Currency_Num1))
  Valid = self.Price_1 and self.Price_1:SetText(PriceText_1)
end
function HermesGoodsDetailPageMB:UpdatePanel(ItemId)
  Valid = self.ItemDescWithHeadPanel and self.ItemDescWithHeadPanel:Update(ItemId)
  self.Display3DModelResult = self.UI3DModel:DisplayByItemId(ItemId, UE4.ELobbyCharacterAnimationStateMachineType.None)
  Valid = self.Img_BG and self.Img_BG:SetVisibility(self.Display3DModelResult and Collapsed or Visible)
  local SendMsg = ItemId
  if self.Display3DModelResult then
    SendMsg = nil
  end
  GameFacade:SendNotification(NotificationDefines.ItemImageDisplay, SendMsg)
end
function HermesGoodsDetailPageMB:UpdateButton(InData)
  Valid = InData and InData == self.GoodsId and self.ButtonSwitcher and self.ButtonSwitcher:SetActiveWidgetIndex(1)
end
function HermesGoodsDetailPageMB:ListNeededMediators()
  return {HermesGoodsDetailMediator}
end
function HermesGoodsDetailPageMB:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.NormalBuyButton and self.NormalBuyButton.OnClicked:Add(self, self.OnClickBuy)
  Valid = self.ReturnButton and self.ReturnButton.OnClickEvent:Add(self, self.ClickReturn)
  Valid = self.SwtichAnimation and self.SwtichAnimation:PlayOpenAnimation()
end
function HermesGoodsDetailPageMB:OnClickBuy()
  ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchaseGoodsPage, nil, {
    StoreId = self.StoreId,
    PageName = UIPageNameDefine.HermesHotListPage
  })
end
function HermesGoodsDetailPageMB:GetLobbyCamera()
  if self.lobbyCamera == nil and self.Display3DModelResult and self.ItemType == UE4.EItemIdIntervalType.RoleSkin then
    self.lobbyCamera = self.Display3DModelResult:RetrieveLobbyCharacterCamera()
  end
  return self.lobbyCamera
end
function HermesGoodsDetailPageMB:ClickReturn()
  ViewMgr:PopPage(self, UIPageNameDefine.HermesGoodsDetailPage)
end
return HermesGoodsDetailPageMB
