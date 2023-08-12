local RankRoomMediator = class("RankRoomMediator", PureMVC.Mediator)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local roomDataProxy
local rankRoomState = {
  allow = 0,
  playerNotPrepare = 1,
  divisionConditionFail = 2,
  divisionLimit = 3
}
function RankRoomMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.OnTeamUpdateNtf,
    NotificationDefines.TeamRoom.OnJoinMatchNtf,
    NotificationDefines.TeamRoom.OnQuitMatchNtf,
    NotificationDefines.TeamRoom.OnTeamInfoNtf,
    NotificationDefines.TeamRoom.OnTeamMemberEnterNtf,
    NotificationDefines.TeamRoom.OnTeamMemberReadyNtf,
    NotificationDefines.TeamRoom.OnTeamTransLeaderNtf,
    NotificationDefines.TeamRoom.OnPenaltyTimeNtf,
    NotificationDefines.GameModeSelect.ChangeTeamMode,
    NotificationDefines.TeamRoom.OnTeamMemberQuitNtf,
    NotificationDefines.TeamRoom.StartRoomMatchTimeCount,
    NotificationDefines.Card.CardPrepareAnimationFinished,
    NotificationDefines.TeamRoom.OnMatchResultNtf,
    NotificationDefines.TeamRoom.ResetRoomPrepareAnimation
  }
