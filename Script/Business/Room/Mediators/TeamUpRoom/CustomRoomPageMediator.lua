local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local CustomRoomPageMediator = class("CustomRoomPageMediator", PureMVC.Mediator)
local roomDataProxy
function CustomRoomPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.OnRoomInfoUpdate,
    NotificationDefines.TeamRoom.OnQuitMatchNtf,
    NotificationDefines.TeamRoom.OnJoinMatchNtf,
    NotificationDefines.TeamRoom.OnMatchResultNtf,
    NotificationDefines.TeamRoom.OnRoomBeginRes,
    NotificationDefines.TeamRoom.OnQuitBattle,
    NotificationDefines.TeamRoom.OnTeamTransLeaderNtf,
    NotificationDefines.TeamRoom.AIEntryRoom,
    NotificationDefines.TeamRoom.UpdateRoomAiLevel,
    NotificationDefines.TeamRoom.OnRoomMemberNtf
  }
end
function CustomRoomPageMediator:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.TeamRoom.OnRoomInfoUpdate then
    self:UpdateRoomInfo()
    self:UpdataNetworkUI()
  elseif notifyName == NotificationDefines.TeamRoom.OnQuitMatchNtf then
    self:OnQuitMatchNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnJoinMatchNtf then
    self:OnJoinMatchNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnMatchResultNtf then
    self:OnMatchResultNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnRoomBeginRes then
    self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CantStart)
  elseif notifyName == NotificationDefines.TeamRoom.OnQuitBattle then
    self:OnQuitBattle()
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamTransLeaderNtf then
    self:UpdateRoomInfo()
    self:UpdataNetworkUI()
  elseif notifyName == NotificationDefines.TeamRoom.AIEntryRoom then
    self:GetViewComponent():K2_PostAkEvent(self:GetViewComponent().bp_aiEntryRoomVoice)
  elseif notifyName == NotificationDefines.TeamRoom.UpdateRoomAiLevel then
    self:UpdateAiLevel()
  elseif notifyName == NotificationDefines.TeamRoom.OnRoomMemberNtf then
    self:UpdateRoomInfo()
  end
end
function CustomRoomPageMediator:OnRegister()
  self:GetViewComponent().actionOnShow:Add(self.OnShow, self)
  if self:GetViewComponent().actionOnClickEsc then
    self:GetViewComponent().actionOnClickEsc:Add(self.OnClickEsc, self)
  end
  self:GetViewComponent().actionOnClickRandom:Add(self.OnClickRandom, self)
  self:GetViewComponent().actionOnClickMapSelect:Add(self.OnClickMapSelect, self)
  self:GetViewComponent().actionOnClickButtonStart:Add(self.OnClickButtonStart, self)
  self:GetViewComponent().actionOnClickButtonUnStart:Add(self.OnClickButtonUnStart, self)
  self:GetViewComponent().actionOnClickButtonReady:Add(self.OnClickButtonReady, self)
  self:GetViewComponent().actionOnClickButtonCancel:Add(self.OnClickButtonCancel, self)
  self:GetViewComponent().actionOnClickButtonQuitMatch:Add(self.OnClickButtonQuitMatch, self)
  self:GetViewComponent().actionOnClickCyAI:Add(self.OnClickCyAI, self)
  self:GetViewComponent().actionOnClickEntryTrainningMap:Add(self.OnClickEntryTrainningMap, self)
  self:GetViewComponent().actionOnClickAiLevel:Add(self.OnClickAiLevel, self)
  self:GetViewComponent().actionOnClickButtonSearchRoomCode:Add(self.OnClickButtonSearchRoomCode, self)
  self:GetViewComponent().actionOnClickCopyRoomCode:Add(self.OnClickCopyRoomCode, self)
  if self:GetViewComponent().actionOnClickButtonQuitRoom then
    self:GetViewComponent().actionOnClickButtonQuitRoom:Add(self.OnClickButtonQuitRoom, self)
  end
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.pageMapTypeCache = RoomEnum.MapType.None
  self:UpdataNetworkUI()
