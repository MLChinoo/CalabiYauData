local CareerRankDataProxy = class("CareerRankDataProxy", PureMVC.Proxy)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local rankInfo = {}
local rewardInfo = {}
local seasonInfo = {}
local starTableRows = {}
local divisionTableRows = {}
local divisionRewardTableRows = {}
function CareerRankDataProxy:GetRankInfo()
  return rankInfo
end
function CareerRankDataProxy:GetRewardInfo(seasonIndex)
  return rewardInfo[seasonIndex or rankInfo.season]
end
function CareerRankDataProxy:GetSeasonInfo()
  return seasonInfo
end
function CareerRankDataProxy:OnRegister()
  LogDebug("CareerRankDataProxy", "Register Career Rank Data Proxy")
  CareerRankDataProxy.super.OnRegister(self)
  starTableRows = ConfigMgr:GetDivisionStarTableRows():ToLuaTable()
  divisionTableRows = ConfigMgr:GetDivisionTableRows():ToLuaTable()
  divisionRewardTableRows = ConfigMgr:GetDivisionRewardTableRows():ToLuaTable()
  self:InitRewardInfo()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_RANKINFO_SYNC_NTF, FuncSlot(self.OnNtfRankInfoSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_QUALIFYING_CHANGE_NTF, FuncSlot(self.OnNtfQualifyingChange, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_SEASON_NTF, FuncSlot(self.OnResBattlepassSeasonNtf, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REWARD_ALL_MODULES_SYNC_NTF, FuncSlot(self.OnNtfAllModuleRewardSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REWARD_MODULE_SYNC_NTF, FuncSlot(self.OnNtfNewModuleRewardSync, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REWARD_RECIVE_RES, FuncSlot(self.OnResRewardReceive, self))
  end
end
function CareerRankDataProxy:OnRemove()
  rankInfo = {}
  rewardInfo = {}
  seasonInfo = {}
  starTableRows = {}
  divisionTableRows = {}
  divisionRewardTableRows = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_RANKINFO_SYNC_NTF, FuncSlot(self.OnNtfRankInfoSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_QUALIFYING_CHANGE_NTF, FuncSlot(self.OnNtfQualifyingChange, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_SEASON_NTF, FuncSlot(self.OnResBattlepassSeasonNtf, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REWARD_ALL_MODULES_SYNC_NTF, FuncSlot(self.OnNtfAllModuleRewardSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REWARD_MODULE_SYNC_NTF, FuncSlot(self.OnNtfNewModuleRewardSync, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REWARD_RECIVE_RES, FuncSlot(self.OnResRewardReceive, self))
  end
  CareerRankDataProxy.super.OnRemove(self)
end
function CareerRankDataProxy:InitRewardInfo()
  for key, value in pairs(divisionRewardTableRows) do
    if rewardInfo[value.Season] == nil then
      rewardInfo[value.Season] = {}
    end
    if 1 == value.Type then
      rewardInfo[value.Season].firstId = value.Id
    end
    rewardInfo[value.Season][value.Id] = {}
    rewardInfo[value.Season][value.Id].config = value
    rewardInfo[value.Season][value.Id].status = CareerEnumDefine.rewardStatus.locked
  end
end
function CareerRankDataProxy:UpdateRewardState(rewardId, status)
  local seasonId = divisionRewardTableRows[tostring(rewardId)].Season
  if rewardInfo[seasonId] and rewardInfo[seasonId][rewardId] then
    rewardInfo[seasonId][rewardId].status = status
    if status == CareerEnumDefine.rewardStatus.unlocked then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.CareerRankReward, 1)
    end
  end
end
function CareerRankDataProxy:OnNtfRankInfoSync(data)
  local rankData = pb.decode(Pb_ncmd_cs_lobby.rankinfo_sync_ntf, data)
  LogDebug("CareerRankDataProxy", "On notify rank info synchronize" .. TableToString(rankData))
  self:InitRankInfo(rankData)
end
function CareerRankDataProxy:OnNtfQualifyingChange(data)
  local starChange = pb.decode(Pb_ncmd_cs_lobby.qualifying_change_ntf, data)
  LogDebug("CareerRankDataProxy", "Star change: " .. TableToString(starChange))
  if rankInfo.season == nil then
    return
  end
  rankInfo.stars = starChange.stars
  rankInfo.scores = starChange.scores
  rankInfo.oldStars = starChange.old_stars
  local currentSeason = rankInfo.season
  rankInfo.divisionOfSeasons[currentSeason].finalStar = starChange.stars
  rankInfo.divisionOfSeasons[currentSeason].topStar = math.max(rankInfo.divisionOfSeasons[currentSeason].topStar, starChange.stars)
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.StarChange, starChange)
end
function CareerRankDataProxy:OnResBattlepassSeasonNtf(data)
  seasonInfo = pb.decode(Pb_ncmd_cs_lobby.battlepass_season_ntf, data)
end
function CareerRankDataProxy:OnNtfAllModuleRewardSync(data)
  local allModuleReward = pb.decode(Pb_ncmd_cs_lobby.reward_all_modules_sync_ntf, data)
  if allModuleReward.all_reward_modules then
    for _, value in pairs(allModuleReward.all_reward_modules) do
      if value.module_id == GlobalEnumDefine.ERewardModule.Rank then
        local rewardList = value.reward_info_list
        for _, rewardItem in pairs(rewardList) do
          self:UpdateRewardState(rewardItem.reward_id, rewardItem.status)
        end
      end
    end
  end
end
function CareerRankDataProxy:OnNtfNewModuleRewardSync(data)
  local newModuleReward = pb.decode(Pb_ncmd_cs_lobby.reward_module_sync_ntf, data)
  LogDebug("CareerRankDataProxy", TableToString(newModuleReward))
  if newModuleReward.single_reward_module.module_id == GlobalEnumDefine.ERewardModule.Rank then
    local rewardList = newModuleReward.single_reward_module.reward_info_list
    for _, value in pairs(rewardList) do
      self:UpdateRewardState(value.reward_id, value.status)
    end
  end
end
function CareerRankDataProxy:ReqReward(rewardId)
  local data = {
    module_id = GlobalEnumDefine.ERewardModule.Rank,
    reward_id = rewardId
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_REWARD_RECIVE_REQ, pb.encode(Pb_ncmd_cs_lobby.reward_recive_req, data))
end
function CareerRankDataProxy:OnResRewardReceive(data)
  local rewardReceive = pb.decode(Pb_ncmd_cs_lobby.reward_recive_res, data)
  LogDebug("CareerRankDataProxy", TableToString(rewardReceive))
  if rewardReceive.module_id == GlobalEnumDefine.ERewardModule.Rank then
    if 0 == rewardReceive.code then
      self:UpdateRewardState(rewardReceive.reward_id, rewardReceive.status)
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.CareerRankReward, -1)
      LogDebug("CareerRankDataProxy", "Career rank red dot cnt: %d", RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.CareerRank))
    end
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.AcquireRankPrize, rewardReceive)
  end
end
function CareerRankDataProxy:InitRankInfo(inRankData)
  rankInfo.season = inRankData.season
  rankInfo.stars = inRankData.stars
  rankInfo.scores = inRankData.scores
  rankInfo.isNewSeason = inRankData.is_new_season
  rankInfo.oldStars = inRankData.old_stars
  rankInfo.divisionOfSeasons = {}
  for _, value in pairs(inRankData.info_list) do
    local seasonDivision = {}
    seasonDivision.topStar = value.top_stars
    seasonDivision.finalStar = value.final_stars
    rankInfo.divisionOfSeasons[value.season] = seasonDivision
  end
  if 0 == table.count(inRankData.info_list) or rankInfo.divisionOfSeasons[inRankData.season] == nil then
    local seasonDivision = {}
    seasonDivision.topStar = inRankData.stars
    seasonDivision.finalStar = inRankData.stars
    rankInfo.divisionOfSeasons[inRankData.season] = seasonDivision
  end
  rankInfo.isGrading = inRankData.is_grading
  rankInfo.gradingInfo = inRankData.grading_standing
end
function CareerRankDataProxy:GetDivision(starId)
  local starShow = 0
  local divisionCfg
  local topDivisionId = 0
  local topStar = 0
  for _, value in pairs(starTableRows) do
    if topStar < value.StarId then
      topStar = value.StarId
      topDivisionId = value.Division
    end
  end
  local divisionStarCfg
  if starId >= topStar then
    starShow = starId - topStar + 1
    divisionStarCfg = starTableRows[tostring(topStar)]
  else
    divisionStarCfg = starTableRows[tostring(starId)]
    if nil == divisionStarCfg then
      return 0, nil
    end
    starShow = divisionStarCfg.ShowStar
  end
  divisionCfg = divisionTableRows[tostring(divisionStarCfg.Division)]
  return starShow, divisionCfg
end
function CareerRankDataProxy:GetDivisionConfigRow(rankID)
  return divisionTableRows[tostring(rankID)]
end
function CareerRankDataProxy:GetRank()
  if rankInfo.stars then
    local _, divisionCfg = self:GetDivision(rankInfo.stars)
    return divisionCfg.Id
  else
    LogWarn("CareerRankDataProxy", "Don't have rank info")
    return 0
  end
end
function CareerRankDataProxy:GetDivisionSubLevelTexture(divisionCfg)
  if not divisionCfg then
    return
  end
  local pathString = UE4.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(divisionCfg.IconDivisionLevelS)
  if "" ~= pathString then
    return divisionCfg.IconDivisionLevelS
  end
end
return CareerRankDataProxy
