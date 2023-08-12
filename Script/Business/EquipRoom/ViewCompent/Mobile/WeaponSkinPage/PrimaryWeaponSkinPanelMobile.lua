local PrimaryWeaponSkinPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/PrimaryWeaponSkinPanelMeditor")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local PrimaryWeaponSkinPanelMobile = class("PrimaryWeaponSkinPanelMobile", TabBasePanelMobile)
function PrimaryWeaponSkinPanelMobile:ListNeededMediators()
  return {PrimaryWeaponSkinPanelMeditor}
end
return PrimaryWeaponSkinPanelMobile
