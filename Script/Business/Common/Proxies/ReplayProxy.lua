local ReplayProxy = class("ReplayProxy", PureMVC.Proxy)
local ReplaySlotName = "ReplaySlotName"
local MaxRecordLength = 50
local GetCurVersion = function(version)
  local targetVersion
  xpcall(function()
    local tbl = string.split(version, ".")
    local curVersion = table.concat(tbl, ".", 1, 3)
    targetVersion = curVersion
  end, function()
    LogInfo("ReplayProxy", string.format("version is %s", tostring(version)))
  end)
  return targetVersion
end
function ReplayProxy:OnRegister()
  ReplayProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLE_REPLAY_RES, FuncSlot(self.OnBattleReplayRes, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ENTER_REPLAY_RES, FuncSlot(self.OnEnterReplayRes, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LEAVE_REPLAY_RES, FuncSlot(self.OnLeaveReplayRes, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_UPLOAD_REPLAY_FINISH_NTF, FuncSlot(self.OnUploadReplayFinishNtf, self))
  end
  self.bFromBattelInfo = false
  self.bGetAllReplayFiles = false
  self.ReplayFileMap = {}
  self.PrepareWellRoomIdMap = {}
  self.ReplayUrlMap = {}
  if UE4.UPMReplaySubSystem and UE4.UPMReplaySubSystem.GetInstance then
    self.ReplayInst = UE4.UPMReplaySubSystem.GetInstance(LuaGetWorld())
    local PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
    self.OnDemoStartSuccessEventHandler = DelegateMgr:AddDelegate(self.ReplayInst.OnDemoStartSuccess, self, "OnDemoStartSuccess")
    self.OnDemoStartFailureEventHandler = DelegateMgr:AddDelegate(self.ReplayInst.OnDemoStartFailure, self, "OnDemoStartFailure")
  end
  local LoginSubSystem = UE4.UPMLoginSubSystem.GetInstance(LuaGetWorld())
  local version = LoginSubSystem:GetGameVersion()
  self.curVersion = GetCurVersion(version)
end
function ReplayProxy:OnRemove()
  ReplayProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLE_REPLAY_RES, FuncSlot(self.OnBattleReplayRes, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ENTER_REPLAY_RES, FuncSlot(self.OnEnterReplayRes, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LEAVE_REPLAY_RES, FuncSlot(self.OnLeaveReplayRes, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_UPLOAD_REPLAY_FINISH_NTF, FuncSlot(self.OnUploadReplayFinishNtf, self))
  end
  if self.ReplayInst then
    if self.OnDemoStartSuccessEventHandler then
      DelegateMgr:RemoveDelegate(self.ReplayInst.OnDemoStartSuccess, self.OnDemoStartFailureEventHandler)
      self.OnDemoStartSuccessEventHandler = nil
    end
    if self.OnDemoStartFailureEventHandler then
      DelegateMgr:RemoveDelegate(self.ReplayInst.OnDemoStartFailure, self.OnDemoStartFailureEventHandler)
      self.OnDemoStartFailureEventHandler = nil
    end
  end
  self.bGetAllReplayFiles = false
  self.bFromBattelInfo = false
  self.ReplayFileMap = {}
  self.ReplayInst = nil
  self.PrepareWellRoomIdMap = {}
  self.ReplayUrlMap = {}
end
function ReplayProxy:OnBattleReplayRes(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.battle_replay_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
    return
  end
  self.ReplayUrlMap[tostring(Data.room_id)] = Data.download_url
  GameFacade:SendNotification(NotificationDefines.Replay.GetDownloadUrl, {
    downloadurl = Data.download_url
  })
end
function ReplayProxy:OnLeaveReplayRes(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.leave_replay_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
    return
  end
end
function ReplayProxy:OnEnterReplayRes(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.enter_replay_res, ServerData)
  if 0 ~= Data.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, Data.code)
    return
  end
end
function ReplayProxy:ReqBattleReplay(roomid)
  local data = {room_id = roomid}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLE_REPLAY_REQ, pb.encode(Pb_ncmd_cs_lobby.battle_replay_req, data))
end
function ReplayProxy:ReqLeaveReplay()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_LEAVE_REPLAY_REQ, pb.encode(Pb_ncmd_cs_lobby.leave_replay_req, {}))
end
function ReplayProxy:ReqEnterReplay()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_ENTER_REPLAY_REQ, pb.encode(Pb_ncmd_cs_lobby.enter_replay_req, {}))
end
function ReplayProxy:SetBattleInfoFlag(bFromBattelInfo, roomid)
  self.bFromBattelInfo = bFromBattelInfo
  self.LastRoomId = roomid
end
function ReplayProxy:GetBattleInfoFlag()
  return self.bFromBattelInfo, self.LastRoomId
end
function ReplayProxy:ConvertDateToTimeStamp(dateStr)
  return dateStr
end
function ReplayProxy:SolveReplayFilename(filename)
  local res = {}
  local tbl = string.split(filename, "_")
  res.playerid = tbl[1]
  res.version = tbl[2]
  res.roomid = tbl[3]
  res.datestr = self:ConvertDateToTimeStamp(tbl[4])
  res.randomkey = tbl[5]
  return res
end
function ReplayProxy:CheckOutofData(time)
  if nil == time then
    return false
  end
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  local diftime = servertime - time
  if diftime >= 604800 then
    return true
  else
    return false
  end
end
function ReplayProxy:CheckFileNotCompatible(version)
  local tVersion = GetCurVersion(version)
  if self.curVersion then
    return self.curVersion ~= tVersion
  end
  return false
end
function ReplayProxy:getFileParent()
  local path = UE.UBlueprintPathsLibrary.ProjectSavedDir()
  local pathArray = UE4.TArray(UE.FString)
  pathArray:Add(path)
  pathArray:Add("Demos")
  local filePath = UE.UBlueprintPathsLibrary.Combine(pathArray)
  return filePath
end
function ReplayProxy:getFilePath(filename, playerid)
  local pathArray = UE4.TArray(UE.FString)
  pathArray:Add(self:getFileParent())
  pathArray:Add(filename)
  local filePath = UE.UBlueprintPathsLibrary.Combine(pathArray)
  return filePath
end
function ReplayProxy:ClearNotValidFiles()
  self:GetAllReplayFiles()
  local roomidArr = {}
  for roomid, restbl in pairs(self.ReplayFileMap) do
    roomidArr[#roomidArr + 1] = {
      roomid = roomid,
      datestr = tonumber(restbl.datestr)
    }
  end
  table.sort(roomidArr, function(a, b)
    return a.datestr > b.datestr
  end)
  if #roomidArr > MaxRecordLength then
    for i = MaxRecordLength + 1, #roomidArr do
      local roomid = roomidArr[i].roomid
      local ele = self.ReplayFileMap[roomid]
      UE4.UBlueprintFileUtilsBPLibrary.DeleteFile(ele.fullfilepath)
      self.ReplayFileMap[roomid] = nil
    end
  end
end
function ReplayProxy:GetAllReplayFiles()
  if self.bGetAllReplayFiles then
    return
  end
  self.bGetAllReplayFiles = true
  self.ReplayFileMap = {}
  local PlayerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local playerid = PlayerAttrProxy:GetPlayerId()
  local fileparent = self:getFileParent(playerid)
  local bExists, Arr = UE4.UFlibAssetManageHelper.FindFilesRecursive(fileparent)
  if bExists then
    for i = 1, Arr:Length() do
      local value = Arr:Get(i)
      local filename = UE4.UBlueprintPathsLibrary.GetBaseFilename(value)
      local ext = UE4.UBlueprintPathsLibrary.GetExtension(value)
      if "replay" == ext then
        local ret = self:SolveReplayFilename(filename)
        if ret.playerid == tostring(playerid) then
          self.ReplayFileMap[tostring(ret.roomid)] = {
            filename = filename,
            fullfilepath = value,
            datestr = ret.datestr
          }
        end
      end
    end
  end
end
function ReplayProxy:GetFileNameByRoomId(roomid)
  self:GetAllReplayFiles()
  roomid = tostring(roomid)
  if self.ReplayFileMap[roomid] then
    return self.ReplayFileMap[roomid].filename
  end
  return nil
end
function ReplayProxy:PushFilePathByRoomId(roomid, tbl)
  self:GetAllReplayFiles()
  self.ReplayFileMap[tostring(roomid)] = tbl
end
function ReplayProxy:OnDemoStartSuccess()
  print("OnDemoStartSuccess")
end
function ReplayProxy:OnDemoStartFailure(failureType)
  print("OnDemoStartFailureType", failureType)
  if self.bPlayReplaying then
    self:ReqLeaveReplay()
    self.bPlayReplaying = false
    local tip = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "ReplayFilePlayError")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
    UE4.UCyLoadingStream.Get(LuaGetWorld()):Stop()
    local backToLobby = function()
      local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
      if not GameState then
        LogDebug("ReplayProxy", "GameState is nil")
        return
      end
      local GoToLobby = function()
        if GameState.RequestFinishAndExitToMainMenu then
          LogDebug("RequestFinishAndExitToMainMenu", "RequestFinishAndExitToMainMenu")
          GameState:RequestFinishAndExitToMainMenu()
        end
      end
      pcall(GoToLobby)
    end
    if self.bFromBattelInfo ~= true then
      backToLobby()
    else
      local GameInstance = UE4.UGameplayStatics.GetGameInstance(LuaGetWorld())
      if GameInstance then
        GameInstance:GotoLobbyScene()
      end
    end
  end
  self:SetBattleInfoFlag(false)
end
function ReplayProxy:QuitDemoReplay()
  if self.bPlayReplaying then
    self:ReqLeaveReplay()
    self.bPlayReplaying = false
  end
end
function ReplayProxy:OnUploadReplayFinishNtf(data)
  local Data = DeCode(Pb_ncmd_cs_lobby.upload_replay_finish_ntf, data)
  self.PrepareWellRoomIdMap[Data.room_id] = true
  GameFacade:SendNotification(NotificationDefines.Replay.DownloadUrlPrepareWell, {
    roomid = Data.room_id
  })
end
function ReplayProxy:CheckReplayWell(roomid)
  return self.PrepareWellRoomIdMap[roomid]
end
function ReplayProxy:GetUrlByRoomId(roomid)
  return self.ReplayUrlMap[roomid]
end
return ReplayProxy
