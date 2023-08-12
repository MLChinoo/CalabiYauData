local HighQualityItemDisplay = class("HighQualityItemDisplay", PureMVC.ViewComponentPanel)
local HighQualityItemDisplayMediator = require("Business/Common/Mediators/HighQualityItemDisplay/HighQualityItemDisplayMediator")
function HighQualityItemDisplay:ListNeededMediators()
  return {HighQualityItemDisplayMediator}
end
function HighQualityItemDisplay:InitializeLuaEvent()
  self.actionOnContinue = LuaEvent.new()
  self.actionOnSkip = LuaEvent.new()
end
function HighQualityItemDisplay:Construct()
  HighQualityItemDisplay.super.Construct(self)
  self.bCanSkip = false
  if self.Button_Click then
    self.Button_Click.OnClicked:Add(self, self.OnClickSkip)
  end
  if self.Button_Equip then
    self.Button_Equip.OnClickEvent:Add(self, self.OnClickEquip)
  end
  if self.Button_Skip then
    self.Button_Skip.OnClickEvent:Add(self, self.OnClickSkip)
  end
end
function HighQualityItemDisplay:Destruct()
  if self.Button_Click then
    self.Button_Click.OnClicked:Remove(self, self.OnClickSkip)
  end
  if self.Button_Equip then
    self.Button_Equip.OnClickEvent:Remove(self, self.OnClickEquip)
  end
  if self.Button_Skip then
    self.Button_Skip.OnClickEvent:Remove(self, self.OnClickSkip)
  end
  HighQualityItemDisplay.super.Destruct(self)
end
function HighQualityItemDisplay:SetItemDisplayed(itemId)
  if nil == itemId then
    return
  end
  self.bCanSkip = false
  self.itemId = itemId
  if self.UI3DModel then
    local itemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(itemId)
    local itemDisplayType = itemQuality == GlobalEnumDefine.EItemQuality.Perfect and UE4.EItemDisplayType.AcquireHQItem_Orange or UE4.EItemDisplayType.AcquireHQItem_red
    self.Display3DModelResult = self.UI3DModel:DisplayByItemId(itemId, UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeaponNoLeisure, itemDisplayType)
    self.itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
    self:InitView(itemId)
  end
end
function HighQualityItemDisplay:InitView(itemId)
  if self.itemType == UE4.EItemIdIntervalType.Weapon or self.itemType == UE4.EItemIdIntervalType.RoleSkin then
    if self.Text_Owner then
      self.Text_Owner:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.Text_Owner then
    self.Text_Owner:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if itemId then
    local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    local itemInfo = itemProxy:GetAnyItemInfoById(itemId)
    if self.Text_Quality then
      self.Text_Quality:SetText(itemInfo.quality and itemProxy:GetItemQualityConfig(itemInfo.quality).Desc or "")
    end
    if self.Text_Name then
      self.Text_Name:SetText(itemInfo.name or "")
    end
    if self.Text_Owner then
      self.Text_Owner:SetText(itemInfo.roleName or "")
    end
  end
  if itemId and self.Button_Equip then
    self.itemId = itemId
    self.Button_Equip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
    local bItemUsed = false
    if itemType == UE4.EItemIdIntervalType.RoleSkin then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsRoleSkinUsed(itemId)
    elseif itemType == UE4.EItemIdIntervalType.Weapon then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):IsWeaponUsed(itemId)
    elseif itemType == UE4.EItemIdIntervalType.VCardAvatar then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID) == itemId
    elseif itemType == UE4.EItemIdIntervalType.VCardBg then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId) == itemId
    else
      self.Button_Equip:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if bItemUsed then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Equipped")
      self.Button_Equip:SetPanelName(text)
      self.Button_Equip:SetButtonIsEnabled(false)
    else
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
      self.Button_Equip:SetPanelName(text)
      self.Button_Equip:SetButtonIsEnabled(true)
    end
  end
  local itemQuality = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(itemId)
  if self.Anim_HQItem and itemQuality == GlobalEnumDefine.EItemQuality.Perfect then
    self:PlayWidgetAnimationWithCallBack("Anim_HQItem", {
      self,
      self.AllowSkip
    })
  end
  if self.Anim_HQItem_red and itemQuality == GlobalEnumDefine.EItemQuality.Legendary then
    self:PlayWidgetAnimationWithCallBack("Anim_HQItem_red", {
      self,
      self.AllowSkip
    })
  end
end
function HighQualityItemDisplay:AllowSkip()
  self.bCanSkip = true
end
function HighQualityItemDisplay:OnClickContinue()
  if self.bCanSkip then
    self.actionOnContinue()
  end
end
function HighQualityItemDisplay:OnClickSkip()
  if self.bCanSkip then
    self.actionOnSkip()
  end
end
function HighQualityItemDisplay:OnClickEquip()
  if self.itemId and self.bCanSkip then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):EquipLotteryResultItem(self.itemId)
  end
end
function HighQualityItemDisplay:ItemUseSucceed()
  if self.Button_Equip then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Equipped")
    self.Button_Equip:SetPanelName(text)
    self.Button_Equip:SetButtonIsEnabled(false)
  end
end
function HighQualityItemDisplay:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.Button_Skip and not ret then
    ret = self.Button_Skip:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_Equip and not ret then
    ret = self.Button_Equip:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
return HighQualityItemDisplay
