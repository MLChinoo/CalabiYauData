local GrowthProxy = class("GrowthProxy", PureMVC.Proxy)
local GrowthDefine = require("Business/Growth/Proxies/GrowthDefine")
local growthCfg = {}
local growthPartAttributeModifierCfg = {}
local TableCfgInited = false
local PropertyDefault = {}
local PropertyMax = {}
local PartProperty = {}
function GrowthProxy:OnRegister()
  if not self.registered then
    GrowthProxy.super.OnRegister(self)
    self.SelectSlot = UE4.EGrowthSlotType.Max
    self.SelectSlotLv = 0
    self.FlyEffectExist = false
    self.registered = true
    self.Property = {}
  end
end
function GrowthProxy:OnRemove()
  GrowthProxy.super.OnRemove(self)
  self:ClearData()
  self.FlyEffectExist = false
  self.registered = nil
  self.Property = {}
end
function GrowthProxy:SetSelectSlot(Slot)
  self.SelectSlot = Slot
end
function GrowthProxy:SetSelectSlotLv(SlotLv)
  self.SelectSlotLv = SlotLv
end
function GrowthProxy:GetSelectSlot()
  return self.SelectSlot
end
function GrowthProxy:GetSelectSlotLv()
  return self.SelectSlotLv
end
function GrowthProxy:ClearData()
  TableCfgInited = false
end
function GrowthProxy:InitGrowthTableCfg()
  if not TableCfgInited then
    ConfigMgr:ClearGrowthTableRows()
    local arrRows = ConfigMgr:GetGrowthTableRows()
    if arrRows then
      growthCfg = arrRows:ToLuaTable()
    end
    arrRows = ConfigMgr:GetGrowthPartAttributeModifierTableRows()
    if arrRows then
      growthPartAttributeModifierCfg = arrRows:ToLuaTable()
    end
    TableCfgInited = true
  end
end
function GrowthProxy:GetGrowthCfg()
  self.InitGrowthTableCfg()
  return growthCfg
end
function GrowthProxy:GetPropertyDefault(RoleId, PropertyName)
  if not PropertyDefault[RoleId] then
    PropertyDefault[RoleId] = {}
    local Cfg = self:GetGrowthRow(RoleId)
    for i = 1, Cfg.DefaultProperty1:Length() do
      local properties = string.split(Cfg.DefaultProperty1[i], "|")
      local name = properties[1]
      local value = properties[2]
      PropertyDefault[RoleId][name] = tonumber(value)
      if not PropertyDefault[RoleId][name] then
        PropertyDefault[RoleId][name] = 0
        LogError("成长表属性配置错误", "roleId[%s]", RoleId)
      end
    end
    local weapon = self:GetWeaponBaseAttributes()
    if weapon then
      local weight = Cfg.AttackSpeedWeight or 1
      local threeDuration = weapon.AttackDuration - weapon.AttackDuration % 0.001
      local baseValue = weight * 100 / (self:GetPropertyMax(RoleId, GrowthDefine.PropertyNames1Actual.ShootSpeed) * threeDuration)
      PropertyDefault[RoleId][GrowthDefine.PropertyNames1Actual.ShootSpeed] = baseValue
      PropertyDefault[RoleId][GrowthDefine.PropertyNames1Actual.MagazineCapacity] = weapon.MagazineCapacity
      PropertyDefault[RoleId][GrowthDefine.PropertyNames3[5]] = weapon.AttackCount
      local ret = {}
      for i = 1, weapon.HeadDamages:Length() do
        table.insert(ret, weapon.HeadDamages:Get(i))
      end
      for i = 1, weapon.BodyDamages:Length() do
        table.insert(ret, weapon.BodyDamages:Get(i))
      end
      for i = 1, weapon.LowBodyDamages:Length() do
        table.insert(ret, weapon.LowBodyDamages:Get(i))
      end
      for index = 1, #GrowthDefine.PropertyNames2 do
        PropertyDefault[RoleId][GrowthDefine.PropertyNames2[index]] = ret[index]
      end
    end
    for i = 1, Cfg.DefaultProperty3:Length() do
      local properties = string.split(Cfg.DefaultProperty3[i], "|")
      local name = properties[1]
      local value = properties[2]
      PropertyDefault[RoleId][name] = tonumber(value)
      if not PropertyDefault[RoleId][name] then
        PropertyDefault[RoleId][name] = 0
        LogError("成长表属性配置错误", "roleId[%s]", RoleId)
      end
    end
  end
  return PropertyDefault[RoleId][PropertyName]
