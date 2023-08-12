local ApartmentStateMachineConfigProxy = class("ApartmentStateMachineConfigProxy", PureMVC.Proxy)
local ApartmentRoomEnum = require("Business/Apartment/Proxies/ApartmentRoomEnum")
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function ApartmentStateMachineConfigProxy:OnRegister()
  self.lastRoleID = 0
  self.characterEnterSceneCenterMood = UE4.ECyApartmentRoleEnterSceneCenterMood.None
  self.newUnlockActivityAreaMap = {}
end
function ApartmentStateMachineConfigProxy:OnRemove()
end
function ApartmentStateMachineConfigProxy:ChangeRoleRestData()
  self.characterEnterSceneCenterMood = UE4.ECyApartmentRoleEnterSceneCenterMood.None
  self.lastServerTime = nil
end
function ApartmentStateMachineConfigProxy:GetApartmentConfigData()
  local data = UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):GetApartmentCharacterConfig()
  if data then
    return data
  end
  LogError("ApartmentStateMachineConfigProxy:GetApartmentConfigData", "ApartmentCharacterConfig is nil")
  return nil
end
function ApartmentStateMachineConfigProxy:SetLastRoleID(roleID)
  self.lastRoleID = roleID
end
function ApartmentStateMachineConfigProxy:GetLastRoleID()
  return self.lastRoleID
end
function ApartmentStateMachineConfigProxy:GetChangSceneIdleTime()
  local time = 300
  if self:GetApartmentConfigData() then
    time = self:GetApartmentConfigData().ChangSceneIdleDuration
  else
    LogError("ApartmentStateMachineConfigProxy:GetChangSceneIdleTime", "GetApartmentConfigData is nil")
  end
  return time
end
function ApartmentStateMachineConfigProxy:GetTouchTwiceTime()
  local time = 0
  if self:GetApartmentConfigData() then
    time = self:GetApartmentConfigData().TwiceTouchTime
  end
  return time
end
function ApartmentStateMachineConfigProxy:GetTouchSequence(clickType)
  return 25146204
end
function ApartmentStateMachineConfigProxy:GetOnceTouchProb()
  local prop = 100
  if self:GetApartmentConfigData() then
    prop = self:GetApartmentConfigData().OnceTouchProb
  end
  return prop
end
function ApartmentStateMachineConfigProxy:GeRelaxTime()
  local time = 0
  if self:GetApartmentConfigData() then
    time = self:GetApartmentConfigData().RelaxTime
  end
  return time
end
function ApartmentStateMachineConfigProxy:SetCharacterEnterSceneCenterMood(mood)
  self.characterEnterSceneCenterMood = mood
end
function ApartmentStateMachineConfigProxy:GetCharacterEnterSceneCenterMood()
  return self.characterEnterSceneCenterMood
end
function ApartmentStateMachineConfigProxy:GeInterpretationIdleTime()
  local time = 10
  if self:GetApartmentConfigData() then
    time = self:GetApartmentConfigData().InterpretationIdleDuration
  end
  return time
end
function ApartmentStateMachineConfigProxy:GetPlayHappySequenceTime()
  local time = 3
  if self:GetApartmentConfigData() then
    time = self:GetApartmentConfigData().HappyCompleteWaitTime
  end
  return time
end
function ApartmentStateMachineConfigProxy:GetPlayDispiritedSequenceTime()
  local time = 3
  if self:GetApartmentConfigData() then
    time = self:GetApartmentConfigData().DispiritedCompleteWaitTime
  end
  return time
end
function ApartmentStateMachineConfigProxy:GetDispiritedSequenceID()
  local stateSequenceData = self:GetStateSequenceAsset(UE4.ECyApartmentState.SceneInterpretationIdle)
  if stateSequenceData and stateSequenceData.DispiritedSequenceArray and stateSequenceData.DispiritedSequenceArray:Length() > 0 then
    return stateSequenceData.DispiritedSequenceArray:Get(1)
  end
  return 0
end
function ApartmentStateMachineConfigProxy:GetHappySequenceID()
  local stateSequenceData = self:GetStateSequenceAsset(UE4.ECyApartmentState.SceneInterpretationIdle)
  if stateSequenceData and stateSequenceData.HappySequenceArray and stateSequenceData.HappySequenceArray:Length() > 0 then
    return stateSequenceData.HappySequenceArray:Get(1)
  end
  return 0