end
function CustomRoomPageMediator:OnRemove()
  self:GetViewComponent().actionOnShow:Remove(self.OnShow, self)
  if self:GetViewComponent().actionOnClickEsc then
    self:GetViewComponent().actionOnClickEsc:Remove(self.OnClickEsc, self)
  end
  self:GetViewComponent().actionOnClickRandom:Remove(self.OnClickRandom, self)
  self:GetViewComponent().actionOnClickMapSelect:Remove(self.OnClickMapSelect, self)
  self:GetViewComponent().actionOnClickButtonStart:Remove(self.OnClickButtonStart, self)
  self:GetViewComponent().actionOnClickButtonUnStart:Remove(self.OnClickButtonUnStart, self)
  self:GetViewComponent().actionOnClickButtonReady:Remove(self.OnClickButtonReady, self)
  self:GetViewComponent().actionOnClickButtonCancel:Remove(self.OnClickButtonCancel, self)
  self:GetViewComponent().actionOnClickButtonQuitMatch:Remove(self.OnClickButtonQuitMatch, self)
  self:GetViewComponent().actionOnClickEntryTrainningMap:Remove(self.OnClickEntryTrainningMap, self)
  self:GetViewComponent().actionOnClickAiLevel:Remove(self.OnClickAiLevel, self)
  self:GetViewComponent().actionOnClickButtonSearchRoomCode:Remove(self.OnClickButtonSearchRoomCode, self)
  self:GetViewComponent().actionOnClickCopyRoomCode:Remove(self.OnClickCopyRoomCode, self)
  if self:GetViewComponent().actionOnClickButtonQuitRoom then
    self:GetViewComponent().actionOnClickButtonQuitRoom:Remove(self.OnClickButtonQuitRoom, self)
  end
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.CommonPopUpPage)
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.ExchangePosPC)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
end
function CustomRoomPageMediator:OnQuitBattle()
  if self:GetViewComponent().Canvas_Shield then
    self:GetViewComponent().Canvas_Shield:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:OnQuitMatchNtfCallback()
end
function CustomRoomPageMediator:OnShow()
  self:UpdateRoomInfo()
  self:UpdateAiLevel()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
end
function CustomRoomPageMediator:OnClickButtonSearchRoomCode()
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.RoomCodePage)
end
function CustomRoomPageMediator:OnClickEsc()
  if roomDataProxy:GetLockEditRoomInfo() then
    local customRoomCantSwitchModeText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CustomRoomCantSwitchModeText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, customRoomCantSwitchModeText)
  else
    GameFacade:SendNotification(NotificationDefines.GameModeSelect, true, NotificationDefines.GameModeSelect.QuitRoomByEsc)
  end
end
function CustomRoomPageMediator:OnClickRandom()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomSwitch(roomInfo.teamId, 0, 0, 2)
  end
end
function CustomRoomPageMediator:OnClickMapSelect()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.mapID then
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MapPopUpInfo)
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      GameFacade:SendNotification(NotificationDefines.MapRoom.RefreshUI, {
        mapId = roomInfo.mapID,
        bAllowed = true
      })
    end
  end
end
function CustomRoomPageMediator:OnClickBot()
  local SelectedTeam = 0
  local RandomRank = math.random(1, 30)
  local SelectedRoleID = 0
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomRobot(roomInfo.teamId, SelectedRoleID, RandomRank, 1, SelectedTeam, 0)
  end
end
function CustomRoomPageMediator:OnClickButtonStart()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomBegin(roomInfo.teamId)
  end
end
function CustomRoomPageMediator:OnClickButtonUnStart()
  if 0 == roomDataProxy:GetTeamMemberCountInBattlePosition() then
    local unStartCustomRoonText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "UnStartCustomRoomText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, unStartCustomRoonText)
  elseif not roomDataProxy:GetAllPlayerReady() then
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PlayerNotReady")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function CustomRoomPageMediator:OnClickButtonReady()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomReady(roomInfo.teamId, true)
  end
