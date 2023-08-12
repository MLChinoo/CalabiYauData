local ApartmentPromisePageDataCmd = class("ApartmentPromisePageDataCmd", PureMVC.Command)
function ApartmentPromisePageDataCmd:Execute(notification)
  local AddSlashText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "AddSlash")
  local AddSemicolonText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "AddSemicolon")
  local TaskTipText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "TaskTip")
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local ItemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local CurrentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local RoleProperties = KaPhoneProxy:GetRoleProperties(CurrentRoleId)
  local RoleLvRewards = RoleProxy:GetRoleFavorabilityRewardData(CurrentRoleId)
  local Body = {
    GiftList = {},
    NewUnlockTask = {}
  }
  local InData = {}
  local ItemCfg, ItemImage, IntervalInfo, ItemQuality
  for index, value in pairs(RoleLvRewards or {}) do
    ItemImage = ItemProxy:GetAnyItemImg(value.itemId)
    ItemCfg = ItemProxy:GetAnyItemInfoById(value.itemId)
    IntervalInfo = ItemProxy:GetItemIdInterval(value.itemId)
    ItemQuality = ItemProxy:GetItemQualityConfig(ItemCfg.quality)
    local ItemTypeNameParam = ObjectUtil:GetTextFromFormat(AddSemicolonText, {
      [0] = IntervalInfo.ItemTypeName,
      [1] = ItemCfg.name
    })
    local ItemDescParam = ObjectUtil:GetTextFromFormat(TaskTipText, {
      [0] = value.favoLv
    })
    InData = {
      ItemId = value.itemId,
      ItemArray = value.itemArray,
      ItemArrayImg = value.itemArrayImg,
      ItemDesc = ItemDescParam,
      ItemTypeName = ItemTypeNameParam,
      Level = value.favoLv,
      ItemAmount = value.itemAmount,
      ItemQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemQuality.Color)),
      ItemsoftTexture = ItemImage,
      bIsGet = false,
      bIsShowRewardTip = value.favoLv <= RoleProperties.intimacy_lv,
      bIsUnlock = value.favoLv <= RoleProperties.intimacy_lv
    }
    if table.containsValue(RoleProperties.upgrade_rewards, value.favoLv) then
      InData.bIsGet = true
      local First = string.split(ItemCfg.desc, "\n")
      InData.ItemDesc = First[1]
    end
    Body.GiftList[index] = InData
  end
  Body.NewUnlockTask = RoleProperties.tasks or {}
  local taskInfo = BattlePassProxy:GetApartmentRoleAllTask(CurrentRoleId)
  for index, value in pairs(taskInfo) do
    ItemImage = ItemProxy:GetAnyItemImg(value.taskReward.ItemId)
    ItemCfg = ItemProxy:GetAnyItemInfoById(value.taskReward.ItemId)
    IntervalInfo = ItemProxy:GetItemIdInterval(value.taskReward.ItemId)
    ItemQuality = ItemProxy:GetItemQualityConfig(ItemCfg.quality)
    value.taskProgress = value.taskProgress or 0
    local ItemTypeNameParam = ObjectUtil:GetTextFromFormat(AddSemicolonText, {
      [0] = IntervalInfo.ItemTypeName,
      [1] = ItemCfg.name
    })
    local TaskProgressParam = ObjectUtil:GetTextFromFormat(AddSlashText, {
      [0] = value.taskProgress,
      [1] = value.taskTarget
    })
    local ItemDescParam = ObjectUtil:GetTextFromFormat(TaskTipText, {
      [0] = value.taskLv
    })
    InData = {
      ItemArray = value.taskRewardArray,
      ItemId = value.taskReward.ItemId,
      ItemTypeName = ItemTypeNameParam,
      Level = value.taskLv,
      ItemAmount = value.taskReward.ItemAmount,
      ItemQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemQuality.Color)),
      ItemsoftTexture = ItemImage,
      ItemArrayImg = ItemImage,
      ItemDesc = ItemDescParam,
      TaskProgress = "",
      TaskId = value.taskId,
      AVGEventId = value.avgEventId,
      AVGSequenceId = value.avgSequenceId,
      ProgressLevel = nil,
      bIsPromise = true,
      bIsGet = false,
      bIsShowRewardTip = false,
      bIsUnlock = value.taskState and value.taskState >= Pb_ncmd_cs.ETaskState.TaskState_PROGRESSING or false
    }
    if InData.bIsUnlock then
      InData.ItemDesc = value.taskDesc
      InData.TaskProgress = TaskProgressParam
      InData.ProgressLevel = value.taskProgress / value.taskTarget
    end
    if value.taskState and value.taskState == Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN then
      InData.bIsGet = true
    elseif value.taskState and value.taskState == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
      InData.bIsShowRewardTip = true
    end
    table.insert(Body.GiftList, value.taskLv + index, InData)
  end
  GameFacade:SendNotification(NotificationDefines.SetApartmentPromisePageData, Body)
end
return ApartmentPromisePageDataCmd
