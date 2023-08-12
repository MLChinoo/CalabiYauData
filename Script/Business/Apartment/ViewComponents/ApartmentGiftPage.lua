local ApartmentGiftPage = class("ApartmentGiftPage", PureMVC.ViewComponentPage)
local ApartmentGiftMediator = require("Business/Apartment/Mediators/ApartmentGiftMediator")
local Valid
function ApartmentGiftPage:SetPageActive(bIsActive)
  self.bIsActivePage = bIsActive
end
function ApartmentGiftPage:GetPageIsActive()
  return self.bIsActivePage
end
function ApartmentGiftPage:Init(PageData)
  if not self.bIsActivePage then
    return
  end
  self.RoleId = PageData.RoleId
  Valid = self.SizeBox_Item and self.SizeBox_Item:SetVisibility(UE.ESlateVisibility.Collapsed)
  Valid = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:Reset(true)
  Valid = self.Button_UseGift and self.Button_UseGift:SetIsEnabled(true)
  self.AllNone = false
  local Item
  if 0 == table.count(PageData.GiftList) then
    for i = 1, 15 do
      Item = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:BP_CreateEntry()
      Valid = Item and Item:InitNoneItem()
    end
    Valid = self.TextBlock_ItemName and self.TextBlock_ItemName:SetText(self.ItemDefaultName)
    Valid = self.TextBlock_ItemDesc and self.TextBlock_ItemDesc:SetText(self.ItemDefaultDesc)
    Valid = self.Button_UseGift and self.Button_UseGift:SetIsEnabled(false)
    Valid = self.TextBlock_ItemChoseNum and self.TextBlock_ItemChoseNum:SetText(0)
    self.AllNone = true
    return
  end
  self.ListItem = {}
  for index, DataInfo in pairs(PageData.GiftList or {}) do
    Item = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:BP_CreateEntry()
    Valid = Item and Item:Init(index, DataInfo)
    table.insert(self.ListItem, Item)
    Item.actionOnClickButton:Add(self.OnClickedItem, self)
  end
  Valid = self.ListItem and self.ListItem[1] and self:OnClickedItem(self.ListItem[1])
end
function ApartmentGiftPage:Construct()
  ApartmentGiftPage.super.Construct(self)
  self.ItemDefaultName = self.TextBlock_ItemName and self.TextBlock_ItemName:GetText()
  self.ItemDefaultDesc = self.TextBlock_ItemDesc and self.TextBlock_ItemDesc:GetText()
  Valid = self.Button_UseGift and self.Button_UseGift.OnClicked:Add(self, self.OnClickUseGift)
  Valid = self.Button_Increase and self.Button_Increase.OnClicked:Add(self, self.OnClickIncrease)
  Valid = self.Button_Decrease and self.Button_Decrease.OnClicked:Add(self, self.OnClickDecrease)
  if self.Button_Increase then
    self.Button_Increase.OnPressed:Add(self, self.OnPressIncrease)
    self.Button_Increase.OnReleased:Add(self, self.OnReleaseIncrease)
  end
  if self.Button_Decrease then
    self.Button_Decrease.OnPressed:Add(self, self.OnPressDecrease)
    self.Button_Decrease.OnReleased:Add(self, self.OnReleaseDecrease)
  end
  self.numChangeSpeed = 1
end
function ApartmentGiftPage:Destruct()
  Valid = self.Button_UseGift and self.Button_UseGift.OnClicked:Remove(self, self.OnClickUseGift)
  Valid = self.Button_Increase and self.Button_Increase.OnClicked:Remove(self, self.OnClickIncrease)
  Valid = self.Button_Decrease and self.Button_Decrease.OnClicked:Remove(self, self.OnClickDecrease)
  if self.Button_Increase then
    self.Button_Increase.OnPressed:Remove(self, self.OnPressIncrease)
    self.Button_Increase.OnReleased:Remove(self, self.OnReleaseIncrease)
  end
  if self.Button_Decrease then
    self.Button_Decrease.OnPressed:Remove(self, self.OnPressDecrease)
    self.Button_Decrease.OnReleased:Remove(self, self.OnReleaseDecrease)
  end
  self:ResetChange()
  ApartmentGiftPage.super.Destruct(self)
end
function ApartmentGiftPage:OnClickUseGift()
  local reqData = {
    roleId = self.RoleId,
    giftId = self.ItemId,
    giveNum = self.TextBlock_ItemChoseNum and tonumber(self.TextBlock_ItemChoseNum:GetText())
  }
  GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy):ReqGiveGiftToRole(reqData)
end
function ApartmentGiftPage:OnClickIncrease()
  self:UpdateValue(math.clamp(self.CurNum + 1, 1, self.MaxNum))
end
function ApartmentGiftPage:OnClickDecrease()
  self:UpdateValue(math.clamp(self.CurNum - 1, 1, self.MaxNum))
end
function ApartmentGiftPage:UpdateValue(value)
  if self.AllNone then
    return
  end
  self.CurNum = value
  Valid = self.TextBlock_ItemChoseNum and self.TextBlock_ItemChoseNum:SetText(self.CurNum)
  self:CheckMaxFavExpGift(self.CurNum)