end
function CustomRoomPageMediator:OnClickButtonCancel()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomReady(roomInfo.teamId, false)
  end
end
function CustomRoomPageMediator:OnClickButtonQuitMatch()
  roomDataProxy:ReqQuitMatch()
end
function CustomRoomPageMediator:OnClickCyAI()
  local SelectedTeam = 0
  local RandomRank = math.random(1, 30)
  local SelectedRoleID = 0
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomRobot(roomInfo.teamId, SelectedRoleID, RandomRank, 1, SelectedTeam, 1)
  end
end
function CustomRoomPageMediator:OnClickEntryTrainningMap()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Context_EnterToRoom")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Confirm_EnterToRoom")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Cancel_EnterToRoom")
  function pageData.cb(bConfirm)
    if bConfirm then
      roomDataProxy:ReqTeamEnterPractice()
    else
      ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage)
    end
  end
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function CustomRoomPageMediator:OnClickAiLevel()
  self:GetViewComponent().MenuAnchor_RoomAiLevel:Open(true)
end
function CustomRoomPageMediator:OnClickCopyRoomCode()
  roomDataProxy:GetRoomCode()
end
function CustomRoomPageMediator:OnClickButtonQuitRoom()
  GameFacade:SendNotification(NotificationDefines.GameModeSelect, true, NotificationDefines.GameModeSelect.QuitRoomByEsc)
end
function CustomRoomPageMediator:UpdateRoomInfo()
  if self:GetViewComponent().Btn_ReturnToLobby then
    self:GetViewComponent().Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CustomRoomMode"))
  end
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.mapID and roomInfo.leaderId then
    local roomMapID = roomInfo.mapID
    if not roomMapID or 0 == roomMapID then
      roomMapID = roomDataProxy:GetDefaultMapId(RoomEnum.MapType.BlastInvasion)
    end
    roomDataProxy:SetRoomMapID(roomMapID)
    self:GetViewComponent().Text_MapName:SetText(roomDataProxy:GetMapName(roomMapID))
    self:GetViewComponent().Text_ModeName:SetText(roomDataProxy:GetMapTypeName(roomMapID))
    local playerInfo = roomDataProxy:GetTeamMemberByPlayerID(roomDataProxy:GetPlayerID())
    if playerInfo and playerInfo.pos then
      self:SetEntryPracticeStatus(playerInfo.pos)
    end
    local mapPlayMode = roomDataProxy:GetMapType(roomInfo.mapID)
    if mapPlayMode and mapPlayMode > RoomEnum.MapType.None and mapPlayMode ~= self.pageMapTypeCache then
      self.pageMapTypeCache = mapPlayMode
      if self:GetViewComponent().WS_PlayerList:GetActiveWidget():IsOpen() then
        self:GetViewComponent().WS_PlayerList:GetActiveWidget():Close()
      end
      self:GetViewComponent().WS_PlayerList:SetActiveWidgetIndex(mapPlayMode - 1)
      if self:GetViewComponent().WS_PlayerList:GetActiveWidget() then
        self:GetViewComponent().WS_PlayerList:GetActiveWidget():Open(true)
      end
    end
    self:SwitchRoomButton()
  end
