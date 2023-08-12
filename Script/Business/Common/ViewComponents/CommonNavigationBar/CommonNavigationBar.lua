local CommonNavigationBar = class("CommonNavigationBar", PureMVC.ViewComponentPanel)
local EBarType = {
  First = 0,
  Middle = 1,
  Last = 2
}
function CommonNavigationBar:OnInitialized()
  CommonNavigationBar.super.OnInitialized(self)
  self.onItemClickEvent = LuaEvent.new()
  self.barItemMap = {}
end
function CommonNavigationBar:CheckItemNum(GoodDataNum)
  local EntryNum = self.DynamicEntryBox_Item:GetNumEntries()
  local SurplusNum = GoodDataNum - EntryNum
  if SurplusNum > 0 then
    for i = 1, SurplusNum do
      local Widget = self:GenerateItem()
      self.barItemMap[EntryNum + i] = Widget
    end
  end
end
function CommonNavigationBar:CheckItemType(dataNum)
  local itemNum = table.count(self.barItemMap)
  for i = 1, itemNum do
    if 1 == i then
      self.barItemMap[i]:SetBarType(EBarType.First)
    elseif i == dataNum then
      self.barItemMap[i]:SetBarType(EBarType.Last)
    else
      self.barItemMap[i]:SetBarType(EBarType.Middle)
    end
    if dataNum < i then
      self:HideUWidget(self.barItemMap[i])
      self.barItemMap[i]:SetSelectState()
      self.barItemMap[i]:SetCustomType(nil)
    end
  end
end
function CommonNavigationBar:GenerateItem()
  local itemWidget = self.DynamicEntryBox_Item:BP_CreateEntry()
  itemWidget.onClickEvent:Add(self.OnItemClick, self)
  return itemWidget
end
function CommonNavigationBar:OnItemClick(item)
  if item == self.lastItem then
    return
  end
  if self.lastItem then
    self.lastItem:SetSelectState(false)
  end
  self.lastItem = item
  self.lastItem:SetSelectState(true)
  self.onItemClickEvent(item:GetCustomType())
end
function CommonNavigationBar:UpdateBar(itemDataMap)
  local dataNum = table.count(itemDataMap)
  if 0 == dataNum then
    LogError("CommonNavigationBar:UpdateBar", "dataNum is 0")
    return
  end
  self:CheckItemNum(dataNum)
  self:CheckItemType(dataNum)
  for key, value in pairs(itemDataMap) do
    local barItem = self.barItemMap[key]
    if barItem then
      self:ShowUWidget(barItem)
      barItem:SetCustomType(value.customType)
      barItem:SetBarName(value.barName)
    end
  end
end
function CommonNavigationBar:SelectBarByCustomType(customType)
  for key, value in pairs(self.barItemMap) do
    if value and value:GetCustomType() == customType then
      value:SetSlefBeSelect()
      break
    end
  end
end
function CommonNavigationBar:GetBarByCustomType(customType)
  for key, value in pairs(self.barItemMap) do
    if value and value:GetCustomType() == customType then
      return value
    end
  end
end
return CommonNavigationBar
