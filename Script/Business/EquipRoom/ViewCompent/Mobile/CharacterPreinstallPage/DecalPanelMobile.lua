local DecalPanelMediator = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/DecalPanelMediator")
local TabBasePanelMobile = require("Business/EquipRoom/ViewCompent/Mobile/TabBasePanel/TabBasePanelMobile")
local DecalPanelMobile = class("DecalPanelMobile", TabBasePanelMobile)
function DecalPanelMobile:ListNeededMediators()
  return {DecalPanelMediator}
end
function DecalPanelMobile:InitializeLuaEvent()
  self.allCharacterEquipEvent = LuaEvent.new()
end
function DecalPanelMobile:Construct()
  DecalPanelMobile.super.Construct(self)
  if self.Btn_AllCharacterEquip then
    self.Btn_AllCharacterEquip.OnClickEvent:Add(self, self.AllCharacterEquip)
  end
end
function DecalPanelMobile:Destruct()
  DecalPanelMobile.super.Destruct(self)
  if self.Btn_AllCharacterEquip then
    self.Btn_AllCharacterEquip.OnClickEvent:Remove(self, self.AllCharacterEquip)
  end
end
function DecalPanelMobile:GetSelectItem()
  if self.GridsPanel then
    local item = self.GridsPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
function DecalPanelMobile:AllCharacterEquip()
  self.allCharacterEquipEvent()
end
return DecalPanelMobile
