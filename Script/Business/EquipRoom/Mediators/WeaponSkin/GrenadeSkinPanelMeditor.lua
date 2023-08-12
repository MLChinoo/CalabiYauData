local WeaponSkinBaseTabPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/WeaponSkinBaseTabPanelMeditor")
local GrenadeSkinPanelMeditor = class("GrenadeSkinPanelMeditor", WeaponSkinBaseTabPanelMeditor)
function GrenadeSkinPanelMeditor:ListNotificationInterests()
  local list = GrenadeSkinPanelMeditor.super.ListNotificationInterests(self)
  return list
end
function GrenadeSkinPanelMeditor:OnRegister()
  GrenadeSkinPanelMeditor.super.OnRegister(self)
  self.weaponSlotType = self:GetViewComponent():GetWeaponSlotType()
end
function GrenadeSkinPanelMeditor:OnRemove()
  GrenadeSkinPanelMeditor.super.OnRemove(self)
end
function GrenadeSkinPanelMeditor:HandleNotification(notify)
  GrenadeSkinPanelMeditor.super.HandleNotification(self, notify)
end
function GrenadeSkinPanelMeditor:OnShowPanel()
  GrenadeSkinPanelMeditor.super.OnShowPanel(self)
end
function GrenadeSkinPanelMeditor:OnHidePanel()
  GrenadeSkinPanelMeditor.super.OnHidePanel(self)
end
return GrenadeSkinPanelMeditor
