local ItemOperateStatePanel = class("ItemOperateStatePanel", PureMVC.ViewComponentPanel)
function ItemOperateStatePanel:OnInitialized()
  ItemOperateStatePanel.super.OnInitialized(self)
  self.Btn_Equip.OnClickEvent:Add(self, self.OnEquipClick)
  if self.UnlockConditionPanel then
    self.UnlockConditionPanel.clickUnlockEvent:Add(self.OnUnlockClick, self)
    self.UnlockConditionPanel.onJumpSceenEvent:Add(self.OnJumpSceenButtonClick, self)
  end
  self.clickEquipEvent = LuaEvent.new()
  self.clickUnlockEvent = LuaEvent.new()
  self.onJumpSceenEvent = LuaEvent.new()
  self:SetEquipBtnName(self.EquipBtnName)
  self:SetEquipBtnSound()
end
function ItemOperateStatePanel:SetEquipBtnName(name)
  if self.Btn_Equip and name then
    self.Btn_Equip:SetPanelName(name)
  end
end
function ItemOperateStatePanel:SetEquipBtnSound()
  if self.Btn_Equip then
    if self.EquipBtnHoveredSound then
      self.Btn_Equip:SetButtonHoveredSound(self.EquipBtnHoveredSound)
    end
    if self.EquipBtnPressedSound then
      self.Btn_Equip:SetButtonPressedSound(self.EquipBtnPressedSound)
    end
  end
end
function ItemOperateStatePanel:SetEquipBtnState(bEnable)
  if self.Btn_Equip then
    self.Btn_Equip:SetButtonIsEnabled(bEnable)
  end
end
function ItemOperateStatePanel:OnEquipClick()
  self.clickEquipEvent()
end
function ItemOperateStatePanel:OnUnlockClick()
  self.clickUnlockEvent()
  local Data = {
    StoreId = self.storeID,
    PageName = self.pageName
  }
  ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchaseGoodsPage, nil, Data)
end
function ItemOperateStatePanel:UpdateOperateState(operateStateData)
  self.itemID = operateStateData.itemID
  self.storeID = operateStateData.storeID
  if operateStateData.operateType == GlobalEnumDefine.EItemOperateStateType.NotUnlcok then
    self.UnlockConditionPanel:UpdateUnlockState(operateStateData)
  end
  self.WidgetSwitcher_Lock:SetActiveWidgetIndex(operateStateData.operateType)
  if operateStateData.equipBtnName then
    self:SetEquipBtnName(operateStateData.equipBtnName)
  end
end
function ItemOperateStatePanel:SetPageName(pageName)
  self.pageName = pageName
end
function ItemOperateStatePanel:OnJumpSceenButtonClick(data)
  self.onJumpSceenEvent()
end
return ItemOperateStatePanel
