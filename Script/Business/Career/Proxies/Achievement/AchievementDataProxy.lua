local AchievementDataProxy = class("AchievementDataProxy", PureMVC.Proxy)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local achievementTable = {}
local achievementTypeTable = {}
local achievementMap = {}
local RoleAchivementCfgs = {}
local RoleAchivementInfoMap = {}
function AchievementDataProxy:GroupLvToAchievementId(groupStartId, level)
  if not groupStartId then
    return
  end
  local groupLv = type(level) == "number" and level or 1
  local achvId = groupStartId
  if groupLv > 0 then
    achvId = groupStartId + groupLv - 1
  end
  return achvId
end
function AchievementDataProxy:GetAchieveLevel(achieveId)
  if achieveId then
    local achieveCfg = self:GetAchievementTableRow(achieveId)
    if achieveCfg then
      local achieveBaseId = tonumber(achieveCfg.Group .. "1")
      for _, value in pairs(achievementMap) do
        if value.achievementList then
          for id, achieveInfo in pairs(value.achievementList) do
            if achieveBaseId == id then
              return achieveBaseId, achieveInfo.level
            end
          end
        end
      end
    end
  end
  return nil, nil
end
function AchievementDataProxy:InitAchievementData()
  local arrRows = ConfigMgr:GetAchievementTableRows()
  if arrRows then
    for RowName, UserData in pairs(arrRows:ToLuaTable()) do
      if UserData.Type > 0 then
        if not achievementTable[UserData.Type] then
          achievementTable[UserData.Type] = {}
        end
        if not achievementTable[UserData.Type][UserData.Group] then
          achievementTable[UserData.Type][UserData.Group] = {}
        end
        achievementTable[UserData.Type][UserData.Group][UserData.Level] = UserData
        if UserData.Type == CareerEnumDefine.achievementType.hero then
          if not RoleAchivementCfgs[UserData.Role] then
            RoleAchivementCfgs[UserData.Role] = {}
          end
          if not RoleAchivementCfgs[UserData.Role][UserData.Group] then
            RoleAchivementCfgs[UserData.Role][UserData.Group] = {}
          end
          RoleAchivementCfgs[UserData.Role][UserData.Group][UserData.Level] = UserData
        end
      end
    end
  else
    LogDebug("AchievementDataProxy", "Initialize achievement failed")
  end
end
function AchievementDataProxy:GetAchievementTableRow(Id)
  if 0 == table.count(achievementTable) then
    self:InitAchievementData()
  end
  for Type, AchvGroups in pairs(achievementTable) do
    for groupId, AchvGroup in pairs(AchvGroups) do
      for idx, AchvRow in pairs(AchvGroup) do
        if AchvRow.Id == tonumber(Id) then
          return AchvRow
        end
      end
    end
  end
  return nil
end
function AchievementDataProxy:InitAchievementTypeData()
  local arrRows = ConfigMgr:GetAchievementTypeTableRows()
  if arrRows then
    for RowName, UserData in pairs(arrRows:ToLuaTable()) do
      if UserData.Id > 0 then
        if not achievementTypeTable[UserData.Id] then
          achievementTypeTable[UserData.Id] = {}
        end
        achievementTypeTable[UserData.Id][UserData.Level] = UserData
      end
    end
  else
    LogDebug("AchievementDataProxy", "Initialize achievement type failed")
  end
end
function AchievementDataProxy:GetAchievementMap()
  return achievementMap
end
function AchievementDataProxy:GetRoleAchvInfo()
  return RoleAchivementInfoMap
end
function AchievementDataProxy:InitAchievementMap()
  if 0 == table.count(achievementMap) then
    for key, achvType in pairs(CareerEnumDefine.achievementType) do
      local achvGroups = achievementTable[achvType]
      if achvGroups then
        local typeSetupTable = {}
        typeSetupTable.config = achievementTypeTable[achvType]
        typeSetupTable.achievementList = {}
        typeSetupTable.totalNum = 0
        typeSetupTable.GotNum = 0
        typeSetupTable.level = 1
        typeSetupTable.rewardReceivedLevel = 1
        typeSetupTable.rank = 0
        local subAchievementList = {}
        for groupId, lvs in pairs(achvGroups) do
          local achievementItem = {}
          local beginLv = 1
          achievementItem.itemConfig = lvs[beginLv]
          achievementItem.progress = 0
          achievementItem.baseId = lvs[beginLv].Id
          achievementItem.level = 0
          achievementItem.rewardStatus = 0
          achievementItem.levelNodes = {}
          for lv, lvCfg in ipairs(lvs) do
            achievementItem.levelNodes[lv] = 0
            if lvCfg.Param2 and lvCfg.Param2:Length() > 0 then
              achievementItem.levelNodes[lv] = lvCfg.Param2:Get(1)
            end
          end
          subAchievementList[lvs[beginLv].Id] = achievementItem
          typeSetupTable.totalNum = typeSetupTable.totalNum + table.count(achievementItem.levelNodes)
        end
        typeSetupTable.achievementList = subAchievementList
        achievementMap[achvType] = typeSetupTable
        if achvType == CareerEnumDefine.achievementType.hero then
          for beginId, subAchv in pairs(subAchievementList) do
            local roleId = subAchv.itemConfig.Role
            if not RoleAchivementInfoMap[roleId] then
              RoleAchivementInfoMap[roleId] = {}
            end
            RoleAchivementInfoMap[roleId][beginId] = subAchv
          end
        end
      end
    end
  end
