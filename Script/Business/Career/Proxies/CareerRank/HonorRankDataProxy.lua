local HonorRankDataProxy = class("HonorRankDataProxy", PureMVC.Proxy)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local preRequiredPage = 2
local numPerPage = 10
function HonorRankDataProxy:GetNumPerPage()
  return numPerPage
end
function HonorRankDataProxy:SetSelfRankInfo(leadboardType, subType, selfRankInfo, relationshipType)
  if leadboardType == CareerEnumDefine.LeaderboardType.StarsRank then
    if not self.myStarsRankInfo then
      self.myStarsRankInfo = {}
    end
    self.myStarsRankInfo[relationshipType] = selfRankInfo
  elseif leadboardType == CareerEnumDefine.LeaderboardType.TeamRank then
    if not self.myTeamRankInfo then
      self.myTeamRankInfo = {}
    end
    self.myTeamRankInfo[relationshipType] = selfRankInfo
  elseif leadboardType == CareerEnumDefine.LeaderboardType.HeroRank then
    if not self.myHeroRankInfo then
      self.myHeroRankInfo = {}
    end
    if not self.myHeroRankInfo[subType] then
      self.myHeroRankInfo[subType] = {}
    end
    return self.myHeroRankInfo[subType][relationshipType]
  end
end
function HonorRankDataProxy:GetSelfRankInfo(leadboardType, relationshipType)
  if leadboardType == CareerEnumDefine.LeaderboardType.StarsRank then
    return self.myStarsRankInfo[relationshipType]
  elseif leadboardType == CareerEnumDefine.LeaderboardType.TeamRank then
    return self.myTeamRankInfo[relationshipType]
  elseif leadboardType == CareerEnumDefine.LeaderboardType.HeroRank then
    local subType = self:GetCurrentReqRoleID()
    return self.myHeroRankInfo[subType][relationshipType]
  end
  LogDebug("HonorRankDataProxy", "GetSelfRankInfo is nil:" .. tostring(leadboardType))
  return nil
end
function HonorRankDataProxy:OnRegister()
  LogDebug("HonorRankDataProxy", "Register Honor Rank Data Proxy")
  HonorRankDataProxy.super.OnRegister(self)
  self:SetReqLeadboardRowNum(10000)
  self:SetVision(0)
  self:SetCurrentReqSeasonId(0)
  self:ClearLeadboardData()
  self:SetLeaderboardRelationshipChain(CareerEnumDefine.LeaderboardRelationshipChain.None)
  self.needRefresh = true
  self.bInLoadingData = false
  self.bReqFrequencyTime = 0.1
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_RANK_DATA_RES, FuncSlot(self.OnResRankData, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_RANK_DATA_REFRESH_NTF, FuncSlot(self.RankDataRefreshNtf, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_RANK_GET_FRIEND_DATA_RES, FuncSlot(self.OnGetRankFriendDataRes, self))
  end
end
function HonorRankDataProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_RANK_DATA_RES, FuncSlot(self.OnResRankData, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_RANK_DATA_REFRESH_NTF, FuncSlot(self.RankDataRefreshNtf, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_RANK_GET_FRIEND_DATA_RES, FuncSlot(self.OnGetRankFriendDataRes, self))
  end
  HonorRankDataProxy.super.OnRemove(self)
end
function HonorRankDataProxy:RankDataRefreshNtf(data)
  LogDebug("HonorRankDataProxy", "Rank data refreshed")
  self.needRefresh = true
end
function HonorRankDataProxy:ReqRankData(leadboardType, subType, seasonId, startPage)
  self:SetCurrentReqLeadboardType(leadboardType)
  self:SetCurrentReqRoleID(subType)
  self:SetCurrentReqSeasonId(seasonId)
  self:SetReqPageIndex(startPage)
  LogDebug("HonorRankDataProxy", "Require rank page")
  if self:GetIsInLoadingData() then
    local tips = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "RequestLeadboardTooFrequently")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tips)
    return
  end
  self:ClearRequestFrequencyTimeHandle()
  self:SetIsInLoadingData(true)
  self:StartRequestFrequencyTimeHandle()
  if startPage < 1 then
    startPage = 1
  end
  local startPos = (startPage - 1) * numPerPage + 1
  local endPos = (startPage - 1 + preRequiredPage) * numPerPage
  local data = {
    rank_type = leadboardType,
    sub_type = subType,
    start_pos = startPos,
    end_pos = endPos,
    custom = seasonId,
    version = 0
  }
  LogDebug("HonorRankDataProxy", "Send rank data require: ", TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_RANK_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.rank_data_req, data))
