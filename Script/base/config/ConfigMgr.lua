local ConfigMgr = {}
local cachedData = {}
local richTextStyleTable = {}
local WrapDataTable = function(dt)
  local wrap = {}
  wrap.originDT = dt
  wrap.dTLenght = -1
  wrap.allRowsName = nil
  function wrap:GetRow(rowName)
    return UE4.UDataTableFunctionLibrary.GetRowDataStructure(self.originDT, tostring(rowName))
  end
  function wrap:RowCount()
    if -1 == self.dTLenght then
      self:GetRowNames()
      if self.allRowsName then
        self.dTLenght = self.allRowsName:Length()
      end
    end
    return self.dTLenght
  end
  function wrap:ToLuaTable()
    local tmpTable = {}
    for i = 1, self:RowCount() do
      local tmpRowName = self.allRowsName:Get(i)
      tmpTable[tmpRowName] = self:GetRow(tmpRowName)
    end
    return tmpTable
  end
  function wrap:DoesRowExist(rowName)
    return UE4.UDataTableFunctionLibrary.DoesDataTableRowExist(self.originDT, rowName)
  end
  function wrap:GetRowNames()
    if not self.allRowsName then
      self.allRowsName = UE4.UDataTableFunctionLibrary.GetDataTableRowNames(self.originDT)
    end
    return self.allRowsName
  end
  return wrap
end
local GetTableRowCached = function(tableRowStructName)
  if cachedData[tableRowStructName] then
    return cachedData[tableRowStructName]
  end
  local loadFunc = UE4.UPMLuaBridgeBlueprintLibrary.GetConfigDataTable
  local data = loadFunc(tableRowStructName)
  if not data then
    LogError("Config", "No TableRowLoad for %s", tableRowStructName)
    return
  end
  local wrapData = WrapDataTable(data)
  cachedData[tableRowStructName] = wrapData
  return wrapData
end
local ClearTableRowCached = function(tableRowStructName)
  cachedData[tableRowStructName] = nil
end
function ConfigMgr:FromStringTable(tableId, key)
  return UE4.UKismetTextLibrary.TextFromStringTable(tableId, key)
end
function ConfigMgr:GetRichTextStyle(styleName)
  if richTextStyleTable[styleName] then
    return richTextStyleTable[styleName].TextStyle
  end
  LogError("ConfigMgr:GetRichTextStyle", "DT_RichTextName Cant Find This Name : " .. styleName)
  return nil
end
function ConfigMgr:GetUITableRows()
  return GetTableRowCached("CyUITableRow")
end
function ConfigMgr:GetDSClusterTableRows()
  return GetTableRowCached("CyDsClusterTableRow")
end
function ConfigMgr:GetDivisionTableRows()
  return GetTableRowCached("CyDivisionTableRow")
end
function ConfigMgr:GetDivisionStarTableRows()
  return GetTableRowCached("CyDivisionStarTableRow")
end
function ConfigMgr:GetDivisionRewardTableRows()
  return GetTableRowCached("CyDivisionRewardTableRow")
end
function ConfigMgr:GetAchievementTableRows()
  return GetTableRowCached("CyAchievementTableRow")
end
function ConfigMgr:GetAchievementTypeTableRows()
  return GetTableRowCached("CyAchievementTypeTableRow")
end
function ConfigMgr:GetIdCardTableRows()
  return GetTableRowCached("CyIdCardTableRow")
end
function ConfigMgr:GetLotteryTableRows()
  return GetTableRowCached("CyLotteryTableRow")
end
function ConfigMgr:GetDropTableRows()
  return GetTableRowCached("CyDropTableRow")
end
function ConfigMgr:GetShortcutTextTableRows()
  return GetTableRowCached("CyChatShortcutTextTableRow")
end
function ConfigMgr:GetBattlePassSeasonTableRows()
  return GetTableRowCached("CyBattlePassSeasonTableRow")
end
function ConfigMgr:GetRichTextTableRows()
  return GetTableRowCached("RichTextStyleRow")
end
function ConfigMgr:GetErrorCodeTableRows()
  return GetTableRowCached("CyErrorCodeTableRow"):ToLuaTable()
end
function ConfigMgr:GetItemTableRows()
  return GetTableRowCached("CyItemTableRow")
end
function ConfigMgr:GetDecalTableRows()
  return GetTableRowCached("CyDecalTableRow")
end
function ConfigMgr:GetWeaponTableRows()
  return GetTableRowCached("CyWeaponTableRow")
end
function ConfigMgr:GetDayTaskTableRow()
  return GetTableRowCached("CyBattlePassDayTaskTableRow")
end
function ConfigMgr:GetWeekTaskTableRow()
  return GetTableRowCached("CyBattlePassWeekTaskTableRow")