end
function RankRoomMediator:HandleNotification(notification)
  local viewComponent = self:GetViewComponent()
  local notifyName = notification:GetName()
  local notifyBody = notification:GetBody()
  if notifyName == NotificationDefines.GameModeSelect.ChangeTeamMode then
    self:OnChangeTeamMode(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamUpdateNtf then
    self:OnTeamUpdateNtfCallback(true)
    self:UpdataNetworkUI()
  elseif notifyName == NotificationDefines.TeamRoom.OnJoinMatchNtf then
    self:OnJoinMatchNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnQuitMatchNtf then
    self:OnQuitMatchNtfCallback()
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamInfoNtf then
    self:OnTeamInfoNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamMemberEnterNtf then
    self:OnTeamMemberEnterNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamMemberReadyNtf then
    self:OnTeamMemberReadyNtfCallback(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamTransLeaderNtf then
    self:OnTeamTransLeaderNtfCallback(notifyBody)
    self:UpdataNetworkUI()
  elseif notifyName == NotificationDefines.TeamRoom.OnPenaltyTimeNtf then
    self:OnMatchPrepareFailed(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamMemberQuitNtf then
    self:OnTeamMemberQuitNtf(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.StartRoomMatchTimeCount then
    self.matchTime = notifyBody
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      self:SetMatchTimeUI(roomDataProxy:IsTeamLeader())
    end
  elseif notifyName == NotificationDefines.Card.CardPrepareAnimationFinished then
    if notification:GetBody() then
      viewComponent.Canvas_BottomButton:SetVisibility(UE4.ESlateVisibility.Visible)
      viewComponent:PlayAnimation(viewComponent.BottomButton_Animation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
      viewComponent.Canvas_BottomButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif notifyName == NotificationDefines.TeamRoom.OnMatchResultNtf then
    viewComponent:PlayAnimation(viewComponent.SceneSwitch, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  elseif notifyName == NotificationDefines.TeamRoom.ResetRoomPrepareAnimation then
    viewComponent:PlayAnimation(viewComponent.SceneSwitch, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
    viewComponent:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function RankRoomMediator:OnRegister()
  local viewComponent = self:GetViewComponent()
  if viewComponent.actionLuaHandleKeyEvent then
    viewComponent.actionLuaHandleKeyEvent:Add(self.LuaHandleKeyEvent, self)
  end
  viewComponent.actionOnClickEsc:Add(self.OnClickEsc, self)
  viewComponent.actionOnClickButtonStart:Add(self.OnClickButtonStart, self)
  viewComponent.actionOnClickButtonUnStart:Add(self.OnClickButtonUnStart, self)
  viewComponent.actionOnClickButtonReady:Add(self.OnClickButtonReady, self)
  viewComponent.actionOnClickButtonCancel:Add(self.OnClickButtonCancel, self)
  viewComponent.actionOnClickButtonQuitMatch:Add(self.OnClickButtonQuitMatch, self)
  viewComponent.actionOnClickButtonQuitRoom:Add(self.OnClickButtonQuitRoom, self)
  viewComponent.actionOnClickEntryTrainningMap:Add(self.OnClickEntryTrainningMap, self)
  viewComponent.actionOnClickButtonSearchRoomCode:Add(self.OnClickButtonSearchRoomCode, self)
  viewComponent.actionOnClickCopyRoomCode:Add(self.OnClickCopyRoomCode, self)
  self:OnInit()
  self:UpdataNetworkUI()
end
function RankRoomMediator:OnRemove()
  local viewComponent = self:GetViewComponent()
  if viewComponent.actionLuaHandleKeyEvent then
    viewComponent.actionLuaHandleKeyEvent:Remove(self.LuaHandleKeyEvent, self)
  end
  viewComponent.actionOnClickEsc:Remove(self.OnClickEsc, self)
  viewComponent.actionOnClickButtonStart:Remove(self.OnClickButtonStart, self)
  viewComponent.actionOnClickButtonUnStart:Remove(self.OnClickButtonUnStart, self)
  viewComponent.actionOnClickButtonReady:Remove(self.OnClickButtonReady, self)
  viewComponent.actionOnClickButtonCancel:Remove(self.OnClickButtonCancel, self)
  viewComponent.actionOnClickButtonQuitMatch:Remove(self.OnClickButtonQuitMatch, self)
  viewComponent.actionOnClickButtonQuitRoom:Remove(self.OnClickButtonQuitRoom, self)
  viewComponent.actionOnClickButtonSearchRoomCode:Remove(self.OnClickButtonSearchRoomCode, self)
  viewComponent.actionOnClickCopyRoomCode:Remove(self.OnClickCopyRoomCode, self)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  ViewMgr:ClosePage(viewComponent, "TeamApplyPC")
  ViewMgr:ClosePage(viewComponent, "FriendBlackConfirmPage")
  ViewMgr:ClosePage(viewComponent, "MapPopUpInfo")
  ViewMgr:ClosePage(viewComponent, "CommonPopUpPage")
  self:ClearTimerHandleMatchTimeCounter()
  self:ClearTimerHandleExpireTime()
end
function RankRoomMediator:LuaHandleKeyEvent(key, inputEvent)
  return self:GetViewComponent().HotKeyButton:MonitorKeyDown(key, inputEvent)
end
function RankRoomMediator:OnInit()
  self.playerSlots = {}
  self.playerReflectionSlots = {}
  self.teamMode = 0
  self.matchTime = -1
  self.rankMatchStatus = rankRoomState.allow
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self:ClearRoomAllMemberCardData()
  self:OnTeamUpdateNtfCallback(true)
  self:SetQuitRoomBtnVisable()
  if not roomDataProxy:IsInMatchPrepare() and roomDataProxy:HasValidMatchResult() then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
    LogInfo("RankRoomMediator", "Has valid MatchResult, but not open, so open it")
  end
end
function RankRoomMediator:OnChangeTeamMode(teamMode)
  self:SetReturnToLobbyButtonName(teamMode)
  self:SetRoomButtonState()
end
function RankRoomMediator:SetReturnToLobbyButtonName(teamMode)
  local viewComponent = self:GetViewComponent()
  if viewComponent.Btn_ReturnToLobby then
    if teamMode == GameModeSelectNum.GameModeType.Boomb then
      viewComponent.Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "BombMode"))
    elseif teamMode == GameModeSelectNum.GameModeType.Team then
      viewComponent.Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamMode"))
    elseif teamMode == GameModeSelectNum.GameModeType.RankBomb then
      viewComponent.Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RankingMode"))
    elseif teamMode == GameModeSelectNum.GameModeType.Room then
      viewComponent.Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CustomRoomMode"))
    elseif teamMode == GameModeSelectNum.GameModeType.Team3V3V3 then
      viewComponent.Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Team3V3V3"))
    end
  end
  if teamMode == GameModeSelectNum.GameModeType.RankBomb or teamMode == GameModeSelectNum.GameModeType.RankTeam then
    self:ShowRankScope(true)
  else
    self:ShowRankScope(false)
  end
end
function RankRoomMediator:OnClickButtonQuitRoom()
  GameFacade:SendNotification(NotificationDefines.GameModeSelect, true, NotificationDefines.GameModeSelect.QuitRoomByEsc)
end
function RankRoomMediator:OnTeamUpdateNtfCallback(bResetFirst)
  if roomDataProxy then
    local tempTeamInfo = roomDataProxy:GetTeamInfo()
    if not tempTeamInfo or not tempTeamInfo.members then
      return
    end
    self:SetReturnToLobbyButtonName(tempTeamInfo.mode)
    if bResetFirst then
      for key, value in pairs(self.playerSlots) do
        value:SetPlayerStateBaseCard(CardEnum.PlayerState.None)
        value.mediators[1]:ResetSmallSpeakerPlayerID()
      end
      if self.playerReflectionSlots and #self.playerReflectionSlots > 0 then
        for key, value in pairs(self.playerReflectionSlots) do
          value:SetPlayerStateBaseCard(CardEnum.PlayerState.None)
          value.mediators[1]:ResetSmallSpeakerPlayerID()
        end
      end
    end
    local playerSlot
    for key, value in pairs(tempTeamInfo.members) do
      if value.bIsRobot then
        break
      end
      if value.pos then
        playerSlot = self.playerSlots[value.pos]
        if playerSlot then
          playerSlot:SetPlayerData(value, true)
        end
        if self.playerReflectionSlots and #self.playerReflectionSlots > 0 and #self.playerReflectionSlots >= value.pos then
          playerSlot = self.playerReflectionSlots[value.pos]
          if playerSlot then
            playerSlot:SetPlayerData(value, true)
          end
        end
      end
      if value.playerId == roomDataProxy:GetPlayerID() then
        self:SetRoomButtonState(value.status)
      end
    end
    if self.teamMode ~= Pb_ncmd_cs.ERoomMode.RoomMode_NONE and self.teamMode ~= Pb_ncmd_cs.ERoomMode.RoomMode_ROOM then
      GameFacade:SendNotification(NotificationDefines.GameModeSelect.ChangeTeamMode, self.teamMode)
    end
    self:SetQuitRoomBtnVisable()
  end
  TimerMgr:AddTimeTask(0.1, 0, 1, function()
    local viewComponent = self:GetViewComponent()
    if viewComponent then
      if viewComponent.PlayerSlotsList then
        viewComponent.PlayerSlotsList:SetVisibility(UE4.ESlateVisibility.Visible)
      end
      if viewComponent.PlayerSlotsList_Ref then
        viewComponent.PlayerSlotsList_Ref:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end)
end
function RankRoomMediator:OnClickEntryTrainningMap()
  if roomDataProxy then
    if roomDataProxy:GetIsInMatch() then
      return
    end
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
end
function RankRoomMediator:OnTeamMemberReadyNtfCallback(data)
  local playerId = data.playerId
  local newStatus = data.status
  local tempTeamInfo = roomDataProxy:GetTeamInfo()
  if not tempTeamInfo or not tempTeamInfo.members then
    return
  end
  for key, value in pairs(self.playerSlots) do
    if value:GetSlotPlayerId() == playerId then
      if newStatus == RoomEnum.TeamMemberStatusType.NotReady then
        value:PlayUnPreparedAnim()
        break
      elseif newStatus == RoomEnum.TeamMemberStatusType.Ready then
        value:PlayPrepareAnim(true, false)
        break
      end
    end
  end
  if self.playerReflectionSlots and #self.playerReflectionSlots > 0 then
    for key, value in pairs(self.playerReflectionSlots) do
      if value:GetSlotPlayerId() == playerId then
        if newStatus == RoomEnum.TeamMemberStatusType.NotReady then
          value:PlayUnPreparedAnim()
          break
        elseif newStatus == RoomEnum.TeamMemberStatusType.Ready then
          value:PlayPrepareAnim(true, false)
          break
        end
      end
    end
  end
  if roomDataProxy:IsTeamLeader() or roomDataProxy:GetPlayerID() == playerId then
    self:SetRoomButtonState(newStatus)
  end
end
function RankRoomMediator:OnJoinMatchNtfCallback(bResult)
  local viewComponent = self:GetViewComponent()
  if roomDataProxy then
    local teamInfo = roomDataProxy:GetTeamInfo()
    if bResult and roomDataProxy and viewComponent.WS_RoomButton and teamInfo and teamInfo.teamId and 0 ~= teamInfo.teamId then
      if roomDataProxy:IsTeamLeader() then
        viewComponent.WS_RoomButton:SetActiveWidgetIndex(4)
      else
        viewComponent.WS_RoomButton:SetActiveWidgetIndex(5)
      end
      viewComponent:PlayAnimation(self.Start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
      for key, value in pairs(self.playerSlots) do
        if value then
          value:PlayAnimation(self.Start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        end
      end
      if self.playerReflectionSlots and #self.playerReflectionSlots > 0 then
        for key, value in pairs(self.playerReflectionSlots) do
          if value then
            value:PlayAnimation(self.Start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
          end
        end
      end
      self:SetRoomButtonState()
    end
  end
end
function RankRoomMediator:OnQuitMatchNtfCallback()
  if roomDataProxy then
    self:SetRoomButtonState()
    if not roomDataProxy.bLockEditRoomInfo then
      self:GetViewComponent().WS_QuitRoomButton:SetActiveWidgetIndex(0)
    end
  end
  self:GetViewComponent().Button_EntryTrainningMap:SetIsEnabled(true)
end
function RankRoomMediator:OnTeamTransLeaderNtfCallback(inLeaderID)
  self:OnTeamUpdateNtfCallback(true)
end
function RankRoomMediator:OnTeamMemberEnterNtfCallback(playerInfo)
  local playerSlot = self.playerSlots[playerInfo.pos]
  if playerSlot then
    playerSlot:SetPlayerData(playerInfo, true)
    if self.playerReflectionSlots and #self.playerReflectionSlots > 0 and #self.playerReflectionSlots >= playerInfo.pos then
      local playerReflectionSlot = self.playerReflectionSlots[playerInfo.pos]
      if playerReflectionSlot then
        playerReflectionSlot:SetPlayerData(playerInfo, true)
      end
    end
  end
  self:SetRoomButtonState()
end
function RankRoomMediator:OnTeamInfoNtfCallback(inTeamInfo)
  self.teamMode = inTeamInfo.mode
  self:SetReturnToLobbyButtonName(self.teamMode)
end
function RankRoomMediator:OnMatchPrepareFailed(penaltyPlayerIDs)
  ViewMgr:ClosePage(self:GetViewComponent(), "RankPreparePage")
  self:GetViewComponent().WS_QuitRoomButton:SetActiveWidgetIndex(0)
  if roomDataProxy then
    if roomDataProxy:IsTeamLeader() then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(0)
      self:OnClickButtonStart()
    else
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(3)
    end
    local penaltyTips = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "PunishTime2")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, penaltyTips)
  end
end
function RankRoomMediator:OnTeamMemberQuitNtf(playerId)
  if playerId then
    for key, value in pairs(self.playerSlots) do
      if value:GetSlotPlayerId() == playerId then
        value:SetPlayerStateBaseCard(CardEnum.PlayerState.None)
      end
    end
    if self.playerReflectionSlots and #self.playerReflectionSlots > 0 then
      for key, value in pairs(self.playerReflectionSlots) do
        if value:GetSlotPlayerId() == playerId then
          value:SetPlayerStateBaseCard(CardEnum.PlayerState.None)
        end
      end
    end
  end
  self:SetQuitRoomBtnVisable()
  self:SetRoomButtonState()
end
function RankRoomMediator:OnClickButtonStart()
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if not NewPlayerGuideProxy:IsAllGuideComplete() then
    roomDataProxy:ReqPlayerGuideBattle()
    roomDataProxy:SetExpectMatchTime(3)
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    return
  end
  if roomDataProxy:GetAllPlayerReady() then
    roomDataProxy:ReqJoinMatch()
    self:GetViewComponent().WS_RoomButton:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:ClearTimerHandleExpireTime()
    self.TimerHandle_ExpireTime = TimerMgr:AddTimeTask(0.5, 0, 0, function()
      self:StartBtnCoolDown()
    end)
  else
    local showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PlayerNotReady")
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.PopUpPromptPage, false, {showMsg = showMsg})
  end
end
function RankRoomMediator:StartBtnCoolDown()
  self:GetViewComponent().WS_RoomButton:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function RankRoomMediator:OnClickButtonUnStart()
  local showMsg = ""
  if self.rankMatchStatus == rankRoomState.divisionConditionFail then
    showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "ExcessiveGapInRank")
  elseif self.rankMatchStatus == rankRoomState.divisionLimit then
    showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "bestPlayerLimit")
  else
    showMsg = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "PlayerNotReady")
  end
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
end
function RankRoomMediator:OnClickButtonReady()
  if roomDataProxy and roomDataProxy.teamInfo and roomDataProxy.teamInfo.teamId then
    roomDataProxy:ReqTeamReady(roomDataProxy.teamInfo.teamId, 1)
  end
end
function RankRoomMediator:OnClickButtonCancel()
  if roomDataProxy and roomDataProxy.teamInfo and roomDataProxy.teamInfo.teamId then
    roomDataProxy:ReqTeamReady(roomDataProxy.teamInfo.teamId, 0)
  end
end
function RankRoomMediator:OnClickButtonQuitMatch()
  if roomDataProxy then
    roomDataProxy:ReqQuitMatch()
    self:GetViewComponent().WS_RoomButton:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:ClearTimerHandleExpireTime()
    self.TimerHandle_ExpireTime = TimerMgr:AddTimeTask(0.5, 0, 0, function()
      self:StartBtnCoolDown()
    end)
  end
end
function RankRoomMediator:OnClickEsc()
  if roomDataProxy and roomDataProxy:IsInMatchPrepare() then
    return
  end
  GameFacade:SendNotification(NotificationDefines.GameModeSelect, false, NotificationDefines.GameModeSelect.QuitRoomByEsc)
end
function RankRoomMediator:OnClickButtonSearchRoomCode()
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.RoomCodePage)
end
function RankRoomMediator:SetQuitRoomBtnVisable()
  if roomDataProxy then
    local tempTeamInfo = roomDataProxy:GetTeamInfo()
    if tempTeamInfo and tempTeamInfo.members and #tempTeamInfo.members > 1 then
      self:GetViewComponent().WS_QuitRoomButton:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self:GetViewComponent().WS_QuitRoomButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function RankRoomMediator:ShowRankScope(shouldShow)
  local viewComponent = self:GetViewComponent()
  if viewComponent and viewComponent.HB_RankScope then
    if shouldShow then
      self:UpdateTeammateDivisionScope()
      viewComponent.HB_RankScope:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      viewComponent.HB_RankScope:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function RankRoomMediator:UpdateTeammateDivisionScope()
  local bMatchEnable = true
  self.rankMatchStatus = rankRoomState.allow
  local teammateList = GameFacade:RetrieveProxy(ProxyNames.RoomProxy):GetTeamMemberList()
  if teammateList then
    local bHasBestPlayer = false
    local playerCnt = 0
    local maxRank = -1
    local minRank = -1
    for key, value in pairs(teammateList) do
      if value.stars then
        if value.stars >= CareerEnumDefine.rankDivisionStar.bestPlayerDivision then
          bHasBestPlayer = true
        end
        local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(value.stars)
        if divisionCfg then
          local rank = divisionCfg.Id
          if maxRank < rank or maxRank < 0 then
            maxRank = rank
          end
          if minRank > rank or minRank < 0 then
            minRank = rank
          end
        end
        if minRank > value.rank or 0 == minRank then
          minRank = value.rank
        end
      end
      playerCnt = playerCnt + 1
    end
    if self:GetViewComponent().WidgetSwitcher_ScopeText then
      self:GetViewComponent().WidgetSwitcher_ScopeText:SetActiveWidgetIndex(bHasBestPlayer and 1 or 0)
    end
    if self:GetViewComponent().WidgetSwitcher_Scope5Text then
      self:GetViewComponent().WidgetSwitcher_Scope5Text:SetActiveWidgetIndex(bHasBestPlayer and 1 or 0)
    end
    if bHasBestPlayer and playerCnt > 2 then
      self.rankMatchStatus = rankRoomState.divisionLimit
      return false
    end
    if minRank < 0 then
      LogError("UpdateTeammateDivisionScope:", "minRank < 0")
      return
    end
    local teammateNum = table.count(teammateList)
    local bCanStart = true
    local careerProxy = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy)
    local minDivisionCfg = careerProxy:GetDivisionConfigRow(minRank)
    local maxDivisionCfg = careerProxy:GetDivisionConfigRow(maxRank)
    local groupStarMax = minDivisionCfg.GroupMax
    local groupStarMin = maxDivisionCfg.GroupMin
    local group5StarMax = minDivisionCfg.Group5Max
    local group5StarMin = maxDivisionCfg.Group5Min
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RankTeamScope")
    if self:GetViewComponent().Text_RankDivisionScope then
      if maxRank > groupStarMax or minRank < groupStarMin then
        groupStarMax = nil
        groupStarMin = nil
        if teammateNum < 5 then
          bCanStart = false
        end
        bMatchEnable = false
        self.rankMatchStatus = rankRoomState.divisionConditionFail
        if self:GetViewComponent().WidgetSwitcher_RankDivisionScope then
          self:GetViewComponent().WidgetSwitcher_RankDivisionScope:SetActiveWidgetIndex(1)
        end
      else
        local groupMinCfg = careerProxy:GetDivisionConfigRow(groupStarMin)
        local groupMaxCfg = careerProxy:GetDivisionConfigRow(groupStarMax)
        local stringMap = {
          [0] = groupMinCfg.Name,
          [1] = groupMaxCfg.Name
        }
        local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
        self:GetViewComponent().Text_RankDivisionScope:SetText(text)
        if self:GetViewComponent().WidgetSwitcher_RankDivisionScope then
          self:GetViewComponent().WidgetSwitcher_RankDivisionScope:SetActiveWidgetIndex(0)
        end
      end
    end
    if self:GetViewComponent().Text_RankDivisionScope5 then
      if maxRank > group5StarMax or minRank < group5StarMin then
        group5StarMax = nil
        group5StarMin = nil
        if 5 == teammateNum then
          bCanStart = false
        end
        bMatchEnable = false
        self.rankMatchStatus = rankRoomState.divisionConditionFail
        if self:GetViewComponent().WidgetSwitcher_RankDivisionScope5 then
          self:GetViewComponent().WidgetSwitcher_RankDivisionScope5:SetActiveWidgetIndex(1)
        end
      else
        local groupMinCfg = careerProxy:GetDivisionConfigRow(group5StarMin)
        local groupMaxCfg = careerProxy:GetDivisionConfigRow(group5StarMax)
        local stringMap = {
          [0] = groupMinCfg.Name,
          [1] = groupMaxCfg.Name
        }
        local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
        self:GetViewComponent().Text_RankDivisionScope5:SetText(text)
        if self:GetViewComponent().WidgetSwitcher_RankDivisionScope5 then
          self:GetViewComponent().WidgetSwitcher_RankDivisionScope5:SetActiveWidgetIndex(0)
        end
      end
    end
  end
  return bMatchEnable