end
function HonorRankDataProxy:OnResRankData(data)
  LogDebug("HonorRankDataProxy", "On receive rank data")
  local rankDataRes = pb.decode(Pb_ncmd_cs_lobby.rank_data_res, data)
  if 0 == rankDataRes.code then
    self:SetVision(rankDataRes.version)
    self:SetReqLeadboardRowNum(rankDataRes.rank_total)
    local startPos = rankDataRes.start_pos
    local rankRowsInfo = rankDataRes.rows_info
    local startPageIndex = math.ceil(startPos / numPerPage)
    local lastIndex = startPos + table.count(rankRowsInfo) - 1
    local endPageIndex = math.ceil(lastIndex / numPerPage)
    local rankInfo = {}
    for pageIndex = startPageIndex, endPageIndex do
      rankInfo[pageIndex] = {}
      rankInfo[pageIndex].start = (pageIndex - 1) * numPerPage + 1
      rankInfo[pageIndex]["end"] = pageIndex * numPerPage
      if lastIndex < rankInfo[pageIndex]["end"] then
        rankInfo[pageIndex]["end"] = lastIndex
      end
      rankInfo[pageIndex].rankTotal = self:GetReqLeadboardRowNum()
      rankInfo[pageIndex].version = self:GetVision()
      rankInfo[pageIndex].rowsInfo = {}
      for index = rankInfo[pageIndex].start, rankInfo[pageIndex]["end"] do
        self:InitRankRowsInfo(rankInfo[pageIndex].rowsInfo, rankRowsInfo[index - startPos + 1])
      end
    end
    self:SetLeadboardData(rankDataRes.rank_type, rankDataRes.sub_type, rankDataRes.custom, false, rankInfo, startPageIndex, endPageIndex)
    self:SetSelfRankInfo(rankDataRes.rank_type, rankDataRes.sub_type, rankDataRes.self_rank, CareerEnumDefine.LeaderboardRelationshipChain.All)
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetHonorRankData, rankInfo[self:GetReqPageIndex()])
  end
  self.needRefresh = false
end
function HonorRankDataProxy:ReqGetRankFriendData(rankType, subType)
  if self:GetIsInLoadingData() then
    local tips = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "RequestLeadboardTooFrequently")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tips)
    return
  end
  if self.bInDataReceiving then
    LogDebug("HonorRankDataProxy", "bInDataReceiving is true, so return")
    return
  end
  self:ClearRequestFrequencyTimeHandle()
  self:SetIsInLoadingData(true)
  self:StartRequestFrequencyTimeHandle()
  self.bInDataReceiving = false
  self.rankFriendDatas = {}
  self.rankFriendDatas.rowsInfo = {}
  local data = {rank_type = rankType, sub_type = subType}
  LogDebug("HonorRankDataProxy", "send get rank friend data: ", TableToString(data))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_RANK_GET_FRIEND_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.rank_get_friend_data_req, data))
