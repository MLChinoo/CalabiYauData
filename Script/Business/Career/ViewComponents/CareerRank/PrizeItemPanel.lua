local PrizeItemPanel = class("PrizeItemPanel", PureMVC.ViewComponentPanel)
function PrizeItemPanel:ListNeededMediators()
  return {}
end
function PrizeItemPanel:InitializeLuaEvent()
  self.actionOnSelectItem = LuaEvent.new(self)
end
function PrizeItemPanel:Init(itemData)
  self.itemId = itemData.ItemId
  local itemConfig = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemInfoById(self.itemId)
  if self.Img_ItemIcon then
    self.Img_ItemIcon:SetBrushFromSoftTexture(itemConfig.image)
  end
  if self.Img_Quality then
    local itemQualityCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(itemConfig.quality)
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.color)))
  end
  if self.ItemNum then
    if itemData.count > 1 then
      self.ItemNum:SetText("X" .. itemData.count)
      self.ItemNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.ItemNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function PrizeItemPanel:Construct()
  PrizeItemPanel.super.Construct(self)
  if self.CheckBox_Item then
    self.CheckBox_Item.OnCheckStateChanged:Add(self, self.OnChangeState)
  end
end
function PrizeItemPanel:OnChangeState(isChosen)
  if not isChosen then
    self.CheckBox_Item:SetIsChecked(true)
  else
    self.actionOnSelectItem(self)
  end
end
function PrizeItemPanel:SetSelected(isSelected)
  if self.CheckBox_Item then
    self.CheckBox_Item:SetIsChecked(isSelected)
  end
end
return PrizeItemPanel
