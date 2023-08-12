local WeaponSkinBaseTabPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/WeaponSkinBaseTabPanelMeditor")
local SecondaryWeaponSkinPanelMeditor = class("SecondaryWeaponSkinPanelMeditor", WeaponSkinBaseTabPanelMeditor)
function SecondaryWeaponSkinPanelMeditor:ListNotificationInterests()
  local list = SecondaryWeaponSkinPanelMeditor.super.ListNotificationInterests(self)
  return list
end
function SecondaryWeaponSkinPanelMeditor:OnRegister()
  SecondaryWeaponSkinPanelMeditor.super.OnRegister(self)
  self.weaponSlotType = UE4.EWeaponSlotTypes.WeaponSlot_Secondary
end
function SecondaryWeaponSkinPanelMeditor:OnRemove()
  SecondaryWeaponSkinPanelMeditor.super.OnRemove(self)
end
function SecondaryWeaponSkinPanelMeditor:HandleNotification(notify)
  SecondaryWeaponSkinPanelMeditor.super.HandleNotification(self, notify)
end
function SecondaryWeaponSkinPanelMeditor:OnShowPanel()
  SecondaryWeaponSkinPanelMeditor.super.OnShowPanel(self)
end
function SecondaryWeaponSkinPanelMeditor:OnHidePanel()
  SecondaryWeaponSkinPanelMeditor.super.OnHidePanel(self)
end
return SecondaryWeaponSkinPanelMeditor
