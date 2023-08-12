local InGameTipoffPlayerDataProxy = class("InGameTipoffPlayerDataProxy", PureMVC.Proxy)
function InGameTipoffPlayerDataProxy:OnRegister()
  InGameTipoffPlayerDataProxy.super.OnRegister(self)
  LogDebug("InGameTipoffPlayerDataProxy", "OnRegister")
  self.TipoffConfig = nil
  local TipoffGlobalTableRow = ConfigMgr:GetTipoffGlobalTableRow()
  if TipoffGlobalTableRow then
    local TipoffGlobalTb = TipoffGlobalTableRow:ToLuaTable()
    if TipoffGlobalTb then
      self.TipoffConfig = {}
      for RowName, RowData in pairs(TipoffGlobalTb) do
        self.TipoffConfig[RowData.Id] = RowData.Param
      end
    end
  else
    LogDebug("TipoffPlayerDataProxy", "Tipff Data Failed .")
  end
  self.TipOffAllPlayerDataList = {}
  self:InitTipoffAllPlayerData()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REPORT_FEEDBACK_RES, FuncSlot(self.OnNetReportFeedback, self))
  end
end
function InGameTipoffPlayerDataProxy:OnRemove()
  LogDebug("InGameTipoffPlayerDataProxy", "OnRemove")
  self.TipOffAllPlayerDataList = nil
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REPORT_FEEDBACK_RES, FuncSlot(self.OnNetReportFeedback, self))
  end
  InGameTipoffPlayerDataProxy.super.OnRemove(self)
end
function InGameTipoffPlayerDataProxy:InitTipoffAllPlayerData()
  local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
  if not GameState then
    return
  end
  for i = 1, GameState.PlayerArray:Length() do
    local playerState = GameState.PlayerArray:Get(i)
    if playerState and not playerState.bOnlySpectator then
      local PlayerTipoffData = {
        UID = playerState.UID,
        TeamNumber = playerState.AttributeTeamID,
        GameEndTipOffCnt = 0
      }
      self.TipOffAllPlayerDataList[playerState.UID] = PlayerTipoffData
    end
  end
end
function InGameTipoffPlayerDataProxy:UpdateTipoffPlayerData()
  local TipoffPlayerDataProy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if TipoffPlayerDataProy then
    local PlayerUID = TipoffPlayerDataProy:GetCurTargetUID()
    local CurEntranceType = TipoffPlayerDataProy:GetCurEnteranceType()
    if CurEntranceType == UE4.ECyTipoffEntranceType.ENTERANCE_INGAME then
      self:UpdateInGameTipoffPlayerData(PlayerUID)
    elseif CurEntranceType == UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME and self.TipOffAllPlayerDataList[PlayerUID] then
      self.TipOffAllPlayerDataList[PlayerUID].GameEndTipOffCnt = self.TipOffAllPlayerDataList[PlayerUID].GameEndTipOffCnt + 1
    end
  end
  LogDebug("InGameTipoffPlayerDataProxy", "UpdateTipoffPlayerData End .")
end
function InGameTipoffPlayerDataProxy:UpdateInGameTipoffPlayerData(playerUID)
  local targetPlayerState = self:GetPlayerState(playerUID)
  if not targetPlayerState then
    return
  end
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(LuaGetWorld(), 0)
  if PlayerController then
    LogDebug("InGameTipoffPlayerDataProxy", "UpdateInGameTipoffPlayerData Send ." .. targetPlayerState.UID)
    return PlayerController:ServerTipoffPlayer(targetPlayerState.UID)
  end
end
function InGameTipoffPlayerDataProxy:GetCurTargetUID()
  local TipoffPlayerDataProy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if TipoffPlayerDataProy then
    return TipoffPlayerDataProy:GetCurTargetUID()
  end
  return -1
end
function InGameTipoffPlayerDataProxy:GetEntranceType()
  local TipoffPlayerDataProy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if TipoffPlayerDataProy then
    return TipoffPlayerDataProy:GetCurEnteranceType()
  end
  return -1