end
function GrowthProxy:GetPropertyMax(RoleId, PropertyName)
  if not PropertyMax[RoleId] then
    PropertyMax[RoleId] = {}
    local Cfg = self:GetGrowthRow(RoleId)
    for i = 1, Cfg.DefaultProperty1:Length() do
      local properties = string.split(Cfg.DefaultProperty1[i], "|")
      local name = properties[1]
      local value = properties[3]
      PropertyMax[RoleId][name] = tonumber(value)
      if not PropertyMax[RoleId][name] then
        PropertyMax[RoleId][name] = 0
        LogError("成长表属性配置错误", "roleId[%s]", RoleId)
      end
    end
  end
  return PropertyMax[RoleId][PropertyName]
end
function GrowthProxy:GetPartProperty(RoleId, SlotType, Level)
  PartProperty = {}
  local PartName
  if SlotType == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    PartName = "Part1Level"
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Sight then
    PartName = "Part2Level"
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Magazine then
    PartName = "Part4Level"
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    PartName = "Part5Level"
  end
  PartName = PartName and PartName .. Level
  local Cfg = self:GetGrowthRow(RoleId)
  if Cfg[PartName] then
    for i = 1, Cfg[PartName]:Length() do
      local properties = string.split(Cfg[PartName][i], "|")
      if #properties > 0 then
        local name = properties[1]
        if not name then
          LogError("成长表属性配置错误", "roleId[%s]", RoleId)
        end
        local multiKey = self:GetPropertyMultiKey(name)
        local value = properties[2]
        local values = string.split(value, "*")
        if #values >= 2 then
          PartProperty[name] = tonumber(values[2])
          PartProperty[multiKey] = true
        else
          PartProperty[name] = tonumber(values[1])
          PartProperty[multiKey] = false
        end
        if not PartProperty[name] then
          PartProperty[name] = 0
          LogError("成长表属性配置错误", "roleId[%s]", RoleId)
        end
      end
    end
  end
  return PartProperty
end
function GrowthProxy:GetPropertyMultiKey(PropertyName)
  return PropertyName .. "_symbol"
end
function GrowthProxy:GetPartsProperty(PlayerState, RoleId, PropertyName, BaseValue)
  local PartProperties = {}
  local SlotTypes = {
    UE4.EGrowthSlotType.WeaponPart_Muzzle,
    UE4.EGrowthSlotType.WeaponPart_Sight,
    UE4.EGrowthSlotType.WeaponPart_Magazine,
    UE4.EGrowthSlotType.WeaponPart_ButtStock
  }
  for key, Slot in pairs(SlotTypes) do
    local Property = self:GetPartProperty(RoleId, Slot, self:GetGrowthLv(PlayerState, Slot))
    if Property[PropertyName] then
      local ChangeValue = self:GetPropertyChangeValue(Property, BaseValue, PropertyName, RoleId)
      if PartProperties[PropertyName] then
        PartProperties[PropertyName] = PartProperties[PropertyName] + ChangeValue
      else
        PartProperties[PropertyName] = ChangeValue
      end
    end
  end
  return PartProperties
end
function GrowthProxy:GetPartsPropertyExcludeSlot(PlayerState, RoleId, PropertyName, BaseValue, ExcludeSlotType)
  local PartProperties = {}
  local SlotTypes = {
    UE4.EGrowthSlotType.WeaponPart_Muzzle,
    UE4.EGrowthSlotType.WeaponPart_Sight,
    UE4.EGrowthSlotType.WeaponPart_Magazine,
    UE4.EGrowthSlotType.WeaponPart_ButtStock
  }
  for key, Slot in pairs(SlotTypes) do
    if Slot ~= ExcludeSlotType then
      local Property = self:GetPartProperty(RoleId, Slot, self:GetGrowthLv(PlayerState, Slot))
      if Property[PropertyName] then
        local ChangeValue = self:GetPropertyChangeValue(Property, BaseValue, PropertyName, RoleId)
        if PartProperties[PropertyName] then
          PartProperties[PropertyName] = PartProperties[PropertyName] + ChangeValue
        else
          PartProperties[PropertyName] = ChangeValue
        end
      end
    end
  end
  return PartProperties
