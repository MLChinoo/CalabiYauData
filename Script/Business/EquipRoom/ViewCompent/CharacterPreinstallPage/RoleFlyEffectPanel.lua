local RoleFlyEffectPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleFlyEffectPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local RoleFlyEffectPanel = class("RoleFlyEffectPanel", TabBasePanel)
function RoleFlyEffectPanel:ListNeededMediators()
  return {RoleFlyEffectPanelMeditor}
end
function RoleFlyEffectPanel:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
return RoleFlyEffectPanel
