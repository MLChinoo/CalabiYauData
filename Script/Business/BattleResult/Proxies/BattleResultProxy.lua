local BattleResultProxy = class("BattleResultProxy", PureMVC.Proxy)
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function BattleResultProxy:OnRegister()
  LogDebug("BattleResultProxy", "OnRegister")
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(LuaGetWorld())
  if GameState and GameState.GetModeType then
    self.GameModeType = GameState:GetModeType()
  end
  if not self.registered then
    self:ResigterNetMsgHandle()
    self:RecordRoleIntimacysPreBattle()
    self:RecordRoleTasksPreBattle()
    self:RecordAccountDataPreBattle()
    self:RecordRankDataPreBattle()
    self:RecordBPDataPreBattle()
    self:RecordBPTasksPreBattle()
    BattleResultProxy.super.OnRegister(self)
    self.registered = true
  end
end
function BattleResultProxy:OnRemove()
  LogDebug("BattleResultProxy", "OnRemove")
  if self.GameModeType and self.GameModeType == UE4.EPMGameModeType.TeamGuide then
    local NewGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
    if NewGuideProxy and not NewGuideProxy:IsAllGuideComplete() and not self.bSetNewGuideSet then
      NewGuideProxy:SetCurComplete()
      self.bSetNewGuideSet = true
    end
  end
  if self.settle_battle_game_ntf and not self.bSetResultState then
    if self.GameModeType ~= UE4.EPMGameModeType.TeamGuide then
      self:LeaveSettle()
    end
    self.bSetResultState = true
  end
  self:RemoveNetMsgHandle()
  BattleResultProxy.super.OnRemove(self)
  self.registered = nil
end
function BattleResultProxy:ResigterNetMsgHandle()
  self.bSetNewGuideSet = false
  self.bSetResultState = false
  self.settle_battle_game_ntf = nil
  self.settle_qualifying_ntf = nil
  self.BPBaseInfoUpdated = false
  self.BPTasksUpdated = {}
  self.standings_like_ntfs = {}
  self.AccountAndRoleRewards = {}
  self.AccountAndRoleRewards.overflowItemList = {}
  self.AccountAndRoleRewards.itemList = {}
  self.CachedPlayerList = {}
  local PlayerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  self.MyPlayerId = PlayerAttrProxy:GetPlayerId()
  LogDebug("BattleResultProxy", "MyPlayerId %s", self.MyPlayerId)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_SETTLE_QUALIFYING_NTF, FuncSlot(self.OnNtfSettleQualifying, self))
    lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_SETTLE_BATTLE_GAME_NTF, FuncSlot(self.OnNtfSettleBattle, self))
    lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_ATTRIBUTE_SYNC_NTF, FuncSlot(self.OnResAttrSyncNtf, self))
    lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_PROGRESS_NTF, FuncSlot(self.OnNtfTaskProgress, self))
    lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIKE_NTF, FuncSlot(self.OnStandingsLikeNtf, self))
  end
