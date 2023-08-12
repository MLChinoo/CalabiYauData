local GridItem = require("Business/Common/ViewComponents/GridPanel/GridItem")
local RoleGridItem = class("RoleGridItem", GridItem)
function RoleGridItem:OnInitialized()
  RoleGridItem.super.OnInitialized(self)
  self:InitItem()
  if self.Img_TeamBar then
    self.Img_TeamBar:SetColorAndOpacity(self.TeamBarNormalColor)
  end
end
function RoleGridItem:SetProfessionIcon(texture)
  if self.Img_RoleProfession then
    self:SetImageByTexture2D(self.Img_RoleProfession, texture)
  end
end
function RoleGridItem:SetProfessionIconColor(color)
  if self.Img_RoleProfession then
    self.Img_RoleProfession:SetColorAndOpacity(color)
    self.professionColor = color
  end
end
function RoleGridItem:SeRoleName(name)
  if self.Tex_ItemName then
    self.Tex_ItemName:SetText(name)
  end
end
function RoleGridItem:SetSelectStateExtend(bSelect)
  if bSelect then
    self:HideUWidget(self.Img_Normal)
    self.Tex_ItemName:SetColorAndOpacity(self.ColorNameSelected)
    self.Img_RoleProfession:SetColorAndOpacity(self.ColorProfessionSelected)
    if self.Img_TeamBar then
      self.Img_TeamBar:SetColorAndOpacity(self.teamColor)
    end
  else
    self:ShowUWidget(self.Img_Normal)
    self.Tex_ItemName:SetColorAndOpacity(self.ColorNameNotSelected)
    self.Img_RoleProfession:SetColorAndOpacity(self.professionColor)
    if self.Img_TeamBar then
      self.Img_TeamBar:SetColorAndOpacity(self.TeamBarNormalColor)
    end
  end
end
function RoleGridItem:SetRoleTeamColor(teamColor)
  self.teamColor = teamColor
end
function RoleGridItem:OnLuaItemClick()
end
return RoleGridItem
