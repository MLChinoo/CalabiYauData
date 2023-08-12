local PlayerDataProxy = class("PlayerDataProxy", PureMVC.Proxy)
local playerInfo = {}
local battleInfo = {}
local rankInfo = {}
local collectionInfo = {}
local roleEmploysInfo = {}
function PlayerDataProxy:GetPlayerInfo()
  return playerInfo
end
function PlayerDataProxy:GetBattleInfo()
  return battleInfo
end
function PlayerDataProxy:GetRankInfo()
  return rankInfo
end
function PlayerDataProxy:GetCollectionInfo()
  return collectionInfo
end
function PlayerDataProxy:GetRoleEmployInfo()
  return roleEmploysInfo
end
function PlayerDataProxy:OnRegister()
  LogDebug("PlayerDataProxy", "Register Career Data Proxy")
  PlayerDataProxy.super.OnRegister(self)
  self.isRequiringData = false
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_CAREER_INFO_RES, FuncSlot(self.OnResCareerInfo, self))
  end
end
function PlayerDataProxy:OnRemove()
  playerInfo = {}
  battleInfo = {}
  rankInfo = {}
  collectionInfo = {}
  roleEmploysInfo = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_CAREER_INFO_RES, FuncSlot(self.OnResCareerInfo, self))
  end
  PlayerDataProxy.super.OnRemove(self)
end
function PlayerDataProxy:ReqPlayerData(inPlayerId)
  self.isRequiringData = true
  local data = {player_id = inPlayerId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_CAREER_INFO_REQ, pb.encode(Pb_ncmd_cs_lobby.career_info_req, data))
end
function PlayerDataProxy:OnResCareerInfo(data)
  LogDebug("PlayerDataProxy", "On receive career info")
  local careerData = pb.decode(Pb_ncmd_cs_lobby.career_info_res, data)
  if 0 ~= careerData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, careerData.code)
    return
  end
  if careerData.career_info then
    playerInfo = careerData.career_info.player
    battleInfo = careerData.career_info.battle_infos
    rankInfo = careerData.career_info.rank
    collectionInfo = careerData.career_info.collect
    if careerData.career_info.role_employs then
      self:InitRoleEmploysInfo(careerData.career_info.role_employs)
    end
    if self.isRequiringData then
      GameFacade:SendNotification(NotificationDefines.PlayerProfile.ShowDataCmd)
      self.isRequiringData = false
    end
  end
end
function PlayerDataProxy:InitRoleEmploysInfo(roleEmploys)
  roleEmploysInfo = {}
  for key, value in pairs(roleEmploys) do
    if roleEmploysInfo[value.game_mode] == nil then
      roleEmploysInfo[value.game_mode] = {}
    end
    roleEmploysInfo[value.game_mode][value.role_id] = {
      count = value.count,
      winCount = value.win_count
    }
  end
end
return PlayerDataProxy