end
function BattleResultProxy:RemoveNetMsgHandle()
  self.bSetNewGuideSet = false
  self.bSetResultState = false
  self.settle_battle_game_ntf = nil
  self.settle_qualifying_ntf = nil
  self.BPBaseInfoUpdated = false
  self.BPTasksUpdated = {}
  self.standings_like_ntfs = {}
  self.AccountAndRoleRewards = {}
  self.AccountAndRoleRewards.overflowItemList = {}
  self.AccountAndRoleRewards.itemList = {}
  self.MyPlayerId = nil
  self.MyObTeamId = nil
  self.CachedPlayerList = nil
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SETTLE_QUALIFYING_NTF, FuncSlot(self.OnNtfSettleQualifying, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SETTLE_BATTLE_GAME_NTF, FuncSlot(self.OnNtfSettleBattle, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ATTRIBUTE_SYNC_NTF, FuncSlot(self.OnResAttrSyncNtf, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_TASK_PROGRESS_NTF, FuncSlot(self.OnNtfTaskProgress, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIKE_NTF, FuncSlot(self.OnStandingsLikeNtf, self))
  end
end
function BattleResultProxy:OnNtfSettleQualifying(data)
  self.settle_qualifying_ntf = pb.decode(Pb_ncmd_cs_lobby.settle_qualifying_ntf, data)
  LogDebug("settle_qualifying_ntf", TableToString(self.settle_qualifying_ntf))
  GameFacade:SendNotification(NotificationDefines.BattleResult.ResultRankDataRecv)
end
function BattleResultProxy:OnResAttrSyncNtf(data)
  local attribute_sync_ntf = pb.decode(Pb_ncmd_cs_lobby.attribute_sync_ntf, data)
  for key, value in pairs(attribute_sync_ntf.items) do
    if value.id == GlobalEnumDefine.PlayerAttributeType.emExplore then
      self.BPBaseInfoUpdated = true
      TimerMgr:RunNextFrame(function()
        GameFacade:SendNotification(NotificationDefines.BattleResult.BattleResultBPBaseInfoUpdated)
      end)
    end
  end
end
function BattleResultProxy:OnNtfTaskProgress(data)
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local battlepass_task_progress_ntf = pb.decode(Pb_ncmd_cs_lobby.battlepass_task_progress_ntf, data)
  for key, value in pairs(battlepass_task_progress_ntf.update_task_datas) do
    local IsChangedAfterBattle = false
    if self.BPTasksPreBattle[value.task_id] and self.BPTasksPreBattle[value.task_id].progressMap[1] ~= value.progresses[1].value then
      IsChangedAfterBattle = true
    end
    if IsChangedAfterBattle and not self.BPTasksUpdated[value.task_id] then
      local taskData = {}
      taskData.taskId = value.task_id
      taskData.taskType = value.task_type
      taskData.state = value.state
      if value.progresses then
        taskData.progressMap = {}
        for key, sValue in pairs(value.progresses) do
          table.insert(taskData.progressMap, sValue.value)
        end
      end
      local TaskCfg = BattlePassProxy:GetTaskCfgById(taskData.taskId)
      taskData.taskTarget = TaskCfg.TaskConditions:Get(1).MainCondition.Num
      taskData.finished = (taskData.progressMap[1] or 0) >= taskData.taskTarget
      if taskData.progressMap[1] and taskData.progressMap[1] > 0 then
        self.BPTasksUpdated[taskData.taskId] = taskData
        GameFacade:SendNotification(NotificationDefines.BattleResult.BattleResultBPTaskUpdated, taskData)
      end
    end
  end
end
function BattleResultProxy:AddAccountAndRoleRewardItem(item)
  table.insert(self.AccountAndRoleRewards.itemList, item)
end
function BattleResultProxy:GetAccountAndRoleRewards()
  return self.AccountAndRoleRewards
end
function BattleResultProxy:GetBPTasksUpdated()
  local tasks = {}
  for key, task in pairs(self.BPTasksUpdated) do
    table.insert(tasks, task)
  end
  local CompareFunc = function(a, b)
    if a.finished and b.finished then
      return a.taskId < b.taskId
    end
    if a.finished then
      return true
    end
    if b.finished then
      return false
    end
    return a.taskId < b.taskId
  end
  table.sort(tasks, CompareFunc)
  return tasks
end
function BattleResultProxy:IsWinnerTeam(TeamId)
  for key, value in pairs(self.settle_battle_game_ntf.winner_team) do
    if TeamId == value then
      return true
    end
  end
  return false
end
function BattleResultProxy:IsDraw()
  return 0 == #self.settle_battle_game_ntf.winner_team
end
function BattleResultProxy:GetRoomId()
  if self.settle_battle_game_ntf then
    return self.settle_battle_game_ntf.room_id or 0
  end
  return 0
end
function BattleResultProxy:GetMapId()
  if self.settle_battle_game_ntf then
    return self.settle_battle_game_ntf.map_id or 0
  end
  return 0
end
function BattleResultProxy:OnNtfSettleBattle(data)
  self.settle_battle_game_ntf = pb.decode(Pb_ncmd_cs_lobby.settle_battle_game_ntf, data)
  local comp = function(a, b)
    if a.scores ~= b.scores then
      return a.scores > b.scores
    elseif a.kill_num ~= b.kill_num then
      return a.kill_num > b.kill_num
    elseif a.damage ~= b.damage then
      return a.damage > b.damage
    end
    return false
  end
  table.sort(self.settle_battle_game_ntf.players, comp)
  local Teams = {}
  for key, player in pairs(self.settle_battle_game_ntf.players) do
    local teamId = player.team_id
    if not Teams[teamId] then
      Teams[teamId] = {}
    end
    table.insert(Teams[teamId], player)
  end
  if self:IsDraw() then
    local mvp
    for key, player in pairs(self.settle_battle_game_ntf.players) do
      mvp = mvp or player
      if player.mvp and player.scores == mvp.scores and player.kill_num == mvp.kill_num and player.damage == mvp.damage then
        player.RealMvp = 1
      else
        player.RealMvp = 0
      end
    end
    for TeamId, Team in pairs(Teams) do
      local TeamMvp
      for key, player in pairs(Team) do
        TeamMvp = TeamMvp or player
        if player.mvp and player.scores == TeamMvp.scores and player.kill_num == TeamMvp.kill_num and player.damage == TeamMvp.damage then
          if 1 ~= player.RealMvp then
            player.RealMvp = 2
          end
        else
          player.RealMvp = 0
        end
      end
    end
  else
    for TeamId, Team in pairs(Teams) do
      local TeamMvp
      for key, player in pairs(Team) do
        TeamMvp = TeamMvp or player
        if player.mvp and player.scores == TeamMvp.scores and player.kill_num == TeamMvp.kill_num and player.damage == TeamMvp.damage then
          player.RealMvp = self:IsWinnerTeam(player.team_id) and 1 or 2
        else
          player.RealMvp = 0
        end
      end
    end
  end
  LogDebug("settle_battle_game_ntf", TableToString(self.settle_battle_game_ntf))
  GameFacade:SendNotification(NotificationDefines.BattleResult.BattleResultReviceData)
end
function BattleResultProxy:GetSettleQualifyingData()
  return self.settle_qualifying_ntf
end
function BattleResultProxy:GetSettleBattleGameData()
  return self.settle_battle_game_ntf
end
function BattleResultProxy:GetLastRoleSkinId()
  for key, value in pairs(self.settle_battle_game_ntf.roles) do
    if value.is_final then
      return value.role_skin_id
    end
  end
end
function BattleResultProxy:GetLastWeaponSkinId()
  for key, value in pairs(self.settle_battle_game_ntf.roles) do
    if value.is_final then
      return value.gun_skin_id
    end
  end
end
function BattleResultProxy:StandingsLike(standings_like_req)
  LogDebug("standings_like_req", TableToString(standings_like_req))
  local req = pb.encode(Pb_ncmd_cs_lobby.standings_like_req, standings_like_req)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_STANDINGS_LIKE_REQ, req)
  end
end
function BattleResultProxy:OnStandingsLikeNtf(data)
  local standings_like_ntf = pb.decode(Pb_ncmd_cs_lobby.standings_like_ntf, data)
  table.insert(self.standings_like_ntfs, standings_like_ntf)
  LogDebug("standings_like_ntf", TableToString(standings_like_ntf))
  GameFacade:SendNotification(NotificationDefines.BattleResult.BattleResultLikeNtf, standings_like_ntf)
end
function BattleResultProxy:GetStandingsLikeNtfs()
  return self.standings_like_ntfs
end
function BattleResultProxy:LeaveSettle()
  local req = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.leave_settle_req, req)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_LEAVE_SETTLE_REQ, req)
  end
