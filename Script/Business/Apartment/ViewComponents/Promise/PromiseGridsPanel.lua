local PromiseRewardGridsPanel = class("PromiseRewardGridsPanel", PureMVC.ViewComponentPanel)
local Valid
function PromiseRewardGridsPanel:Update(ItemsData)
  self.ItemMap = {}
  self.CurSelectedItemId = nil
  local Item
  for index, value in pairs(ItemsData or {}) do
    if 0 == table.count(self.ItemMap) then
      self.CurSelectedItemId = value.ItemId
    end
    Item = nil
    Item = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:BP_CreateEntry()
    Valid = Item and Item:Init(value)
    Valid = Item and Item.clickItemEvent:Add(self.ClickedItem, self)
    self.ItemMap[value.ItemId] = Item
  end
  self.ItemMap[self.CurSelectedItemId]:ClickedItem()
end
function PromiseRewardGridsPanel:UpdateItemState()
  for k, v in pairs(self.ItemMap) do
    v:UpdateState()
  end
end
function PromiseRewardGridsPanel:ClickedItem(ItemId)
  Valid = self.ItemMap[self.CurSelectedItemId] and self.ItemMap[self.CurSelectedItemId]:ResetItem()
  self.CurSelectedItemId = ItemId
  Valid = self.ItemMap[self.CurSelectedItemId] and self.ItemMap[self.CurSelectedItemId]:SelectedItem()
  GameFacade:SendNotification(NotificationDefines.PromiseRewardClickItem, ItemId)
end
function PromiseRewardGridsPanel:Destruct()
  for i, v in pairs(self.ItemMap or {}) do
    v.clickItemEvent:Remove(self.ClickedItem, self)
  end
  PromiseRewardGridsPanel.super.Destruct(self)
end
return PromiseRewardGridsPanel
