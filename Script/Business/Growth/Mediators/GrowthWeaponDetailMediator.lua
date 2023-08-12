local GrowthWeaponDetailMediator = class("GrowthWeaponDetailMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local GrowthDefine = require("Business/Growth/Proxies/GrowthDefine")
function GrowthWeaponDetailMediator:ListNotificationInterests()
  return {
    NotificationDefines.Growth.GrowthWeaponDetailUpdateCmd
  }
end
function GrowthWeaponDetailMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Growth.GrowthWeaponDetailUpdateCmd then
    self:UpdateView(false, body)
  end
end
function GrowthWeaponDetailMediator:OnRegister()
  self:UpdateView(true)
end
function GrowthWeaponDetailMediator:IsFloatProperty(PropertyName)
  for key, value in pairs(GrowthDefine.PropertyFloatNames) do
    if value == PropertyName then
      return true
    end
  end
  return false
end
function GrowthWeaponDetailMediator:UpdateView(isInit, isPreview)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local RoleId = MyPlayerState.SelectRoleId
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local Slot = GrowthProxy:GetSelectSlot()
  local CurrentLevel = GrowthProxy:GetGrowthLv(MyPlayerState, Slot)
  local SlotNextLevel = CurrentLevel + 1
  local MaxLevel = GrowthProxy:GetGrowthSlotLvMax(RoleId, Slot)
  local GrowthTableRow = GrowthProxy:GetGrowthRow(RoleId)
  local bShowNextLevelAddInfo = SlotNextLevel <= MaxLevel
  local IsSingleSelect = GrowthProxy:IsSingleSelect(RoleId, Slot)
  if IsSingleSelect then
    SlotNextLevel = GrowthProxy:GetSelectSlotLv()
    if CurrentLevel == SlotNextLevel then
      bShowNextLevelAddInfo = false
    else
      bShowNextLevelAddInfo = true
    end
  end
  if not isPreview then
    bShowNextLevelAddInfo = false
  end
  local PartsPropertySlotNextLevel = GrowthProxy:GetPartProperty(RoleId, Slot, SlotNextLevel)
  local GrowthDetailData = {}
  GrowthDetailData.SlotType = Slot
  for key, PropertyName in pairs(GrowthDefine.PropertyNames1Simulant) do
    local BaseValue = GrowthProxy:GetPropertyDefault(RoleId, PropertyName)
    local PartsProperty = GrowthProxy:GetPartsProperty(MyPlayerState, RoleId, PropertyName, BaseValue)
    local FullValue = GrowthProxy:GetPropertyMax(RoleId, PropertyName)
    local CurValue = BaseValue + (PartsProperty[PropertyName] or 0)
    local NextValue = CurValue
    if bShowNextLevelAddInfo then
      local PartsPropertyExcludeSlot = GrowthProxy:GetPartsPropertyExcludeSlot(MyPlayerState, RoleId, PropertyName, BaseValue, Slot)
      local NextChangeValue = GrowthProxy:GetPropertyChangeValue(PartsPropertySlotNextLevel, BaseValue, PropertyName, RoleId)
      NextValue = BaseValue + (PartsPropertyExcludeSlot[PropertyName] or 0) + (NextChangeValue or 0)
    end
    local MaxValue = GrowthProxy:GetPropertyMax(RoleId, PropertyName)
    if self:IsFloatProperty(PropertyName) then
      BaseValue = string.format("%.2f", BaseValue)
      CurValue = string.format("%.2f", CurValue)
      NextValue = string.format("%.2f", NextValue)
      BaseValue = tonumber(BaseValue)
      CurValue = tonumber(CurValue)
      NextValue = tonumber(NextValue)
    else
      BaseValue = math.floor(BaseValue)
      CurValue = math.floor(CurValue)
      NextValue = math.floor(NextValue)
    end
    local BasePercent = 1.0 * BaseValue / MaxValue
    local FullLevelPercent = 1.0 * FullValue / MaxValue
    local Percent = 1.0 * CurValue / MaxValue
    local NextLevelPercent = 1.0 * NextValue / MaxValue
    GrowthDetailData[PropertyName] = {}
    GrowthDetailData[PropertyName].InBaseNum = BaseValue
    GrowthDetailData[PropertyName].InNum = CurValue
    GrowthDetailData[PropertyName].InNextLevelNum = NextValue
    GrowthDetailData[PropertyName].InPercent = Percent
    GrowthDetailData[PropertyName].InBasePercent = BasePercent
    GrowthDetailData[PropertyName].InFullLevelPercent = FullLevelPercent
    GrowthDetailData[PropertyName].InNextLevenPercent = NextLevelPercent
    GrowthDetailData[PropertyName].PropertyName = PropertyName
  end
  for key, PropertyName in ipairs(GrowthDefine.PropertyNames3Simulant) do
    local BaseValue = GrowthProxy:GetPropertyDefault(RoleId, PropertyName)
    if BaseValue then
      local PartsProperty = GrowthProxy:GetPartsProperty(MyPlayerState, RoleId, PropertyName, BaseValue)
      local CurValue = BaseValue + (PartsProperty[PropertyName] or 0)
      local NextValue = CurValue
      if bShowNextLevelAddInfo then
        local PartsPropertyExcludeSlot = GrowthProxy:GetPartsPropertyExcludeSlot(MyPlayerState, RoleId, PropertyName, BaseValue, Slot)
        local NextChangeValue = GrowthProxy:GetPropertyChangeValue(PartsPropertySlotNextLevel, BaseValue, PropertyName, RoleId)
        NextValue = BaseValue + (PartsPropertyExcludeSlot[PropertyName] or 0) + (NextChangeValue or 0)
      end
      if self:IsFloatProperty(PropertyName) then
        BaseValue = string.format("%.2f", BaseValue)
        CurValue = string.format("%.2f", CurValue)
        NextValue = string.format("%.2f", NextValue)
        BaseValue = tonumber(BaseValue)
        CurValue = tonumber(CurValue)
        NextValue = tonumber(NextValue)
      else
        BaseValue = math.floor(BaseValue)
        CurValue = math.floor(CurValue)
        NextValue = math.floor(NextValue)
      end
      GrowthDetailData[PropertyName] = {}
      GrowthDetailData[PropertyName].InBaseNum = BaseValue
      GrowthDetailData[PropertyName].InNum = CurValue
      GrowthDetailData[PropertyName].InNextLevelNum = NextValue
      GrowthDetailData[PropertyName].PropertyName = PropertyName
    end
  end
  local currentWeaponInfo = UE4.FWeaponInfoDisplay()
  local previewWeaponInfo = UE4.FWeaponInfoDisplay()
  local weapon = self.viewComponent:K2_GetWeaponBySlot()
  if weapon then
    if not isInit and not isPreview and 0 == CurrentLevel then
      SlotNextLevel = 0
    end
    local strPre = isInit and "Init" or isPreview or "CallBack"
    LogDebug("GetWeaponAttributes", "Slot = " .. Slot .. " CurrentLevel = " .. CurrentLevel .. " SlotNextLevel = " .. SlotNextLevel)
    LogDebug("GetWeaponAttributes", "Source = " .. strPre)
    local isSuccess = weapon:GetWeaponAttributesDisplay(GrowthDefine.Mapping[Slot], SlotNextLevel, currentWeaponInfo, previewWeaponInfo)
    if isSuccess then
      local dump_array = function(array)
        local ret = {}
        for i = 1, array:Length() do
          table.insert(ret, array:Get(i))
        end
        return "[" .. table.concat(ret, ",") .. "]"
      end
      if currentWeaponInfo.HeadDamages then
        LogDebug("GetWeaponAttributes", "current Head:" .. dump_array(currentWeaponInfo.HeadDamages))
      end
      if currentWeaponInfo.BodyDamages then
        LogDebug("GetWeaponAttributes", "current Body:" .. dump_array(currentWeaponInfo.BodyDamages))
      end
      if currentWeaponInfo.LowBodyDamages then
        LogDebug("GetWeaponAttributes", "current LowBody:" .. dump_array(currentWeaponInfo.LowBodyDamages))
      end
      LogDebug("GetWeaponAttributes", "current Capacity:" .. currentWeaponInfo.MagazineCapacity)
      LogDebug("GetWeaponAttributes", "current AttackDuration:" .. currentWeaponInfo.AttackDuration)
      LogDebug("GetWeaponAttributes", "current AttackCount:" .. currentWeaponInfo.AttackCount)
      if previewWeaponInfo.HeadDamages then
        LogDebug("GetWeaponAttributes", "next Head:" .. dump_array(previewWeaponInfo.HeadDamages))
      end
      if previewWeaponInfo.BodyDamages then
        LogDebug("GetWeaponAttributes", "next Body:" .. dump_array(previewWeaponInfo.BodyDamages))
      end
      if previewWeaponInfo.LowBodyDamages then
        LogDebug("GetWeaponAttributes", "next LowBody:" .. dump_array(previewWeaponInfo.LowBodyDamages))
      end
      LogDebug("GetWeaponAttributes", "next Capacity:" .. previewWeaponInfo.MagazineCapacity)
      LogDebug("GetWeaponAttributes", "next AttackDuration:" .. previewWeaponInfo.AttackDuration)
      LogDebug("GetWeaponAttributes", "next AttackCount:" .. previewWeaponInfo.AttackCount)
      local currentActualProperty = {}
      currentActualProperty[GrowthDefine.PropertyNames1Actual.ShootSpeed] = GrowthProxy:GetAttackSpeedByTotalDuration(RoleId, currentWeaponInfo.AttackDuration)
      currentActualProperty[GrowthDefine.PropertyNames1Actual.MagazineCapacity] = currentWeaponInfo.MagazineCapacity
      local previewActualProperty = {}
      previewActualProperty[GrowthDefine.PropertyNames1Actual.ShootSpeed] = GrowthProxy:GetAttackSpeedByTotalDuration(RoleId, previewWeaponInfo.AttackDuration)
      previewActualProperty[GrowthDefine.PropertyNames1Actual.MagazineCapacity] = previewWeaponInfo.MagazineCapacity
      for key, PropertyName in pairs(GrowthDefine.PropertyNames1Actual) do
        local BaseValue = GrowthProxy:GetPropertyDefault(RoleId, PropertyName)
        local FullValue = GrowthProxy:GetPropertyMax(RoleId, PropertyName)
        local CurValue = currentActualProperty[PropertyName]
        if not isInit and not isPreview then
          CurValue = previewActualProperty[PropertyName]
        end
        local NextValue = CurValue
        if bShowNextLevelAddInfo then
          NextValue = previewActualProperty[PropertyName]
        end
        BaseValue = math.floor(BaseValue)
        CurValue = math.floor(CurValue)
        NextValue = math.floor(NextValue)
        local BasePercent = 1.0 * BaseValue / FullValue
        local FullLevelPercent = 1.0
        local Percent = 1.0 * CurValue / FullValue
        local NextLevelPercent = 1.0 * NextValue / FullValue
        GrowthDetailData[PropertyName] = {}
        GrowthDetailData[PropertyName].InBaseNum = BaseValue
        GrowthDetailData[PropertyName].InNum = CurValue
        GrowthDetailData[PropertyName].InNextLevelNum = NextValue
        GrowthDetailData[PropertyName].InPercent = Percent
        GrowthDetailData[PropertyName].InBasePercent = BasePercent
        GrowthDetailData[PropertyName].InFullLevelPercent = FullLevelPercent
        GrowthDetailData[PropertyName].InNextLevenPercent = NextLevelPercent
        GrowthDetailData[PropertyName].PropertyName = PropertyName
      end
      local currentDamage = {}
      for i = 1, currentWeaponInfo.HeadDamages:Length() do
        table.insert(currentDamage, currentWeaponInfo.HeadDamages:Get(i))
      end
      for i = 1, currentWeaponInfo.BodyDamages:Length() do
        table.insert(currentDamage, currentWeaponInfo.BodyDamages:Get(i))
      end
      for i = 1, currentWeaponInfo.LowBodyDamages:Length() do
        table.insert(currentDamage, currentWeaponInfo.LowBodyDamages:Get(i))
      end
      local previewDamage = {}
      for i = 1, previewWeaponInfo.HeadDamages:Length() do
        table.insert(previewDamage, previewWeaponInfo.HeadDamages:Get(i))
      end
      for i = 1, previewWeaponInfo.BodyDamages:Length() do
        table.insert(previewDamage, previewWeaponInfo.BodyDamages:Get(i))
      end
      for i = 1, previewWeaponInfo.LowBodyDamages:Length() do
        table.insert(previewDamage, previewWeaponInfo.LowBodyDamages:Get(i))
      end
      GrowthDetailData.DamageInfos = {}
      for index = 1, #GrowthDefine.PropertyNames2 do
        local BaseValue = GrowthProxy:GetPropertyDefault(RoleId, GrowthDefine.PropertyNames2[index])
        local CurValue = currentDamage[index]
        if not isInit and not isPreview then
          CurValue = previewDamage[index]
        end
        local NextValue = CurValue
        if bShowNextLevelAddInfo then
          NextValue = previewDamage[index]
        end
        BaseValue = math.floor(BaseValue)
        CurValue = math.floor(CurValue)
        NextValue = math.floor(NextValue)
        local DamageInfo = {}
        DamageInfo.InBaseNum = BaseValue
        DamageInfo.InNum = CurValue
        DamageInfo.InNextLevelNum = NextValue
        DamageInfo.PropertyName = GrowthDefine.PropertyNames2[index]
        table.insert(GrowthDetailData.DamageInfos, DamageInfo)
      end
      local BaseValue = GrowthProxy:GetPropertyDefault(RoleId, GrowthDefine.PropertyNames3Actual[1])
      if BaseValue > 1 then
        local CurValue = currentWeaponInfo.AttackCount
        if not isInit and not isPreview then
          CurValue = previewWeaponInfo.AttackCount
        end
        local NextValue = CurValue
        if bShowNextLevelAddInfo then
          NextValue = previewWeaponInfo.AttackCount
        end
        BaseValue = math.floor(BaseValue)
        CurValue = math.floor(CurValue)
        NextValue = math.floor(NextValue)
        GrowthDetailData[GrowthDefine.PropertyNames3Actual[1]] = {}
        GrowthDetailData[GrowthDefine.PropertyNames3Actual[1]].InBaseNum = BaseValue
        GrowthDetailData[GrowthDefine.PropertyNames3Actual[1]].InNum = CurValue
        GrowthDetailData[GrowthDefine.PropertyNames3Actual[1]].InNextLevelNum = NextValue
        GrowthDetailData[GrowthDefine.PropertyNames3Actual[1]].PropertyName = GrowthDefine.PropertyNames3Actual[1]
      end
    end
  end
  GrowthDetailData.AssistShoot = GrowthTableRow.AssistShoot
  GrowthDetailData.GunFeature = GrowthTableRow.GunFeature
  self.viewComponent:Update(GrowthDetailData)
end
return GrowthWeaponDetailMediator
