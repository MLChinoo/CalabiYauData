local KaMailAttachItem = class("KaMailAttachItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaMailAttachItem:OnListItemObjectSet(UObject)
  self:InitItem(UObject.data)
  UObject.Item = self
end
function KaMailAttachItem:InitItem(Data)
  if nil == Data then
    return nil
  end
  self.ItemId = Data.ItemId
  self:SetImageByTexture2D(self.ItemImg, Data.ItemImg)
  self.ItemNum:SetText(Data.ItemNum)
  self.ItemAttach:SetVisibility(Data.IsAttached and SelfHitTestInvisible or Collapsed)
  Valid = Data.ItemQualityColor and self.ItemQualityColor:SetColorAndOpacity(Data.ItemQualityColor)
end
return KaMailAttachItem