end
function ConfigMgr:GetLoopTaskTableRow()
  return GetTableRowCached("CyBattlePassLoopTaskTableRow")
end
function ConfigMgr:GetActivityTaskTableRow()
  return GetTableRowCached("CyActivityTaskTableRow")
end
function ConfigMgr:GetTaskRefreshTableRow()
  return GetTableRowCached("CyBattlePassDayTaskRefreshTableRow")
end
function ConfigMgr:GetBattlePassPrizeTableRows()
  return GetTableRowCached("CyBattlePassPrizeTableRow")
end
function ConfigMgr:GetBattlePassBackGroudTableRows()
  return GetTableRowCached("CyBattlePassBackGroudTableRow")
end
function ConfigMgr:GetBattlePassClueTableRows()
  return GetTableRowCached("CyBattlePassClueTableRow")
end
function ConfigMgr:GetItemQualityTableRows()
  return GetTableRowCached("CyItemQualityResTableRow")
end
function ConfigMgr:GetItemIdIntervalTableRows()
  return GetTableRowCached("CyItemIdIntervalTableRow")
end
function ConfigMgr:GetCurrencyTableRows()
  return GetTableRowCached("CyCurrencyTableRow")
end
function ConfigMgr:GetParameterTableRows()
  return GetTableRowCached("CyParameterTableRow")
end
function ConfigMgr:GetRoleTableRows()
  return GetTableRowCached("CyRoleTableRow")
end
function ConfigMgr:GetRoleSkinTableRows()
  return GetTableRowCached("CyRoleSkinTableRow")
end
function ConfigMgr:GetRoleActionTableRows()
  return GetTableRowCached("CyRoleActionTableRow")
end
function ConfigMgr:GetRoleVoiceTableRows()
  return GetTableRowCached("CyRoleVoiceTableRow")
end
function ConfigMgr:GetRoleProfileTableRows()
  return GetTableRowCached("CyRoleProfileTableRow")
end
function ConfigMgr:GetRoleFavorabilityTableRows()
  return GetTableRowCached("CyRoleFavorabilityTableRow")
end
function ConfigMgr:GetRoleFavorabilityMissionTableRows()
  return GetTableRowCached("CyRoleFavorabilityMissionTableRow")
end
function ConfigMgr:GetRoleTeamTableRows()
  return GetTableRowCached("CyRoleTeamTableRow")
end
function ConfigMgr:GetRoleFavorabilityEventTableRows()
  return GetTableRowCached("CyRoleFavorabilityEventTableRow")
end
function ConfigMgr:GetRoleProfessionTableRows()
  return GetTableRowCached("CyRoleProfessionTableRow")
end
function ConfigMgr:GetRoleSkillTableRows()
  return GetTableRowCached("CySkillTableRow")
end
function ConfigMgr:GetWeaponTableRows()
  return GetTableRowCached("CyWeaponTableRow")
end
function ConfigMgr:GetMapCfgTableRows()
  return GetTableRowCached("CyMapCfgTableRow")
end
function ConfigMgr:GetFunctionUnlockTableRows()
  return GetTableRowCached("CyFunctionUnlockTableRow")
end
function ConfigMgr:GetFunctionUnlockMobileTableRows()
  return GetTableRowCached("CyFunctionUnlockMBTableRow")
end
function ConfigMgr:GetChatEmotionTableRows()
  return GetTableRowCached("CyChatEmoteTableRow")
end
function ConfigMgr:GetChatCfgTableRows()
  return GetTableRowCached("CyChatCfgTableRow"):ToLuaTable()
end
function ConfigMgr:GetEventTalkTableRows()
  return GetTableRowCached("CyEventTalkTableRow"):ToLuaTable()
end
function ConfigMgr:GetCommunicationCfgTableRows()
  return GetTableRowCached("CyCommunicationFirstLevelConfigTableRow"):ToLuaTable()
end
function ConfigMgr:GetPledgeEventTableRows()
  return GetTableRowCached("CyPledgeEventTableRow"):ToLuaTable()
end
function ConfigMgr:GetLikeability()
  return GetTableRowCached("CyLikabilityTableRow")
end
function ConfigMgr:GetPlayerLevelTableRows()
  return GetTableRowCached("CyPlayerLevelTableRow")
end
function ConfigMgr:GetGoodsTableRows()
  return GetTableRowCached("CyGoodsTableRow")
end
function ConfigMgr:GetPayTableRows()
  return GetTableRowCached("CyPayTableRow")
end
function ConfigMgr:GetRoleFxFlyingTableRows()
  return GetTableRowCached("CyFxFlyingTableRow")
end
function ConfigMgr:GetCinematicCloisterTableRows()
  return GetTableRowCached("CyCinematicCloisterTableRow")