end
function ApartmentStateMachineConfigProxy:GetSceneInterpretationClickSequenceID(clickPart)
  if self:CanClick(clickPart) == false then
    return 0
  end
  local stateConfig = self:GetStateSequenceAsset(UE4.ECyApartmentState.SceneInterpretationIdle)
  if stateConfig and stateConfig.TouchPartMap then
    local touchConfig = stateConfig.TouchPartMap:Find(clickPart)
    if touchConfig and touchConfig.SequenceArray and touchConfig.SequenceArray:Length() > 0 then
      local length = touchConfig.SequenceArray:Length()
      local index = math.random(length)
      return touchConfig.SequenceArray:Get(index)
    end
  end
  return 0
end
function ApartmentStateMachineConfigProxy:GetEnterSceneCenterSequenceID()
  local sequenceAsset = self:GetCurrentRoleStateAesst(UE4.ECyApartmentState.EnterSceneCenter)
  if sequenceAsset then
    if GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):IsTwoStage() then
      LogDebug("ApartmentStateMachineConfigProxy:GetEnterSceneCenterSequenceID", "Is twoStage")
      return sequenceAsset.TwoStageMoodSequenceMap:Find(self:GetCharacterEnterSceneCenterMood())
    else
      return sequenceAsset.MoodSequenceMap:Find(self:GetCharacterEnterSceneCenterMood())
    end
  end
  LogWarn("ApartmentStateMachineConfigProxy:GetEnterSceneCenterSequenceID", "sequenceAsset is nil")
  return 0
end
function ApartmentStateMachineConfigProxy:GetRelaxSequenceID()
  local sequenceAsset = self:GetCurrentRoleStateAesst(UE4.ECyApartmentState.SceneChangeIdle)
  if sequenceAsset and sequenceAsset.RelaxSequenceArray then
    local arrayLength = sequenceAsset.RelaxSequenceArray:Length()
    if nil ~= arrayLength and 0 ~= arrayLength then
      local randomIndex = math.random(arrayLength)
      local sequenceId = sequenceAsset.RelaxSequenceArray:Get(randomIndex)
      if sequenceId then
        return sequenceId
      end
    end
  end
  return 0
end
function ApartmentStateMachineConfigProxy:GetCharacterEnterSequenceID()
  local stateAesset = self:GetStateSequenceAsset(UE4.ECyApartmentState.EnterCharacterRoom)
  if stateAesset then
    local timeStage = self:GetApartmnetLocalTimeStage()
    local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateAesset, timeStage)
    if activityAreaAsset then
      local array = self:GetUnlockActivityAreaList()
      local length = table.count(array)
      if length and length > 0 then
        local index = math.random(length)
        local area = array[index]
        self:SetApartmnetCurrentActivityArea(area)
        local roleStateAsset = self:GetRolesatusAssetByActivityArea(activityAreaAsset, area)
        if roleStateAsset then
          local sequenceAsset = self:RandomGetRoleStateAsset(roleStateAsset.RoleStateMap)
          if sequenceAsset and sequenceAsset.SequenceArray:Length() > 0 then
            return sequenceAsset.SequenceArray:Get(1)
          end
        end
      end
    end
  end
  LogWarn("ApartmentStateMachineConfigProxy:GetCharacterEnterSequenceID", "GetCharacterEnterSequenceID is 0")
  return 0
