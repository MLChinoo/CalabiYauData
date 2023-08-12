local GoodsBasePanel = class("GoodsBasePanel", PureMVC.ViewComponentPanel)
function GoodsBasePanel:InitializeLuaEvent()
  self.goodItems = {}
  self.clickItemEvent = LuaEvent.new()
  self.onitemDoubleClickEvent = LuaEvent.new()
end
function GoodsBasePanel:CheckDynamicEntryNum(GoodDataNum)
  local EntryNum = self.DynamicEntryBox_Item:GetNumEntries()
  local SurplusNum = GoodDataNum - EntryNum
  if SurplusNum > 0 then
    for i = 1, SurplusNum do
      local Widget = self:GenerateItem()
      self.goodItems[EntryNum + i] = Widget
    end
  end
  self:HandleSurplusItem(GoodDataNum)
  LogDebug("GoodsBasePanel", "EntryNum:%s ,GoodDataNum:%s", self.DynamicEntryBox_Item:GetNumEntries(), GoodDataNum)
  return self.goodItems
end
function GoodsBasePanel:HandleSurplusItem(needItemNum)
  local itemNum = self.DynamicEntryBox_Item:GetNumEntries()
  local entries = self.DynamicEntryBox_Item:GetAllEntries()
  for i = 1, itemNum do
    local item = entries:Get(i)
    if item then
      if needItemNum < i then
        self:HideUWidget(item)
      else
        self:ShowUWidget(item)
      end
      item:ResetItem()
    end
  end
end
function GoodsBasePanel:UpdateItemInfo(dataIndex, GoodsItemInfo)
  if dataIndex <= #self.goodItems then
    local itemWidget = self.goodItems[dataIndex]
    if itemWidget then
      self:ShowUWidget(itemWidget)
      itemWidget:SetItemID(GoodsItemInfo.InItemID)
      itemWidget:SetEquipState(GoodsItemInfo.bEquip)
      itemWidget:SetItemUnlockState(GoodsItemInfo.bUnlock)
      itemWidget:SetRedDotVisible(GoodsItemInfo.bShowRedDot)
      itemWidget:SetDargState(GoodsItemInfo.bCanDrag)
      itemWidget:SetRedDotID(GoodsItemInfo.redDotID)
      itemWidget:SetItemSpecial(GoodsItemInfo.privilegeData)
      self:UpdateItemInfoInDifferentPanel(itemWidget, GoodsItemInfo)
    else
      LogDebug("GoodsBasePanel:UpdateItemInfo", "itemWidget is null")
    end
  end
end
function GoodsBasePanel:GetSingleItemByItemID(itemID)
  if self.goodItems == nil then
    LogError("GoodsBasePanel", "goodItems is nil")
    return
  end
  for key, value in pairs(self.goodItems) do
    if itemID == value:GetItemID() then
      return value
    end
  end
  return nil
end
function GoodsBasePanel:UpdateItemInfoInDifferentPanel(itemWidget, goodItemInfo)
end
function GoodsBasePanel:OnItemClick(clickItem)
  if self.lastClickItem then
    self.lastClickItem:SetSelectState(false)
  end
  clickItem:SetSelectState(true)
  self.lastClickItem = clickItem
  self.clickItemEvent(clickItem:GetItemID())
end
function GoodsBasePanel:OnItemDoubleClick(clickItem)
  self.onitemDoubleClickEvent(clickItem)
end
function GoodsBasePanel:OnStartDrag(dragItem)
  self.lastDragItem = dragItem
end
function GoodsBasePanel:GetCurrentDragItem()
  return self.lastDragItem
end
function GoodsBasePanel:GenerateItem()
  local itemWidget
  if self.EntryModelClass then
    itemWidget = self.DynamicEntryBox_Item:BP_CreateEntryOfClass(self.EntryModelClass)
  else
    itemWidget = self.DynamicEntryBox_Item:BP_CreateEntry()
  end
  itemWidget.itemClickEvent:Add(self.OnItemClick, self)
  itemWidget.onStartDragEvent:Add(self.OnStartDrag, self)
  itemWidget.onitemDoubleClickEvent:Add(self.OnItemDoubleClick, self)
  return itemWidget