end
function ConfigMgr:GetTipoffBehaviorTableRow()
  return GetTableRowCached("CyTipoffBehaviorTableRow")
end
function ConfigMgr:GetTipoffCategoryTableRow()
  return GetTableRowCached("CyTipoffCategoryTableRow")
end
function ConfigMgr:GetTipoffGlobalTableRow()
  return GetTableRowCached("CyTipoffGlobalTableRow")
end
function ConfigMgr:GetGrowthTableRows()
  return GetTableRowCached("CyGrowthTableRow")
end
function ConfigMgr:ClearGrowthTableRows()
  ClearTableRowCached("CyGrowthTableRow")
end
function ConfigMgr:GetGrowthSlotDescTableRows()
  return GetTableRowCached("CyGrowthSlotDescTableRow")
end
function ConfigMgr:GetGrowthPartAttributeModifierTableRows()
  return GetTableRowCached("CyGrowthPartAttributeModifierTableRow")
end
function ConfigMgr:GetPlayerIdCardTableRows()
  return GetTableRowCached("CyIdCardTableRow")
end
function ConfigMgr:GetCyMapCfgTableRows()
  return GetTableRowCached("CyMapCfgTableRow")
end
function ConfigMgr:GetRoleFavorabilityGiftPresentTableRow()
  return GetTableRowCached("CyRoleFavorabilityGiftPresentTableRow")
end
function ConfigMgr:GetApartmentMainPageGalSequenceTableRow()
  return GetTableRowCached("CyApartmentMainPageGalSequenceTableRow")
end
function ConfigMgr:GetSettingTableRow()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    return GetTableRowCached("CySettingMBTableRow")
  else
    return GetTableRowCached("CySettingTableRow")
  end
end
function ConfigMgr:GetCommonSettingConfigTableRow()
  return GetTableRowCached("CySettingConfigTableRow")
end
function ConfigMgr:GetApartmentEventTableRow()
  return GetTableRowCached("CyApartmentEventTableRow")
end
function ConfigMgr:GetLoginWelcomeVoiceTableRow()
  return GetTableRowCached("CyLoginWelcomeVoiceTableRow")
end
function ConfigMgr:GetApartmentStateMachineTableRow()
  return GetTableRowCached("CyApartmentStateMachineTableRow")
end
function ConfigMgr:GetConditionTemplateTableRow()
  return GetTableRowCached("CyConditionTemplateTableRow")
end
function ConfigMgr:GetWebUrlTableRow()
  return GetTableRowCached("CyWebUrlTableRow")
end
function ConfigMgr:GetWindingCorridorTableRow()
  return GetTableRowCached("CyWindingCorridorTableRow")
end
function ConfigMgr:GetRoleBiographyTableRow()
  return GetTableRowCached("CyRoleBiographyTableRow")
end
function ConfigMgr:GetCyGameplayActorInfoTableRow()
  return GetTableRowCached("CyGameplayActorInfoTableRow")
end
function ConfigMgr:GetCyDivisionRoomAITableRow()
  return GetTableRowCached("CyDivisionRoomAITableRow")
end
function ConfigMgr:GetNewPlayerGuideTableRow()
  return GetTableRowCached("PMNewPlayerGuideTableRow")
end
function ConfigMgr:GetReturnLetterTableRow()
  return GetTableRowCached("CyReturnLetterCfgTableRow")
end
function ConfigMgr:GetAttributeTableRow()
  return GetTableRowCached("CyAttributeTableRow")
end
function ConfigMgr:GetPledgeItemTableRow()
  return GetTableRowCached("CyPledgeItemTableRow")
end
function ConfigMgr:GetRoleEmoteTableRow()
  return GetTableRowCached("CyEmoteTableRow")
end
function ConfigMgr:GetAvgExtensionTableRow()
  return GetTableRowCached("CyAVGExtensionTableRow")
end
function ConfigMgr:GetActivityTableRow()
  return GetTableRowCached("CyActivityTableRow")
end
function ConfigMgr:GetPayDirectlyTableRow()
  return GetTableRowCached("CyPayDirectlyTableRow")
end
function ConfigMgr:GetFxWeaponTableRows()
  return GetTableRowCached("CyFxWeaponTableRow")
end
function ConfigMgr:GetCafePrivilegeTypeTableRow()
  return GetTableRowCached("CyCafePrivilegeTypeTableRow")
end
function ConfigMgr:GetLeaderboardContentDisplayControl()
  return GetTableRowCached("CyLeaderboardContentDisplayControlTableRow")
end
function ConfigMgr:GetCityCode()
  return GetTableRowCached("CyCityCodeTableRow")
end
richTextStyleTable = ConfigMgr:GetRichTextTableRows():ToLuaTable()
_G.ConfigMgr = ConfigMgr
return ConfigMgr