end
function ApartmentGiftPage:CheckMaxFavExpGift(curValue)
  local isMax = false
  local predictLv
  local MaxLv = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavorabilityMaxLv()
  local MaxLvCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavoribility(math.max(MaxLv - 1, 1))
  local roleApartmentInfo = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(self.RoleId)
  if roleApartmentInfo then
    local giftCfg = GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy):GetGiftToRoleCfg(self.ItemId, self.RoleId)
    local totalFavExp = giftCfg.favorability * curValue
    local predictExp = roleApartmentInfo.intimacy + totalFavExp
    if predictExp >= MaxLvCfg.FExp then
      isMax = true
      predictLv = MaxLv
    else
      isMax = false
      for lv = roleApartmentInfo.intimacy_lv, MaxLv do
        local intimacyLvCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavoribility(lv)
        if predictExp < intimacyLvCfg.FExp then
          predictLv = lv
          break
        end
      end
    end
  end
  Valid = self.TextBlock_PredictInitmacityLv and self.TextBlock_PredictInitmacityLv:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if isMax then
    local tipsMsg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "GiftWillBeWaste")
    Valid = self.TextBlock_PredictInitmacityLv and self.TextBlock_PredictInitmacityLv:SetText(tipsMsg)
  elseif predictLv then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "PredictInmacityLv")
    local stringMap = {
      [0] = predictLv
    }
    local tipsMsg = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    Valid = self.TextBlock_PredictInitmacityLv and self.TextBlock_PredictInitmacityLv:SetText(tipsMsg)
  end
end
function ApartmentGiftPage:SetSliderMinAndMaxValue(Min, Max)
  local predictLv = Max
  local MaxLv = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavorabilityMaxLv()
  local MaxLvCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavoribility(math.max(MaxLv - 1, 1))
  local giftCfg = GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy):GetGiftToRoleCfg(self.ItemId, self.RoleId)
  local roleApartmentInfo = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(self.RoleId)
  for i = Min, Max do
    if roleApartmentInfo then
      local predictExp = roleApartmentInfo.intimacy + giftCfg.favorability * i
      if predictExp >= MaxLvCfg.FExp then
        predictLv = i
        break
      end
    end
  end
  self.MinNum = Min
  self.MaxNum = predictLv
  self:UpdateValue(1)
end
function ApartmentGiftPage:OnClickedItem(Item)
  self.ItemUUID = Item.ItemUUID
  self.ItemId = Item.ItemId
  Valid = self.Image_Item and self:SetImageByTexture2D(self.Image_Item, Item.ItemImage)
  Valid = self.TextBlock_ItemName and self.TextBlock_ItemName:SetText(Item.ItemName)
  Valid = self.TextBlock_ItemDesc and self.TextBlock_ItemDesc:SetText(Item.ItemDesc)
  Valid = self.TextBlock_ItemChoseNum and self.TextBlock_ItemChoseNum:SetText(1)
  Valid = self.SizeBox_Item and self.SizeBox_Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:SetSliderMinAndMaxValue(1, Item.ItemNum)
  for index, value in pairs(self.ListItem or {}) do
    Valid = value.Button_Clicked and value.Button_Clicked:SetIsEnabled(value.Index ~= Item.Index)
  end
  Item:ShowRedDot(false)
  if Item.RedDotID and 0 ~= Item.RedDotID then
    GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(Item.RedDotID)
    GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy):SetGiftRedDotRead(Item.RedDotID)
    GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):InitRedDot()
  end
end
function ApartmentGiftPage:ListNeededMediators()
  return {ApartmentGiftMediator}
end
function ApartmentGiftPage:InitializeLuaEvent()
end
function ApartmentGiftPage:OnPressIncrease()
  self:StartChangeSpeedTimer()
  self:StartChangeNumTimer(1)
end
function ApartmentGiftPage:OnReleaseIncrease()
  self:ResetChange()
end
function ApartmentGiftPage:OnPressDecrease()
  self:StartChangeSpeedTimer()
  self:StartChangeNumTimer(-1)
end
function ApartmentGiftPage:OnReleaseDecrease()
  self:ResetChange()
end
function ApartmentGiftPage:StartChangeSpeedTimer()
  self.changeSpeedTask = TimerMgr:AddTimeTask(self.ChangeSpeedInterval, self.ChangeSpeedInterval, 0, function()
    self:StartChangeSpeed()
  end)
end
function ApartmentGiftPage:StartChangeSpeed()
  if self.numChangeSpeed then
    self.numChangeSpeed = self.numChangeSpeed + 2 > 30 and 30 or self.numChangeSpeed + 2
  end
end
function ApartmentGiftPage:StartChangeNumTimer(delta)
  self.changeNumTask = TimerMgr:AddTimeTask(0.5, 0.1, 0, function()
    self:StartChangeNum(delta)
  end)
end
function ApartmentGiftPage:StartChangeNum(delta)
  self.CurNum = self.CurNum + self.numChangeSpeed * delta
  self:UpdateValue(math.clamp(self.CurNum, 1, self.MaxNum))
end
function ApartmentGiftPage:ResetChange()
  if self.changeSpeedTask then
    self.changeSpeedTask:EndTask()
    self.changeSpeedTask = nil
  end
  if self.changeNumTask then
    self.changeNumTask:EndTask()
    self.changeNumTask = nil
  end
  self.numChangeSpeed = 1
end
return ApartmentGiftPage
