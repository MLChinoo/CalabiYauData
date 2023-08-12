local RoleVoicePanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleVoicePanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local RoleVoicePanelPanel = class("RoleVoicePanelPanel", TabBasePanel)
function RoleVoicePanelPanel:ListNeededMediators()
  return {RoleVoicePanelMeditor}
end
function RoleVoicePanelPanel:OnShowPanel()
  if self.MainPage then
    self.MainPage:HideViewTips()
  end
end
function RoleVoicePanelPanel:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
return RoleVoicePanelPanel