end
function ApartmentStateMachineConfigProxy:GetTransitionSequenceID()
  local ApartmentStateMachineProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy)
  local sequenceAsset
  if self:IsNewUnlockActivityArea() then
    local areaType = self:GetNewUnlockActivityArea()
    self:SetApartmnetCurrentActivityArea(areaType)
    local stateConfig = self:GetStateSequenceAsset(UE4.ECyApartmentState.SceneChangeIdle)
    local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateConfig, self:GetApartmnetLocalTimeStage())
    local roleStateAsset = self:GetRolesatusAssetByActivityArea(activityAreaAsset, areaType)
    if roleStateAsset then
      sequenceAsset = self:RandomGetRoleStateAsset(roleStateAsset.RoleStateMap)
    end
    self:RemoveNewUnlockActivityArea()
    LogDebug("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "newActivityArea play")
  elseif self:IsRandomActivityArea() then
    sequenceAsset = self:RandomSceneChangeIdleActivityArea()
    LogDebug("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "RandomActivityArea play")
  else
    sequenceAsset = self:GetCurrentRoleStateAesst(UE4.ECyApartmentState.SceneChangeIdle)
    LogDebug("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "GetCurrentRoleStateAesst play")
  end
  if nil == sequenceAsset then
    sequenceAsset = self:RandomSceneChangeIdleActivityArea()
  end
  if sequenceAsset then
    local transitionsSequenceID = 0
    if ApartmentStateMachineProxy:IsTwoStage() then
      transitionsSequenceID = sequenceAsset.TwoStageSequenceID
    end
    if 0 ~= transitionsSequenceID then
      return transitionsSequenceID
    end
    local stateID = ApartmentStateMachineProxy:GetLastStateID()
    transitionsSequenceID = sequenceAsset.LastStateTransitionMap:Find(stateID)
    if transitionsSequenceID then
      return transitionsSequenceID
    else
      return 0
    end
  end
  LogWarn("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "sequenceAsset is nil")
  return 0
end
function ApartmentStateMachineConfigProxy:GetPromiseSequenceID()
  local stateConfig = self:GetStateSequenceAsset(UE4.ECyApartmentState.Promise)
  if stateConfig and stateConfig.SequenceArray and stateConfig.SequenceArray:Length() > 0 then
    return stateConfig.SequenceArray:Get(1)
  end
  return 0
end
function ApartmentStateMachineConfigProxy:CanClick(partType)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local roleProp = KaPhoneProxy:GetRoleProperties(currentRoleId)
  local unlockPartList = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomTouchProxy):GetRoleUnlockCfg(currentRoleId, roleProp.intimacy_lv)
  if unlockPartList and table.count(unlockPartList) > 0 then
    for key, value in pairs(unlockPartList) do
      if value == partType then
        return true
      end
    end
  end
  return false
end
function ApartmentStateMachineConfigProxy:IsRandomActivityArea()
  if self:GetApartmentConfigData() == nil then
    return false
  end
  if nil == self.lastServerTime or 0 == self.lastServerTime then
    self.lastServerTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    LogWarn("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "lastServerTime is 0")
    return false
  end
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if nil == servertime then
    LogWarn("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "servertime is nil")
    return false
  end
  if self:GetApartmentConfigData() == nil then
    return false
  end
  local configTime = self:GetApartmentConfigData().ChangSceneIdleRandomActivityAreaDuration
  if nil == configTime then
    LogWarn("ApartmentStateMachineConfigProxy:GetTransitionSequenceID", "configTime is nil")
    return false
  end
  if configTime <= servertime - self.lastServerTime then
    self.lastServerTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    return true
  end
  return false
end
function ApartmentStateMachineConfigProxy:GetUnlockActivityAreaList()
  local array = {}
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local roleProp = KaPhoneProxy:GetRoleProperties(currentRoleId)
  if roleProp then
    local unlocAreaList = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleUnlockArea(currentRoleId, roleProp.intimacy_lv)
    LogDebug("ApartmentStateMachineConfigProxy:GetUnlockActivityAreaList", "UnlockActivityAreaList")
    table.print(unlocAreaList)
    array = unlocAreaList
  end
  if 0 == table.count(array) then
    LogError("ApartmentStateMachineConfigProxy:GetUnlockActivityAreaList", "unlocAreaList is nil,use local config")
    table.insert(array, UE4.ECyApartmentRoleActivityArea.ComputerTable)
  end
  return array
end
function ApartmentStateMachineConfigProxy:RandomSceneChangeIdleActivityArea()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):SetTwoStage(false)
  local unlockActivityAreaList = self:GetUnlockActivityAreaList()
  local newArray = {}
  if table.count(unlockActivityAreaList) > 1 then
    local currentActivityArea = self:GetApartmnetCurrentActivityArea()
    if currentActivityArea and 0 ~= currentActivityArea then
      for key, value in pairs(unlockActivityAreaList) do
        if value ~= currentActivityArea then
          table.insert(newArray, value)
        end
      end
    end
  else
    newArray = unlockActivityAreaList
  end
  local length = table.count(newArray)
  if length and length > 0 then
    local index = math.random(length)
    local area = newArray[index]
    self:SetApartmnetCurrentActivityArea(area)
    local stateConfig = self:GetStateSequenceAsset(UE4.ECyApartmentState.SceneChangeIdle)
    local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateConfig, self:GetApartmnetLocalTimeStage())
    local roleStateAsset = self:GetRolesatusAssetByActivityArea(activityAreaAsset, area)
    if roleStateAsset then
      return self:RandomGetRoleStateAsset(roleStateAsset.RoleStateMap)
    end
    LogDebug("ApartmentStateMachineConfigProxy:RandomSceneChangeIdleActivityArea", "RandomSceneChangeIdleActivityArea is " .. area .. "roleState is " .. self:GetApartmnetRolePose())
  end
  return nil
end
function ApartmentStateMachineConfigProxy:SaveRoleNewUnlockActivityArea(serverData)
  if serverData then
    if serverData.intimacy_lv == nil or nil == serverData.upgrade_lv then
      LogDebug(" ApartmentStateMachineConfigProxy:SaveRoleNewUnlockActivityArea", "serverData.intimacy_lv is nil or serverData.upgrade_lv is nil ")
      return
    end
    if 0 == serverData.upgrade_lv then
      return
    end
    local minLevel = serverData.intimacy_lv - serverData.upgrade_lv
    local maxLevel = serverData.intimacy_lv
    local cfgList = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleFavorabilityEventSectionCfg(serverData.role_id, maxLevel, minLevel)
    for index = 1, table.count(cfgList) do
      local row = cfgList[index]
      if row and row.AreaUnlock:Length() > 0 and 0 ~= row.AreaUnlock:Get(1) then
        self.newUnlockActivityAreaMap[serverData.role_id] = row.AreaUnlock:Get(1)
        break
      end
    end
  end
end
function ApartmentStateMachineConfigProxy:IsNewUnlockActivityArea()
  if self.newUnlockActivityAreaMap == nil or 0 == table.count(self.newUnlockActivityAreaMap) then
    return false
  end
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local newActivityAreaType = self.newUnlockActivityAreaMap[currentRoleId]
  if nil == newActivityAreaType then
    return false
  end
  return true
end
function ApartmentStateMachineConfigProxy:GetNewUnlockActivityArea()
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = KaNavigationProxy:GetCurrentRoleId()
  return self.newUnlockActivityAreaMap[currentRoleId]
end
function ApartmentStateMachineConfigProxy:RemoveNewUnlockActivityArea()
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = KaNavigationProxy:GetCurrentRoleId()
  self.newUnlockActivityAreaMap[currentRoleId] = nil
  LogDebug(" ApartmentStateMachineConfigProxy:RemoveNewUnlockActivityArea", "RemoveNewUnlockActivityArea")
end
function ApartmentStateMachineConfigProxy:GetStateSequenceConfig(stateID)
  local configData = self:GetApartmentConfigData()
  if configData and configData.StateSequenceMap then
    return configData.StateSequenceMap:Find(stateID)
  end
  return nil
end
function ApartmentStateMachineConfigProxy:GetApartmnetCurrentActivityArea()
  if self.currentActivityArea == nil then
    LogDebug("ApartmentStateMachineConfigProxy:GetApartmnetCurrentActivityArea", "currentActivityArea is nil,use ConfigActivityArea")
    self.currentActivityArea = self:CheckApartmentActivityArea()
  end
  return self.currentActivityArea
end
function ApartmentStateMachineConfigProxy:SetApartmnetCurrentActivityArea(activityArea)
  LogDebug("ApartmentStateMachineConfigProxy:SetApartmnetCurrentActivityArea", "set currentActivityArea : " .. tostring(activityArea))
  self.currentActivityArea = activityArea
end
function ApartmentStateMachineConfigProxy:SetApartmnetRolePose(roleState)
  LogDebug("ApartmentStateMachineConfigProxy:SetApartmnetRolePose", "set currentRoleState : " .. tostring(roleState))
  self.currentRolePose = roleState
end
function ApartmentStateMachineConfigProxy:GetApartmnetRolePose()
  if self.currentRolePose == nil then
    LogDebug("ApartmentStateMachineConfigProxy:GetApartmnetRolePose", "currentRoleState is nil,use ConfigRoleStatus")
    self.currentRolePose = self:CheckApartmentRoleStatus()
  end
  return self.currentRolePose
end
function ApartmentStateMachineConfigProxy:SetApartmnetLocalTimeStage(timeStage)
  LogDebug(" ApartmentStateMachineConfigProxy:SetApartmnetLocalTimeStage", "set currentLocalTimeStage : " .. tostring(timeStage))
  self.currentLocalTimeStage = timeStage
end
function ApartmentStateMachineConfigProxy:GetApartmnetLocalTimeStage()
  if self.currentLocalTimeStage == nil then
    LogDebug("ApartmentStateMachineConfigProxy:GetApartmnetLocalTimeStage", "currentLocalTimeStage is nil,use ConfigTimeStage")
    self.currentLocalTimeStage = self:CheckApartmentTimeStage()
  end
  return self.currentLocalTimeStage
end
function ApartmentStateMachineConfigProxy:GetApartmnetSeverCurrentTime()
  return 21600
end
function ApartmentStateMachineConfigProxy:GetApartmnetServerTimeStage()
  local currentTime = self:GetApartmnetSeverCurrentTime()
  if currentTime >= 21600 and currentTime < 43200 then
    return UE4.ECyApartmentTimeStage.DayTime
  elseif currentTime >= 43200 and currentTime < 72000 then
    return UE4.ECyApartmentTimeStage.Noon
  elseif currentTime >= 72000 and currentTime < 82800 then
    return UE4.ECyApartmentTimeStage.Night
  else
    return UE4.ECyApartmentTimeStage.WeeHours
  end
end
function ApartmentStateMachineConfigProxy:RandomGetActivityArea(areaMap)
  if areaMap then
    local key, value = self:RandomGetMapValue(areaMap)
    self:SetApartmnetCurrentActivityArea(key)
    return value
  end
  LogWarn("ApartmentStateMachineConfigProxy:RandomGetActivityArea", "ActivityArea is nil")
  return nil
end
function ApartmentStateMachineConfigProxy:RandomGetRoleStateAsset(roleStatusMap)
  if roleStatusMap then
    local key, value = self:RandomGetMapValue(roleStatusMap)
    self:SetApartmnetRolePose(key)
    return value
  end
  LogWarn("ApartmentStateMachineConfigProxy:RandomGetRoleStateAsset", "roleStatusMap is nil")
  return nil
end
function ApartmentStateMachineConfigProxy:RandomGetMapValue(map)
  if map then
    local keys = map:Keys()
    local length = keys:Length()
    if length > 0 then
      local index = math.random(length)
      local key = keys:Get(index)
      return key, map:Find(key)
    end
  end
  LogWarn("ApartmentStateMachineConfigProxy:RandomGetMapValue", "map is nil")
  return nil, nil
end
function ApartmentStateMachineConfigProxy:GetStateSequenceAsset(stateID)
  local configData = self:GetApartmentConfigData()
  if configData and configData.StateSequenceMap then
    return configData.StateSequenceMap:Find(stateID)
  end
  LogError("ApartmentStateMachineConfigProxy:GetStateSequenceAsset", "configData is nil,stateID :" .. tostring(stateID))
  return nil
end
function ApartmentStateMachineConfigProxy:GetRoleStateAesst(stateID, timeStage, activityArea, roleState)
  LogDebug("ApartmentStateMachineConfigProxy:GetRoleStateAesst", "stateID ：" .. tostring(stateID) .. "  timeStage :" .. tostring(timeStage) .. " activityArea: " .. tostring(activityArea) .. " roleState :" .. tostring(roleState))
  if nil == stateID then
    LogWarn("ApartmentStateMachineConfigProxy:GetRoleStateAesst", "stateID is nil")
    return nil
  end
  if nil == timeStage then
    LogWarn("ApartmentStateMachineConfigProxy:GetRoleStateAesst", "timeStage is nil")
    return nil
  end
  if nil == activityArea then
    LogWarn("ApartmentStateMachineConfigProxy:GetRoleStateAesst", "activityArea is nil")
    return nil
  end
  if nil == roleState then
    LogWarn("ApartmentStateMachineConfigProxy:GetRoleStateAesst", "roleState is nil")
    return nil
  end
  local stateConfig = self:GetStateSequenceAsset(stateID)
  local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateConfig, timeStage)
  local roleStateAsset = self:GetRolesatusAssetByActivityArea(activityAreaAsset, activityArea)
  local sequenceAsset = self:GetSequenceAssetByRoleStatusType(roleStateAsset, roleState)
  if sequenceAsset then
    return sequenceAsset
  end
  LogWarn("ApartmentStateMachineConfigProxy:GetRoleStateAesst", "sequenceAsset is nil")
  return nil
end
function ApartmentStateMachineConfigProxy:GetCurrentRoleStateAesst(stateID)
  local timeStage = self:GetApartmnetLocalTimeStage()
  local activityArea = self:GetApartmnetCurrentActivityArea()
  local roleState = self:GetApartmnetRolePose()
  local asset = self:GetRoleStateAesst(stateID, timeStage, activityArea, roleState)
  if nil ~= asset then
    LogDebug("ApartmentStateMachineConfigProxy:GetCurrentRoleStateAesst", "stateID is " .. tostring(stateID))
    return asset
  end
  LogWarn("ApartmentStateMachineConfigProxy:GetCurrentRoleStateAesst", "asset is nil")
  return nil
end
function ApartmentStateMachineConfigProxy:RandomStateSequenceAsset(stateAesset)
  if stateAesset then
    local timeStage = self:GetApartmnetLocalTimeStage()
    local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateAesset, timeStage)
    if activityAreaAsset then
      local roleStateAsset = self:RandomGetActivityArea(activityAreaAsset.RoleActivityAreaMap)
      if roleStateAsset then
        return self:RandomGetRoleStateAsset(roleStateAsset.RoleStateMap)
      end
    end
  end
  return nil
end
function ApartmentStateMachineConfigProxy:GetRoleActivityAreaAssetByTimeStage(stateSequenceAsset, timeStage)
  if nil == stateSequenceAsset then
    LogError("ApartmentStateMachineConfigProxy:GetRoleActivityAreaAssetByTimeStage", "stateSequenceAsset is nil")
    return nil
  end
  if nil == timeStage then
    LogError("ApartmentStateMachineConfigProxy:GetRoleActivityAreaAssetByTimeStage", "timeStage is nil")
    return nil
  end
  return stateSequenceAsset.TimeStageMap:Find(timeStage)
end
function ApartmentStateMachineConfigProxy:GetRolesatusAssetByActivityArea(activityAreaAsset, activityAreaType)
  if nil == activityAreaAsset then
    LogWarn("ApartmentStateMachineConfigProxy:GetRolesatusAssetByActivityArea", "activityAreaAsset is nil")
    return
  end
  if nil == activityAreaType then
    LogWarn("ApartmentStateMachineConfigProxy:GetRolesatusAssetByActivityArea", "activityAreaType is nil")
  end
  if nil == activityAreaAsset.RoleActivityAreaMap then
    LogWarn("ApartmentStateMachineConfigProxy:GetRolesatusAssetByActivityArea", "activityAreaAsset.RoleStateMap is nil")
  end
  return activityAreaAsset.RoleActivityAreaMap:Find(activityAreaType)
end
function ApartmentStateMachineConfigProxy:GetSequenceAssetByRoleStatusType(roleStateAsset, roleStatusType)
  if nil == roleStateAsset then
    LogWarn("ApartmentStateMachineConfigProxy:GetSequenceAssetByRoleStatusType", "roleStateAsset is nil")
    return nil
  end
  if nil == roleStatusType then
    LogWarn("ApartmentStateMachineConfigProxy:GetSequenceAssetByRoleStatusType", "roleStatusType is nil")
    return nil
  end
  if nil == roleStateAsset.RoleStateMap then
    LogWarn("ApartmentStateMachineConfigProxy:GetSequenceAssetByRoleStatusType", "roleStateAsset.RoleStateMap is nil")
    return nil
  end
  return roleStateAsset.RoleStateMap:Find(roleStatusType)
end
function ApartmentStateMachineConfigProxy:IsHighLevel()
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local currentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local roleProp = KaPhoneProxy:GetRoleProperties(currentRoleId)
  local configData = self:GetApartmentConfigData()
  if configData and roleProp then
    return roleProp.intimacy_lv > configData.HighIntimacyLv
  end
  return false
end
function ApartmentStateMachineConfigProxy:CheckApartmentTimeStage()
  local timeStage = UE4.ECyApartmentTimeStage.DayTime
  local currStateID = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):GetCurrentStateID()
  local stateSequenceAsset = self:GetStateSequenceAsset(currStateID)
  if stateSequenceAsset then
    local temp = self:GetMapKeyByIndex(stateSequenceAsset.TimeStageMap)
    if 0 ~= temp then
      timeStage = temp
    end
  end
  LogDebug("ApartmentStateMachineConfigProxy:CheckApartmentTimeStage", "timeStage is " .. tostring(timeStage))
  return timeStage