end
function HonorRankDataProxy:OnGetRankFriendDataRes(data)
  LogDebug("HonorRankDataProxy", "On receive rank friend data")
  local rankFriendDataRes = pb.decode(Pb_ncmd_cs_lobby.rank_get_friend_data_res, data)
  LogDebug("HonorRankDataProxy rank friend data:", TableToString(rankFriendDataRes))
  local errorCode = rankFriendDataRes.code
  if 0 == errorCode then
    if rankFriendDataRes.rows_info and table.count(rankFriendDataRes.rows_info) > 0 then
      for k, value in pairs(rankFriendDataRes.rows_info) do
        self:InitRankRowsInfo(self.rankFriendDatas.rowsInfo, value)
      end
    end
    if rankFriendDataRes.finish then
      self:SetSelfRankInfo(self:GetCurrentReqLeadboardType(), self:GetCurrentReqRoleID(), rankFriendDataRes.self_rank, CareerEnumDefine.LeaderboardRelationshipChain.Friend)
      local rankRowsInfo = self.rankFriendDatas.rowsInfo
      self:InitRankRowsInfo(rankRowsInfo, rankFriendDataRes.self_rank)
      self.rankFriendDatas.start = 1
      self.rankFriendDatas["end"] = table.count(rankRowsInfo)
      self:SetReqLeadboardRowNum(table.count(rankRowsInfo))
      self.rankFriendDatas.rankTotal = table.count(rankRowsInfo)
      table.sort(rankRowsInfo, function(a, b)
        local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
        if honorRankDataProxy:GetCurrentReqLeadboardType() == CareerEnumDefine.LeaderboardType.StarsRank then
          if a.rankDivisionData and b.rankDivisionData then
            return a.rankDivisionData.stars > b.rankDivisionData.stars
          end
          return false
        elseif honorRankDataProxy:GetCurrentReqLeadboardType() == CareerEnumDefine.LeaderboardType.TeamRank then
          if a.rankTeamData and b.rankTeamData then
            return a.rankTeamData.kills > b.rankTeamData.kills
          end
          return false
        end
        return false
      end)
      local startPos = 1
      local startPageIndex = math.ceil(startPos / numPerPage)
      local lastIndex = startPos + table.count(rankRowsInfo) - 1
      local endPageIndex = math.ceil(lastIndex / numPerPage)
      local rankInfo = {}
      for pageIndex = startPageIndex, endPageIndex do
        rankInfo[pageIndex] = {}
        local startIndex = (pageIndex - 1) * numPerPage + 1
        rankInfo[pageIndex].start = startIndex
        local endIndex = pageIndex * numPerPage
        rankInfo[pageIndex]["end"] = endIndex
        if lastIndex < rankInfo[pageIndex]["end"] then
          rankInfo[pageIndex]["end"] = lastIndex
        end
        rankInfo[pageIndex].rankTotal = self:GetReqLeadboardRowNum()
        rankInfo[pageIndex].version = self:GetVision()
        local pageRowsInfo = {}
        if startIndex <= endIndex then
          for x = startIndex, endIndex do
            if rankRowsInfo[x] then
              table.insert(pageRowsInfo, rankRowsInfo[x])
            end
          end
        end
        rankInfo[pageIndex].rowsInfo = pageRowsInfo
      end
      self:SetLeadboardData(self:GetCurrentReqLeadboardType(), self:GetCurrentReqRoleID(), self:GetCurrentReqSeasonId(), true, rankInfo, startPageIndex, endPageIndex)
      self.bInDataReceiving = false
      if rankRowsInfo and table.count(rankRowsInfo) > 0 and rankInfo[1] then
        GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetHonorRankData, rankInfo[1])
        return
      end
    else
      self.bInDataReceiving = true
    end
  else
    self.bInDataReceiving = false
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errorCode)
  end
end
function HonorRankDataProxy:InitRankRowsInfo(pageRows, rowInfo)
  local rankRow = {}
  rankRow.playerId = rowInfo.player_id
  rankRow.rankPos = rowInfo.rank_pos
  rankRow.nick = rowInfo.nick
  rankRow.icon = rowInfo.icon
  rankRow.icon = rowInfo.icon
  rankRow.freqRoles = rowInfo.freq_roles
  rankRow.cityCode = rowInfo.city_code
  rankRow.level = rowInfo.level
  rankRow.vcBorderId = rowInfo.vc_border_id
  rankRow.rankDivisionData = rowInfo.rank_division_data
  rankRow.rankTeamData = rowInfo.rank_team_data
  rankRow.rankRoleData = rowInfo.rank_role_data
  rankRow.lastQQLoginTime = 0
  if rankRow.playerId and rankRow.playerId == GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId() then
    local PlayerDC = UE4.UPMPlayerDataCenter.Get(LuaGetWorld())
    if PlayerDC then
      rankRow.lastQQLoginTime = PlayerDC:GetLastQQLaunchTime()
    end
  end
  table.insert(pageRows, rankRow)
end
function HonorRankDataProxy:SetCurrentReqSeasonId(seasonId)
  self.currentReqSeason = seasonId
end
function HonorRankDataProxy:GetCurrentReqSeasonId()
  return self.currentReqSeason
end
function HonorRankDataProxy:SetCurrentReqLeadboardType(leadboardType)
  self.currentReqLeadboardType = leadboardType
end
function HonorRankDataProxy:GetCurrentReqLeadboardType()
  return self.currentReqLeadboardType
end
function HonorRankDataProxy:SetCurrentReqRoleID(roleId)
  self.currentReqRoleId = roleId
end
function HonorRankDataProxy:GetCurrentReqRoleID()
  if self.currentReqRoleId then
    return self.currentReqRoleId
  end
  return 0
end
function HonorRankDataProxy:SetIsInLoadingData(bInloading)
  self.bInLoadingData = bInloading
end
function HonorRankDataProxy:GetIsInLoadingData()
  return self.bInLoadingData
end
function HonorRankDataProxy:ClearRequestFrequencyTimeHandle()
  if self.requestFrequencyTimeHandle then
    self.requestFrequencyTimeHandle:EndTask()
    self.requestFrequencyTimeHandle = nil
  end
