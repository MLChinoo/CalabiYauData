local HermesGoodsDetailPage = class("HermesGoodsDetailPage", PureMVC.ViewComponentPage)
local HermesGoodsDetailMediator = require("Business/Hermes/Mediators/HotList/GoodsDetailMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Hidden = UE4.ESlateVisibility.Hidden
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesGoodsDetailPage:Init(GoodsData)
  self.StoreId = GoodsData.StoreId
  self.StoreType = GoodsData.StoreType
  self.bIsDuringSwitch = false
  Valid = self.ButtonSwitcher and self.ButtonSwitcher:SetActiveWidgetIndex(GoodsData.IsLimited and 1 or 0)
  Valid = self.SingleButtonSwitcher and self.SingleButtonSwitcher:SetActiveWidgetIndex(GoodsData.IsLimited and 1 or 0)
  Valid = self.TextBlock_SingleBuy and self.TextBlock_SingleBuy:SetVisibility(GoodsData.IsLimited and Hidden or SelfHitTestInvisible)
  if table.count(GoodsData.ItemsData) <= 1 then
    self.bIsSingle = true
    Valid = self.VerticalBox_Buy and self.VerticalBox_Buy:SetVisibility(Collapsed)
    Valid = self.TextBlock_SingleBuy and self.TextBlock_SingleBuy:SetVisibility(Hidden)
  else
    Valid = self.VerticalBox_Buy and self.VerticalBox_Buy:SetVisibility(GoodsData.IsLimited and Collapsed or SelfHitTestInvisible)
  end
  Valid = self.NormalBuyButton and self.NormalBuyButton:UpdateView(GoodsData.StoreId)
  if GoodsData.bIsPackageDisplay then
    self.bIsPackageDisplay = true
    self.DefaultRoleSkinId = GoodsData.DefaultRoleSkinId
    self.DefaultWeaponId = GoodsData.DefaultWeaponId
  end
  Valid = self.GoodsGridsPanel and self.GoodsGridsPanel:Update(GoodsData.ItemsData)
end
function HermesGoodsDetailPage:UpdatePanel(ItemId)
  self.CurClickedItemId = ItemId
  self.bIsDuringSwitch = false
  local bIsGiftAway = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyStoreGoodsDataByStoreId(ItemId).store_param == GlobalEnumDefine.EStoreType.GiftAway
  local bIsLimited = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemOwned(ItemId)
  if GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetIsLimited(self.StoreId) then
    bIsLimited = true
  end
  local bIsDiscountPackage = self.StoreType == GlobalEnumDefine.EStoreType.DiscountPackage
  Valid = self.ItemDescWithHeadPanel and self.ItemDescWithHeadPanel:Update(ItemId)
  local data = {}
  data.itemId = ItemId
  data.imageBG = self.Img_BG
  data.show3DBackground = true
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:SetItemDisplayed(data)
  if self.bIsPackageDisplay then
    Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:ShowSwitch(true)
  end
  Valid = self.SkinUpgradePanel and self.SkinUpgradePanel:UpdatePanel(ItemId)
  if bIsGiftAway or bIsDiscountPackage then
    Valid = self.VerticalBox_SingleBuy and self.VerticalBox_SingleBuy:SetVisibility(Collapsed)
    Valid = self.Overlay_GiftAway and self.Overlay_GiftAway:SetVisibility(SelfHitTestInvisible)
    local TextTip = ""
    if bIsDiscountPackage then
      TextTip = ConfigMgr:FromStringTable(StringTablePath.ST_Store, "DiscountPackageTip")
    end
    if bIsGiftAway then
      TextTip = ConfigMgr:FromStringTable(StringTablePath.ST_Store, "GiftAwayTip")
    end
    Valid = self.TextBlock_BuyTip and self.TextBlock_BuyTip:SetText(TextTip)
  else
    Valid = self.VerticalBox_SingleBuy and self.VerticalBox_SingleBuy:SetVisibility(SelfHitTestInvisible)
    Valid = self.Overlay_GiftAway and self.Overlay_GiftAway:SetVisibility(Collapsed)
    local PackageData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetStoreGoodsPriceData(self.StoreId)
    local SingleData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetStoreGoodsPriceData(self.CurClickedItemId)
    if PackageData and PackageData.priceList[1] and SingleData and SingleData.priceList[1] and PackageData.priceList[1].currencyID == SingleData.priceList[1].currencyID then
      if tonumber(SingleData.priceList[1].currencyNum) > tonumber(PackageData.priceList[1].currencyNum) then
        Valid = self.SingleNormalBuyButton and self.SingleNormalBuyButton:UpdateView(self.StoreId)
      else
        Valid = self.SingleNormalBuyButton and self.SingleNormalBuyButton:UpdateView(ItemId)
      end
    end
    Valid = self.SingleButtonSwitcher and self.SingleButtonSwitcher:SetActiveWidgetIndex(bIsLimited and 1 or 0)
    Valid = self.TextBlock_SingleBuy and self.TextBlock_SingleBuy:SetVisibility((bIsLimited or self.bIsSingle) and Hidden or SelfHitTestInvisible)
  end
end
function HermesGoodsDetailPage:UpdateButton()
  local bPackageIsLimited = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetStoreGoodsOwned(self.StoreId)
  local bIsLimited = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemOwned(self.CurClickedItemId)
  if GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetIsLimited(self.StoreId) then
    bPackageIsLimited = true
    bIsLimited = true
  end
  Valid = self.CurClickedItemId and self.SkinUpgradePanel and self.SkinUpgradePanel:UpdatePanel(self.CurClickedItemId)
  Valid = self.ButtonSwitcher and self.ButtonSwitcher:SetActiveWidgetIndex(bPackageIsLimited and 1 or 0)
  Valid = self.VerticalBox_Buy and self.VerticalBox_Buy:SetVisibility(bPackageIsLimited and Collapsed or SelfHitTestInvisible)
  Valid = self.NormalBuyButton and self.NormalBuyButton:UpdateView(self.StoreId)
  if bIsLimited then
    Valid = self.SingleButtonSwitcher and self.SingleButtonSwitcher:SetActiveWidgetIndex(1)
    Valid = self.TextBlock_SingleBuy and self.TextBlock_SingleBuy:SetVisibility(Hidden)
    Valid = self.GoodsGridsPanel and self.GoodsGridsPanel:UpdateItemState()
  end
end
function HermesGoodsDetailPage:ListNeededMediators()
  return {HermesGoodsDetailMediator}
end
function HermesGoodsDetailPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function HermesGoodsDetailPage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.ClosePage, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStartPreview:Add(self.OnClickStartPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStopPreview:Add(self.OnClickStopPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnSwitchShow:Add(self.OnClickSwitchShow, self)
  Valid = self.NormalBuyButton and self.NormalBuyButton.clickUnlockEvent:Add(self.OnClickBuy, self)
  Valid = self.SingleNormalBuyButton and self.SingleNormalBuyButton.clickUnlockEvent:Add(self.OnClickSingleBuy, self)
  Valid = self.SkinUpgradePanel and self.SkinUpgradePanel.onSelectItemEvent:Add(self.OnSkinUpItemSelected, self)
  self.IsPreview = false
  self.bIsDuringSwitch = false
  self:PlayOpenOrCloseAnimation(true)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:SetSwitchBtnName(self.SwitchBtnName)
end
function HermesGoodsDetailPage:OnClose()
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.ClosePage, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStartPreview:Remove(self.OnClickStartPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStopPreview:Remove(self.OnClickStopPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnSwitchShow:Remove(self.OnClickSwitchShow, self)
  Valid = self.NormalBuyButton and self.NormalBuyButton.clickUnlockEvent:Remove(self.OnClickBuy, self)
  Valid = self.SingleNormalBuyButton and self.SingleNormalBuyButton.clickUnlockEvent:Remove(self.OnClickSingleBuy, self)
  Valid = self.SkinUpgradePanel and self.SkinUpgradePanel.onSelectItemEvent:Remove(self.OnSkinUpItemSelected, self)
  self.bIsDuringSwitch = false
end
function HermesGoodsDetailPage:ClosePage()
  ViewMgr:ClosePage(self)
end
function HermesGoodsDetailPage:OnClickBuy()
  ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchasePackageGoodsPage, nil, {
    StoreId = self.StoreId,
    PageName = UIPageNameDefine.HermesHotListPage
  })
end
function HermesGoodsDetailPage:OnClickSingleBuy()
  local PackageData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetStoreGoodsPriceData(self.StoreId)
  local SingleData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetStoreGoodsPriceData(self.CurClickedItemId)
  if PackageData and PackageData.priceList[1] and SingleData and SingleData.priceList[1] and PackageData.priceList[1].currencyID == SingleData.priceList[1].currencyID then
    if tonumber(SingleData.priceList[1].currencyNum) > tonumber(PackageData.priceList[1].currencyNum) then
      self:OnClickBuy()
    elseif tonumber(SingleData.priceList[1].currencyNum) == tonumber(PackageData.priceList[1].currencyNum) then
      local Data = {
        StoreId = self.StoreId,
        PageName = UIPageNameDefine.HermesHotListPage
      }
      ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchaseGoodsPage, nil, Data)
    else
      local Data = {
        StoreId = self.CurClickedItemId,
        PageName = UIPageNameDefine.HermesHotListPage
      }
      ViewMgr:OpenPage(self, UIPageNameDefine.HermesPurchaseGoodsPage, nil, Data)
    end
  end
end
function HermesGoodsDetailPage:OnClickStartPreview(is3DModel)
  self:PlayOpenOrCloseAnimation(false)
end
function HermesGoodsDetailPage:OnClickStopPreview(is3DModel)
  self:PlayOpenOrCloseAnimation(true)
  if self.bIsPackageDisplay then
    Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:ShowSwitch(true)
  end
end
function HermesGoodsDetailPage:OnClickSwitchShow()
  if self.bIsPackageDisplay then
    if self.bIsDuringSwitch then
      self.bIsDuringSwitch = false
      local data = {}
      data.itemId = self.CurClickedItemId
      data.imageBG = self.Img_BG
      data.show3DBackground = true
      Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:SetItemDisplayed(data)
    else
      self.bIsDuringSwitch = true
      Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:DisplayPackageSkin(self.DefaultRoleSkinId, self.DefaultWeaponId)
    end
    Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:ShowSwitch(true)
  end
end
function HermesGoodsDetailPage:OnSkinUpItemSelected(item)
  if nil == item then
    return
  end
  local data = {}
  data.itemId = item:GetItemID()
  data.imageBG = self.Img_BG
  data.show3DBackground = true
  data.flyEffectSkinId = self.CurClickedItemId
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:SetItemDisplayed(data)
  if self.bIsPackageDisplay then
    Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:ShowSwitch(true)
  end
end
function HermesGoodsDetailPage:PlayOpenOrCloseAnimation(Open)
  if self.SwitchAnimation == nil then
    return nil
  end
  if Open then
    if self.IsPreview == false then
      self.SwitchAnimation:PlayOpenAnimation()
      self.IsPreview = true
    end
  else
    if self.IsPreview then
      self.SwitchAnimation:PlayCloseAnimation()
    end
    self.IsPreview = false
  end
end
return HermesGoodsDetailPage