end
function AchievementDataProxy:ProcessAchievementData(achievementListReceived)
  local achievementListRes = achievementListReceived.achievement_list
  if achievementListRes then
    for key, value in pairs(achievementListRes) do
      local achievementTypeMap = achievementMap[value.type]
      if achievementTypeMap then
        if value.achievements then
          for i, v in pairs(value.achievements) do
            local achvId = v.id
            local curLv = v.level
            if curLv and achvId and achievementTypeMap.achievementList[achvId] then
              local levelId = self:GroupLvToAchievementId(achvId, curLv)
              achievementTypeMap.achievementList[achvId].level = curLv
              achievementTypeMap.achievementList[achvId].itemConfig = self:GetAchievementTableRow(levelId)
              if v.progress then
                achievementTypeMap.achievementList[achvId].progress = v.progress
              end
              if v.reward_status then
                achievementTypeMap.achievementList[achvId].rewardStatus = v.reward_status
              end
            end
          end
        end
        if value.rank then
          achievementTypeMap.rank = value.rank
        end
        if value.reward_reach_lv and value.reward_reach_lv > 1 then
          achievementTypeMap.level = value.reward_reach_lv
        end
        if value.reward_take_lv and value.reward_take_lv > 1 then
          achievementTypeMap.rewardReceivedLevel = value.reward_take_lv
        end
        if value.reward_take_lv < value.reward_reach_lv then
          self:ChangeRedDotCnt(value.type, value.reward_reach_lv - value.reward_take_lv)
        end
      end
    end
  end
  for key, value in pairs(achievementMap) do
    local totalGotAchvLv = 0
    local lightSubAchievementNum = 0
    for i, v in pairs(value.achievementList) do
      if v.level > 0 then
        totalGotAchvLv = totalGotAchvLv + v.level
        lightSubAchievementNum = lightSubAchievementNum + 1
      end
    end
    value.GotNum = totalGotAchvLv
    value.lightNum = lightSubAchievementNum
  end
