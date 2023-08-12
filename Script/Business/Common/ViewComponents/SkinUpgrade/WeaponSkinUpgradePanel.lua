local WeaponSkinUpgradePanel = class("WeaponSkinUpgradePanel", PureMVC.ViewComponentPanel)
local WeaponSkinUpgradeProxy
function WeaponSkinUpgradePanel:Construct()
  WeaponSkinUpgradePanel.super.Construct(self)
  WeaponSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy)
  self.UpgradeItemMap = {}
  self:InitPanel()
  self:InSkinColorItem()
  self.onSelectItemEvent = LuaEvent.new()
end
function WeaponSkinUpgradePanel:Destruct()
  WeaponSkinUpgradePanel.super.Destruct(self)
  for key, value in pairs(self.UpgradeItemMap) do
    if value then
      value.onClickEvent:Remove(self.OnSelectItem, self)
    end
  end
  if self.DynamicBox_Item then
    for index = 1, 4 do
      local widget = self.DynamicBox_Item:BP_CreateEntry()
      if widget then
        widget.onClickEvent:Remove(self.OnSelectColorItem, self)
      end
    end
  end
end
function WeaponSkinUpgradePanel:InitPanel()
  self.UpgradeItemMap[1] = self.BasicsItem
  self.UpgradeItemMap[2] = self.AbvancedEffectItem
  self.UpgradeItemMap[3] = self.FinalEffectItem
  for key, value in pairs(self.UpgradeItemMap) do
    if value then
      value.onClickEvent:Add(self.OnSelectItem, self)
    end
  end
end
function WeaponSkinUpgradePanel:InSkinColorItem()
  if self.DynamicBox_Item then
    for index = 1, 4 do
      local widget = self.DynamicBox_Item:BP_CreateEntry()
      if widget then
        widget.onClickEvent:Add(self.OnSelectColorItem, self)
      end
    end
  end
end
function WeaponSkinUpgradePanel:GetSelectItem()
  if self.selectItem == self.AdvancedItem then
    return self.selectColorItem
  end
  return self.selectItem
end
function WeaponSkinUpgradePanel:OnSelectItem(item)
  if self.selectItem ~= nil and self.selectItem == item then
    return
  end
  if nil == item then
    return
  end
  self:SelectItem(item)
  self.onSelectItemEvent(item)
end
function WeaponSkinUpgradePanel:OnSelectColorItem(item)
  if self.selectColorItem ~= nil and self.selectColorItem == item then
    return
  end
  if nil == item then
    return
  end
  self:SelectColorItem(item)
  self.onSelectItemEvent(item)
end
function WeaponSkinUpgradePanel:UpdatePanel(skinID)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local weaponRow = weaponProxy:GetWeapon(skinID)
  self:RestPanel()
  self:ClearAllSelectState()
  if nil == weaponRow then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    LogError("WeaponSkinUpgradePanel.UpdatePanel", "weaponRow is nil ，武器id ：" .. tostring(skinID))
    return
  end
  self.levelupType = weaponRow.LevelupType
  self:UpdateBaseSkinItem(weaponRow)
  self:SelectItem(self.BasicsItem)
  if weaponRow.LevelupType == UE4.ECyCharacterSkinUpgradeType.NoUpgrade or weaponRow.LevelupType == UE4.ECyCharacterSkinUpgradeType.None then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if weaponRow.LevelupType == UE4.ECyCharacterSkinUpgradeType.Advance then
    LogError("WeaponSkinUpgradePanel.UpdatePanel", "策划配置错误，当前武器升级类型为进阶，武器id ：" .. tostring(skinID))
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateAbvancedFx(weaponRow)
  self:UpdateFinalFx(weaponRow)
  self:UpdateAbvancedSkinListItem(weaponRow)
  self:DefaultSelectItem(weaponRow)
end
function WeaponSkinUpgradePanel:UpdateBaseSkinItem(baseWeaponRow)
  if self.BasicsItem then
    local data = WeaponSkinUpgradeProxy:GetBaseItemData(baseWeaponRow)
    self.BasicsItem:UpdateItemData(data)
  end