end
function InGameTipoffPlayerDataProxy:IsPlayerTipoffMax()
  local CurTargetUID = self:GetCurTargetUID()
  local CurEntranceType = self:GetEntranceType()
  return self:CheckPlayerTipoffMax(CurTargetUID, CurEntranceType)
end
function InGameTipoffPlayerDataProxy:CheckPlayerTipoffMax(targetUID, entranceType)
  if entranceType == UE4.ECyTipoffEntranceType.ENTERANCE_INGAME then
    local myPlayerState = self:GetMyPlayerState()
    if myPlayerState then
      local myUID = myPlayerState.UID
      if myPlayerState then
        LogDebug("CheckPlayerTipoffMax", self:GetInGameTipoffCnt(myUID, targetUID))
        return self:GetInGameTipoffCnt(myUID, targetUID) >= self:GetMaxTipoffTimes(entranceType)
      end
    end
  elseif entranceType == UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME then
    if self.TipOffAllPlayerDataList[targetUID] then
      LogDebug("CheckPlayerTipoffMax", self.TipOffAllPlayerDataList[targetUID].GameEndTipOffCnt)
      return self.TipOffAllPlayerDataList[targetUID].GameEndTipOffCnt >= self:GetMaxTipoffTimes(entranceType)
    end
  else
    return false
  end
  return false
end
function InGameTipoffPlayerDataProxy:IsPlayerIsLastTimeTipoff(targetUID, entranceType)
  if entranceType == UE4.ECyTipoffEntranceType.ENTERANCE_INGAME then
    local myPlayerState = self:GetMyPlayerState()
    if myPlayerState then
      local myUID = myPlayerState.UID
      if myPlayerState then
        return self:GetInGameTipoffCnt(myUID, targetUID) + 1 >= self:GetMaxTipoffTimes(entranceType)
      end
    end
  elseif entranceType == UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME then
    if self.TipOffAllPlayerDataList[targetUID] then
      return self.TipOffAllPlayerDataList[targetUID].GameEndTipOffCnt + 1 >= self:GetMaxTipoffTimes(entranceType)
    end
  else
    return false
  end
  return false
end
function InGameTipoffPlayerDataProxy:GetInGameTipoffCnt(initiatorPID, targetPID)
  local targetPlayerState = self:GetPlayerState(targetPID)
  if targetPlayerState then
    return targetPlayerState:GetTipoffPlayerCount(initiatorPID)
  end
  return 0
end
function InGameTipoffPlayerDataProxy:GetMyPlayerState()
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(LuaGetWorld(), 0)
  if PlayerController and PlayerController.PlayerState then
    return PlayerController.PlayerState
  end
  return nil
end
function InGameTipoffPlayerDataProxy:GetPlayerState(uid)
  local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
  if not GameState then
    LogDebug("InGameTipoffPlayerDataProxy", "GameState Error")
    return nil
  end
  for i = 1, GameState.PlayerArray:Length() do
    local playerState = GameState.PlayerArray:Get(i)
    if playerState and not playerState.bOnlySpectator and playerState.UID == uid then
      return playerState
    end
  end
  return nil
end
function InGameTipoffPlayerDataProxy:GetMaxTipoffTimes(EntranceType)
  if EntranceType == UE4.ECyTipoffEntranceType.ENTERANCE_INGAME then
    if self.TipoffConfig and self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_INGAME_MAX_NUM] then
      return self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_INGAME_MAX_NUM]
    end
    return 3
  elseif EntranceType == UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME then
    if self.TipoffConfig and self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_ENDGAME_MAX_NUM] then
      return self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_ENDGAME_MAX_NUM]
    end
    return 1
  end
  return 0
end
function InGameTipoffPlayerDataProxy:OnNetReportFeedback(Data)
  LogDebug("InGameTipoffPlayerDataProxy", "OnNetReportFeedback")
  self:UpdateTipoffPlayerData()
end
return InGameTipoffPlayerDataProxy
