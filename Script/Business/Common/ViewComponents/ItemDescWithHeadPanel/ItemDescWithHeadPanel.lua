local ItemDescWithHeadPanel = class("ItemDescWithHeadPanel", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
function ItemDescWithHeadPanel:Update(ItemId)
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local ItemCfg = ItemProxy:GetAnyItemInfoById(ItemId)
  local ItemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(ItemCfg.quality)
  local intervalInfo = ItemProxy:GetItemIdInterval(ItemId)
  self.Text_Name:SetText(ItemCfg.name)
  self.Text_Info:SetText(ItemCfg.desc)
  self.Text_ItemType:SetText(intervalInfo.ItemTypeName)
  self.Text_Quality:SetText(ItemQuality.Desc)
  local qualityColor = self:GetColorFromHex(ItemQuality.Color)
  self.Img_Quality:SetColorAndOpacity(qualityColor)
  if ItemCfg.roleName then
    self.Text_RoleName:SetText(ItemCfg.roleName)
    self.Text_RoleName:SetVisibility(SelfHitTestInvisible)
    self.SizeBox_1:SetVisibility(SelfHitTestInvisible)
  else
    self.Text_RoleName:SetVisibility(Collapsed)
    self.SizeBox_1:SetVisibility(Collapsed)
  end
end
return ItemDescWithHeadPanel