end
function RankRoomMediator:ClearRoomAllMemberCardData()
  for i = 1, 5 do
    local slotStr = "PlayerSlot_"
    local slotReflectionStr = "PlayerSlot_Ref_"
    slotStr = slotStr .. tostring(i)
    slotReflectionStr = slotReflectionStr .. tostring(i)
    local playerSlotIns = self:GetViewComponent()[slotStr]
    if playerSlotIns then
      playerSlotIns.position = i
      playerSlotIns.memberInfo = {}
      table.insert(self.playerSlots, playerSlotIns)
    end
    local playerSlotReflectionIns = self:GetViewComponent()[slotReflectionStr]
    if playerSlotReflectionIns then
      playerSlotReflectionIns.position = i
      playerSlotReflectionIns.memberInfo = {}
      table.insert(self.playerReflectionSlots, playerSlotReflectionIns)
    end
  end
end
function RankRoomMediator:SetRoomButtonState(playerStatus)
  if roomDataProxy:GetCurrentModeIsTeam3v3v3Mode() and roomDataProxy:GetPlayerNumberInRoom() > 3 then
    self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(6)
    return
  end
  if roomDataProxy:GetIsInMatch() then
    self:GetViewComponent().Button_EntryTrainningMap:SetIsEnabled(false)
  end
  if roomDataProxy:IsTeamLeader() then
    local teamMode = roomDataProxy:GetGameMode()
    if (teamMode == GameModeSelectNum.GameModeType.RankBomb or teamMode == GameModeSelectNum.GameModeType.RankTeam) and not self:UpdateTeammateDivisionScope() then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(1)
      return
    end
    if roomDataProxy:GetAllPlayerReady() then
      if roomDataProxy:GetIsInMatch() then
        self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(4)
      else
        self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(0)
      end
    else
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(1)
    end
  else
    if not playerStatus then
      local tempTeamInfo = roomDataProxy:GetTeamInfo()
      if not tempTeamInfo or not tempTeamInfo.members then
        LogInfo("MatchRoom:", "SetRoomButtonState Call, tempTeamInfo or tempTeamInfo.members is nil")
        return
      end
      for key, value in pairs(tempTeamInfo.members) do
        if value.playerId == roomDataProxy:GetPlayerID() then
          playerStatus = value.status
        end
      end
    end
    if playerStatus == RoomEnum.TeamMemberStatusType.NotReady then
      self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(2)
    elseif playerStatus == RoomEnum.TeamMemberStatusType.Ready then
      if roomDataProxy:GetIsInMatch() then
        self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(5)
      else
        self:GetViewComponent().WS_RoomButton:SetActiveWidgetIndex(3)
      end
    else
      LogInfo("MatchRoom:", "SetRoomButtonState Call, bad room button state, playerStatus is " .. tostring(playerStatus))
    end
  end
  self:SetQuitRoomBtnVisable()