end
function AchievementDataProxy:OnRegister()
  LogDebug("AchievementDataProxy", "Register AchievementData Proxy")
  AchievementDataProxy.super.OnRegister(self)
  self:InitAchievementData()
  self:InitAchievementTypeData()
  self:InitAchievementMap()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnResLogin, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PLAYER_CREATE_RES, FuncSlot(self.OnResCreatePlayer, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LIST_RES, FuncSlot(self.OnResAchievementList, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LIST_SYNC_NTF, FuncSlot(self.OnNtfAchievementListSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LEVEL_REWARD_RES, FuncSlot(self.OnResAchievementLevelReward, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_REWARD_RES, FuncSlot(self.OnResAchievementReward, self))
  end
end
function AchievementDataProxy:OnRemove()
  achievementTable = {}
  achievementTypeTable = {}
  achievementMap = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnResLogin, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PLAYER_CREATE_RES, FuncSlot(self.OnResCreatePlayer, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LIST_RES, FuncSlot(self.OnResAchievementList, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LIST_SYNC_NTF, FuncSlot(self.OnNtfAchievementListSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LEVEL_REWARD_RES, FuncSlot(self.OnResAchievementLevelReward, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_REWARD_RES, FuncSlot(self.OnResAchievementReward, self))
  end
  AchievementDataProxy.super.OnRemove(self)
end
function AchievementDataProxy:OnResLogin(data)
  local login_res = pb.decode(Pb_ncmd_cs_lobby.login_res, data)
  if 0 == login_res.code and login_res.player then
    local playerId = login_res.player.player_id
    self:ReqAchievementList(playerId)
  end
end
function AchievementDataProxy:OnResCreatePlayer(data)
  local createPlayerRes = pb.decode(Pb_ncmd_cs_lobby.player_create_res, data)
  if 0 == createPlayerRes.code and createPlayerRes.player then
    local playerId = createPlayerRes.player.player_id
    self:ReqAchievementList(playerId)
  end
end
function AchievementDataProxy:ReqAchievementList(playerId)
  local data = {player_id = playerId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LIST_REQ, pb.encode(Pb_ncmd_cs_lobby.achievement_list_req, data))
end
function AchievementDataProxy:OnResAchievementList(data)
  LogDebug("AchievementDataProxy", "On Res achievement list")
  local achievementList = pb.decode(Pb_ncmd_cs_lobby.achievement_list_res, data)
  self:ProcessAchievementData(achievementList)
end
function AchievementDataProxy:OnNtfAchievementListSync(data)
  local achievementList = pb.decode(Pb_ncmd_cs_lobby.achievement_list_sync_ntf, data)
  self:ProcessAchievementData(achievementList)
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.RefreshData, achievementMap)
end
function AchievementDataProxy:OnResAchievementLevelReward(data)
  LogDebug("AchievementDataProxy", "On receive achievement level reward")
  local rewardData = pb.decode(Pb_ncmd_cs_lobby.achievement_level_reward_res, data)
  if 0 == rewardData.code and achievementMap[rewardData.type].rewardReceivedLevel then
    achievementMap[rewardData.type].rewardReceivedLevel = rewardData.level
  end
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.OnResAcquireLevelReward, rewardData)
end
function AchievementDataProxy:ReqAchievementLevelReward(achievementTypeReq)
  LogDebug("AchievementDataProxy", "Request acquire achievement level reward")
  local data = {
    type = achievementTypeReq,
    level = achievementMap[achievementTypeReq].rewardReceivedLevel + 1
  }
  self:ChangeRedDotCnt(achievementTypeReq, achievementMap[achievementTypeReq].level - data.level)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LEVEL_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.achievement_level_reward_req, data))
end
function AchievementDataProxy:OnResAchievementReward(data)
  LogDebug("AchievementDataProxy", "On receive achievement reward")
  local rewardData = pb.decode(Pb_ncmd_cs_lobby.achievement_reward_res, data)
  if 0 == rewardData.code and achievementMap[3].achievementList[rewardData.id] then
    achievementMap[3].achievementList[rewardData.id].rewardStatus = 2
  end
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.OnResAcquireReward, rewardData)
end
function AchievementDataProxy:ReqAchievementReward(achievementId)
  LogDebug("AchievementDataProxy", "Request acquire achievement %d reward", achievementId)
  local data = {id = achievementId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.achievement_reward_req, data))
end
function AchievementDataProxy:InitRedDot()
  LogDebug("AchievementDataProxy", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_REACH_ACHIEVEMENT)
  if redDotList then
    for _, value in pairs(redDotList) do
      if value.mark then
        self:AddRedDot(value)
      end
    end
  end
end
function AchievementDataProxy:AddRedDot(redDotInfo)
  if redDotInfo then
    for k, v in pairs(achievementMap) do
      local achieveId = 0 ~= redDotInfo.event_id and redDotInfo.event_id or redDotInfo.reddot_rid
      if v.achievementList and v.achievementList[achieveId] then
        self:UpdateRedDotCnt(k, 1)
      end
    end
  end
end
function AchievementDataProxy:ChangeRedDotCnt(achieveType, cnt)
  local redDotName = ""
  if achieveType == CareerEnumDefine.achievementType.combat then
    redDotName = RedDotModuleDef.ModuleName.CareerACReward
  end
  if achieveType == CareerEnumDefine.achievementType.hornor then
    redDotName = RedDotModuleDef.ModuleName.CareerAHReward
  end
  if achieveType == CareerEnumDefine.achievementType.glory then
    redDotName = RedDotModuleDef.ModuleName.CareerAGReward
  end
  if "" ~= redDotName then
    RedDotTree:SetRedDotCnt(redDotName, cnt)
  end
end
function AchievementDataProxy:UpdateRedDotCnt(achieveType, cnt)
  local redDotName = ""
  if achieveType == CareerEnumDefine.achievementType.combat then
    redDotName = RedDotModuleDef.ModuleName.CareerACItem
  end
  if achieveType == CareerEnumDefine.achievementType.hornor then
    redDotName = RedDotModuleDef.ModuleName.CareerAHItem
  end
  if achieveType == CareerEnumDefine.achievementType.glory then
    redDotName = RedDotModuleDef.ModuleName.CareerAGItem
  end
  if achieveType == CareerEnumDefine.achievementType.hero then
    redDotName = RedDotModuleDef.ModuleName.CareerAHeroItem
  end
  if "" ~= redDotName then
    RedDotTree:ChangeRedDotCnt(redDotName, cnt)
  end
end
return AchievementDataProxy
