local SettingCombatProxy = class("SettingCombatProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local defaultVoiceValue = 100
function SettingCombatProxy:OnRegister()
  SettingCombatProxy.super.OnRegister(self)
  self.voiceMap = {}
  self.friendInviteStatusMap = {}
  self.teamInviteStatusMap = {}
  self.wordChatStatusMap = {}
  self.signalStatusMap = {}
  self.allWordChatStatus = false
  self.teamInviteIdArr = {}
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnEndGameDelegateHandle = DelegateMgr:AddDelegate(GlobalDelegateManager.OnEndGameDelegateSubsystem, self, "OnEndGameDelegate")
    self.OnBeginGameDelegateHandle = DelegateMgr:AddDelegate(GlobalDelegateManager.OnBeginGameDelegateSubsystem, self, "OnBeginGameDelegate")
    self.OnOneKeyShieldPlayerHandle = DelegateMgr:AddDelegate(GlobalDelegateManager.OnPlayreForbidStateChangeDelegate, self, "OnOneKeyShieldPlayer")
  end
end
function SettingCombatProxy:OnRemove()
  SettingCombatProxy.super.OnRemove(self)
  self.voiceMap = {}
  self.friendInviteStatusMap = {}
  self.teamInviteStatusMap = {}
  self.wordChatStatusMap = {}
  self.signalStatusMap = {}
  self.allWordChatStatus = false
  self.teamInviteIdArr = {}
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnBeginGameDelegateSubsystem, self.OnBeginGameDelegateHandle)
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnEndGameDelegateSubsystem, self.OnEndGameDelegateHandle)
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnPlayreForbidStateChangeDelegate, self.OnOneKeyShieldPlayerHandle)
  end
end
function SettingCombatProxy:IsFriend(name)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  for k, v in pairs(friendDataProxy.allFriendMap) do
    if v.nick == name then
      return true
    end
  end
  return false
end
function SettingCombatProxy:GetPlayerData(modeType)
  if modeType == UE4.EPMGameModeType.Spar then
    return self:GetPlayerDefaultData()
  elseif modeType == UE4.EPMGameModeType.Team then
    return self:GetPlayerTeamData()
  else
    return self:GetPlayerDefaultData()
  end
