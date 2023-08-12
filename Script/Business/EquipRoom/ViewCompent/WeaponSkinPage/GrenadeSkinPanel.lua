local GrenadeSkinPanelMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/GrenadeSkinPanelMeditor")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local GrenadeSkinPanel = class("GrenadeSkinPanel", TabBasePanel)
function GrenadeSkinPanel:ListNeededMediators()
  return {GrenadeSkinPanelMeditor}
end
function GrenadeSkinPanel:OnInitialized()
  GrenadeSkinPanel.super.OnInitialized(self)
  if self.ItemLlistName and self.ItemListPanel and self.ItemListPanel.PanelNameCN then
    self.ItemListPanel.PanelNameCN = self.ItemLlistName
    self.ItemListPanel:SetPanelName()
  end
end
function GrenadeSkinPanel:GetSelectItem()
  if self.itemListPanel then
    local item = self.itemListPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
function GrenadeSkinPanel:GetWeaponSlotType()
  return self.WeaponSlotType
end
return GrenadeSkinPanel
