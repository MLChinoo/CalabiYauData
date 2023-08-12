local BattlePassProgressCombineItem = class("BattlePassProgressCombineItem", PureMVC.ViewComponentPanel)
function BattlePassProgressCombineItem:InitializeLuaEvent()
  self.widgetArray = {}
end
function BattlePassProgressCombineItem:Construct()
  BattlePassProgressCombineItem.super.Construct(self)
end
function BattlePassProgressCombineItem:Destruct()
  BattlePassProgressCombineItem.super.Destruct(self)
end
function BattlePassProgressCombineItem:GenerateCombineItem(itemObj)
  local prizeData = itemObj.data
  local level = itemObj.level
  local parentPage = itemObj.parentPage
  if prizeData then
    if self.Text_Lv then
      self.Text_Lv:SetText("Lv." .. level)
    end
    if self.DynamicEntryBox_Items then
      local prizeNum = #prizeData
      local widgetNum = self.DynamicEntryBox_Items:GetNumEntries()
      if prizeNum > widgetNum then
        local extraEntryNum = prizeNum - widgetNum
        for index = 1, extraEntryNum do
          local widget = self.DynamicEntryBox_Items:BP_CreateEntry()
          table.insert(self.widgetArray, widget)
        end
      end
      local found
      for index = 1, prizeNum do
        if self.widgetArray[index] then
          self.widgetArray[index]:UpdateView(prizeData[index], parentPage)
          self.widgetArray[index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          found = index
        end
      end
      for index = found + 1, #self.widgetArray do
        if self.widgetArray[index] then
          self.widgetArray[index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
end
function BattlePassProgressCombineItem:ScrolledIntoItem()
  if self.widgetArray[1] then
    self.widgetArray[1]:ScrolledIntoItem()
  end
end
return BattlePassProgressCombineItem
