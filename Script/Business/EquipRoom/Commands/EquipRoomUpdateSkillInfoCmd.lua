local EquipRoomUpdateSkillInfoCmd = class("EquipRoomUpdateSkillInfoCmd", PureMVC.Command)
function EquipRoomUpdateSkillInfoCmd:Execute(notification)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local skillDataMap = {}
  local roleData = roleProxy:GetRole(notification.body)
  if roleData then
    local activeSkillID = roleData.SkillActive:Get(1)
    local activeSkillTableData = roleProxy:GetRoleSkill(activeSkillID)
    if activeSkillTableData then
      self:GetSkilData(activeSkillTableData, skillDataMap)
    else
      LogError("EquipRoomUpdateSkillInfoCmd", "技能（技能ID：%s）为空，请找策划，", activeSkillID)
      return
    end
    local passiveSkillID = roleData.SkillPassive:Get(1)
    local passiveSkillTableData = roleProxy:GetRoleSkill(passiveSkillID)
    if passiveSkillTableData then
      self:GetSkilData(passiveSkillTableData, skillDataMap)
    else
      LogError("EquipRoomUpdateSkillInfoCmd", "技能（技能ID：%s）为空，请找策划，", passiveSkillID)
      return
    end
    local ultimateSkillID = roleData.SkillUltimate:Get(1)
    local ultimateSkillTableData = roleProxy:GetRoleSkill(ultimateSkillID)
    if ultimateSkillTableData then
      self:GetSkilData(ultimateSkillTableData, skillDataMap)
    else
      LogError("EquipRoomUpdateSkillInfoCmd", "技能（技能ID：%s）为空，请找策划，", ultimateSkillID)
      return
    end
  end
  LogDebug("EquipRoomUpdateSkillInfoCmd", "EquipRoomUpdateSkillInfoCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateSkillInfo, skillDataMap)
end
function EquipRoomUpdateSkillInfoCmd:GetSkilData(skillTableData, skillDataMap)
  local skillData = {}
  if skillTableData then
    skillData.skillTexture = skillTableData.IconSkill
    skillData.skillName = skillTableData.Name
    skillData.skillDesc = skillTableData.Intro
    skillData.skillTypeName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "SkillTypeName_" .. skillTableData.SkillType)
    local inputKey
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform ~= GlobalEnumDefine.EPlatformType.Mobile then
      if skillTableData.SkillType == GlobalEnumDefine.ERoleSkillType.Active then
        inputKey = self:GetSkilKeyName("SkillQ")
      elseif skillTableData.SkillType == GlobalEnumDefine.ERoleSkillType.Unique then
        inputKey = self:GetSkilKeyName("SkillX")
      else
        inputKey = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PassiveSkillKeyName")
      end
      skillData.keyName = inputKey
    end
  end
  skillDataMap[skillTableData.SkillType] = skillData
end
function EquipRoomUpdateSkillInfoCmd:GetSkilKeyName(keyName)
  local settingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local key1, key2 = settingInputUtilProxy:GetKeyByInputName(keyName)
  if key1 and 0 ~= string.len(key1) then
    return key1
  else
    return key2
  end
end
return EquipRoomUpdateSkillInfoCmd