end
function GrowthProxy:GetPropertyChangeValue(Property, BaseValue, PropertyName, RoleId)
  if not PropertyName then
    LogError("成长表属性配置错误", "roleId[%s]", RoleId)
  end
  local multiKey = self:GetPropertyMultiKey(PropertyName)
  local ChangeValue
  if Property[multiKey] then
    ChangeValue = BaseValue * Property[PropertyName]
  else
    ChangeValue = Property[PropertyName]
  end
  return ChangeValue
end
function GrowthProxy:GetGrowthRow(roleId)
  local Cfg = self:GetGrowthCfg()
  local row = Cfg[tostring(roleId)]
  if not row then
    LogError("gowth table config error", "roleId[%s] not found!", roleId)
  end
  return row
end
function GrowthProxy:GetWeaponTableRowByRoleId(RoleId)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local WeaponId = RoleProxy:GetRole(RoleId).DefaultWeapon1
  local WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  return WeaponProxy:GetWeapon(WeaponId)
end
function GrowthProxy:GetGrowthSlotLvMax(roleId, slotType)
  local growthRow = self:GetGrowthRow(roleId)
  local lvMax = 0
  if slotType == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    lvMax = growthRow.Parts1Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Sight then
    lvMax = growthRow.Parts2Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Grip then
    lvMax = growthRow.Parts3Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Magazine then
    lvMax = growthRow.Parts4Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    lvMax = growthRow.Parts5Max
  elseif slotType == UE4.EGrowthSlotType.QSkill then
    lvMax = growthRow.QMax
  elseif slotType == UE4.EGrowthSlotType.PassiveSkill then
    lvMax = growthRow.PassiveMax
  elseif slotType == UE4.EGrowthSlotType.Shield then
    lvMax = growthRow.ShieldMax
  elseif slotType == UE4.EGrowthSlotType.Survive then
    lvMax = growthRow.SurviveMax
  end
  return lvMax
end
function GrowthProxy:GetGrowthPartSlotName(roleId, slotType)
  local growthRow = self:GetGrowthRow(roleId)
  local name = ""
  if slotType == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    name = growthRow.PartName:Get(1)
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Sight then
    name = growthRow.PartName:Get(2)
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Magazine then
    name = growthRow.PartName:Get(3)
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    name = growthRow.PartName:Get(4)
  end
  return name
end
function GrowthProxy:GetGrowthSlotSubItemNum(roleId, slotType)
  local growthRow = self:GetGrowthRow(roleId)
  local lvMax = 0
  if slotType == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    lvMax = growthRow.Parts1Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Sight then
    lvMax = growthRow.Parts2Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Grip then
    lvMax = growthRow.Parts3Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_Magazine then
    lvMax = growthRow.Parts4Max
  elseif slotType == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    lvMax = growthRow.Parts5Max
  elseif slotType == UE4.EGrowthSlotType.QSkill then
    lvMax = growthRow.QMax
  elseif slotType == UE4.EGrowthSlotType.PassiveSkill then
    lvMax = growthRow.PassiveMax
  elseif slotType == UE4.EGrowthSlotType.Shield then
    lvMax = growthRow.ShieldMax
  elseif slotType == UE4.EGrowthSlotType.Survive then
    lvMax = growthRow.SurviveMax
  end
  return lvMax