end
function RankRoomMediator:SetMatchTimeUI(bIsLeader)
  self:ClearTimerHandleMatchTimeCounter()
  self.matchTimeCounterHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
    self.matchTime = self.matchTime + 1
    local minutes = math.floor(self.matchTime / 60)
    local seconds = self.matchTime % 60
    local timeText = self:GetTimeText(minutes, seconds)
    if bIsLeader then
      self:GetViewComponent().Text_Time:SetText(timeText)
    else
      self:GetViewComponent().Text_Time_TeamMate:SetText(timeText)
    end
  end)
end
function RankRoomMediator:GetTimeText(minutes, seconds)
  local minutesText = tostring(minutes)
  local secondsText = tostring(seconds)
  if #minutesText < 2 then
    minutesText = "0" .. minutesText
  end
  if #secondsText < 2 then
    secondsText = "0" .. secondsText
  end
  local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
  local arg1 = UE4.FFormatArgumentData()
  arg1.ArgumentName = "Min"
  arg1.ArgumentValue = minutesText
  arg1.ArgumentValueType = 4
  local arg2 = UE4.FFormatArgumentData()
  arg2.ArgumentName = "Sec"
  arg2.ArgumentValue = secondsText
  arg2.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  inArgsTarry:Add(arg2)
  local timeText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Time")
  return UE4.UKismetTextLibrary.Format(timeText, inArgsTarry)
end
function RankRoomMediator:OnClickCopyRoomCode()
  roomDataProxy:GetRoomCode()
end
function RankRoomMediator:ClearTimerHandleExpireTime()
  if self.TimerHandle_ExpireTime then
    self.TimerHandle_ExpireTime:EndTask()
    self.TimerHandle_ExpireTime = nil
  end
end
function RankRoomMediator:ClearTimerHandleMatchTimeCounter()
  if self.matchTimeCounterHandle then
    self.matchTimeCounterHandle:EndTask()
    self.matchTimeCounterHandle = nil
  end
end
function RankRoomMediator:UpdataNetworkUI()
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
function RankRoomMediator:GetNetworkStateImg(Ping)
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
function RankRoomMediator:GetNetworkStateColor(Ping)
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
return RankRoomMediator
