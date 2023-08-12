local SecondaryWeaponSkinPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/SecondaryWeaponSkinPanelMeditor")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local SecondaryWeaponSkinPanelMobile = class("SecondaryWeaponSkinPanelMobile", TabBasePanelMobile)
function SecondaryWeaponSkinPanelMobile:ListNeededMediators()
  return {SecondaryWeaponSkinPanelMeditor}
end
return SecondaryWeaponSkinPanelMobile
