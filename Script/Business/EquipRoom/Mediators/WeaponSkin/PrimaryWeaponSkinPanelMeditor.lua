local WeaponSkinBaseTabPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/WeaponSkinBaseTabPanelMeditor")
local PrimaryWeaponSkinPanelMeditor = class("PrimaryWeaponSkinPanelMeditor", WeaponSkinBaseTabPanelMeditor)
function PrimaryWeaponSkinPanelMeditor:ListNotificationInterests()
  local list = PrimaryWeaponSkinPanelMeditor.super.ListNotificationInterests(self)
  return list
end
function PrimaryWeaponSkinPanelMeditor:OnRegister()
  PrimaryWeaponSkinPanelMeditor.super.OnRegister(self)
  self.weaponSlotType = UE4.EWeaponSlotTypes.WeaponSlot_Primary
end
function PrimaryWeaponSkinPanelMeditor:OnRemove()
  PrimaryWeaponSkinPanelMeditor.super.OnRemove(self)
end
function PrimaryWeaponSkinPanelMeditor:HandleNotification(notify)
  PrimaryWeaponSkinPanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
end
function PrimaryWeaponSkinPanelMeditor:OnShowPanel()
  PrimaryWeaponSkinPanelMeditor.super.OnShowPanel(self)
end
function PrimaryWeaponSkinPanelMeditor:OnHidePanel()
  PrimaryWeaponSkinPanelMeditor.super.OnHidePanel(self)
end
function PrimaryWeaponSkinPanelMeditor:OnItemClick(itemID)
  PrimaryWeaponSkinPanelMeditor.super.OnItemClick(self, itemID)
end
return PrimaryWeaponSkinPanelMeditor
