local SecondaryWeaponSkinPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/SecondaryWeaponSkinPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local SecondaryWeaponSkinPanel = class("SecondaryWeaponSkinPanel", TabBasePanel)
function SecondaryWeaponSkinPanel:ListNeededMediators()
  return {SecondaryWeaponSkinPanelMeditor}
end
function SecondaryWeaponSkinPanel:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
return SecondaryWeaponSkinPanel