end
function BattleResultProxy:RecordBPDataPreBattle()
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  self.BPDataPreBattle = {}
  self.BPDataPreBattle.explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
  LogDebug("BPDataPreBattle", TableToString(self.BPDataPreBattle))
end
function BattleResultProxy:GetBPDataPreBattle()
  return self.BPDataPreBattle
end
function BattleResultProxy:IsBPBaseInfoUpdated()
  return self.BPBaseInfoUpdated
end
function BattleResultProxy:RecordRankDataPreBattle()
  local CareerRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy)
  local RankData = CareerRankDataProxy:GetRankInfo()
  self.RankDataPreBattle = {}
  self.RankDataPreBattle = table.clone(RankData)
  LogDebug("RankDataPreBattle", TableToString(self.RankDataPreBattle))
end
function BattleResultProxy:GetRankDataPreBattle()
  return self.RankDataPreBattle
end
function BattleResultProxy:RecordAccountDataPreBattle()
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  self.AccountDataPreBattle = {}
  self.AccountDataPreBattle.PreLevel = playerAttrProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
  self.AccountDataPreBattle.PreExp = playerAttrProxy:GetPlayerCurExperience()
  self.AccountDataPreBattle.PreUpExp = playerAttrProxy:GetLevelUpExperience(self.AccountDataPreBattle.PreLevel)
  self.AccountDataPreBattle.PreExpTotal = playerAttrProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emEXP)
  LogDebug("AccountDataPreBattle", TableToString(self.AccountDataPreBattle))
