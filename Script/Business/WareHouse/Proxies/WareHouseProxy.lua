local WareHouseProxy = class("WareHouseProxy", PureMVC.Proxy)
local Valid
function WareHouseProxy:ReqUseItem(ReqData)
  local data = {
    item_uuid = ReqData.UUid,
    item_id = ReqData.ItemID,
    count = ReqData.Num
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ITEM_USE_REQ, pb.encode(Pb_ncmd_cs_lobby.item_use_req, data))
end
function WareHouseProxy:ReqSellItem(ReqData)
  local data = {
    item_uuid = ReqData.UUid,
    sell_count = ReqData.Num
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BAG_ITEM_SELL_REQ, pb.encode(Pb_ncmd_cs_lobby.bag_item_sell_req, data))
end
function WareHouseProxy:ReqModName(ReqData)
  local data = {
    item_uuid = ReqData.UUid,
    new_nick = ReqData.NickName
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BAG_MOD_NAME_REQ, pb.encode(Pb_ncmd_cs_lobby.bag_mod_name_req, data))
end
function WareHouseProxy:GetItemListData()
  return self.ItemList
end
function WareHouseProxy:GetGiftItemListData()
  local GiftProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy)
  local GiftList = {}
  for uuid, itemData in pairs(self.ItemList or {}) do
    if GiftProxy:ItemIsGift(itemData.item_id) then
      GiftList[uuid] = itemData
    end
  end
  return GiftList
end
function WareHouseProxy:GetItemData(ItemUUId)
  if self.ItemList then
    if ItemUUId then
      return self.ItemList[ItemUUId]
    else
      LogInfo("WareHouseProxy", "GetItemData, ItemUUid is NULL!!!")
    end
  end
  return nil
end
function WareHouseProxy:GetItemCnt(itemId)
  for _, value in pairs(self.ItemList or {}) do
    if value.item_id == itemId then
      return value.count
    end
  end
  return 0
end
function WareHouseProxy:OnRegister()
  self.super:OnRegister()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BAG_ALL_ITEMS_SYNC_NTF, FuncSlot(self.ResWareHouseList, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BAG_PART_ITEMS_SYNC_NTF, FuncSlot(self.ResWareHousePartList, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ITEM_USE_RES, FuncSlot(self.ResUseItem, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BAG_ITEM_SELL_RES, FuncSlot(self.ResSellItem, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BAG_MOD_NAME_RES, FuncSlot(self.ResModName, self))
  end
end
function WareHouseProxy:OnRemove()
  self.super:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BAG_ALL_ITEMS_SYNC_NTF, FuncSlot(self.ResWareHouseList, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BAG_PART_ITEMS_SYNC_NTF, FuncSlot(self.ResWareHousePartList, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ITEM_USE_RES, FuncSlot(self.ResUseItem, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BAG_ITEM_SELL_RES, FuncSlot(self.ResSellItem, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BAG_MOD_NAME_RES, FuncSlot(self.ResModName, self))
  end
end
function WareHouseProxy:ResWareHousePartList(data)
  local PartList = DeCode(Pb_ncmd_cs_lobby.bag_part_items_sync_ntf, data)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local roleFlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  for index, list in ipairs(PartList.item_list or {}) do
    if list.count == nil or 0 == list.count then
      self.ItemList[list.item_uuid] = nil
    else
      self.ItemList[list.item_uuid] = list
    end
    if itemProxy:GetItemIdIntervalType(list.item_id) == UE4.EItemIdIntervalType.BagItem_LotteryTicket then
      lotteryProxy:UpdateTicketCount(list.item_id, list.count)
    end
  end
  for inde, value in ipairs(PartList.decal_list or {}) do
    equipRoomPaintProxy:UpdateOwnedDecalByServer(value)
  end
  for inde, value in ipairs(PartList.weapon_list or {}) do
    Valid = value and weaponProxy:UpdateOwnWeapon(value)
  end
  roleFlyEffectProxy:UpdateOwnFlyEffect(PartList.fluttering_list)
  local emoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  emoteProxy:UpdateOwnEmoteSeverData(PartList.emotion_list)
  local weaponSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy)
  weaponSkinUpgradeProxy:UpdateOwnedWeaponFx(PartList.weapon_fx_list)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local CurrentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local MaxLv = RoleProxy:GetRoleFavorabilityMaxLv()
  local SpecialRewardItem = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetApartmentTaskByRoleIdNLv(CurrentRoleId, MaxLv)
  local SpecialRewardData = SpecialRewardItem and table.count(SpecialRewardItem) > 0 and SpecialRewardItem[1].taskReward
  local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
  local inFrontEnd = true
  if GameState and GameState.GetModeType then
    inFrontEnd = GameState:GetModeType() == UE4.EPMGameModeType.FrontEnd
  end
  if inFrontEnd and PartList.obtain_list and table.count(PartList.obtain_list) > 0 and (table.count(PartList.obtain_list.result_list) > 0 or table.count(PartList.obtain_list.convert_list) > 0) then
    local IsGift = false
    local IsNoDisplayAchieveCard = false
    for i, v in pairs(PartList.obtain_list.result_list or {}) do
      if SpecialRewardData and SpecialRewardData.ItemId and v.item_id == SpecialRewardData.ItemId then
        IsGift = true
      end
      if itemProxy:GetItemIdIntervalType(v.item_id) == UE4.EItemIdIntervalType.Achievement then
        local idCardCfg = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardIdConfig(v.item_id)
        if idCardCfg and 0 == idCardCfg.PopupGain then
          IsNoDisplayAchieveCard = true
        end
      end
    end
    if IsNoDisplayAchieveCard then
      return
    end
    if IsGift then
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ApartmentGiftSharePage, nil, SpecialRewardData.ItemId)
    else
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RewardDisplayPage, true, PartList.obtain_list)
    end
  end
  GameFacade:SendNotification(NotificationDefines.HermesHotListRefreshPriceState)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
  GameFacade:SendNotification(NotificationDefines.ReqApartmentGiftPageData)
  GameFacade:RetrieveProxy(ProxyNames.HermesProxy):ReqGiftAway()
end
function WareHouseProxy:ResWareHouseList(data)
  local WareHouseServerList = DeCode(Pb_ncmd_cs_lobby.bag_all_items_sync_ntf, data)
  local roleFlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  self.ItemList = {}
  for key, value in pairs(WareHouseServerList.item_list or {}) do
    self.ItemList[value.item_uuid] = value
  end
  for inde, value in ipairs(WareHouseServerList.decal_list or {}) do
    equipRoomPaintProxy:UpdateOwnedDecalByServer(value)
  end
  for inde, value in ipairs(WareHouseServerList.weapon_list or {}) do
    Valid = value and weaponProxy:UpdateOwnWeapon(value)
  end
  roleFlyEffectProxy:UpdateOwnFlyEffect(WareHouseServerList.fluttering_list)
  local emoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  emoteProxy:UpdateOwnEmoteSeverData(WareHouseServerList.emotion_list)
  local weaponSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy)
  weaponSkinUpgradeProxy:UpdateOwnedWeaponFx(WareHouseServerList.weapon_fx_list)
end
function WareHouseProxy:ResUseItem(data)
  local ResItem = DeCode(Pb_ncmd_cs_lobby.item_use_res, data)
  if 0 ~= ResItem.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ResItem.code)
  elseif ResItem.item_id ~= 10001 then
    local UseItemText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "UseItem")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, UseItemText)
    GameFacade:SendNotification(NotificationDefines.OnResWareHouseCloseOperate)
  end