end
function HonorRankDataProxy:StartRequestFrequencyTimeHandle()
  self.requestFrequencyTimeHandle = TimerMgr:AddTimeTask(self.bReqFrequencyTime, 0, 1, function()
    self:SetIsInLoadingData(false)
  end)
end
function HonorRankDataProxy:SetVision(visionValue)
  self.version = visionValue
end
function HonorRankDataProxy:GetVision()
  return self.version
end
function HonorRankDataProxy:SetReqLeadboardRowNum(num)
  self.reqLeadboardRowNum = num
end
function HonorRankDataProxy:GetReqLeadboardRowNum()
  if self.reqLeadboardRowNum then
    return self.reqLeadboardRowNum
  end
  return 10
end
function HonorRankDataProxy:SetLeaderboardRelationshipChain(type)
  self.leaderboardRelationshipChain = type
end
function HonorRankDataProxy:GetLeaderboardRelationshipChain()
  return self.leaderboardRelationshipChain
end
function HonorRankDataProxy:SetReqPageIndex(index)
  self.reqPageIndex = index
end
function HonorRankDataProxy:GetReqPageIndex(index)
  if self.reqPageIndex and self.reqPageIndex > 0 then
    return self.reqPageIndex
  end
  return 1
end
function HonorRankDataProxy:ClearLeadboardData()
  self.cacheLeadboardData = {}
end
function HonorRankDataProxy:SetLeadboardData(leadboardType, subType, seasonId, bIsFriend, playerInfo, startPageIndex, startPageLastIndex)
  if self.cacheLeadboardData then
    if seasonId and seasonId > 0 and not self.cacheLeadboardData[seasonId] then
      self.cacheLeadboardData[seasonId] = {}
    end
    local isFriendIndex = "all"
    if bIsFriend then
      isFriendIndex = "friend"
    end
    if not self.cacheLeadboardData[seasonId][isFriendIndex] then
      self.cacheLeadboardData[seasonId][isFriendIndex] = {}
    end
    if leadboardType then
      if not self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType then
        self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType = {}
      end
      if not self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType[leadboardType] then
        self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType[leadboardType] = {}
      end
      if leadboardType == CareerEnumDefine.LeaderboardType.HeroRank then
        if subType and subType > 0 then
          if not self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType[leadboardType].subType then
            self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType[leadboardType].subType = {}
          end
          table.insert(self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType[leadboardType].subType[subType], playerInfo)
        end
      else
        for i = startPageIndex, startPageLastIndex do
          self.cacheLeadboardData[seasonId][isFriendIndex].leadboardType[leadboardType][i] = playerInfo[i]
        end
      end
    end
  end
end
function HonorRankDataProxy:GetLeadboardData(leadboardType, subType, seasonId, relationshipChainType, inPage)
  if self.cacheLeadboardData and leadboardType and subType and seasonId and seasonId > 0 then
    local isFriendIndex = "all"
    if relationshipChainType == CareerEnumDefine.LeaderboardRelationshipChain.Friend then
      isFriendIndex = "friend"
    end
    if self.cacheLeadboardData[seasonId] then
      local tempTable = self.cacheLeadboardData[seasonId][isFriendIndex]
      if tempTable and tempTable.leadboardType and tempTable.leadboardType[leadboardType] then
        if leadboardType == CareerEnumDefine.LeaderboardType.HeroRank then
          local tempTable1 = tempTable.leadboardType[leadboardType].subType
          if tempTable1 and tempTable1[subType] then
            local tempTable2 = tempTable1.seasonId
            if tempTable2 and tempTable2[seasonId] and tempTable2[seasonId][inPage] and tempTable2[seasonId][inPage] and not self:NeedToUpdateLeadboard(tempTable2[seasonId][inPage].version) then
              return tempTable2[seasonId][inPage]
            end
          end
        elseif tempTable.leadboardType[leadboardType][inPage] and not self:NeedToUpdateLeadboard(tempTable.leadboardType[leadboardType][inPage].version) then
          return tempTable.leadboardType[leadboardType][inPage]
        end
      end
    end
  end
  if relationshipChainType == CareerEnumDefine.LeaderboardRelationshipChain.Friend then
    self:ReqGetRankFriendData(leadboardType, subType, seasonId)
  else
    self:ReqRankData(leadboardType, subType, seasonId, inPage)
  end
  return nil
end
function HonorRankDataProxy:NeedToUpdateLeadboard(pageVision)
  if not pageVision then
    return true
  end
  local serverTimeStamp = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if serverTimeStamp - pageVision > 3600000 then
    return true
  end
  return false
end
return HonorRankDataProxy
