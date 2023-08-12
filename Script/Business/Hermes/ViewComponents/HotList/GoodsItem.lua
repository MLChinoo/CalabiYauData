local HermesGoodsItemPage = class("HermesGoodsItemPage", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesGoodsItemPage:Init(GoodsItemData)
  self.ItemId = GoodsItemData.ItemId
  Valid = self.ItemName and self.ItemName:SetText(GoodsItemData.Name)
  Valid = GoodsItemData.ItemNum > 1 and self.ItemNum and self.ItemNum:SetText("X" .. GoodsItemData.ItemNum)
  Valid = self.ItemNum and self.ItemNum:SetVisibility(GoodsItemData.ItemNum > 1 and SelfHitTestInvisible or Collapsed)
  Valid = self.Img_Item and self:SetImageByTexture2D(self.Img_Item, GoodsItemData.Image)
  Valid = self.Img_Quality and self.Img_Quality:SetColorAndOpacity(GoodsItemData.QualityColor)
  Valid = self.Overlay_GiftAway and self.Overlay_GiftAway:SetVisibility(GoodsItemData.StoreType == GlobalEnumDefine.EStoreType.GiftAway and SelfHitTestInvisible or Collapsed)
  Valid = self.SizeBox_Had and self.SizeBox_Had:SetVisibility(GoodsItemData.IsLimited and SelfHitTestInvisible or Collapsed)
end
return HermesGoodsItemPage