end
function GoodsBasePanel:UpdatePanel(GoodDatas)
  self:CheckDynamicEntryNum(table.count(GoodDatas))
  for key, value in pairs(GoodDatas) do
    self:UpdateItemInfo(key, value)
  end
end
function GoodsBasePanel:UpdateItemNumStr(GoodDatas)
  local itemUnlockedNum = 0
  local inItemAllNum = 0
  self:ShowUWidget(self.HorizontalBox_ItemNum)
  for key, value in pairs(GoodDatas) do
    if value.bUnlock then
      itemUnlockedNum = itemUnlockedNum + 1
    end
    inItemAllNum = inItemAllNum + 1
  end
  if self.Txt_ItemUnlockedNum then
    self.Txt_ItemUnlockedNum:SetText(itemUnlockedNum)
  end
  if self.Txt_ItemAllNum then
    self.Txt_ItemAllNum:SetText(inItemAllNum)
  end
end
function GoodsBasePanel:SetDefaultSelectItem(defaultSelectIndex)
  local item = self.goodItems[defaultSelectIndex]
  if item then
    item:SetSelfBeClick()
  end
end
function GoodsBasePanel:SetDefaultSelectItemByItemID(itemID)
  if self.goodItems == nil then
    LogError("GoodsBasePanel", "goodItems is nil")
    return
  end
  for key, value in pairs(self.goodItems) do
    if itemID == value:GetItemID() then
      value:SetSelfBeClick()
      break
    end
  end
end
function GoodsBasePanel:ClearSelectedState()
  if self.lastClickItem then
    self.lastClickItem:SetSelectState(false)
    self.lastClickItem = nil
  end
end
function GoodsBasePanel:SetSelectedStateByItemID(itemID)
  local clickItem
  for key, value in pairs(self.goodItems) do
    if itemID == value:GetItemID() then
      clickItem = value
      break
    end
  end
  if clickItem then
    if self.lastClickItem then
      self.lastClickItem:SetSelectState(false)
    end
    clickItem:SetSelectState(true)
    self.lastClickItem = clickItem
  end
end
function GoodsBasePanel:GetSelectItem()
  return self.lastClickItem
end
function GoodsBasePanel:GetSelectItemID()
  if self.lastClickItem then
    return self.lastClickItem:GetItemID()
  end
  return nil
end
function GoodsBasePanel:GetSelectItemRedDotID()
  if self.lastClickItem then
    return self.lastClickItem:GetRedDotID()
  end
  return 0
end
function GoodsBasePanel:SetSelectItemRedDotID(inRedDorID)
  if self.lastClickItem then
    return self.lastClickItem:SetRedDotID(inRedDorID)
  end
  return 0
end
function GoodsBasePanel:SetPanelName()
  if self.Tex_NameCN then
    self.Tex_NameCN:SetText(self.PanelNameCN)
  end
  if self.Tex_NameEN then
    self.Tex_NameEN:SetText(self.PanelNameEN)
  end
end
function GoodsBasePanel:HideCollectPanel()
  if self.Canvas_Collect then
    self:HideUWidget(self.Canvas_Collect)
  end
end
function GoodsBasePanel:ClearPanel()
  local itemNum = self.DynamicEntryBox_Item:GetNumEntries()
  local entries = self.DynamicEntryBox_Item:GetAllEntries()
  for i = 1, itemNum do
    local item = entries:Get(i)
    if item then
      self:HideUWidget(item)
      item:ResetItem()
    end
  end
  if self.Txt_ItemUnlockedNum then
    self.Txt_ItemUnlockedNum:SetText(0)
  end
  if self.Txt_ItemAllNum then
    self.Txt_ItemAllNum:SetText(0)
  end
end
return GoodsBasePanel
