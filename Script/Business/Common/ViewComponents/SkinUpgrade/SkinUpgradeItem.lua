local BaseItem = require("Business/Common/ViewComponents/SkinUpgrade/BaseItem")
local SkinUpgradeItem = class("SkinUpgradeItem", BaseItem)
function SkinUpgradeItem:Construct()
  SkinUpgradeItem.super.Construct(self)
  if self.Img_Select_Icon and self.SelectIcon then
    self.Img_Select_Icon:SetBrush(self.SelectIcon)
  end
  if self.Img_Nomal_Icon and self.NormalIcon then
    self.Img_Nomal_Icon:SetBrush(self.NormalIcon)
  end
end
function SkinUpgradeItem:Destruct()
  SkinUpgradeItem.super.Destruct(self)
end
function SkinUpgradeItem:SetSelectIconVisibility(bSelect)
  SkinUpgradeItem.super.SetSelectIconVisibility(self, bSelect)
  if self.Text_ItemName and self.SelectFontColor and self.NormalFontColor then
    self.Text_ItemName:SetColorAndOpacity(bSelect and self.SelectFontColor or self.NormalFontColor)
  end
end
return SkinUpgradeItem
