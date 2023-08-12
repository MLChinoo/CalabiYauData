local GrenadeSkinPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/GrenadeSkinPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local GrenadeSkinPanelMobile = class("GrenadeSkinPanelMobile", TabBasePanel)
function GrenadeSkinPanelMobile:ListNeededMediators()
  return {GrenadeSkinPanelMeditor}
end
function GrenadeSkinPanelMobile:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
function GrenadeSkinPanelMobile:GetWeaponSlotType()
  return self.WeaponSlotType
end
return GrenadeSkinPanelMobile
