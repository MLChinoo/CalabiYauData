local UpdateBattleDataCmd = class("UpdateBattleDataCmd", PureMVC.Command)
local MaxDisplayDataNum = 7
local MaxHitsNum = 99
local MaxDamageNum = 999
function UpdateBattleDataCmd:Execute(notification)
  GameFacade:SendNotification(NotificationDefines.BattleData.UpdatePanelRecvMediator, self:GetBattleData(notification.body))
end
function UpdateBattleDataCmd:GetBattleData(UObject)
  local TempRecData = {}
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local DamageList = GameFacade:RetrieveProxy(ProxyNames.BattleDataProxy):GetBattleReportComponent(UObject)
  LogDebug("Lua", "UpdateBattleDataCmd:GetBattleData : DamageLength = " .. DamageList:Length())
  if DamageList then
    for index = 1, DamageList:Length() do
      local ReplyInfo = DamageList:Get(index)
      local EnemyRoleSkin
      if ReplyInfo.EnemySkinId and 0 ~= ReplyInfo.EnemySkinId then
        EnemyRoleSkin = RoleProxy:GetRoleSkin(ReplyInfo.EnemySkinId)
      else
        EnemyRoleSkin = RoleProxy:GetRoleSkin(ReplyInfo.SelfSkinId)
      end
      local PlayerRoleSkin = RoleProxy:GetRoleSkin(ReplyInfo.SelfSkinId)
      if ReplyInfo.DetailedBattleReportList:Length() <= 0 then
      else
        local LastDamageInfo = ReplyInfo.DetailedBattleReportList:Get(ReplyInfo.DetailedBattleReportList:Length())
        if nil == LastDamageInfo then
        else
          local TotalDamageInfo = ReplyInfo.DetailedTotalData
          local InData = {
            EnemyAvatar = EnemyRoleSkin and EnemyRoleSkin.IconRoleScoreboard,
            PlayerAvatar = PlayerRoleSkin and PlayerRoleSkin.IconRoleScoreboard,
            PlayerIsDead = ReplyInfo.bIsKill,
            DamagerName = ReplyInfo.EnemyRoleName,
            DamagerType = ReplyInfo.DamageRelation,
            bHitBodyPartsWeapon = LastDamageInfo.bHitBodyPartsWeapon,
            DamageOriginType = LastDamageInfo.DamageOriginType,
            PlayerWeaponType = LastDamageInfo.PlayerWeaponType,
            PlayerSkillType = LastDamageInfo.PlayerSkillType,
            SystemWeaponType = LastDamageInfo.SystemWeaponType,
            HitTime = LastDamageInfo.DamageTime,
            WeaponImage = self:GetWeaponIcon(LastDamageInfo.DamageOriginType, LastDamageInfo.PlayerWeaponType, LastDamageInfo.WeaponId, LastDamageInfo.TextureIcon),
            HitNumsOfHead = math.clamp(math.modf(TotalDamageInfo.TotalHeadDamage), 0, MaxDamageNum),
            HitNumsOfBody = math.clamp(math.modf(TotalDamageInfo.TotalBodyDamage), 0, MaxDamageNum),
            HitNumsOfFoot = math.clamp(math.modf(TotalDamageInfo.TotalLegDamage), 0, MaxDamageNum),
            TotalDamage = math.clamp(math.modf(TotalDamageInfo.TotalDamage), 0, MaxDamageNum)
          }
          InData.SecondaryList = {}
          LogDebug("Lua", "UpdateBattleDataCmd:SecondaryListLength = " .. ReplyInfo.DetailedBattleReportList:Length() .. "----Num:" .. index)
          for i = 1, ReplyInfo.DetailedBattleReportList:Length() do
            local CurDamageInfo = ReplyInfo.DetailedBattleReportList:Get(i)
            local InInData = {
              DamageOriginType = CurDamageInfo.DamageOriginType,
              PlayerWeaponType = CurDamageInfo.PlayerWeaponType,
              PlayerSkillType = CurDamageInfo.PlayerSkillType,
              SystemWeaponType = CurDamageInfo.SystemWeaponType,
              WeaponImage = self:GetWeaponIcon(CurDamageInfo.DamageOriginType, LastDamageInfo.PlayerWeaponType, CurDamageInfo.WeaponId, CurDamageInfo.TextureIcon),
              bHitBodyPartsWeapon = CurDamageInfo.bHitBodyPartsWeapon,
              HitNumsOfHead = math.clamp(math.modf(CurDamageInfo.HeadHitDamage), 0, MaxDamageNum),
              HitNumsOfBody = math.clamp(math.modf(CurDamageInfo.BodyHitDamage), 0, MaxDamageNum),
              HitNumsOfFoot = math.clamp(math.modf(CurDamageInfo.LegHitDamage), 0, MaxDamageNum),
              TotalDamage = math.clamp(math.modf(CurDamageInfo.Damage), 0, MaxDamageNum),
              OriginTotalDamage = CurDamageInfo.Damage,
              TotalHitNums = math.clamp(math.modf(CurDamageInfo.NotBodyPartsHitNum), 0, MaxHitsNum),
              HitTime = CurDamageInfo.DamageTime
            }
            table.insert(InData.SecondaryList, InInData)
          end
          table.sort(InData.SecondaryList, function(a, b)
            if a.OriginTotalDamage > b.OriginTotalDamage then
              return true
            end
            return false
          end)
          table.insert(TempRecData, InData)
        end
      end
    end
    table.sort(TempRecData, function(a, b)
      if a.HitTime > b.HitTime then
        return true
      end
      return false
    end)
  end
  local RecData = {}
  for i = 1, table.count(TempRecData or {}) do
    RecData[i] = TempRecData[i]
    if i == MaxDisplayDataNum then
      break
    end
  end
  return RecData
end
function UpdateBattleDataCmd:GetWeaponIcon(DamageOriginType, PlayerWeaponType, TypeId, SkillTag)
  if DamageOriginType == UE4.ECyDamageOriginType.Weapon then
    if PlayerWeaponType == UE4.ECyPlayerWeaponType.C4 then
      return SkillTag
    else
      local Weapon = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetWeapon(TypeId)
      return Weapon and Weapon.IconHud
    end
  end
  if DamageOriginType == UE4.ECyDamageOriginType.Skill then
    return SkillTag
  end
end
return UpdateBattleDataCmd