end
function WareHouseProxy:ResSellItem(data)
  local ResItem = DeCode(Pb_ncmd_cs_lobby.bag_item_sell_res, data)
  if 0 ~= ResItem.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ResItem.code)
  else
    local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    local openData = {}
    openData.itemList = {
      [1] = {
        itemId = ItemsProxy:GetCurrencyConfig(ResItem.currency_type).Id,
        itemCnt = ResItem.currency_total
      }
    }
    GameFacade:SendNotification(NotificationDefines.OnResWareHouseCloseOperate)
  end
end
function WareHouseProxy:ResModName(data)
  local ResItem = DeCode(Pb_ncmd_cs_lobby.bag_mod_name_res, data)
  if 0 == ResItem.code then
    GameFacade:SendNotification(NotificationDefines.OnResWareHouseCloseOperate)
  elseif ResItem.code == 20607 then
    local tipsPattern = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "RenameForbidden")
    local keyMap = {}
    keyMap.reason = ResItem.ban_reason
    local timeZoneOffset = FunctionUtil:getTimeZoneOffset()
    local unlockDate = os.date("*t", ResItem.ban_time + timeZoneOffset)
    keyMap.year = unlockDate.year
    keyMap.mon = unlockDate.month
    keyMap.day = unlockDate.day
    keyMap.hour = unlockDate.hour
    keyMap.min = unlockDate.min
    local popTips = ObjectUtil:GetTextFromFormat(tipsPattern, keyMap)
    ShowCommonTip(popTips)
  elseif ResItem.code == 5056 then
    local TimeTable = FunctionUtil:FormatTime(ResItem.rest_cd or 0)
    local tipsTime = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "RenameTimeTip")
    local TimeTips = ObjectUtil:GetTextFromFormat(tipsTime, {
      Time = TimeTable.PMGameUtil_Format_ExpectUnit
    })
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TimeTips)
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ResItem.code)
  end
end
function WareHouseProxy:ClassifyItemRedDot(value)
  local ItemData = self:GetItemData(value.reddot_rid)
  local GoodsCfg = ItemData and GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemCfg(ItemData.item_id)
  local ItemsType = ItemData and GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(ItemData.item_id)
  if ItemsType and value.mark then
    if ItemsType == UE4.EItemIdIntervalType.BagItem_RoleFavorabilityGift then
      GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy):AddNewGiftRedDot(value)
      self:AddRedDot(value)
      LogDebug("WareHouseProxy:ClassifyItemRedDot", TableToString(ItemData))
    elseif 1 == GoodsCfg.ItemType or 2 == GoodsCfg.ItemType then
      self:AddRedDot(value)
      LogDebug("WareHouseProxy:ClassifyItemRedDot", TableToString(ItemData))
    end
  end
end
function WareHouseProxy:InitRedDot()
  LogDebug("WareHouseProxy", "Init red dot...")
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.CareerWarehouse, 0)
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ITEM)
  for key, value in pairs(redDotList or {}) do
    self:ClassifyItemRedDot(value)
  end
end
function WareHouseProxy:AddRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.CareerWarehouse, 1)
    GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
  end
end
return WareHouseProxy
