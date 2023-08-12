local CinematicCloisterProxy = class("CinematicCloisterProxy", PureMVC.Proxy)
function CinematicCloisterProxy:OnRegister()
  CinematicCloisterProxy.super.OnRegister(self)
  self:InitCinematicCloisterData()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnSequenceStopDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self, "OnCinematicCloisteSequenceStop")
    self.OnGuideEndDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnGuideEnd, self, "OnNoviceSpracticeCompleted")
  end
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_INIT_STATE_SYNC_FINISH_NTF, FuncSlot(self.OnReceiveLoginRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLOISTER_RES, FuncSlot(self.OnRcvCinematicCloisterDatas, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLOISTER_READ_RES, FuncSlot(self.OnRcvCinematicCloisterCompletedData, self))
end
function CinematicCloisterProxy:OnRemove()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self.OnSequenceStopDelegate)
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnGuideEnd, self.OnGuideEndDelegate)
  end
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_INIT_STATE_SYNC_FINISH_NTF, FuncSlot(self.OnReceiveLoginRes, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLOISTER_RES, FuncSlot(self.OnRcvCinematicCloisterDatas, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLOISTER_READ_RES, FuncSlot(self.OnRcvCinematicCloisterCompletedData, self))
  end
  self.selectedIndex = nil
  self.playingSequenceId = nil
  self.playCloisterIndex = nil
  self.CinematicRewards = nil
end
function CinematicCloisterProxy:OnReceiveLoginRes()
  LogDebug("==========CinematicCloisterProxy:OnReceiveLoginRes  Receive NID_INIT_STATE_SYNC_FINISH_NTF")
  self:UpdateSequenceListByPlatform()
end
function CinematicCloisterProxy:InitCinematicCloisterData()
  self.cinematicCloisterList = {}
  local arrRows = ConfigMgr:GetCinematicCloisterTableRows()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      self.cinematicCloisterList[rowData.Id] = rowData
    end
  end
end
function CinematicCloisterProxy:UpdateSequenceListByPlatform()
  if not self.cinematicCloisterList then
    return
  end
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  if UserSetting and UserSetting:NeedPlayMovie() then
    for key, value in pairs(self.cinematicCloisterList) do
      value.SequenceIdList = value.SequenceIdListMobile
    end
  end
end
function CinematicCloisterProxy:GetCinematicCloisterDataByKey(index)
  return self.cinematicCloisterList[index]
end
function CinematicCloisterProxy:GetCinematicCloisterDatas()
  return self.cinematicCloisterList
end
function CinematicCloisterProxy:GetSelectedIndex()
  return self.selectedIndex
end
function CinematicCloisterProxy:GetPlayCloisterIndex()
  return self.playCloisterIndex
end
function CinematicCloisterProxy:ResetPlayCloisterDatas()
  self.playCloisterIndex = nil
  self.playingSequenceId = nil
end
function CinematicCloisterProxy:GetPlayCloisterIndexBySequenceId(inSequenceId)
  for k, v in ipairs(self.cinematicCloisterList) do
    local count = v.SequenceIdList:Length()
    for index = 1, count do
      local sequenceId = v.SequenceIdList:Get(index)
      if sequenceId == inSequenceId then
        return k, v, index >= count
      end
    end
  end
end
function CinematicCloisterProxy:GetSequenceIdByIndex(index)
  local data = self.cinematicCloisterList[index]
  if data and data.SequenceIdList and data.SequenceIdList:Length() > 0 then
    return data.SequenceIdList:Get(1)
  else
    return 0
  end
end
function CinematicCloisterProxy:GetNextSequenceId()
  local sequenceId = 0
  local cloisterIndex = self.playCloisterIndex
  if cloisterIndex and self.cinematicCloisterList[cloisterIndex] and self.cinematicCloisterList[cloisterIndex].SequenceIdList then
    local count = self.cinematicCloisterList[cloisterIndex].SequenceIdList:Length()
    for index = 1, count do
      if self.playingSequenceId == self.cinematicCloisterList[cloisterIndex].SequenceIdList:Get(index) then
        if index < count then
          sequenceId = self.cinematicCloisterList[cloisterIndex].SequenceIdList:Get(index + 1)
          break
        end
        cloisterIndex = cloisterIndex + 1
        sequenceId = self:GetSequenceIdByIndex(cloisterIndex)
        break
      end
    end
  end
  return sequenceId, cloisterIndex
end
function CinematicCloisterProxy:UpdateSelectedIndex(index)
  self.selectedIndex = index
end
function CinematicCloisterProxy:AddCinematicRewards(CloisterId)
  if not self.CinematicRewards then
    self.CinematicRewards = {}
    self.CinematicRewards.overflowItemList = {}
    self.CinematicRewards.itemList = {}
  end
  if self.cinematicCloisterList[CloisterId] and not self.cinematicCloisterList[CloisterId].IsPlayCompleted then
    local Rewards = self.cinematicCloisterList[CloisterId].Rewards
    for i = 1, Rewards:Length() do
      local Reward = Rewards:Get(i)
      local item = {}
      item.itemId = Reward.ItemId
      item.itemCnt = Reward.ItemAmount
      table.insert(self.CinematicRewards.itemList, item)
    end
  end
  TimerMgr:AddTimeTask(180, 0, 1, function()
    self:ClearCinematicRewards()
  end)
end
function CinematicCloisterProxy:ClearCinematicRewards()
  self.CinematicRewards = nil
end
function CinematicCloisterProxy:GetCinematicRewards()
  return self.CinematicRewards
end
function CinematicCloisterProxy:OnRcvCinematicCloisterDatas(data)
  LogDebug("NID_BATTLEPASS_CLOISTER_RES")
  local netData = DeCode(Pb_ncmd_cs_lobby.battlepass_cloister_res, data)
  local cloisters = netData.cloisters
  for key, value in pairs(cloisters) do
    self:UpdatePlayCompletedState(value.id)
  end
end
function CinematicCloisterProxy:ReqCinematicCloisterCompletedDatas(CloisterId)
  LogDebug("NID_BATTLEPASS_CLOISTER_READ_REQ", CloisterId)
  local data = {id = CloisterId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLEPASS_CLOISTER_READ_REQ, pb.encode(Pb_ncmd_cs_lobby.battlepass_cloister_read_req, data))
end
function CinematicCloisterProxy:OnRcvCinematicCloisterCompletedData(data)
  LogDebug("NID_BATTLEPASS_CLOISTER_READ_RES", data.id)
  local netData = DeCode(Pb_ncmd_cs_lobby.battlepass_cloister_read_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  local id = netData.id
  if id then
    self:AddCinematicRewards(id)
    self:UpdatePlayCompletedState(id)
  end
end
function CinematicCloisterProxy:PlayCinematicChapter(index)
  local roomPrxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local bCanPlaySequence = roomPrxy:CanPlaySequence()
  if bCanPlaySequence then
    self.playingSequenceId = self:GetSequenceIdByIndex(index)
    if self.playingSequenceId > 0 then
      self.playCloisterIndex = index
      local SM = UE4.UPMGlobalStateMachine.Get(LuaGetWorld())
      if SM then
        SM:TransferGlobalScenarioState()
      end
      GameFacade:SendNotification(NotificationDefines.BattlePass.CinematicCloisterCmd, {
        sequenceId = self.playingSequenceId
      }, NotificationDefines.BattlePass.CinematicCloistertype.CinematicCloisterPlay)
    end
  else
    local msg = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "InRoomCannotPlayCinematic")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
  end
end
function CinematicCloisterProxy:OnCinematicCloisteSequenceStop(sequenceId, reasonType)
  LogDebug("==========CinematicCloisterProxy:OnCinematicCloisteSequenceStop，sequenceId=", sequenceId, "reasonType =", reasonType)
  local cloisterIndex, cloisterData, isLastSequence = self:GetPlayCloisterIndexBySequenceId(sequenceId)
  if cloisterIndex and cloisterData and 0 == cloisterData.ChapterType then
    if 1 == reasonType or 2 == reasonType then
      if isLastSequence then
        self:ReqCinematicCloisterCompletedDatas(cloisterIndex)
      end
      if self:__IsCinematicCloisterPlay() then
        self:__OnPlayNext()
      end
    elseif 4 == reasonType then
      if isLastSequence then
        self:ReqCinematicCloisterCompletedDatas(cloisterIndex)
      end
    elseif 3 == reasonType and self:__IsCinematicCloisterPlay() then
      GameFacade:SendNotification(NotificationDefines.BattlePass.CinematicCloisterCmd, nil, NotificationDefines.BattlePass.CinematicCloistertype.ReturnCinematicCloister)
    end
  end
end
function CinematicCloisterProxy:__IsCinematicCloisterPlay()
  local isCinematicCloisterPlay = false
  local world = LuaGetWorld()
  if world then
    isCinematicCloisterPlay = UE4.UCyCinematicChapterManager.Get(world):GetIsCompletedAllChapter()
  end
  return isCinematicCloisterPlay
end
function CinematicCloisterProxy:__OnPlayNext()
  LogDebug("==========CinematicCloisterProxy:__OnPlayNext()", self.playCloisterIndex)
  local sequenceId, cloisterIndex = self:GetNextSequenceId()
  self.playingSequenceId = sequenceId
  if sequenceId > 0 then
    self.playCloisterIndex = cloisterIndex
    TimerMgr:RunNextFrame(function()
      GameFacade:SendNotification(NotificationDefines.BattlePass.CinematicCloisterCmd, {sequenceId = sequenceId}, NotificationDefines.BattlePass.CinematicCloistertype.CinematicCloisterPlay)
    end)
  else
    GameFacade:SendNotification(NotificationDefines.BattlePass.CinematicCloisterCmd, nil, NotificationDefines.BattlePass.CinematicCloistertype.ReturnCinematicCloister)
  end
end
function CinematicCloisterProxy:OnNoviceSpracticeCompleted(inType)
  LogDebug("==========CinematicCloisterProxy:OnNoviceSpracticeCompleted")
  if inType ~= UE4.EPMGameModeType.NoviceGuide then
    return
  end
  for k, v in ipairs(self.cinematicCloisterList) do
    if 1 == v.ChapterType then
      self:ReqCinematicCloisterCompletedDatas(k)
      if self:__IsCinematicCloisterPlay() then
        self:__OnPlayNext()
      end
      return
    end
  end
end
function CinematicCloisterProxy:UpdatePlayCompletedState(Id)
  if not self.cinematicCloisterList then
    return
  end
  local data = self.cinematicCloisterList[Id]
  if data then
    data.IsPlayCompleted = true
    GameFacade:SendNotification(NotificationDefines.BattlePass.CinematicCloisterCmd, {
      sequenceId = data.SequenceId
    }, NotificationDefines.BattlePass.CinematicCloistertype.CinematicPlayStoped)
  end
end
return CinematicCloisterProxy
