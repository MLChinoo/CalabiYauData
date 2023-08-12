local BattleDataSecondaryPanel = class("BattleDataSecondaryPanel", PureMVC.ViewComponentPanel)
local Valid
function BattleDataSecondaryPanel:Construct()
  BattleDataSecondaryPanel.super.Construct(self)
end
function BattleDataSecondaryPanel:Destruct()
  BattleDataSecondaryPanel.super.Destruct(self)
end
function BattleDataSecondaryPanel:Init(AllSecondaryInfo)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  for index, SecondaryInfo in pairs(AllSecondaryInfo or {}) do
    local BDItem = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
    Valid = BDItem and BDItem:Init(SecondaryInfo)
  end
end
return BattleDataSecondaryPanel
