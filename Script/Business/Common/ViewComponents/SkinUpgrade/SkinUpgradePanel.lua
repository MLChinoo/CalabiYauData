local SkinUpgradePanel = class("SkinUpgradePanel", PureMVC.ViewComponentPanel)
local RoleSkinUpgradeProxy
function SkinUpgradePanel:Construct()
  SkinUpgradePanel.super.Construct(self)
  RoleSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.RoleSkinUpgradeProxy)
  self.UpgradeItemMap = {}
  self:InitPanel()
  self:InSkinColorItem()
  self.onSelectItemEvent = LuaEvent.new()
end
function SkinUpgradePanel:Destruct()
  SkinUpgradePanel.super.Destruct(self)
end
function SkinUpgradePanel:InitPanel()
  self.UpgradeItemMap[1] = self.BasicsItem
  self.UpgradeItemMap[2] = self.FlyEffectItem
  self.UpgradeItemMap[3] = self.AdvancedItem
  for key, value in pairs(self.UpgradeItemMap) do
    if value then
      value.onClickEvent:Add(self.OnSelectItem, self)
    end
  end
end
function SkinUpgradePanel:InSkinColorItem()
  if self.DynamicBox_Item then
    for index = 1, 4 do
      local widget = self.DynamicBox_Item:BP_CreateEntry()
      if widget then
        widget.onClickEvent:Add(self.OnSelectColorItem, self)
      end
    end
  end
end
function SkinUpgradePanel:GetSelectItem()
  if self.selectItem == self.AdvancedItem then
    return self.selectColorItem
  end
  return self.selectItem
end
function SkinUpgradePanel:OnSelectItem(item)
  if self.selectItem ~= nil and self.selectItem == item then
    return
  end
  if nil == item then
    return
  end
  self:SelectItem(item)
  if self.selectItem:GetUIItemType() == UE4.ECyCharacterSkinUpgradeUIItemType.Advanced then
    self:DefaultSelectColorItemByAdvancedItem()
    self.onSelectItemEvent(self.selectColorItem)
  else
    if self.selectColorItem then
      self.selectColorItem:SetSelectState(false)
      self.selectColorItem = nil
    end
    self.onSelectItemEvent(item)
  end
end
function SkinUpgradePanel:OnSelectColorItem(item)
  if self.selectColorItem ~= nil and self.selectColorItem == item then
    return
  end
  if nil == item then
    return
  end
  self:SelectItem(self.AdvancedItem)
  self:SelectColorItem(item)
  self.onSelectItemEvent(item)
end
function SkinUpgradePanel:UpdatePanel(skinID)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleSkinRow = rolePorxy:GetRoleSkin(skinID)
  self.bCanUpgrade = true
  if nil == roleSkinRow then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bCanUpgrade = false
    return
  end
  if roleSkinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
    LogError("SkinUpgradePanel:UpdatePanel", "ECyCharacterSkinUpgradeType is Advanca,skinID ID :", tostring(skinID))
    self.bCanUpgrade = false
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self:RestPanel()
  self:ClearAllSelectState()
  self:UpdateBaseSkinItem(roleSkinRow)
  if roleSkinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.NoUpgrade then
    self.bCanUpgrade = false
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:UpdateFlyEffectItem(roleSkinRow)
    self:UpdateAbvancedSkinItem(roleSkinRow)
  end
  self:DefaultSelectItem(roleSkinRow)
end
function SkinUpgradePanel:UpdatePanelByEquipOrBuy(skinID)
  local rolePorxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleSkinRow = rolePorxy:GetRoleSkin(skinID)
  if nil == roleSkinRow then
    return
  end
  if self.FlyEffectItem == self.selectItem then
    self:UpdateFlyEffectItem(roleSkinRow)
  else
    self:UpdateBaseSkinItem(roleSkinRow)
    self:UpdateAbvancedSkinItem(roleSkinRow)
  end
end
function SkinUpgradePanel:DefaultSelectItem(roleSkinRow)
  self:SelectItem(self.BasicsItem)
  if roleSkinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Basics and not self.BasicsItem:GetIsEquip() then
    local advancedEquip = self.AdvancedItem:GetIsEquip()
    local advancedUnlock = self.AdvancedItem:GetIsUnlock()
    if advancedEquip or advancedUnlock then
      self:SelectItem(self.AdvancedItem)
      self:DefaultSelectColorItem()
    end
  end
