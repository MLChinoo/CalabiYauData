local RoleInfoPanel = class("RoleInfoPanel", PureMVC.ViewComponentPanel)
function RoleInfoPanel:UpdatePanel(data)
  self:SetRoleName(data.roleName)
  self:SetRoleTitle(data.roleTitle)
  self:SetRoleProfessIcon(data.professSoftTexture)
end
function RoleInfoPanel:SetRoleName(roleName)
  if self.Txt_RoleName and roleName then
    self.Txt_RoleName:SetText(roleName)
  end
end
function RoleInfoPanel:SetRoleTitle(roleTitle)
  if self.Txt_RoleTitle and roleTitle then
    self.Txt_RoleTitle:SetText(roleTitle)
  end
end
function RoleInfoPanel:SetRoleProfessIcon(professSoftTexture)
  if self.Img_RoleProfession and professSoftTexture then
    self:SetImageByTexture2D(self.Img_RoleProfession, professSoftTexture)
  end
end
function RoleInfoPanel:SetRoleProfessIconColor(professColor)
  if self.Img_RoleProfession and professColor then
    self.Img_RoleProfession:SetColorandOpacity(professColor)
  end
end
return RoleInfoPanel
