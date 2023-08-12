local GeometricShapeNavigationBar = class("GeometricShapeNavigationBar", PureMVC.ViewComponentPanel)
function GeometricShapeNavigationBar:InitializeLuaEvent()
  self.OnItemCheckEvent = LuaEvent.new()
end
function GeometricShapeNavigationBar:SetItemsStyle()
  if self.DynamicEntryBox_Item then
    local num = self.DynamicEntryBox_Item:GetNumEntries()
    local AllEntrys = self.DynamicEntryBox_Item:GetAllEntries()
    for index = 1, num do
      local entry = AllEntrys:Get(index)
      if not entry or index == num then
      else
        entry:SetBarNormalStyle()
      end
    end
  end
end
function GeometricShapeNavigationBar:OnItemCheck(item)
  if item == self.lastItem then
    return
  end
  if self.lastItem then
    self.lastItem:SetSelectState(false)
  end
  self.lastItem = item
  self.lastItem:SetSelectState(true)
  self.OnItemCheckEvent(item:GetCustomIndex())
end
function GeometricShapeNavigationBar:UpdateBar(datas)
  if nil == datas then
    return
  end
  if nil == self.DynamicEntryBox_Item then
    return
  end
  self.DynamicEntryBox_Item:Reset(false)
  local dataNum = table.count(datas)
  for index = 1, dataNum do
    local entry = self.DynamicEntryBox_Item:BP_CreateEntry()
    if entry then
      local data = datas[index]
      entry:SetButtonName(data.barName)
      entry:SetIconBySprite(data.barIcon)
      entry:SetCustomIndex(data.customType)
      entry.OnCheckStateChanged:Add(self, self.OnItemCheck)
    end
  end
  self:SetItemsStyle()
end
function GeometricShapeNavigationBar:SelectBarByCustomType(customType)
  if self.DynamicEntryBox_Item then
    local num = self.DynamicEntryBox_Item:GetNumEntries()
    local AllEntrys = self.DynamicEntryBox_Item:GetAllEntries()
    for index = 1, num do
      local entry = AllEntrys:Get(index)
      if entry and entry:GetCustomIndex() == customType then
        entry:SetSelfBeSelect()
      end
    end
  end
end
function GeometricShapeNavigationBar:SetBarCheckStateByCustomType(customType)
  if self.DynamicEntryBox_Item then
    local num = self.DynamicEntryBox_Item:GetNumEntries()
    local AllEntrys = self.DynamicEntryBox_Item:GetAllEntries()
    for index = 1, num do
      local entry = AllEntrys:Get(index)
      if entry and entry:GetCustomIndex() == customType then
        if self.lastItem then
          self.lastItem:SetSelectState(false)
        end
        self.lastItem = entry
        self.lastItem:SetSelectState(true)
        break
      end
    end
  end
end
function GeometricShapeNavigationBar:GetBarByIndex(index)
  if self.DynamicEntryBox_Item then
    local num = self.DynamicEntryBox_Item:GetNumEntries()
    local AllEntrys = self.DynamicEntryBox_Item:GetAllEntries()
    if index <= num then
      return AllEntrys:Get(index)
    end
    return nil
  end
end
function GeometricShapeNavigationBar:SetRedDot(inIndex, cnt)
  if not self.DynamicEntryBox_Item then
    return
  end
  local AllEntrys = self.DynamicEntryBox_Item:GetAllEntries()
  local length = AllEntrys:Length()
  for index = 1, length do
    if inIndex == index then
      local entry = AllEntrys:Get(index)
      if entry then
        entry:SetRedDot(cnt)
      end
      break
    end
  end
end
return GeometricShapeNavigationBar