end
function WeaponSkinUpgradePanel:UpdateAbvancedFx(weaponRow)
  if nil == weaponRow then
    return
  end
  local weaponData = WeaponSkinUpgradeProxy:GetAdvanceFxItemData(weaponRow)
  local show = weaponData and nil ~= weaponData.InItemID and 0 ~= weaponData.InItemID
  if self.AbvancedEffectItem then
    self.AbvancedEffectItem:SetVisibility(show and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.AbvancedEffectItem:UpdateItemData(weaponData)
  end
end
function WeaponSkinUpgradePanel:UpdateFinalFx(weaponRow)
  if nil == weaponRow then
    return
  end
  local weaponData = WeaponSkinUpgradeProxy:GetFinalFxItemData(weaponRow)
  local show = weaponData and nil ~= weaponData.InItemID and 0 ~= weaponData.InItemID
  if self.FinalEffectItem then
    self.FinalEffectItem:SetVisibility(show and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.FinalEffectItem:UpdateItemData(weaponData)
  end
end
function WeaponSkinUpgradePanel:UpdateAbvancedSkinListItem(baseWeaponRow)
  if nil == baseWeaponRow then
    return
  end
  local bCnaUp = baseWeaponRow.LevelupType == UE4.ECyCharacterSkinUpgradeType.Basics
  if false == bCnaUp then
    self:SetColorItemPanelVisible(bCnaUp)
    return
  end
  local skinDataAarray = WeaponSkinUpgradeProxy:GetAdvadceSkinDataListByRow(baseWeaponRow)
  local configDataNum = table.count(skinDataAarray)
  bCnaUp = configDataNum > 0
  if false == bCnaUp then
    self:SetColorItemPanelVisible(bCnaUp)
    return
  end
  self:SetColorItemPanelVisible(true)
  local entryNum = self.DynamicBox_Item:GetNumEntries()
  local entryArray = self.DynamicBox_Item:GetAllEntries()
  for index = 1, entryNum do
    local entry = entryArray:Get(index)
    if entry then
      entry:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:UpdateSkinColorItem(skinDataAarray)
end
function WeaponSkinUpgradePanel:UpdateSkinColorItem(dataArray)
  if self.DynamicBox_Item == nil then
    return
  end
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
function WeaponSkinUpgradePanel:SetColorItemPanelVisible(bVisibilityColor)
  if self.Overlay_ColorPanel then
    self.Overlay_ColorPanel:SetVisibility(bVisibilityColor and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function WeaponSkinUpgradePanel:DefaultSelectItem(baseWeaponRow)
  local bCnaUp = self.BasicsItem and self.BasicsItem:GetIsEquip()
  if bCnaUp then
    return
  end
  self:DefaultSelectColorItem()
end
function WeaponSkinUpgradePanel:DefaultSelectColorItem()
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
function WeaponSkinUpgradePanel:IsCanUpgrade()
  return self.levelupType == UE4.ECyCharacterSkinUpgradeType.Basics
end
function WeaponSkinUpgradePanel:UpdatePanelByEquipOrBuy(baseWeaponID)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local baseWeaponRow = weaponProxy:GetWeapon(baseWeaponID)
  if nil == baseWeaponRow then
    return
  end
  local currentItem = self:GetSelectItem()
  if nil == currentItem then
    return
  end
  local itemUIType = currentItem:GetUIItemType()
  if itemUIType == UE4.ECyWeaponSkinUpgradeUIItemType.Advanced then
    self:UpdateBaseSkinItem(baseWeaponRow)
    self:UpdateAbvancedSkinListItem(baseWeaponRow)
  elseif itemUIType == UE4.ECyWeaponSkinUpgradeUIItemType.AdvancedEffect then
    self:UpdateAbvancedFx(baseWeaponRow)
  elseif itemUIType == UE4.ECyWeaponSkinUpgradeUIItemType.FinalEffect then
    self:UpdateFinalFx(baseWeaponRow)
    self:UpdateAbvancedSkinListItem(baseWeaponRow)
  else
    self:UpdateBaseSkinItem(baseWeaponRow)
    self:UpdateAbvancedSkinListItem(baseWeaponRow)
  end
end
function WeaponSkinUpgradePanel:SelectColorItem(colorItem)
  if self.selectColorItem then
    self.selectColorItem:SetSelectState(false)
  end
  self.selectColorItem = colorItem
  self.selectColorItem:SetSelectState(true)
  if self.selectItem then
    self.selectItem:SetSelectState(false)
    self.selectItem = nil
  end
end
function WeaponSkinUpgradePanel:SelectItem(item)
  if nil == item and self.selectItem == item then
    return
  end
  if self.selectItem then
    self.selectItem:SetSelectState(false)
  end
  if self.selectColorItem then
    self.selectColorItem:SetSelectState(false)
    self.selectColorItem = nil
  end
  item:SetSelectState(true)
  self.selectItem = item
end
function WeaponSkinUpgradePanel:ClearAllSelectState()
  if self.selectItem then
    self.selectItem:SetSelectState(false)
    self.selectItem = nil
  end
  if self.selectColorItem then
    self.selectColorItem:SetSelectState(false)
    self.selectColorItem = nil
  end
end
function WeaponSkinUpgradePanel:RestPanel()
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
function WeaponSkinUpgradePanel:SelectColorItemByItemID(itemID)
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
function WeaponSkinUpgradePanel:GetBaseItemID()
  if self.BasicsItem then
    return self.BasicsItem:GetItemID()
  end
  return 0
end
return WeaponSkinUpgradePanel
