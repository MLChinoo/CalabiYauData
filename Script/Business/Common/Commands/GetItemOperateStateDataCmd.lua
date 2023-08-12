local GetItemOperateStateDataCmd = class("GetItemOperateStateDataCmd", PureMVC.Command)
function GetItemOperateStateDataCmd:Execute(notification)
  local notificationBody = notification:GetBody()
  local operateStateData = {}
  operateStateData.itemID = notificationBody.itemID
  if notificationBody.itemType == UE4.EItemIdIntervalType.Decal then
    operateStateData = self:GetDecalUnlockInfo(notificationBody.itemID, notificationBody.soltItemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.RoleSkin then
    operateStateData = self:GetSkinUnlockInfo(notificationBody.roleID, notificationBody.itemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.RoleVoice then
    operateStateData = self:GetRoleVoiceUnlockInfo(notificationBody.itemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.RoleAction then
    operateStateData = self:GetRoleActionUnlockInfo(notificationBody.itemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.Weapon then
    operateStateData = self:GetWeaponUnlockInfo(notificationBody.roleID, notificationBody.itemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.FlyEffect then
    operateStateData = self:GetFlyEffectUnlockInfo(notificationBody.baseSkinID, notificationBody.itemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.Achievement then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
    local itemConfig = notificationBody.config
    self:AssembleUnlcokInfo(itemConfig.GainType, itemConfig.GainParam1, itemConfig.GainParam2, operateStateData)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.RoleEmote then
    operateStateData = self:GetRoleEmoteUnlockInfo(notificationBody.roleID, notificationBody.itemID)
  elseif notificationBody.itemType == UE4.EItemIdIntervalType.WeaponUpgradeFx then
    operateStateData = self:GetWeaponFxUnlockInfo(notificationBody.baseSkinID, notificationBody.itemID)
  end
  if notificationBody.itemType == UE4.EItemIdIntervalType.VCardAvatar then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
    local itemConfig = notificationBody.config
    self:AssembleUnlcokInfo(itemConfig.GainType, itemConfig.GainParam1, itemConfig.GainParam2, operateStateData)
  end
  operateStateData.itemType = notificationBody.itemType
  LogDebug("GetItemOperateStateDataCmd", "GetItemOperateStateDataCmd Execute")
  GameFacade:SendNotification(NotificationDefines.UpdateItemOperateState, operateStateData)
end
function GetItemOperateStateDataCmd:GetDecalUnlockInfo(itemID, soltItemID)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local operateStateData = {}
  local bUnlock = equipRoomPaintProxy:IsOwnDecalByDecalID(itemID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    local bEquip = itemID == soltItemID
    if bEquip then
      operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.Equiped
    else
      operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    end
    return operateStateData
  end
  local decalRowData = equipRoomPaintProxy:GetDecalTableDataByItemID(itemID)
  self:AssembleUnlcokInfo(decalRowData.GainType, decalRowData.GainParam1, decalRowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:GetSkinUnlockInfo(roleID, itemID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.RoleSkinUpgradeProxy)
  local operateStateData = {}
  operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
  local skinRowData = roleProxy:GetRoleSkin(itemID)
  if nil == skinRowData then
    LogError("GetItemOperateStateDataCmd:GetSkinUnlockInfo", "role skin is nil ,skinID is " .. tostring(itemID))
    return operateStateData
  end
  local bUnlock = roleProxy:IsUnlockRoleSkin(itemID)
  local bEquip = roleProxy:IsEquipRoleSkin(roleID, itemID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    if bEquip then
      operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.Equiped
      if skinRowData.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
        local baseSkinIDEquip = roleProxy:IsEquipRoleSkin(roleID, skinRowData.BasicSkinId)
        if not baseSkinIDEquip then
          operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
        end
      elseif skinRowData.UpdateType == UE4.ECyCharacterSkinUpgradeType.Basics and roleSkinUpgradeProxy:IsEquipAdvancedSkin(itemID) then
        operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
      end
    else
      operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    end
    return operateStateData
  elseif skinRowData.UpdateType == UE4.ECyCharacterSkinUpgradeType.Advance then
    local bBasicSkinUnlock = roleProxy:IsUnlockRoleSkin(skinRowData.BasicSkinId)
    if not bBasicSkinUnlock then
      operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
      operateStateData.unlockCondtionType = GlobalEnumDefine.EItemUnlockConditionType.None
      operateStateData.unlockConditionInfo = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "UnlockAdvanceSkinTips")
      return operateStateData
    end
  end
  self:AssembleUnlcokInfo(skinRowData.GainType, skinRowData.GainParam1, skinRowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:GetRoleVoiceUnlockInfo(roleVoiceID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local operateStateData = {}
  local bUnlock = roleProxy:IsUnlockRoleVoice(roleVoiceID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    return operateStateData
  end
  local voiceRowData = roleProxy:GetRoleVoice(roleVoiceID)
  self:AssembleUnlcokInfo(voiceRowData.GainType, voiceRowData.GainParam1, voiceRowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:GetRoleActionUnlockInfo(roleActionID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local operateStateData = {}
  local bUnlock = roleProxy:IsUnlockRoleAction(roleActionID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    return operateStateData
  end
  local actionRowData = roleProxy:GetRoleAction(roleActionID)
  self:AssembleUnlcokInfo(actionRowData.GainType, actionRowData.GainParam1, actionRowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:GetWeaponUnlockInfo(roleID, weaponID)
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local bHasRole = roleProxy:IsUnlockRole(roleID)
  local operateStateData = {}
  local bUnlock = weaponProxy:GetWeaponUnlockState(weaponID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
  local weaponRowData = weaponProxy:GetWeapon(weaponID)
  if weaponRowData.LevelupType == UE4.ECyCharacterSkinUpgradeType.Advance then
    self:GetAdvanceWeaponUnlockInfo(roleID, weaponRowData, operateStateData)
    return operateStateData
  end
  if bUnlock then
    if bHasRole then
      local bEquip = equipRoomPrepareProxy:IsEquipWeapon(roleID, weaponID)
      if bEquip then
        operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.Equiped
        if weaponRowData.LevelupType == UE4.ECyCharacterSkinUpgradeType.Basics and 0 ~= weaponProxy:GetCurrentEquipAdvanedSkinID(weaponRowData.Id) then
          operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
        end
      else
        operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
      end
    else
      operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    end
    return operateStateData
  end
  self:AssembleUnlcokInfo(weaponRowData.GainType, weaponRowData.GainParam1, weaponRowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:GetAdvanceWeaponUnlockInfo(roleID, weaponRow, operateStateData)
  if nil == weaponRow then
    return
  end
  local baseSkinID = weaponRow.BasicSkinId
  if nil == baseSkinID then
    return
  end
  local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local bHasRole = roleProxy:IsUnlockRole(roleID)
  local baseSkinUnlock = weaponProxy:GetWeaponUnlockState(baseSkinID)
  if not baseSkinUnlock then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
    operateStateData.unlockCondtionType = GlobalEnumDefine.EItemUnlockConditionType.None
    operateStateData.unlockConditionInfo = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "UnlockAdvanceSkinTips")
    return operateStateData
  end
  local bUnlock = weaponProxy:GetWeaponUnlockState(weaponRow.Id)
  if not bUnlock then
    self:AssembleUnlcokInfo(weaponRow.GainType, weaponRow.GainParam1, weaponRow.GainParam2, operateStateData)
    return
  end
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
  operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
  local baseSkinEuqip = equipRoomPrepareProxy:IsEquipWeapon(roleID, baseSkinID)
  local bEquip = equipRoomPrepareProxy:IsEquipWeapon(roleID, weaponRow.Id)
  if baseSkinEuqip and bEquip then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.Equiped
  end
end
function GetItemOperateStateDataCmd:GetFlyEffectUnlockInfo(baseSkinID, flyEffectID)
  local roleFlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local operateStateData = {}
  local bBasicSkinUnlock = roleProxy:IsUnlockRoleSkin(baseSkinID)
  if false == bBasicSkinUnlock then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
    operateStateData.unlockCondtionType = GlobalEnumDefine.EItemUnlockConditionType.None
    operateStateData.unlockConditionInfo = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "UnlockAdvanceSkinTips")
    return operateStateData
  end
  local bUnlock = roleFlyEffectProxy:IsUnlockFlyEffect(flyEffectID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    local bEquip = GameFacade:RetrieveProxy(ProxyNames.RoleSkinUpgradeProxy):IsEquipFlyEffect(baseSkinID, flyEffectID)
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    if bEquip then
      operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CancelEquipBtnName")
    else
      operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
    end
    return operateStateData
  end
  local flyEffectRowData = roleFlyEffectProxy:GetFlyEffectRowTableCfg(flyEffectID)
  self:AssembleUnlcokInfo(flyEffectRowData.GainType, flyEffectRowData.GainParam1, flyEffectRowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:AssembleUnlcokInfo(unlockTypeTarry, argTarry, unlockFText, operateStateData)
  if nil == unlockTypeTarry or 0 == unlockTypeTarry:Length() then
    LogError("GetItemOperateStateDataCmd", "unlockTypeTarry is nil")
    return
  end
  local conditionType = unlockTypeTarry:Get(1)
  operateStateData.unlockCondtionType = conditionType
  if conditionType == GlobalEnumDefine.EItemUnlockConditionType.AccountLevel then
    operateStateData.unlockConditionInfo = self:GetAccountLevelInfo({
      conditionLevel = argTarry:Get(1),
      levalFText = unlockFText
    })
  elseif conditionType == GlobalEnumDefine.EItemUnlockConditionType.None then
    operateStateData.unlockConditionInfo = unlockFText
  elseif conditionType == GlobalEnumDefine.EItemUnlockConditionType.Store then
    if nil == argTarry then
      LogError(" GetItemOperateStateDataCmd:AssembleUnlcokInfo", "argsTarry is nil")
    else
      operateStateData.storeID = argTarry:Get(1)
    end
  elseif conditionType == GlobalEnumDefine.EItemUnlockConditionType.BattlePass then
    self:GetBattlePassInfo({
      arg = argTarry:Get(1),
      argText = unlockFText
    }, operateStateData)
  elseif conditionType == GlobalEnumDefine.EItemUnlockConditionType.Lottery then
    self:GetLotteryInfo({
      arg = argTarry:Get(1),
      argText = unlockFText
    }, operateStateData)
  end
end
function GetItemOperateStateDataCmd:GetAccountLevelInfo(conditionLevelData)
  local argsTarry = UE4.TArray(UE4.FFormatArgumentData)
  local currenLevelArg = UE4.FFormatArgumentData()
  currenLevelArg.ArgumentName = "0"
  currenLevelArg.ArgumentValue = 1
  currenLevelArg.ArgumentValueType = 4
  local conditionLevelArg = UE4.FFormatArgumentData()
  conditionLevelArg.ArgumentName = "2"
  conditionLevelArg.ArgumentValue = conditionLevelData.conditionLevel
  conditionLevelArg.ArgumentValueType = 4
  argsTarry:Add(currenLevelArg)
  argsTarry:Add(conditionLevelArg)
  local info = UE4.UKismetTextLibrary.Format(conditionLevelData.levalFText, argsTarry)
  return info
end
function GetItemOperateStateDataCmd:GetBattlePassInfo(conditionData, operateStateData)
  local seasonID = conditionData.arg
  local battlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local seasonConfig = battlePassProxy:GetSeasonConfig(seasonID)
  if nil == seasonConfig then
    LogError("GetItemOperateStateDataCmd:GetBattlePassInfo", "物品解锁类型为BattlePass的参数配置错误，arg is " .. tostring(seasonID))
    operateStateData.bCanJump = false
    return
  end
  local currentSeasonID = battlePassProxy:GetCurrentSeasonID()
  local bCuttentSeason = currentSeasonID == seasonID
  operateStateData.bCanJump = bCuttentSeason
  if bCuttentSeason then
    operateStateData.unlockConditionInfo = conditionData.argText
  else
    local proxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
    local row = proxy:GetFunctionById(UE4.EPMFunctionTypes.BattlePass)
    if row then
      local outText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "HaveExpired")
      operateStateData.unlockConditionInfo = row.Name .. outText
    end
  end
end
function GetItemOperateStateDataCmd:GetLotteryInfo(conditionData, operateStateData)
  local lotteryID = conditionData.arg
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  local lotteryList = lotteryProxy:GetEnableList()
  local bOpen = false
  if lotteryList then
    bOpen = nil ~= lotteryList[lotteryID]
  end
  operateStateData.bCanJump = bOpen
  if operateStateData.bCanJump then
    operateStateData.unlockConditionInfo = conditionData.argText
  else
    local outText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "HaveExpired")
    operateStateData.unlockConditionInfo = conditionData.argText .. outText
  end
end
function GetItemOperateStateDataCmd:AssembleRoleSkinUnlcokInfo(skinRow, operateStateData)
end
function GetItemOperateStateDataCmd:GetRoleEmoteUnlockInfo(roleID, emoteID)
  local rolePersonalityCommunicationProxy = GameFacade:RetrieveProxy(ProxyNames.RolePersonalityCommunicationProxy)
  local emoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  local operateStateData = {}
  local bUnlock = emoteProxy:IsUnlockEmote(emoteID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    return operateStateData
  end
  local rowData = emoteProxy:GetRoleEmoteTableRow(emoteID)
  self:AssembleUnlcokInfo(rowData.GainType, rowData.GainParam1, rowData.GainParam2, operateStateData)
  return operateStateData
end
function GetItemOperateStateDataCmd:GetWeaponFxUnlockInfo(baseWeaponID, fxID)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local operateStateData = {}
  local bBasicSkinUnlock = weaponProxy:GetWeaponUnlockState(baseWeaponID)
  if false == bBasicSkinUnlock then
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
    operateStateData.unlockCondtionType = GlobalEnumDefine.EItemUnlockConditionType.None
    operateStateData.unlockConditionInfo = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "UnlockAdvanceSkinTips")
    return operateStateData
  end
  local weaponSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy)
  local bUnlock = weaponSkinUpgradeProxy:IsUnlockWeaponFx(fxID)
  operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotUnlcok
  if bUnlock then
    local bEquip = weaponProxy:IsEquipWeaponFx(fxID, baseWeaponID)
    operateStateData.operateType = GlobalEnumDefine.EItemOperateStateType.NotEquip
    if bEquip then
      operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CancelEquipBtnName")
    else
      operateStateData.equipBtnName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
    end
    return operateStateData
  end
  local rowData = weaponSkinUpgradeProxy:GetFxWeaponRow(fxID)
  self:AssembleUnlcokInfo(rowData.GainType, rowData.GainParam1, rowData.GainParam2, operateStateData)
  return operateStateData
end
return GetItemOperateStateDataCmd