end
function ApartmentStateMachineConfigProxy:CheckApartmentActivityArea()
  local activityAreaType = UE4.ECyApartmentRoleActivityArea.ComputerTable
  local currStateID = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):GetCurrentStateID()
  local stateSequenceAsset = self:GetStateSequenceAsset(currStateID)
  if stateSequenceAsset then
    local timeStage = self:GetApartmnetLocalTimeStage()
    local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateSequenceAsset, timeStage)
    if activityAreaAsset then
      local unlockActivityAreaList = self:GetUnlockActivityAreaList()
      if table.count(unlockActivityAreaList) > 0 then
        activityAreaType = unlockActivityAreaList[1]
        LogDebug("ApartmentStateMachineConfigProxy:CheckApartmentActivityArea", "use first unlockactivityAreaType is " .. tostring(activityAreaType))
      else
        local activityAreaTempType = self:GetMapKeyByIndex(activityAreaAsset.RoleActivityAreaMap)
        if 0 ~= activityAreaTempType then
          activityAreaType = activityAreaTempType
        end
        LogDebug("ApartmentStateMachineConfigProxy:CheckApartmentActivityArea", "use DA Config first AreaType is " .. tostring(activityAreaType))
      end
    end
  end
  LogDebug("ApartmentStateMachineConfigProxy:CheckApartmentActivityArea", "activityAreaType is " .. tostring(activityAreaType))
  return activityAreaType