end
function SkinUpgradePanel:DefaultSelectColorItem()
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  local bEquip = false
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if entry and entry:GetIsEquip() then
      self:SelectColorItem(entry)
      bEquip = true
      break
    end
  end
  if not bEquip then
    for index = 1, entryNum do
      local entry = entryArray:Get(index)
      if entry and entry:GetIsUnlock() then
        self:SelectColorItem(entry)
        break
      end
    end
  end
end
function SkinUpgradePanel:DefaultSelectColorItemByAdvancedItem()
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if 1 == index then
      self:SelectColorItem(entry)
    end
    if entry and entry:GetIsEquip() then
      self:SelectColorItem(entry)
      break
    end
  end
end
function SkinUpgradePanel:UpdateBaseSkinItem(roleSkinRow)
  if self.BasicsItem then
    local data = RoleSkinUpgradeProxy:GetSkinItemData(roleSkinRow)
    self.BasicsItem:UpdateItemData(data)
  end
end
function SkinUpgradePanel:UpdateFlyEffectItem(skinRow)
  if self.FlyEffectItem then
    local visibility = 0 == skinRow.FxflyingId
    if visibility then
      self.FlyEffectItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
      return
    end
    local data = RoleSkinUpgradeProxy:GetFlyEffectItemData(skinRow)
    self.FlyEffectItem:UpdateItemData(data)
    self.FlyEffectItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SkinUpgradePanel:UpdateAbvancedSkinItem(skinRow)
  if self.AdvancedItem == nil then
    return
  end
  local bCnaUp = skinRow.UpdateType == UE4.ECyCharacterSkinUpgradeType.Basics
  self.AdvancedItem:SetVisibility(bCnaUp and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if false == bCnaUp then
    return
  end
  local skinDataAarray = RoleSkinUpgradeProxy:GetAdvadceSkinListByRow(skinRow)
  local configDataNum = table.count(skinDataAarray)
  local bHideAdvanceItem = 0 == configDataNum
  self.AdvancedItem:SetVisibility(bHideAdvanceItem and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  if bHideAdvanceItem then
    return
  end
  self.AdvancedItem:UpdateItemData(RoleSkinUpgradeProxy:GetUpSkinItemData(skinRow))
  if nil == self.DynamicBox_Item then
    return
  end
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if entry then
      entry:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local bVisibilityColor = configDataNum > 1 and self.AdvancedItem:GetIsUnlock()
  self.Overlay_ColorPanel:SetVisibility(bVisibilityColor and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self:UpdateSkinColorItem(skinDataAarray)
end
function SkinUpgradePanel:UpdateSkinColorItem(dataArray)
  local dataNum = table.count(dataArray)
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if index <= dataNum then
      entry:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local data = dataArray[index]
      entry:UpdateItemData(data)
    else
      entry:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function SkinUpgradePanel:SelectColorItem(colorItem)
  if self.selectColorItem then
    self.selectColorItem:SetSelectState(false)
  end
  self.selectColorItem = colorItem
  self.selectColorItem:SetSelectState(true)
end
function SkinUpgradePanel:SelectItem(item)
  if nil == item and self.selectItem == item then
    return
  end
  if self.selectItem then
    self.selectItem:SetSelectState(false)
  end
  item:SetSelectState(true)
  self.selectItem = item
end
function SkinUpgradePanel:ClearAllSelectState()
  if self.selectItem then
    self.selectItem:SetSelectState(false)
    self.selectItem = nil
  end
  if self.selectColorItem then
    self.selectColorItem:SetSelectState(false)
    self.selectColorItem = nil
  end
end
function SkinUpgradePanel:RestPanel()
  for key, value in pairs(self.UpgradeItemMap) do
    if value then
      value:ResetItem()
    end
  end
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if entry then
      entry:ResetItem()
    end
  end
  if self.Overlay_ColorPanel then
    self.Overlay_ColorPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SkinUpgradePanel:SelectColorItemByItemID(itemID)
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if entry and entry:GetItemID() == itemID then
      self:SelectColorItem(entry)
      break
    end
  end
end
function SkinUpgradePanel:IsCanUpgrade()
  return self.bCanUpgrade
end
return SkinUpgradePanel
