local LotteryPoolDetailPage = class("LotteryPoolDetailPage", PureMVC.ViewComponentPage)
function LotteryPoolDetailPage:ListNeededMediators()
  return {}
end
function LotteryPoolDetailPage:InitView(itemsInfo)
  if self.List_Items then
    self.List_Items:ClearListItems()
    for _, item in pairsByKeys(itemsInfo, function(a, b)
      if itemsInfo[a].quality == itemsInfo[b].quality then
        return itemsInfo[a].id > itemsInfo[b].id
      else
        return itemsInfo[a].quality > itemsInfo[b].quality
      end
    end) do
      local itemObj = ObjectUtil:CreateLuaUObject(self)
      itemObj.ItemId = item.id
      itemObj.ItemNum = item.amount
      self.List_Items:AddItem(itemObj)
    end
    self.List_Items:SetSelectedIndex(0)
  end
end
function LotteryPoolDetailPage:OnItemSelectionChanged(itemObj)
  if nil == itemObj then
    return
  end
  local itemId = itemObj.ItemId
  self:ShowItemInfo(itemId)
  self.selectedItemId = itemId
end
function LotteryPoolDetailPage:ChooseItem(itemId)
  for index = 1, self.itemsPanel:Length() do
    if self.itemsPanel:Get(index).ItemId ~= itemId then
      self.itemsPanel:Get(index):ResetItem()
    end
  end
  self:ShowItemInfo(itemId)
end
function LotteryPoolDetailPage:ShowItemInfo(itemId)
  if self.ItemDescPanel then
    self.ItemDescPanel:Update(itemId)
  end
  if self.SkinUpgradePanel then
    self.SkinUpgradePanel:UpdatePanel(itemId)
  end
  if self.SkinUpgradePanel_Weapon then
    self.SkinUpgradePanel_Weapon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.HotKeyButton_Esc then
    local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
    if itemType == UE4.EItemIdIntervalType.RoleSkin then
      if self.SkinUpgradePanel and self.SkinUpgradePanel:GetSelectItem() then
        itemId = self.SkinUpgradePanel:GetSelectItem():GetItemID()
      end
    elseif itemType == UE4.EItemIdIntervalType.Weapon and self.SkinUpgradePanel_Weapon then
      self.SkinUpgradePanel_Weapon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.SkinUpgradePanel_Weapon:UpdatePanel(itemId)
      if self.SkinUpgradePanel_Weapon:GetSelectItem() then
        itemId = self.SkinUpgradePanel_Weapon:GetSelectItem():GetItemID()
      end
    end
    local data = {}
    data.itemId = itemId
    data.show3DBackground = true
    self.HotKeyButton_Esc:SetItemDisplayed(data)
  end
end
function LotteryPoolDetailPage:OnSkinUpItemSelected(item)
  if nil == item or nil == self.HotKeyButton_Esc or nil == self.selectedItemId then
    return
  end
  if item:GetUIItemType() == UE4.ECyCharacterSkinUpgradeUIItemType.FlyEffect then
    local data = {}
    data.itemId = item:GetItemID()
    data.flyEffectSkinId = self.selectedItemId
    self.HotKeyButton_Esc:SetItemDisplayed(data)
  else
    local data = {}
    data.itemId = item:GetItemID()
    data.show3DBackground = true
    self.HotKeyButton_Esc:SetItemDisplayed(data)
  end
end
function LotteryPoolDetailPage:OnWeaponSkinUpItemSelected(item)
  if nil == item or nil == self.HotKeyButton_Esc or nil == self.selectedItemId then
    return
  end
  local upItemID = item:GetItemID()
  local itemIdIntervalType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(upItemID)
  if itemIdIntervalType == UE4.EItemIdIntervalType.Weapon then
    local data = {}
    data.itemId = upItemID
    data.show3DBackground = true
    self.HotKeyButton_Esc:SetItemDisplayed(data)
  elseif itemIdIntervalType == UE4.EItemIdIntervalType.WeaponUpgradeFx then
    local data = {}
    data.itemId = upItemID
    data.weaponID = self.selectedItemId
    self.HotKeyButton_Esc:SetItemDisplayed(data)
  else
    LogError("LotteryPoolDetailPage", "Weapon skin up errpr")
  end
