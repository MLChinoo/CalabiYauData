local CollectionDataPanel = class("CollectionDataPanel", PureMVC.ViewComponentPanel)
function CollectionDataPanel:ListNeededMediators()
  return {}
end
function CollectionDataPanel:UpdateView(infoShown)
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "Collection")
  if self.TextBlock_RoleNum then
    local stringMap = {
      [0] = infoShown.role_own,
      [1] = infoShown.role_max
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.TextBlock_RoleNum:SetText(text)
  end
  if self.TextBlock_SkinNum then
    local stringMap = {
      [0] = infoShown.skin_own,
      [1] = infoShown.skin_max
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.TextBlock_SkinNum:SetText(text)
  end
  if self.TextBlock_WeaponNum then
    local stringMap = {
      [0] = infoShown.weapon_own,
      [1] = infoShown.weapon_max
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.TextBlock_WeaponNum:SetText(text)
  end
  if self.TextBlock_WeaponSkinNum then
    local stringMap = {
      [0] = infoShown.weapon_skin_own or 0,
      [1] = infoShown.weapon_skin_max or 0
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.TextBlock_WeaponSkinNum:SetText(text)
  end
end
return CollectionDataPanel
