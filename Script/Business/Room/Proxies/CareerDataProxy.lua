local CareerDataProxy = class("CareerDataProxy", PureMVC.Proxy)
function CareerDataProxy:ctor(proxyName, data)
  CareerDataProxy.super.ctor(self, proxyName, data)
end
function CareerDataProxy:OnRegister()
  CareerDataProxy.super.OnRegister(self)
  self:InitTableCfg()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
end
function CareerDataProxy:InitTableCfg()
end
function CareerDataProxy:ReqAvatarList()
  local careerGetHeadIconsReq = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.career_get_head_icons_req, careerGetHeadIconsReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_CAREER_GET_HEAD_ICONS_REQ, req)
  end
end
function CareerDataProxy:ReqChangeAvatar(avatarId)
  local careerSetHeadIconReq = {}
  careerSetHeadIconReq.icon_id = avatarId
  local req = pb.encode(Pb_ncmd_cs_lobby.career_set_head_icon_req, careerSetHeadIconReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_CAREER_GET_HEAD_ICONS_REQ, req)
  end
end
function CareerDataProxy:ReqThumb(playerId)
  local careerLaudReq = {}
  careerLaudReq.player_id = playerId
  local req = pb.encode(Pb_ncmd_cs_lobby.career_laud_req, careerLaudReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_CAREER_LAUD_REQ, req)
  end
end
function CareerDataProxy:ReqAchievementList(playerId)
  local achievementListReq = {}
  achievementListReq.player_id = playerId
  local req = pb.encode(Pb_ncmd_cs_lobby.achievement_list_req, achievementListReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_ACHIEVEMENT_LIST_REQ, req)
  end
end
function CareerDataProxy:ReqBattleRecord(index, playerId)
  local standingsListReq = {}
  standingsListReq.player_id = playerId
  standingsListReq.index = index
  local req = pb.encode(Pb_ncmd_cs_lobby.standings_list_req, standingsListReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIST_REQ, req)
  end
end
function CareerDataProxy:ReqBattleInfo(roomId, playerId)
  local standingsInfoReq = {}
  standingsInfoReq.player_id = playerId
  standingsInfoReq.room_id = roomId
  local req = pb.encode(Pb_ncmd_cs_lobby.standings_list_req, standingsInfoReq)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_STANDINGS_INFO_REQ, req)
  end
end
function CareerDataProxy:GetPlayerInfoRef()
  return self.playerInfo
end
function CareerDataProxy:GetFriendInfoRef()
  return self.friendInfo
end
function CareerDataProxy:GetCareerDataArrayRef()
  return self.careerDataArray
end
function CareerDataProxy:GetFriendCareerDataArrayRef()
  return self.friendCareerDataArray
end
function CareerDataProxy:GetCareerRankRef()
  return self.careerRank
end
function CareerDataProxy:GetFriendCareerRankRef()
  return self.friendCareerRank
end
function CareerDataProxy:GetPlayerCollectionRef()
  return self.playerCollection
end
function CareerDataProxy:GetFriendCollectionRef()
  return self.friendCollection
end
return CareerDataProxy