end
function BattleResultProxy:GetAccountDataPreBattle()
  return self.AccountDataPreBattle
end
function BattleResultProxy:RecordBPTasksPreBattle()
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local DayTasks = BattlePassProxy:GetDayTasks()
  local WeekTasks = BattlePassProxy:GetWeekTasks()
  local LoopTasks = BattlePassProxy:GetLoopTasks()
  self.BPTasksPreBattle = {}
  for key, Task in pairs(DayTasks) do
    self.BPTasksPreBattle[Task.taskId] = table.clone(Task)
  end
  for key, Task in pairs(WeekTasks) do
    self.BPTasksPreBattle[Task.taskId] = table.clone(Task)
  end
  for key, Task in pairs(LoopTasks) do
    self.BPTasksPreBattle[Task.taskId] = table.clone(Task)
  end
  LogDebug("BPTasksPreBattle", TableToString(self.BPTasksPreBattle))
end
function BattleResultProxy:GetBPTaskPreBattle(TaskId)
  return self.BPTasksPreBattle[TaskId]
end
function BattleResultProxy:GetSignedRoleTasks(Role)
  local tasks = {}
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local RoleIdSigned = kaNavigationProxy:GetCurrentRoleId()
  if Role ~= RoleIdSigned then
    return tasks
  end
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local RoleTasksPostBattle = BattlePassProxy:GetApartmentTaskByRoleId(Role)
  LogDebug("GetSignedRoleTasks RoleTasksPostBattle", TableToString(RoleTasksPostBattle))
  local RoleTasksPreBattle = self.RoleTasksPreBattle[tonumber(Role)]
  local SignedRoleTasks = {}
  for key, RoleTask in pairs(RoleTasksPostBattle) do
    if RoleTask.taskState ~= Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN and RoleTask.taskState ~= Pb_ncmd_cs.ETaskState.TaskState_TIME_OUT then
      if not RoleTasksPreBattle[RoleTask.taskId] then
        SignedRoleTasks[RoleTask.taskId] = RoleTask
        SignedRoleTasks[RoleTask.taskId].PreTaskProgress = 0
        SignedRoleTasks[RoleTask.taskId].finished = (RoleTask.taskProgress or 0) >= RoleTask.taskTarget
      else
        SignedRoleTasks[RoleTask.taskId] = RoleTask
        SignedRoleTasks[RoleTask.taskId].PreTaskProgress = RoleTasksPreBattle[RoleTask.taskId].taskProgress
        SignedRoleTasks[RoleTask.taskId].finished = (RoleTask.taskProgress or 0) >= RoleTask.taskTarget
      end
    end
  end
  local tasks = {}
  for key, task in pairs(SignedRoleTasks) do
    table.insert(tasks, task)
  end
  local CompareFunc = function(a, b)
    if a.finished and b.finished then
      return a.taskId < b.taskId
    end
    if a.finished then
      return true
    end
    if b.finished then
      return false
    end
    return a.taskId < b.taskId
  end
  table.sort(tasks, CompareFunc)
  LogDebug("GetSignedRoleTasks", TableToString(tasks))
  return tasks
