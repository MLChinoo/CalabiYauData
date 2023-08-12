local RoleFlyEffectPanelMeditor = require("Business/EquipRoom/Mediators/CommonDefaultPage/RoleFlyEffectPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local RoleFlyEffectPanelMobile = class("RoleFlyEffectPanelMobile", TabBasePanel)
function RoleFlyEffectPanelMobile:ListNeededMediators()
  return {RoleFlyEffectPanelMeditor}
end
function RoleFlyEffectPanelMobile:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
return RoleFlyEffectPanelMobile