end
function SettingCombatProxy:GetPlayerDefaultData()
  local myPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(LuaGetWorld(), 0)
  local myPlayerState = myPlayerController.PlayerState
  local myTeamID = myPlayerState.AttributeTeamID
  local myPlayerId = myPlayerState.PlayerId
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local gamestate = LuaGetWorld().GameState
  local MyTeamDataTbl = {}
  local EnemyTeamDataTbl = {}
  if myPlayerController:IsOnlyASpectator() then
    myTeamID = gamestate:GetDefendTeam()
  end
  for i = 1, gamestate.PlayerArray:Length() do
    local playerstate = gamestate.PlayerArray:Get(i)
    if playerstate.bOnlySpectator == false then
      local bEnemy = true
      if playerstate.AttributeTeamID == myTeamID then
        bEnemy = false
      end
      local tempDataTbl = {}
      tempDataTbl.name = playerstate:GetPlayerName()
      local RoleSkinTableRow = roleProxy:GetRoleSkin(playerstate.RoleSkinId)
      if nil == RoleSkinTableRow then
        break
      end
      tempDataTbl.imageHead = RoleSkinTableRow.IconRoleHud
      tempDataTbl.PlayerId = playerstate.PlayerId
      tempDataTbl.bIsFriend = false
      tempDataTbl.bIsSelf = false
      if playerstate.AttributeTeamID == myTeamID then
        if myPlayerState.UID ~= playerstate.UID then
          if self:IsFriend(tempDataTbl.name) then
            tempDataTbl.bIsFriend = true
          else
            tempDataTbl.bIsFriend = false
          end
        else
          tempDataTbl.bIsSelf = true
        end
      end
      tempDataTbl.uid = playerstate.UID
      tempDataTbl.teamFlag = not bEnemy
      if bEnemy then
        EnemyTeamDataTbl[#EnemyTeamDataTbl + 1] = tempDataTbl
      else
        MyTeamDataTbl[#MyTeamDataTbl + 1] = tempDataTbl
      end
    end
  end
  local data = {EnemyTeamData = EnemyTeamDataTbl, MyTeamData = MyTeamDataTbl}
  return data
end
function SettingCombatProxy:GetPlayerTeamData()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(LuaGetWorld())
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local myTeamID = MyPlayerState.AttributeTeamID
  local myPlayerId = MyPlayerState.PlayerId
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local MyTeamDataTbl = {}
  local EnemyTeamDataTbl = {}
  local EnemyTempTeamDataTbl = {}
  if MyPlayerController:IsOnlyASpectator() then
    myTeamID = GameState:GetDefendTeam()
  end
  local teamIdFlag = {}
  local teamIdArr = {}
  for i = 1, GameState.PlayerArray:Length() do
    local playerstate = GameState.PlayerArray:Get(i)
    if playerstate.bOnlySpectator == false then
      local bEnemy = true
      if playerstate.AttributeTeamID == myTeamID then
        bEnemy = false
      end
      local tempDataTbl = {}
      tempDataTbl.name = playerstate:GetPlayerName()
      local RoleSkinTableRow = roleProxy:GetRoleSkin(playerstate.RoleSkinId)
      if nil == RoleSkinTableRow then
        break
      end
      tempDataTbl.imageHead = RoleSkinTableRow.IconRoleHud
      tempDataTbl.PlayerId = playerstate.PlayerId
      tempDataTbl.bIsFriend = false
      tempDataTbl.bIsSelf = false
      if playerstate.AttributeTeamID == myTeamID then
        if MyPlayerState.UID ~= playerstate.UID then
          if self:IsFriend(tempDataTbl.name) then
            tempDataTbl.bIsFriend = true
          else
            tempDataTbl.bIsFriend = false
          end
        else
          tempDataTbl.bIsSelf = true
        end
      end
      tempDataTbl.uid = playerstate.UID
      tempDataTbl.teamFlag = not bEnemy
      if bEnemy then
        EnemyTempTeamDataTbl[playerstate.AttributeTeamID] = EnemyTempTeamDataTbl[playerstate.AttributeTeamID] or {}
        local tempTbl = EnemyTempTeamDataTbl[playerstate.AttributeTeamID]
        tempTbl[#tempTbl + 1] = tempDataTbl
        if teamIdFlag[playerstate.AttributeTeamID] == nil then
          teamIdFlag[playerstate.AttributeTeamID] = true
          teamIdArr[#teamIdArr + 1] = playerstate.AttributeTeamID
        end
      else
        MyTeamDataTbl[#MyTeamDataTbl + 1] = tempDataTbl
      end
    end
  end
  local index = 1
  for i, teamId in ipairs(teamIdArr) do
    EnemyTeamDataTbl[index] = EnemyTempTeamDataTbl[teamId]
    index = index + 1
  end
  if nil == EnemyTeamDataTbl[1] then
    EnemyTeamDataTbl[1] = {}
  end
  if nil == EnemyTeamDataTbl[2] then
    EnemyTeamDataTbl[2] = {}
  end
  local data = {EnemyTeamData = EnemyTeamDataTbl, MyTeamData = MyTeamDataTbl}
  table.print(data)
  return data
end
function SettingCombatProxy:CheckIsCustomRoomMode()
  local RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomModeType = RoomProxy:GetGameModeType()
  if roomModeType == GameModeSelectNum.GameModeType.Room then
    return true
  end
  return false
end
function SettingCombatProxy:CheckIsInGame()
  local gamestate = LuaGetWorld().GameState
  if gamestate and gamestate.GetModeType and gamestate:GetModeType() ~= UE4.EPMGameModeType.FrontEnd then
    return true
  else
    return false
  end
end
function SettingCombatProxy:GetVoiceByPlayerId(playerId)
  if self.voiceMap[playerId] == nil then
    self.voiceMap[playerId] = defaultVoiceValue
  end
  return self.voiceMap[playerId]
end
function SettingCombatProxy:SetVoiceByPlayerId(playerId, value)
  self.voiceMap[playerId] = value
end
function SettingCombatProxy:GetFriendInviteByPlayerId(playerId)
  if self.friendInviteStatusMap[playerId] == nil then
    self.friendInviteStatusMap[playerId] = false
  end
  return self.friendInviteStatusMap[playerId]
end
function SettingCombatProxy:SetFriendInviteByPlayerId(playerId, value)
  self.friendInviteStatusMap[playerId] = value
end
function SettingCombatProxy:GetTeamInviteStatusByPlayerId(playerId)
  if self.teamInviteStatusMap[playerId] == nil then
    self.teamInviteStatusMap[playerId] = false
  end
  return self.teamInviteStatusMap[playerId]
end
function SettingCombatProxy:SetTeamInviteStatusByPlayerId(playerId, value)
  self.teamInviteStatusMap[playerId] = value
end
function SettingCombatProxy:GetWordChatStatusByPlayerId(playerId)
  if self.wordChatStatusMap[playerId] == nil then
    self.wordChatStatusMap[playerId] = true
  end
  return self.wordChatStatusMap[playerId]
end
function SettingCombatProxy:SetWordChatStatusByPlayerId(playerId, value)
  self.wordChatStatusMap[playerId] = value
  LogWarn("SettingCombatProxy", "Update chat blacklist: " .. playerId .. " %s", value)
  local ChatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
  ChatDataProxy:AddToChatBlacklist(playerId, not value)
end
function SettingCombatProxy:GetSignalStatusByPlayerId(playerId)
  if self.signalStatusMap[playerId] == nil then
    self.signalStatusMap[playerId] = true
  end
  return self.signalStatusMap[playerId]
end
function SettingCombatProxy:SetSignalStatusByPlayerId(playerId, value)
  self.signalStatusMap[playerId] = value
  self:addShieldSetByPlayerID(not value, playerId)
end
function SettingCombatProxy:addShieldSetByPlayerID(bAdd, playerID)
  local inst = UE4.UPMMarkPointGameSubSystem.GetInst(LuaGetWorld())
  if bAdd then
    LogInfo("SettingCombatProxy:addShieldSetByPlayerID", tostring(playerID))
    inst:AddSheildSet(tostring(playerID), true)
  else
    LogInfo("SettingCombatProxy:removeShieldSetByPlayerID", tostring(playerID))
    inst:AddSheildSet(tostring(playerID), false)
  end
end
function SettingCombatProxy:AddTeamInviteId(id)
  local bFind = false
  for i, v in ipairs(self.teamInviteIdArr) do
    if v == id then
      bFind = true
      break
    end
  end
  if false == bFind then
    self.teamInviteIdArr[#self.teamInviteIdArr + 1] = id
    LogInfo("SettingCombatProxy:AddTeamInviteId", "add ID" .. tostring(id))
  else
    LogInfo("SettingCombatProxy:AddTeamInviteId", "repeat ID or id is zero" .. tostring(id))
  end
end
function SettingCombatProxy:SendTeamInvteReq()
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local teamInfo = roomProxy:GetTeamInfo()
  if #self.teamInviteIdArr > 0 and teamInfo and teamInfo.teamId then
    LogInfo("SettingCombatProxy:SendTeamInvteReq", TableToString(self.teamInviteIdArr))
    roomProxy:ReqTeamInvite(teamInfo.teamId, self.teamInviteIdArr)
  else
    LogInfo("SettingCombatProxy:SendTeamInvteReq", "teamInviteIdArr is Empty")
  end
  self.teamInviteIdArr = {}
end
function SettingCombatProxy:OnEndGameDelegate()
  LogInfo("SettingCombatProxy", "OnEndGameDelegate")
  local ChatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
  for playerId, value in pairs(self.wordChatStatusMap) do
    ChatDataProxy:AddToChatBlacklist(playerId, false)
  end
end
function SettingCombatProxy:VoiceMapEmpty()
  self.voiceMap = {}
end
function SettingCombatProxy:IsRobotPlayer(data)
  if data and data.PlayerId then
    return 0 == data.PlayerId
  end
  LogInfo("SettingCombatProxy", "IsRobotPlayer data  is nil")
  return true
end
function SettingCombatProxy:OnBeginGameDelegate()
  LogInfo("SettingCombatProxy", "OnBeginGameDelegate")
  self.friendInviteStatusMap = {}
  self.teamInviteStatusMap = {}
  self.wordChatStatusMap = {}
  self.signalStatusMap = {}
  self.allWordChatStatus = false
end
function SettingCombatProxy:OnOneKeyShieldPlayer(playerIDStr, bIsForbid)
  local numberPID = tonumber(playerIDStr)
  if numberPID < 0 then
    return
  end
  local inst = UE4.UPMMarkPointGameSubSystem.GetInst(LuaGetWorld())
  if inst then
    self:SetSignalStatusByPlayerId(numberPID, not bIsForbid)
  end
  self:SetWordChatStatusByPlayerId(numberPID, not bIsForbid)
end
return SettingCombatProxy
