local RewardDisplayMediator = class("RewardDisplayMediator", PureMVC.Mediator)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
function RewardDisplayMediator:ListNotificationInterests()
  return {
    NotificationDefines.ShowPlayerGuideCurrentIndex
  }
end
function RewardDisplayMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local data = notification:GetBody()
end
function RewardDisplayMediator:OnRegister()
  self:GetViewComponent().updateViewEvent:Add(self.UpdateViewData, self)
end
function RewardDisplayMediator:OnRemove()
  self:GetViewComponent().updateViewEvent:Remove(self.UpdateViewData, self)
end
function RewardDisplayMediator:UpdateViewData(luaOpenData, nativeOpenData)
  if luaOpenData then
    self:ProcessLuaData(luaOpenData)
  elseif nativeOpenData then
    self:ProcessNativeData(nativeOpenData)
  end
end
function RewardDisplayMediator:ProcessLuaData(luaOpenData)
  local obtainData = {}
  obtainData.overflowItemList = {}
  obtainData.itemList = {}
  if luaOpenData.result_list and luaOpenData.convert_list then
    for key, value in pairs(luaOpenData.convert_list) do
      local info = {}
      info.itemId = value.item_id
      info.itemCnt = value.count
      info.currencyId = value.currency_id
      info.currencyCnt = value.currency_cnt
      table.insert(obtainData.overflowItemList, info)
    end
    for key, value in pairs(luaOpenData.result_list) do
      local info = {}
      info.itemId = value.item_id
      info.itemCnt = value.count
      table.insert(obtainData.itemList, info)
    end
  else
    obtainData.itemList = luaOpenData.itemList
  end
  local rewardDatas = {}
  if #obtainData.overflowItemList > 0 then
    rewardDatas.isOverflow = true
  end
  rewardDatas.itemInfoList = {}
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  for index, value in pairs(obtainData.itemList) do
    local itemInfo = {}
    local itemId = value.itemId
    local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
    itemInfo.img = itemCfg.image
    itemInfo.name = itemCfg.name
    itemInfo.count = value.itemCnt
    local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
    if qualityInfo then
      itemInfo.qualityColor = qualityInfo.Color
    end
    itemInfo.ownerList = {}
    itemsProxy:GetItemOwnerById(itemId, {
      UE4.EItemIdIntervalType.Weapon,
      UE4.EItemIdIntervalType.RoleSkin,
      UE4.EItemIdIntervalType.RoleVoice
    }, itemInfo.ownerList)
    table.insert(rewardDatas.itemInfoList, itemInfo)
  end
  for index, value in pairs(obtainData.overflowItemList) do
    local itemInfo = {}
    local itemId = value.itemId
    local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
    itemInfo.img = itemCfg.image
    itemInfo.name = itemCfg.name
    itemInfo.count = value.itemCnt
    local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
    if qualityInfo then
      itemInfo.qualityColor = qualityInfo.Color
    end
    local currencyCfg = itemsProxy:GetCurrencyConfig(value.currencyId)
    if currencyCfg then
      itemInfo.currencyImg = currencyCfg.IconTipItem
    end
    itemInfo.currencyCnt = value.currencyCnt
    itemInfo.ownerList = {}
    itemsProxy:GetItemOwnerById(itemId, {
      UE4.EItemIdIntervalType.Weapon,
      UE4.EItemIdIntervalType.RoleSkin,
      UE4.EItemIdIntervalType.RoleVoice
    }, itemInfo.ownerList)
    table.insert(rewardDatas.itemInfoList, itemInfo)
  end
  self:GetViewComponent():UpdatePageView(rewardDatas)
end
function RewardDisplayMediator:ProcessNativeData(nativeOpenData)
  local rewardDatas = {}
  if nativeOpenData.OverflowItemPairs and nativeOpenData.OverflowItemPairs:Length() > 0 then
    rewardDatas.isOverflow = true
  end
  rewardDatas.itemInfoList = {}
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local itemPairs = nativeOpenData.ItemPairs
  for i = 1, itemPairs:Length() do
    local itemInfo = {}
    local itemId = itemPairs:Get(i).ItemId
    local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
    itemInfo.img = itemCfg.image
    itemInfo.name = itemCfg.name
    itemInfo.count = itemPairs:Get(i).ItemCnt
    local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
    if qualityInfo then
      itemInfo.qualityColor = qualityInfo.Color
    end
    itemInfo.ownerList = {}
    itemsProxy:GetItemOwnerById(itemId, {
      UE4.EItemIdIntervalType.Weapon,
      UE4.EItemIdIntervalType.RoleSkin,
      UE4.EItemIdIntervalType.RoleVoice
    }, itemInfo.ownerList)
    table.insert(rewardDatas.itemInfoList, itemInfo)
  end
  self:GetViewComponent():UpdatePageView(rewardDatas)
end
return RewardDisplayMediator