end
function ApartmentStateMachineConfigProxy:CheckApartmentRoleStatus()
  local roleSatusType = UE4.EPMApartmentRoleStatusType.Stand
  local currStateID = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):GetCurrentStateID()
  local stateSequenceAsset = self:GetStateSequenceAsset(currStateID)
  if stateSequenceAsset then
    local timeStage = self:GetApartmnetLocalTimeStage()
    local activityAreaAsset = self:GetRoleActivityAreaAssetByTimeStage(stateSequenceAsset, timeStage)
    if activityAreaAsset then
      local activityAreaType = self:GetApartmnetCurrentActivityArea()
      local roleSatusAsset = self:GetRolesatusAssetByActivityArea(activityAreaAsset, activityAreaType)
      if roleSatusAsset then
        local roleSatusTypeTemp = self:GetMapKeyByIndex(roleSatusAsset.RoleStateMap)
        if 0 ~= roleSatusTypeTemp then
          roleSatusType = roleSatusTypeTemp
        end
      end
    end
  end
  LogDebug("ApartmentStateMachineConfigProxy:CheckApartmentRoleStatus", "roleSatusType is " .. tostring(roleSatusType))
  return roleSatusType
end
function ApartmentStateMachineConfigProxy:GetMapKeyByIndex(map, index)
  if nil == index then
    index = 1
  end
  if map then
    local keys = map:Keys()
    local length = keys:Length()
    if length > 0 and index <= length then
      local key = keys:Get(index)
      return key
    end
  end
  LogWarn("ApartmentStateMachineConfigProxy:RandomGetMapValue", "map is nil")
  return 0
end
return ApartmentStateMachineConfigProxy
