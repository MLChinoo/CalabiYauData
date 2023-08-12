local RoleProfessionInfoPanel = class("RoleProfessionInfoPanel", PureMVC.ViewComponentPanel)
function RoleProfessionInfoPanel:UpdatePanel(info)
  if self.Img_RoleProfession then
    self:SetImageByTexture2D(self.Img_RoleProfession, info.professSoftTexture)
    self.Img_RoleProfession:SetColorandOpacity(info.professColor)
  end
  if self.Txt_RoleDesc then
    self.Txt_RoleDesc:SetText(info.roleDesc)
  end
  if self.Txt_RoleName then
    self.Txt_RoleName:SetText(info.itemName)
  end
  if self.Txt_RoleTitle then
    self.Txt_RoleTitle:SetText(info.roleTitle)
  end
  if self.Txt_RoleProfession then
    self.Txt_RoleProfession:SetText(info.professNameCn)
  end
  if self.Txt_RoleProfessionDesc then
    self.Txt_RoleProfessionDesc:SetText(info.professDesc)
  end
end
return RoleProfessionInfoPanel