end
function CustomRoomPageMediator:SetEntryPracticeStatus(pos)
  local playerMaxNum = 10
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.mapID then
    local mapPlayMode = roomDataProxy:GetMapType(roomInfo.mapID)
    if mapPlayMode == RoomEnum.MapType.Team5V5V5 then
      playerMaxNum = 15
    else
      playerMaxNum = 10
    end
  end
  if pos > playerMaxNum then
    self:GetViewComponent().Button_EntryTrainningMap:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:GetViewComponent().Button_EntryTrainningMap:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function CustomRoomPageMediator:GetAllPlayerReady()
  local roomInfo = roomDataProxy:GetTeamInfo()
  local playerList = roomDataProxy:GetTeamMemberList()
  local bAllPlayerReady = true
  if roomInfo and roomInfo.leaderId and playerList then
    for i, player in ipairs(playerList) do
      if player.playerId ~= roomInfo.leaderId and player.status ~= RoomEnum.TeamMemberStatusType.Ready then
        bAllPlayerReady = false
        break
      end
    end
  end
  return bAllPlayerReady
end
function CustomRoomPageMediator:OnJoinMatchNtfCallback(bResult)
  if bResult then
    self.bJoinMatch = bResult
    self:SetGameEnterRoomButton()
  end
end
function CustomRoomPageMediator:OnQuitMatchNtfCallback()
  local playerId = roomDataProxy:GetPlayerID()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if playerId and roomInfo and roomInfo.leaderId and playerId == roomInfo.leaderId then
    local bAllPlayerReady = self:GetAllPlayerReady()
    if bAllPlayerReady then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CanStart)
    else
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CantStart)
    end
  elseif not roomDataProxy:IsTeamLeader() then
    self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.Ready)
  end
end
function CustomRoomPageMediator:OnMatchResultNtfCallback(bResult)
  local playerId = roomDataProxy:GetPlayerID()
  if bResult then
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MatchTimeCounterPage)
    self:SetGameEnterRoomButton()
    if self:GetViewComponent().Canvas_Shield then
      self:GetViewComponent().Canvas_Shield:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    GameFacade:SendNotification(NotificationDefines.TeamRoom.MatchResultNtf, bResult)
  else
    return
  end
  local playerList = roomDataProxy:GetTeamMemberList()
  if playerList then
    for _, player in ipairs(playerList) do
      if player.playerId == playerId and 1 ~= player.status then
        local text = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PMRoomPageReadyText")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
        break
      end
    end
  end
end
function CustomRoomPageMediator:SwitchRoomButton()
  if roomDataProxy:IsRoomMaster() then
    local bAllPlayerReady = self:GetAllPlayerReady()
    if 0 == roomDataProxy:GetTeamMemberCountInBattlePosition() then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CantStart)
    elseif bAllPlayerReady and not self.bJoinMatch then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CanStart)
    elseif bAllPlayerReady and self.bJoinMatch then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CancelMatch)
    else
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.CantStart)
    end
    self:GetViewComponent():SetUIVisibilityOfRoomMasterOrMember(true)
  else
    local playerId = roomDataProxy:GetPlayerID()
    local playerList = roomDataProxy:GetTeamMemberList()
    if playerList then
      for i, player in pairs(playerList) do
        if player.playerId == playerId then
          if player.status == RoomEnum.TeamMemberStatusType.NotReady then
            self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.NotPrepared)
            break
          end
          if player.status == RoomEnum.TeamMemberStatusType.Ready then
            self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.Ready)
          end
          break
        end
      end
    end
    self:GetViewComponent():SetUIVisibilityOfRoomMasterOrMember(false)
  end
end
function CustomRoomPageMediator:SetGameEnterRoomButton()
  if roomDataProxy:IsRoomMaster() then
    self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.RoomMasterEnterGame)
  else
    self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(RoomEnum.CustomRoomButtonStatus.RoomMemberEnterGame)
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    audio.PostEvent(audio.GetID(self:GetViewComponent().bp_matchingTipsVoice))
  end
