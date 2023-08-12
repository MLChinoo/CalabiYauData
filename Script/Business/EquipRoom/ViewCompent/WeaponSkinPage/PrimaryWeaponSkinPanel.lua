local PrimaryWeaponSkinPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/PrimaryWeaponSkinPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local PrimaryWeaponSkinPanel = class("PrimaryWeaponSkinPanel", TabBasePanel)
function PrimaryWeaponSkinPanel:ListNeededMediators()
  return {PrimaryWeaponSkinPanelMeditor}
end
function PrimaryWeaponSkinPanel:OnShowPanel()
  self:ShowScreenShotKey(true)
end
function PrimaryWeaponSkinPanel:OnHidePanel()
  self:ShowScreenShotKey(false)
end
function PrimaryWeaponSkinPanel:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
return PrimaryWeaponSkinPanel