end
function GrowthProxy:GetGrowthSlotCost(RoleId, SlotType, Lv)
  Lv = Lv and Lv or 0
  local growthRow = self:GetGrowthRow(RoleId)
  local Needs
  if SlotType == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    Needs = growthRow.Parts1Need
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Sight then
    Needs = growthRow.Parts2Need
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Grip then
    Needs = growthRow.Parts3Need
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Magazine then
    Needs = growthRow.Parts4Need
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    Needs = growthRow.Parts5Need
  elseif SlotType == UE4.EGrowthSlotType.QSkill then
    Needs = growthRow.QNeed
  elseif SlotType == UE4.EGrowthSlotType.PassiveSkill then
    Needs = growthRow.PassiveNeed
  elseif SlotType == UE4.EGrowthSlotType.Shield then
    Needs = growthRow.ShieldNeed
  elseif SlotType == UE4.EGrowthSlotType.Survive then
    Needs = growthRow.SurviveNeed
  end
  if Needs and Lv <= self:GetGrowthSlotLvMax(RoleId, SlotType) then
    return Needs:Get(Lv)
  end
  return 0
end
function GrowthProxy:GetGrowthItemDesc(RoleId, SlotType, Lv)
  Lv = Lv and Lv or 0
  local growthRow = self:GetGrowthRow(RoleId)
  local Descs
  if SlotType == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    Descs = growthRow.Part1Desc
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Sight then
    Descs = growthRow.Part2Desc
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_Magazine then
    Descs = growthRow.Part4Desc
  elseif SlotType == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    Descs = growthRow.Part5Desc
  end
  if Descs and Lv <= self:GetGrowthSlotLvMax(RoleId, SlotType) then
    return Descs:Get(Lv)
  end
  return ""
end
function GrowthProxy:IsSkillSlot(Slot)
  return Slot >= UE4.EGrowthSlotType.QSkill and Slot <= UE4.EGrowthSlotType.PassiveSkill
end
function GrowthProxy:IsRecommendSlot(PlayerState, Slot)
  local Row = self:GetGrowthRow(PlayerState.SelectRoleId)
  if not Row then
    LogDebug("IsRecommendSlot", "GetGrowthRow Error SelectRoleId=%s", PlayerState.SelectRoleId)
  end
  for i = 1, Row.RecommendUpgrade:Length() do
    local RecommendSlot = Row.RecommendUpgrade:Get(i)
    local CurLevel = self:GetGrowthLv(PlayerState, RecommendSlot)
    if CurLevel <= 0 then
      return RecommendSlot == Slot
    end
  end
end
function GrowthProxy:IsSingleSelect(RoleId, Slot)
  local Row = self:GetGrowthRow(RoleId)
  local SingleSelect
  if Slot == UE4.EGrowthSlotType.WeaponPart_Muzzle then
    SingleSelect = Row.Parts1SingleSelect
  elseif Slot == UE4.EGrowthSlotType.WeaponPart_Sight then
    SingleSelect = Row.Parts2SingleSelect
  elseif Slot == UE4.EGrowthSlotType.WeaponPart_Magazine then
    SingleSelect = Row.Parts4SingleSelect
  elseif Slot == UE4.EGrowthSlotType.WeaponPart_ButtStock then
    SingleSelect = Row.Parts5SingleSelect
  elseif Slot == UE4.EGrowthSlotType.QSkill then
    SingleSelect = Row.QSingleSelect
  elseif Slot == UE4.EGrowthSlotType.PassiveSkill then
    SingleSelect = Row.PassiveSingleSelect
  elseif Slot == UE4.EGrowthSlotType.Shield then
    SingleSelect = Row.ShieldSingleSelect
  elseif Slot == UE4.EGrowthSlotType.Survive then
    SingleSelect = Row.SurviveSingleSelect
  end
  return SingleSelect
end
function GrowthProxy:GetGrowthLv(PlayerState, Slot)
  local LevelMask = PlayerState.GrowthComponent.LevelMask
  local GrowthIndex = Slot - 1
  local Bit = 4 * GrowthIndex
  return (LevelMask & 15 << Bit) >> Bit
end
function GrowthProxy:GetGrowthTempLv(PlayerState, Slot)
  local LevelMask = PlayerState.GrowthComponent.LevelTempMask
  local GrowthIndex = Slot - 1
  local Bit = 4 * GrowthIndex
  return (LevelMask & 15 << Bit) >> Bit