end
function BattleResultProxy:RecordRoleTasksPreBattle()
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleIds = RoleProxy:GetRoleIds()
  self.RoleTasksPreBattle = {}
  for key, RoleId in pairs(RoleIds) do
    self.RoleTasksPreBattle[tonumber(RoleId)] = BattlePassProxy:GetApartmentTaskByRoleId(RoleId) or {}
  end
  LogDebug("RoleTasksPreBattle", TableToString(self.RoleTasksPreBattle))
end
function BattleResultProxy:GetRoleTasksOfChanged(RoleId)
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local RoleTasksPostBattle = BattlePassProxy:GetApartmentTaskByRoleId(RoleId)
  LogDebug("RoleTasksPostBattle", TableToString(RoleTasksPostBattle))
  local RoleTasksPreBattle = self.RoleTasksPreBattle[tonumber(RoleId)]
  local RoleTasksOfChanged = {}
  for key, RoleTask in pairs(RoleTasksPostBattle) do
    if not RoleTasksPreBattle[RoleTask.taskId] then
      RoleTasksOfChanged[RoleTask.taskId] = RoleTask
      RoleTasksOfChanged[RoleTask.taskId].PreTaskProgress = 0
      RoleTasksOfChanged[RoleTask.taskId].finished = (RoleTask.taskProgress or 0) >= RoleTask.taskTarget
    elseif RoleTasksPreBattle[RoleTask.taskId].taskProgress ~= RoleTask.taskProgress then
      RoleTasksOfChanged[RoleTask.taskId] = RoleTask
      RoleTasksOfChanged[RoleTask.taskId].PreTaskProgress = RoleTasksPreBattle[RoleTask.taskId].taskProgress
      RoleTasksOfChanged[RoleTask.taskId].finished = (RoleTask.taskProgress or 0) >= RoleTask.taskTarget
    end
  end
  local tasks = {}
  for key, task in pairs(RoleTasksOfChanged) do
    table.insert(tasks, task)
  end
  local CompareFunc = function(a, b)
    if a.finished and b.finished then
      return a.taskId < b.taskId
    end
    if a.finished then
      return true
    end
    if b.finished then
      return false
    end
    return a.taskId < b.taskId
  end
  table.sort(tasks, CompareFunc)
  LogDebug("RoleTasksOfChanged", TableToString(tasks))
  return tasks
end
function BattleResultProxy:GetRoleTaskPreBattle(RoleId, TaskId)
  local RoleTasksPreBattle = self.RoleTasksPreBattle[tonumber(RoleId)]
  if RoleTasksPreBattle then
    return RoleTasksPreBattle[TaskId]
  end
end
function BattleResultProxy:RecordRoleIntimacysPreBattle()
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleIds = RoleProxy:GetRoleIds()
  self.RoleIntimacysPreBattle = {}
  for key, RoleId in pairs(RoleIds) do
    RoleId = tonumber(RoleId)
    local roleApartmentInfo = KaPhoneProxy:GetRoleProperties(RoleId)
    if roleApartmentInfo then
      self.RoleIntimacysPreBattle[RoleId] = {}
      self.RoleIntimacysPreBattle[RoleId].IntimacyLv = roleApartmentInfo.intimacy_lv
      self.RoleIntimacysPreBattle[RoleId].Intimacy = roleApartmentInfo.intimacy
    else
      self.RoleIntimacysPreBattle[RoleId] = {}
      self.RoleIntimacysPreBattle[RoleId].IntimacyLv = 1
      self.RoleIntimacysPreBattle[RoleId].Intimacy = 0
    end
  end
  LogDebug("RoleIntimacysPreBattle", TableToString(self.RoleIntimacysPreBattle))
end
function BattleResultProxy:GetRoleIntimacysPreBattle(RoleId)
  return self.RoleIntimacysPreBattle[tonumber(RoleId)]
