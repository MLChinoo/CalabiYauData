local RoleFlyEffectPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleFlyEffectPanelMeditor")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local RoleFlyEffectPanelMobile = class("RoleFlyEffectPanelMobile", TabBasePanelMobile)
function RoleFlyEffectPanelMobile:ListNeededMediators()
  return {RoleFlyEffectPanelMeditor}
end
return RoleFlyEffectPanelMobile
