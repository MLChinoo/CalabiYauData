local RoleCommuicationPanelMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/RoleCommuicationPanelMeditor")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local RoleCommunicationPanelMobile = class("RoleCommunicationPanelMobile", TabBasePanelMobile)
function RoleCommunicationPanelMobile:ListNeededMediators()
  return {RoleCommuicationPanelMeditor}
end
function RoleCommunicationPanelMobile:OnShowPanel()
  if self.MainPage then
    self.MainPage:HideViewTips()
  end
end
function RoleCommunicationPanelMobile:InitializeLuaEvent()
  RoleCommunicationPanelMobile.super.InitializeLuaEvent(self)
  if self.ItemListPanel then
    self.ItemListPanel:HideCollectPanel()
  end
  if self.GridsPanel then
    self.GridsPanel:HideCollectPanel()
  end
  self:UpdateKetTips()
end
function RoleCommunicationPanelMobile:ClearPanelExpend()
  if self.NavigationBar then
  end
  if self.RoulettePanel then
    self.RoulettePanel:ClearSelectState()
  end
end
function RoleCommunicationPanelMobile:UpdateKetTips()
  local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Mobile_TacticalRouletteKeyTips")
  if self.RoulettePanel then
    self.RoulettePanel:SetKeyTips(formatText)
  end
end
return RoleCommunicationPanelMobile
