local RoleVoicePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleVoicePanelMeditor")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local RoleVoicePanelMobile = class("RoleVoicePanelMobile", TabBasePanelMobile)
function RoleVoicePanelMobile:ListNeededMediators()
  return {RoleVoicePanelMeditor}
end
function RoleVoicePanelMobile:OnShowPanel()
  if self.MainPage then
    self.MainPage:HideViewTips()
  end
end
return RoleVoicePanelMobile
