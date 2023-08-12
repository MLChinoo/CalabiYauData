local LotteryResultItem = class("LotteryResultItem", PureMVC.ViewComponentPanel)
function LotteryResultItem:InitializeLuaEvent()
  LogDebug("LotteryResultItem", "Init lua event")
  self.actionOnClickItem = LuaEvent.new(lotteryId)
  self.actionOnAnimFinish = LuaEvent.new()
end
function LotteryResultItem:Init(itemInfo)
  if nil == itemInfo then
    return
  end
  self.itemId = itemInfo.item_id
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if self.Text_Name then
    self.Text_Name:SetText(itemProxy:GetAnyItemShotName(self.itemId))
  end
  self:ShowTitle()
  self:ShowIcon()
  if self.Image_Quality then
    self.itemQuality = itemInfo.quality
    local color = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(itemInfo.quality).Color
    self.Image_Quality:SetColorandOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(color)))
  end
  if self.Overlay_Count and self.Txt_Count then
    if itemInfo.count > 1 then
      self.Txt_Count:SetText("x" .. itemInfo.count)
      self.Overlay_Count:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Overlay_Count:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if itemInfo.currency_id then
    local currencyCfg = itemProxy:GetCurrencyConfig(itemInfo.currency_id)
    if currencyCfg and self.Img_Currency then
      self:SetImageByTexture2D(self.Img_Currency, currencyCfg.IconTipItem)
    end
    if self.Txt_Currency then
      self.Txt_Currency:SetText(itemInfo.currency_cnt)
    end
    self.needConvert = true
  end
end
function LotteryResultItem:StartPlayAnim()
  if self.itemQuality then
    if self.itemQuality == UE4.ECyItemQualityType.Red then
      self.effectShown = "Anim_red"
    elseif self.itemQuality == UE4.ECyItemQualityType.Orange then
      self.effectShown = "Anim_yellow"
    elseif self.itemQuality == UE4.ECyItemQualityType.Purple then
      self.effectShown = "Anim_purple"
    else
      self.effectShown = "Anim_blue"
    end
  end
  if self.effectShown then
    self:PlayWidgetAnimationWithCallBack(self.effectShown, {
      self,
      self.ShowConvertFX
    })
  end
end
function LotteryResultItem:ShowQualityFX()
  if self.Effect and self.itemQuality then
    self.Effect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.itemQuality == UE4.ECyItemQualityType.Red then
      self.Effect:SetActiveWidgetIndex(0)
    elseif self.itemQuality == UE4.ECyItemQualityType.Orange then
      self.Effect:SetActiveWidgetIndex(1)
    elseif self.itemQuality == UE4.ECyItemQualityType.Purple then
      self.Effect:SetActiveWidgetIndex(2)
    else
      self.Effect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.needConvert then
  end
  self.actionOnAnimFinish()
end
function LotteryResultItem:ShowConvertFX()
  if self.needConvert and self.Anim_zi then
    self:PlayAnimation(self.Anim_zi, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function LotteryResultItem:OnLuaItemClick()
  self.actionOnClickItem(self.itemId)
end
function LotteryResultItem:Destruct()
  self:RemoveWidgetAnimationFinishedCallback("Anim_Item")
  LotteryResultItem.super.Destruct(self)
end
function LotteryResultItem:ShowIcon()
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local index = 0
  local itemType = itemProxy:GetItemIdIntervalType(self.itemId)
  if itemType == UE4.EItemIdIntervalType.RoleSkin or itemType == UE4.EItemIdIntervalType.Role then
    index = 1
    self:SetImageMatParamByTexture2D(self.Image_Role, "RoleSkin", itemProxy:GetAnyItemImg(self.itemId))
  elseif itemType == UE4.EItemIdIntervalType.Weapon then
    index = 2
    if self.Image_Weapon then
      local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
      local weaponRow = weaponProxy:GetWeapon(self.itemId)
      if weaponRow then
        self:SetImageByTexture2D(self.Image_Weapon, weaponRow.IconItemBig)
      end
    end
  elseif self.Image_Item then
    self:SetImageByTexture2D(self.Image_Item, itemProxy:GetAnyItemImg(self.itemId))
  end
  if self.WidgetSwitcher_Icon then
    self.WidgetSwitcher_Icon:SetActiveWidgetIndex(index)
  end
end
function LotteryResultItem:ShowTitle()
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local itemRow = itemProxy:GetItemIdInterval(self.itemId)
  if nil == itemRow then
    return
  end
  local itemTitle = ""
  local itemType = itemRow.ItemType
  local itemTypeList = {
    UE4.EItemIdIntervalType.Weapon,
    UE4.EItemIdIntervalType.RoleSkin,
    UE4.EItemIdIntervalType.RoleVoice
  }
  local itemOwnerList = {}
  itemProxy:GetItemOwnerById(self.itemId, itemTypeList, itemOwnerList)
  if table.count(itemOwnerList) > 1 then
    itemTitle = itemOwnerList[2] .. "·" .. itemOwnerList[1]
  else
    itemTitle = itemRow.ItemTypeName
  end
  self.Txt_Count:SetText(itemTitle)
end
return LotteryResultItem
