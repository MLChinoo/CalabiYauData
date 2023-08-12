local RoleSettingKey = {
  RoleLikeLv = 1,
  RoleTime = 2,
  RoleBattleResult = 3,
  RoleLastRoomID = 4,
  RoleLikeLvAnim = 5
}
local EnumConditionType = {
  LoginInternalTimeCond = 1,
  UnreadEmailCond = 2,
  FriendScopeCond = 3,
  EpicSkinCond = 4,
  FirstEnterCharacterRoomCond = 5,
  EnterCharacterRoomCond = 6,
  CombatComfortCond = 7,
  LongTimeNotLogginCond = 8,
  IntimacyLvCond = 9,
  IntimacyLvAnimCond = 10,
  PromisePageIsOpenCond = 11,
  RewardNeedReceiveCond = 12,
  SincerityInteractionCond = 13,
  FlapFaceCond = 14
}
local EnumBattleAnim = {
  Invalid = 0,
  Played = 1,
  CanPlay = 2
}
local FirstGoApartmentFlag = 999
local BattleRoleID = 146
local ConditionTemplateMap
local UpdateFunc = function(conditionType)
  if nil == ConditionTemplateMap then
    ConditionTemplateMap = {}
    local data = ConfigMgr:GetConditionTemplateTableRow()
    local configTbl = data:ToLuaTable()
    for k, v in pairs(configTbl) do
      ConditionTemplateMap[k] = v
    end
  end
  conditionType = conditionType .. ""
  if nil == ConditionTemplateMap[conditionType] then
    LogInfo("ConditionTemplateMap", "conditionType:" .. conditionType .. " is nil")
  end
  if nil == ConditionTemplateMap[conditionType].LuaClass then
    LogInfo("ConditionTemplateMap", "conditionType:" .. conditionType .. "'s LuaClass is nil")
  end
  xpcall(function()
    local conditionClass = require(ConditionTemplateMap[conditionType].LuaClass)
    LogInfo("ConditionTemplateMap ", "conditionClass " .. tostring(conditionClass))
    conditionClass:Update()
  end, function(err)
    LogInfo("ConditionTemplateMap", tostring(err))
  end)
end
local CheckFunc = function(conditionType, paramStr)
  paramStr = paramStr or ""
  return UE4.UCyConditionGameInstanceSubsystem.Get(LuaGetWorld()):IsMatchCondition(conditionType, paramStr)
end
local Map = {
  RoleSettingKey = RoleSettingKey,
  EnumBattleAnim = EnumBattleAnim,
  FirstGoApartmentFlag = FirstGoApartmentFlag,
  BattleRoleID = BattleRoleID,
  EnumConditionType = EnumConditionType,
  UpdateFunc = UpdateFunc,
  CheckFunc = CheckFunc
}
return Map