end
function LotteryPoolDetailPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("LotteryPoolDetailPage", "Lua implement OnOpen")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  self.isPreviewing = false
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Add(self.OnClickReturnPC, self)
    self.HotKeyButton_Esc.actionOnStartPreview:Add(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopPreview:Add(self.StopPreview, self)
    self.HotKeyButton_Esc.actionOnStartDrag:Add(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopDrag:Add(self.StopPreview, self)
  end
  if self.List_Items then
    self.List_Items.BP_OnItemSelectionChanged:Add(self, self.OnItemSelectionChanged)
  end
  if self.SkinUpgradePanel then
    self.SkinUpgradePanel.onSelectItemEvent:Add(self.OnSkinUpItemSelected, self)
  end
  if self.SkinUpgradePanel_Weapon then
    self.SkinUpgradePanel_Weapon.onSelectItemEvent:Add(self.OnWeaponSkinUpItemSelected, self)
  end
  if luaOpenData and luaOpenData.lotteryId then
    local dropItems = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryItems(luaOpenData.lotteryId)
    local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    local itemsInfo = {}
    local itemsId = {}
    for _, dropGroup in pairs(dropItems) do
      for _, itemData in pairs(dropGroup) do
        if itemsId[itemData.ItemId] == nil then
          local item = {
            id = itemData.ItemId,
            amount = itemData.ItemAmount,
            quality = itemProxy:GetAnyItemQuality(itemData.ItemId)
          }
          itemsId[itemData.ItemId] = true
          table.insert(itemsInfo, item)
        end
      end
    end
    self:InitView(itemsInfo)
  end
  GameFacade:SendNotification(NotificationDefines.Lottery.ShowMainPage, false)
end
function LotteryPoolDetailPage:OnClose()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Remove(self.OnClickReturnPC, self)
    self.HotKeyButton_Esc.actionOnStartPreview:Remove(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopPreview:Remove(self.StopPreview, self)
    self.HotKeyButton_Esc.actionOnStartDrag:Remove(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopDrag:Remove(self.StopPreview, self)
  end
  if self.List_Items then
    self.List_Items.BP_OnItemSelectionChanged:Remove(self, self.OnItemSelectionChanged)
  end
  if self.SkinUpgradePanel then
    self.SkinUpgradePanel.onSelectItemEvent:Remove(self.OnSkinUpItemSelected, self)
  end
  if self.SkinUpgradePanel_Weapon then
    self.SkinUpgradePanel_Weapon.onSelectItemEvent:Remove(self.OnWeaponSkinUpItemSelected, self)
  end
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  GameFacade:SendNotification(NotificationDefines.Lottery.ShowMainPage, true)
end
function LotteryPoolDetailPage:SetDropProbability(lotteryCfg)
  local probs = lotteryCfg.Probability
  if probs:Length() > 0 then
    for i = 1, probs:Length() do
      if probs:Get(i).Quality == GlobalEnumDefine.EItemQuality.Legendary then
        if self.Text_RedProb then
          local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, "Text_RedProb")
          local stringMap = {
            [0] = probs:Get(i).Prob .. "%"
          }
          local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
          self.Text_RedProb:SetText(text)
          self.Text_RedProb:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      elseif probs:Get(i).Quality == GlobalEnumDefine.EItemQuality.Perfect then
        if self.Text_OrangeProb then
          local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, "Text_OrangeProb")
          local stringMap = {
            [0] = probs:Get(i).Prob .. "%"
          }
          local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
          self.Text_OrangeProb:SetText(text)
          self.Text_OrangeProb:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      elseif probs:Get(i).Quality == GlobalEnumDefine.EItemQuality.Superior then
        if self.Text_PurpleProb then
          local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, "Text_PurpleProb")
          local stringMap = {
            [0] = probs:Get(i).Prob .. "%"
          }
          local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
          self.Text_PurpleProb:SetText(text)
          self.Text_PurpleProb:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      elseif probs:Get(i).Quality == GlobalEnumDefine.EItemQuality.Exquisite and self.Text_BlueProb then
        local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lottery, "Text_BlueProb")
        local stringMap = {
          [0] = probs:Get(i).Prob .. "%"
        }
        local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
        self.Text_BlueProb:SetText(text)
        self.Text_BlueProb:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function LotteryPoolDetailPage:StartPreview(is3DModel)
  if self.SwtichAnimation and not self.isPreviewing then
    self.SwtichAnimation:PlayCloseAnimation()
    if self.Anim_MoveOut then
      self:PlayAnimationForward(self.Anim_MoveOut, 1.67)
    end
    self.isPreviewing = true
  end
end
function LotteryPoolDetailPage:StopPreview(is3DModel)
  if self.SwtichAnimation and self.isPreviewing then
    self.SwtichAnimation:PlayOpenAnimation()
    if self.Anim_MoveOut then
      self:PlayAnimationReverse(self.Anim_MoveOut, 1.67)
    end
    self.isPreviewing = false
  end
end
function LotteryPoolDetailPage:LuaHandleKeyEvent(key, inputEvent)
  if self.HotKeyButton_Esc then
    return self.HotKeyButton_Esc:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function LotteryPoolDetailPage:OnClickReturnPC()
  ViewMgr:ClosePage(self)
end
return LotteryPoolDetailPage
