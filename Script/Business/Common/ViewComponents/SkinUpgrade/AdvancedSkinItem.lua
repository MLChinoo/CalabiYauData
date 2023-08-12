local BaseItem = require("Business/Common/ViewComponents/SkinUpgrade/BaseItem")
local AdvancedSkinItem = class("AdvancedSkinItem", BaseItem)
function AdvancedSkinItem:Construct()
  AdvancedSkinItem.super.Construct(self)
end
function AdvancedSkinItem:Destruct()
  AdvancedSkinItem.super.Destruct(self)
end
function AdvancedSkinItem:UpdateItemData(data)
  AdvancedSkinItem.super.UpdateItemData(self, data)
  if data then
    self:SetItemIcon(data.softTexture)
  end
end
function AdvancedSkinItem:SetItemIcon(icon)
  if self.Img_ItemIcon then
    self:SetImageByTexture2D(self.Img_ItemIcon, icon)
  end
end
function AdvancedSkinItem:GetUIItemType()
  return UE4.ECyCharacterSkinUpgradeUIItemType.Advanced
end
return AdvancedSkinItem