end
function BattleResultProxy:SaveCachedPlayerInfo(PlayerState)
  if not PlayerState then
    return
  end
  local PlayerCacheData = {
    PlayerId = PlayerState.UID,
    bIsABot = PlayerState.bIsABot
  }
  if PlayerCacheData and self.CachedPlayerList then
    self.CachedPlayerList[PlayerState.UID] = PlayerCacheData
  end
  LogDebug("BattleResultProxy", TableToString(self.CachedPlayerList))
end
function BattleResultProxy:GetCachedPlayerInfo(PlayerUID)
  if not self.CachedPlayerList[PlayerUID] then
    return nil
  end
  return self.CachedPlayerList[PlayerUID]
end
function BattleResultProxy:GetPlayerState(WorldObject)
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(WorldObject, 0)
  if PlayerController and PlayerController.PlayerState then
    return PlayerController.PlayerState
  end
  return nil
end
function BattleResultProxy:GetMapTableRow(MapId)
  local mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  return mapTableRows[tostring(MapId)]
end
function BattleResultProxy:GetAvatar(InAvatarId)
end
function BattleResultProxy:GetPlayerBattleInfos(WorldObject)
  local GameState = UE4.UGameplayStatics.GetGameState(WorldObject)
  if not GameState then
    return
  end
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(WorldObject, 0)
  local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
  if not MyPlayerState then
    return
  end
  self.UIDs = {}
  local PlayerBattleInfos = {}
  for i = 1, GameState.PlayerArray:Length() do
    local playerState = GameState.PlayerArray:Get(i)
    local BattleInfo = {}
    BattleInfo.UID = playerState.UID
    table.insert(self.UIDs, playerState.UID)
    BattleInfo.PlayerName = playerState:GetPlayerName()
    BattleInfo.AttributeTeamID = playerState.AttributeTeamID
    BattleInfo.NumKills = playerState.NumKills or 0
    BattleInfo.NumDeaths = playerState.NumDeaths or 0
    BattleInfo.NumAssist = playerState.NumAssist or 0
    BattleInfo.RescueCount = playerState.RescueCount or 0
    BattleInfo.TotalDamage = playerState.TotalDamage or 0
    BattleInfo.CompositeScore = playerState.CompositeScore or 0
    BattleInfo.SelectRoleId = playerState.SelectRoleId
    BattleInfo.RoleSkinId = playerState.RoleSkinId
    BattleInfo.bOnlySpectator = playerState.bOnlySpectator
    BattleInfo.IsSelf = playerState == MyPlayerState
    BattleInfo.bIsWinner = GameState.WinnerTeam == playerState.AttributeTeamID
    BattleInfo.bIsMVP = GameState:GetMVPPlayerState(playerState.AttributeTeamID) == playerState
    BattleInfo.AreaScore = playerState.AreaScore or 0
    BattleInfo.InstallC4Count = playerState.InstallC4Count or 0
    BattleInfo.RemoveC4Count = playerState.RemoveC4Count or 0
    table.insert(PlayerBattleInfos, BattleInfo)
  end
  LogDebug("PlayerBattleInfos", TableToString(PlayerBattleInfos))
  return PlayerBattleInfos
end
function BattleResultProxy:GetPlayerIds()
  local Ids = {}
  for key, player in pairs(self.settle_battle_game_ntf.players) do
    table.insert(Ids, player.player_id)
  end
  return Ids
end
function BattleResultProxy:GetMyPlayerInfo()
  if self.MyObTeamId then
    return self:GetFirstPlayerInfoByTeamId(self.MyObTeamId)
  else
    return self:GetPlayerInfo(self.MyPlayerId)
  end
end
function BattleResultProxy:GetFirstPlayerInfoByTeamId(TeamId)
  for key, player in pairs(self.settle_battle_game_ntf.players) do
    if player.team_id == TeamId + 1 then
      return player
    end
  end
  LogDebug("BattleResultProxy", "TeamId id=%s not found", TeamId)
end
function BattleResultProxy:GetPlayerInfo(PlayerId)
  for key, player in pairs(self.settle_battle_game_ntf.players) do
    if player.player_id == PlayerId then
      return player
    end
  end
  LogDebug("BattleResultProxy", "player id=%s not found", PlayerId)
end
return BattleResultProxy
