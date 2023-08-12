local ItemUnlockConditionPanel = class("ItemUnlockConditionPanel", PureMVC.ViewComponentPanel)
function ItemUnlockConditionPanel:OnInitialized()
  ItemUnlockConditionPanel.super.OnInitialized(self)
  if self.CommonDiscountBuyButton then
    self.CommonDiscountBuyButton.clickUnlockEvent:Add(self.OnUnlockClick, self)
  end
  if self.JumpSceenButton then
    self.JumpSceenButton.OnClickEvent:Add(self, self.OnJumpSceenButtonClick)
  end
  self.clickUnlockEvent = LuaEvent.new()
  self.onJumpSceenEvent = LuaEvent.new()
end
function ItemUnlockConditionPanel:Destruct()
  if self.CommonDiscountBuyButton then
    self.CommonDiscountBuyButton.clickUnlockEvent:Remove(self.OnUnlockClick, self)
  end
  if self.JumpSceenButton then
    self.JumpSceenButton.OnClickEvent:Remove(self, self.OnJumpSceenButtonClick)
  end
end
function ItemUnlockConditionPanel:OnUnlockClick()
  self.clickUnlockEvent()
end
function ItemUnlockConditionPanel:OnJumpSceenButtonClick()
  if self.unlockData == nil then
    LogDebug("OnJumpSceenButtonClick", "self.unlockData is nil")
    return
  end
  self.onJumpSceenEvent(self.unlockData)
  if self.unlockData.unlockCondtionType == GlobalEnumDefine.EItemUnlockConditionType.BattlePass then
    local navBarbody = {}
    navBarbody.pageType = UE4.EPMFunctionTypes.BattlePass
    navBarbody.secondIndex = 2
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, navBarbody)
  elseif self.unlockData.unlockCondtionType == GlobalEnumDefine.EItemUnlockConditionType.Lottery then
    local navBarbody = {}
    navBarbody.pageType = UE4.EPMFunctionTypes.Shop
    navBarbody.secondIndex = 3
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, navBarbody)
  else
    LogError("OnJumpSceenButtonClick", "self.unlockData.unlockCondtionType no handler is" .. tostring(self.unlockData.unlockCondtionType))
  end
end
function ItemUnlockConditionPanel:UpdateUnlockState(unlcokData)
  self.unlockData = unlcokData
  local index = 0
  if unlcokData.unlockCondtionType == GlobalEnumDefine.EItemUnlockConditionType.None then
    if self.WBP_CustomStyleButton_PC then
      self.WBP_CustomStyleButton_PC:SetPanelName(unlcokData.unlockConditionInfo)
    end
  elseif unlcokData.unlockCondtionType == GlobalEnumDefine.EItemUnlockConditionType.Store then
    index = 1
    if self.CommonDiscountBuyButton then
      self.CommonDiscountBuyButton:UpdateView(unlcokData.storeID)
    end
  elseif unlcokData.unlockCondtionType == GlobalEnumDefine.EItemUnlockConditionType.BattlePass or unlcokData.unlockCondtionType == GlobalEnumDefine.EItemUnlockConditionType.Lottery then
    index = 2
    if self.JumpSceenButton then
      self.JumpSceenButton:SetPanelName(unlcokData.unlockConditionInfo)
      self.JumpSceenButton:SetButtonIsEnabled(unlcokData.bCanJump)
    end
  end
  if self.WidgetSwitcher_Lock then
    self.WidgetSwitcher_Lock:SetActiveWidgetIndex(index)
  end
end
function ItemUnlockConditionPanel:SetUnlockConditionInfo(info)
  if self.JumpSceenButton then
    self.JumpSceenButton:SetPanelName(info)
  end
  self.RichTxt_UnLockCondition:SetText(info)
end
return ItemUnlockConditionPanel