end
function CustomRoomPageMediator:UpdateAiLevel()
  local currentSelectLevel = roomDataProxy:GetCurrentAiLevel()
  if currentSelectLevel then
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      if currentSelectLevel == RoomEnum.AiLevelEnum.Simple then
        self:GetViewComponent().Img_AiLevelIcon:SetBrush(self:GetViewComponent().bp_aiLevelSimpleBtnStyle)
      elseif currentSelectLevel == RoomEnum.AiLevelEnum.Normal then
        self:GetViewComponent().Img_AiLevelIcon:SetBrush(self:GetViewComponent().bp_aiLevelNormalBtnStyle)
      elseif currentSelectLevel == RoomEnum.AiLevelEnum.Difficult then
        self:GetViewComponent().Img_AiLevelIcon:SetBrush(self:GetViewComponent().bp_aiLevelDifficultBtnStyle)
      end
    elseif currentSelectLevel == RoomEnum.AiLevelEnum.Simple then
      self:GetViewComponent().Button_AiLevel:SetStyle(self:GetViewComponent().bp_aiLevelSimpleBtnStyle)
    elseif currentSelectLevel == RoomEnum.AiLevelEnum.Normal then
      self:GetViewComponent().Button_AiLevel:SetStyle(self:GetViewComponent().bp_aiLevelNormalBtnStyle)
    elseif currentSelectLevel == RoomEnum.AiLevelEnum.Difficult then
      self:GetViewComponent().Button_AiLevel:SetStyle(self:GetViewComponent().bp_aiLevelDifficultBtnStyle)
    end
  end
end
function CustomRoomPageMediator:UpdataNetworkUI()
  local dsClusterIndex, ping, DsClusterName = roomDataProxy:GetLeaderDSClusterInfo()
  if dsClusterIndex then
    if self:GetViewComponent().Img_NetworkState then
      self:GetViewComponent():SetImageByPaperSprite_MatchSize(self:GetViewComponent().Img_NetworkState, self:GetNetworkStateImg(ping))
    end
    if self:GetViewComponent().Text_NetworkAddress then
      self:GetViewComponent().Text_NetworkAddress:SetText(DsClusterName)
    end
    if self:GetViewComponent().Text_NetworkPing then
      self:GetViewComponent().Text_NetworkPing:SetText(tostring(ping))
      self:GetViewComponent().Text_NetworkPing:SetColorAndOpacity(self:GetNetworkStateColor(ping))
    end
  end
end
function CustomRoomPageMediator:GetNetworkStateImg(Ping)
  local NetworkStateImg
  local NetworkStateString = ""
  local NetworkStateStringList = roomDataProxy:GetNetworkStateStringList(self:GetViewComponent().NetworkStateImgList)
  if NetworkStateStringList and #NetworkStateStringList > 0 then
    NetworkStateString = NetworkStateStringList[1]
    if Ping > 100 then
      NetworkStateString = NetworkStateStringList[3]
    elseif Ping > 50 then
      NetworkStateString = NetworkStateStringList[2]
    else
      NetworkStateString = NetworkStateStringList[1]
    end
  end
  LogDebug("GetNetworkStateImg", "NetworkStateString = " .. NetworkStateString)
  local PictureStrpath = UE.UKismetSystemLibrary.MakeSoftObjectPath(NetworkStateString)
  NetworkStateImg = UE.UKismetSystemLibrary.Conv_SoftObjPathToSoftObjRef(PictureStrpath)
  print("GetNetworkStateImg", NetworkStateImg)
  return NetworkStateImg
end
function CustomRoomPageMediator:GetNetworkStateColor(Ping)
  local NetworkStateColor
  if self:GetViewComponent().NetworkTextColorList and self:GetViewComponent().NetworkTextColorList:Length() > 0 then
    NetworkStateColor = self:GetViewComponent().NetworkTextColorList:Get(1)
    if Ping > 100 then
      NetworkStateColor = self:GetViewComponent().NetworkTextColorList:Get(3)
    elseif Ping > 50 then
      NetworkStateColor = self:GetViewComponent().NetworkTextColorList:Get(2)
    else
      NetworkStateColor = self:GetViewComponent().NetworkTextColorList:Get(1)
    end
  end
  return NetworkStateColor
end
return CustomRoomPageMediator