end
function GrowthProxy:GetGrowthRoundStartLv(PlayerState, Slot)
  local Lv = self:GetGrowthLv(PlayerState, Slot)
  local TempLv = self:GetGrowthTempLv(PlayerState, Slot)
  return Lv - TempLv
end
function GrowthProxy:GetWeaponPartLv(PlayerState)
  local WeaponPartLv = self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_Muzzle)
  WeaponPartLv = WeaponPartLv + self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_Sight)
  WeaponPartLv = WeaponPartLv + self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_Magazine)
  WeaponPartLv = WeaponPartLv + self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_ButtStock)
  return WeaponPartLv
end
function GrowthProxy:GetSkillLv(PlayerState)
  local WeaponPartLv = self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.QSkill)
  WeaponPartLv = WeaponPartLv + self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.PassiveSkill)
  return WeaponPartLv
end
function GrowthProxy:GetShieldLv(PlayerState)
  local WeaponPartLv = self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.Shield)
  WeaponPartLv = WeaponPartLv + self:GetGrowthLv(PlayerState, UE4.EGrowthSlotType.Survive)
  return WeaponPartLv
end
function GrowthProxy:IsSlotMaxLv(PlayerState, SlotType)
  local CurrentLevel = self:GetGrowthLv(PlayerState, SlotType)
  if self:IsSingleSelect(PlayerState.SelectRoleId, SlotType) then
    return CurrentLevel > 0
  else
    local MaxLevel = self:GetGrowthSlotLvMax(PlayerState.SelectRoleId, SlotType)
    return CurrentLevel >= MaxLevel
  end
end
function GrowthProxy:GetWeaponPartMaxLvNum(PlayerState)
  local MaxLvNum = 0
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_Muzzle) then
    MaxLvNum = MaxLvNum + 1
  end
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_Sight) then
    MaxLvNum = MaxLvNum + 1
  end
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_Magazine) then
    MaxLvNum = MaxLvNum + 1
  end
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.WeaponPart_ButtStock) then
    MaxLvNum = MaxLvNum + 1
  end
  return MaxLvNum
end
function GrowthProxy:GetSkillMaxLvNum(PlayerState)
  local MaxLvNum = 0
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.QSkill) then
    MaxLvNum = MaxLvNum + 1
  end
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.PassiveSkill) then
    MaxLvNum = MaxLvNum + 1
  end
  return MaxLvNum
end
function GrowthProxy:GetShieldMaxLvNum(PlayerState)
  local MaxLvNum = 0
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.Shield) then
    MaxLvNum = MaxLvNum + 1
  end
  if self:IsSlotMaxLv(PlayerState, UE4.EGrowthSlotType.Survive) then
    MaxLvNum = MaxLvNum + 1
  end
  return MaxLvNum
end
function GrowthProxy:IsWakeSkillActived(PlayerState, Index)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  if -1 == PlayerState.SelectRoleId then
    return false
  end
  local RoleRow = roleProxy:GetRole(PlayerState.SelectRoleId)
  if not RoleRow then
    LogError("role config error", "PlayerState.SelectRoleId=%d", PlayerState.SelectRoleId)
    return
  end
  local WakeSkillId = RoleRow.SkillWake:Get(Index)
  local SkillRow = roleProxy:GetRoleSkill(WakeSkillId)
  if not SkillRow then
    LogError("skill config error", "RoleId=%d,WakeSkillId=%d", PlayerState.SelectRoleId, WakeSkillId)
    return
  end
  local WeaponNum = SkillRow.ActiveCond:Get(1)
  local SkillNum = SkillRow.ActiveCond:Get(2)
  local ShieldNum = SkillRow.ActiveCond:Get(3)
  local ActiveWeaponNum = self:GetWeaponPartMaxLvNum(PlayerState)
  local ActiveSkillNum = self:GetSkillMaxLvNum(PlayerState)
  local ActiveShieldNum = self:GetShieldMaxLvNum(PlayerState)
  local bActive = WeaponNum <= ActiveWeaponNum and SkillNum <= ActiveSkillNum and ShieldNum <= ActiveShieldNum
  return bActive
