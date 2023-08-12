local ItemsDisplayGridsPanel = class("ItemsDisplayGridsPanel", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function ItemsDisplayGridsPanel:Update(ItemsData)
  self.ItemMap = {}
  self.CurSelectedItemId = nil
  local Item
  for index, value in pairs(ItemsData or {}) do
    if 0 == table.count(self.ItemMap) then
      self.CurSelectedItemId = value.itemId
    end
    Item = nil
    Item = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:BP_CreateEntry()
    Valid = Item and Item:Init(value)
    Valid = Item and Item.clickItemEvent:Add(self.ClickedItem, self)
    self.ItemMap[value.itemId] = Item
  end
  self.ItemMap[self.CurSelectedItemId]:ClickedItem()
end
function ItemsDisplayGridsPanel:UpdateItemState()
  for k, v in pairs(self.ItemMap) do
    v:UpdateState()
  end
end
function ItemsDisplayGridsPanel:ClickedItem(ItemId)
  Valid = self.ItemMap[self.CurSelectedItemId] and self.ItemMap[self.CurSelectedItemId]:ResetItem()
  self.CurSelectedItemId = ItemId
  Valid = self.ItemMap[self.CurSelectedItemId] and self.ItemMap[self.CurSelectedItemId]:SelectedItem()
  GameFacade:SendNotification(NotificationDefines.HermesGoodsDetailClickItem, ItemId)
end
function ItemsDisplayGridsPanel:Destruct()
  for i, v in pairs(self.ItemMap) do
    v.clickItemEvent:Remove(self.ClickedItem, self)
  end
  ItemsDisplayGridsPanel.super.Destruct(self)
end
return ItemsDisplayGridsPanel
