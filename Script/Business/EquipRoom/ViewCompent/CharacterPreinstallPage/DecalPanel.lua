local DecalPanelMediator = require("Business/EquipRoom/Mediators/CharacterPreinstallPanel/DecalPanelMediator")
local TabBasePanel = require("Business/EquipRoom/ViewCompent/TabBasePanel/TabBasePanel")
local DecalPanel = class("DecalPanel", TabBasePanel)
function DecalPanel:ListNeededMediators()
  return {DecalPanelMediator}
end
function DecalPanel:InitializeLuaEvent()
  self:ShowDecalShortcutKey()
  self.allCharacterEquipEvent = LuaEvent.new()
end
function DecalPanel:Construct()
  DecalPanel.super.Construct(self)
  if self.Btn_AllCharacterEquip then
    self.Btn_AllCharacterEquip.OnClickEvent:Add(self, self.AllCharacterEquip)
  end
end
function DecalPanel:Destruct()
  DecalPanel.super.Destruct(self)
  if self.Btn_AllCharacterEquip then
    self.Btn_AllCharacterEquip.OnClickEvent:Remove(self, self.AllCharacterEquip)
  end
end
function DecalPanel:ShowDecalShortcutKey()
  if self.DecalDropSlotPanel then
    local inputKey = UE4.UPMInputSubsystem.Get(LuaGetWorld()):GetActionMappingByInputName("Graffiti", 0)
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "KeyTips")
    local stringMap = {
      ["0"] = inputKey
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.DecalDropSlotPanel:ShowDecalShortcutKey(text)
  end
end
function DecalPanel:GetSelectItem()
  if self.GridsPanel then
    local item = self.GridsPanel:GetSelectItem()
    if item then
      return item
    end
  end
  return nil
end
function DecalPanel:AllCharacterEquip()
  self.allCharacterEquipEvent()
end
return DecalPanel
