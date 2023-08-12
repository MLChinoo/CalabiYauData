local BattlePassProgressCombineItemMobile = class("BattlePassProgressCombineItemMobile", PureMVC.ViewComponentPanel)
function BattlePassProgressCombineItemMobile:InitializeLuaEvent()
  self.widgetArray = {}
end
function BattlePassProgressCombineItemMobile:Construct()
  BattlePassProgressCombineItemMobile.super.Construct(self)
end
function BattlePassProgressCombineItemMobile:Destruct()
  BattlePassProgressCombineItemMobile.super.Destruct(self)
end
function BattlePassProgressCombineItemMobile:OnListItemObjectSet(itemObj)
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
      local found = 0
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
function BattlePassProgressCombineItemMobile:ScrolledIntoItem()
  if self.widgetArray[1] then
    self.widgetArray[1]:ScrolledIntoItem()
  end
end
return BattlePassProgressCombineItemMobile
