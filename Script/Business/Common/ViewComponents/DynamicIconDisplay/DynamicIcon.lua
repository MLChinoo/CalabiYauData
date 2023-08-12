local DynamicIcon = class("DynamicIcon", PureMVC.ViewComponentPanel)
function DynamicIcon:InitView(itemId)
  if itemId then
    local itemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(itemId)
    if itemQuality and itemQuality >= 3 then
      LogDebug("DynamicIcon", "Item %d should use dynamic icon", itemId)
      local itemCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemCfg(itemId)
      if itemCfg then
        if self.WidgetSwitcher_IconType and itemCfg.AnimBlueprint then
          local dynamicIconBP = ObjectUtil:LoadClass(itemCfg.AnimBlueprint)
          if dynamicIconBP and self.Border_DynamicIconSlot then
            self.Border_DynamicIconSlot:ClearChildren()
            local dynamicIconIns = UE4.UWidgetBlueprintLibrary.Create(self, dynamicIconBP)
            self.Border_DynamicIconSlot:AddChild(dynamicIconIns)
            self.WidgetSwitcher_IconType:SetActiveWidgetIndex(1)
            return true
          end
        end
      else
        LogError("DynamicIcon", "Do not have item %d config", itemId)
      end
    end
    self:SetImage(itemId)
  end
  return false
end
function DynamicIcon:SetImage(itemId)
  if self.Image_Item then
    local texturePath = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemDisplayImg(itemId)
    self:SetImageByTexture2D(self.Image_Item, texturePath)
  end
  self.WidgetSwitcher_IconType:SetActiveWidgetIndex(0)
end
return DynamicIcon