end
function GrowthProxy:IsGrowthMode(WorldObject)
  local GameState = UE4.UGameplayStatics.GetGameState(WorldObject)
  if not GameState then
    return false
  end
  local GrowthModes = {
    UE4.EPMGameModeType.Bomb,
    UE4.EPMGameModeType.Spar,
    UE4.EPMGameModeType.Practice
  }
  for key, value in pairs(GrowthModes) do
    if value == GameState:GetModeType() then
      return true
    end
  end
  return false
end
function GrowthProxy:IsGrowthPartUpgradeManual(WorldObject)
  local GameState = UE4.UGameplayStatics.GetGameState(WorldObject)
  if not GameState then
    return false
  end
  local GrowthModes = {
    UE4.EPMGameModeType.Bomb,
    UE4.EPMGameModeType.Spar,
    UE4.EPMGameModeType.Practice
  }
  for key, value in pairs(GrowthModes) do
    if value == GameState:GetModeType() then
      return true
    end
  end
  return false
end
function GrowthProxy:GetPartAttrModifyValue(PartName, Lv, WeaponId, CfgField)
  local id = string.format("%s_%s_%s", PartName, Lv, WeaponId)
  local row = growthPartAttributeModifierCfg[id]
  if not row then
    LogError("growthPartAttributeModifierCfg", "id=%s not found!", id)
  else
    return row[CfgField]
  end
  return 0
end
local dump_array = function(array)
  local ret = {}
  for i = 1, array:Length() do
    table.insert(ret, array:Get(i))
  end
  return "[" .. table.concat(ret, ",") .. "]"
end
function GrowthProxy:GetWeaponBaseAttributes()
  local baseWeaponInfo = UE4.FWeaponInfoDisplay()
  local weapon = UE4.UPMLuaBridgeBlueprintLibrary.GetWeaponBySlot(LuaGetWorld())
  if weapon then
    local isSuccess = weapon:GetWeaponBaseAttributes(baseWeaponInfo)
    if isSuccess then
      if baseWeaponInfo.HeadDamages then
        LogDebug("GetWeaponAttributes", "base Head:" .. dump_array(baseWeaponInfo.HeadDamages))
      end
      if baseWeaponInfo.BodyDamages then
        LogDebug("GetWeaponAttributes", "base Head:" .. dump_array(baseWeaponInfo.BodyDamages))
      end
      if baseWeaponInfo.LowBodyDamages then
        LogDebug("GetWeaponAttributes", "base Head:" .. dump_array(baseWeaponInfo.LowBodyDamages))
      end
      LogDebug("GetWeaponAttributes", "base Capacity:" .. baseWeaponInfo.MagazineCapacity)
      LogDebug("GetWeaponAttributes", "base AttackDuration:" .. baseWeaponInfo.AttackDuration)
      LogDebug("GetWeaponAttributes", "base AttackCount:" .. baseWeaponInfo.AttackCount)
    end
  end
  return baseWeaponInfo
end
function GrowthProxy:GetWeaponAttributes(part, level)
  local currentWeaponInfo = UE4.FWeaponInfoDisplay()
  local previewWeaponInfo = UE4.FWeaponInfoDisplay()
  local weapon = UE4.UPMLuaBridgeBlueprintLibrary.GetWeaponBySlot(LuaGetWorld())
  if weapon then
    local isSuccess = weapon:GetWeaponAttributesDisplay(part, level, currentWeaponInfo, previewWeaponInfo)
    if isSuccess then
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
    end
  end
  return currentWeaponInfo, previewWeaponInfo
end
function GrowthProxy:GetAttackSpeedByTotalDuration(RoleId, value)
  local speed = value - value % 0.001
  local Cfg = self:GetGrowthRow(RoleId)
  local weight = Cfg.AttackSpeedWeight or 1
  speed = weight * 100 / (self:GetPropertyMax(RoleId, GrowthDefine.PropertyNames1Actual.ShootSpeed) * speed)
  return speed
end
return GrowthProxy
