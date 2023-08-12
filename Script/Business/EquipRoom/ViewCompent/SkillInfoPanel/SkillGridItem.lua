local GoodsBaseItem = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBaseItem")
local SkillGridItem = class("SkillGridItem", GoodsBaseItem)
function SkillGridItem:OnInitialized()
  SkillGridItem.super.OnInitialized(self)
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
  self.onHoveredEvent = LuaEvent.new()
end
function SkillGridItem:SetSkillIcon(texture)
  self:SetImageByTexture2D(self.Img_SkillIcon, texture)
end
function SkillGridItem:SetSkillType(type)
  self.skillType = type
end
function SkillGridItem:GetSkillType()
  return self.skillType
end
function SkillGridItem:OnLuaItemHovered()
  self.onHoveredEvent(self)
end
function SkillGridItem:OnLuaItemUnhovered()
end
function SkillGridItem:SetHoveredState(bShow)
  if bShow then
    self:ShowUWidget(self.Img_Hovered)
  else
    self:HideUWidget(self.Img_Hovered)
  end
end
function SkillGridItem:SetSelfBeHovered()
  self.onHoveredEvent(self)
end
return SkillGridItem
