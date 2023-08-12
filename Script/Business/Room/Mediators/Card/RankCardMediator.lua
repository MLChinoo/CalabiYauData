local RankCardMediator = class("RankCardMediator", PureMVC.Mediator)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local cardDataProxy, roomDataProxy
function RankCardMediator:ListNotificationInterests()
  return {
    NotificationDefines.GameModeSelect.ChangeTeamMode,
    NotificationDefines.Card.SetEnterPracticeStatus,
    NotificationDefines.Card.PracticeRemindClickStatus,
    NotificationDefines.Card.PlayerHoverInviteFriendBtn,
    NotificationDefines.Card.PlayerUnHoverInviteFriendBtn,
    NotificationDefines.GameModeSelect.TeamModeModify
  }
end
function RankCardMediator:HandleNotification(notification)
  local viewComponent = self:GetViewComponent()
  local notifyName = notification:GetName()
  local body = notification:GetBody()
  if notifyName == NotificationDefines.GameModeSelect.ChangeTeamMode then
    if body == GameModeSelectNum.GameModeType.RankBomb or body == GameModeSelectNum.GameModeType.RankTeam then
      self:ShowRankDivision(true)
    else
      self:ShowRankDivision(false)
    end
  elseif notifyName == NotificationDefines.Card.SetEnterPracticeStatus then
    if body and body.playerId and viewComponent.memberInfo and viewComponent.memberInfo.playerId and body.playerId == self:GetViewComponent().memberInfo.playerId then
      self:OnSetPracticeInfoVisibility(body.bEnter)
    end
  elseif notifyName == NotificationDefines.Card.PracticeRemindClickStatus then
    if body and body.playerId and viewComponent.memberInfo and viewComponent.memberInfo.playerId and body.playerId == self:GetViewComponent().memberInfo.playerId and viewComponent.Btn_PracticeRemind then
      viewComponent.Btn_PracticeRemind:SetIsEnabled(body.bClick)
    end
  elseif notifyName == NotificationDefines.Card.PlayerHoverInviteFriendBtn then
    if body and viewComponent.position and body == viewComponent.position then
      viewComponent:PlayHoveredInviteFriend()
    end
  elseif notifyName == NotificationDefines.Card.PlayerUnHoverInviteFriendBtn then
    if body and viewComponent.position and body == viewComponent.position then
      viewComponent:PlayUnhoveredInviteFriend()
    end
  elseif notifyName == NotificationDefines.GameModeSelect.TeamModeModify then
    self:OnTeamModeModify(body)
  end
end
function RankCardMediator:OnRegister()
  self.super:OnRegister()
  self:GetViewComponent().memberInfo = nil
  cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self:GetViewComponent().actionOnClickedAdd:Add(self.OnClickedAdd, self)
  self:GetViewComponent().actionOnPressedAdd:Add(self.OnPressedAdd, self)
  self:GetViewComponent().actionOnReleasedAdd:Add(self.OnReleasedAdd, self)
  self:GetViewComponent().actionSetPlayerStateBaseCard:Add(self.SetPlayerState, self)
  self:GetViewComponent().actionSetPlayerData:Add(self.SetPlayerData, self)
  self:GetViewComponent().actionSetPlayerHost:Add(self.SetPlayerHost, self)
  if self:GetViewComponent().actionOnClickPracticeRemind then
    self:GetViewComponent().actionOnClickPracticeRemind:Add(self.OnClickPracticeRemind, self)
  end
end
function RankCardMediator:OnRemove()
  self.super:OnRemove()
  self:GetViewComponent().actionOnClickedAdd:Remove(self.OnClickedAdd, self)
  self:GetViewComponent().actionOnPressedAdd:Remove(self.OnPressedAdd, self)
  self:GetViewComponent().actionOnReleasedAdd:Remove(self.OnReleasedAdd, self)
  self:GetViewComponent().actionSetPlayerStateBaseCard:Remove(self.SetPlayerState, self)
  self:GetViewComponent().actionSetPlayerData:Remove(self.SetPlayerData, self)
  self:GetViewComponent().actionSetPlayerHost:Remove(self.SetPlayerHost, self)
  if self:GetViewComponent().actionOnClickPracticeRemind then
    self:GetViewComponent().actionOnClickPracticeRemind:Remove(self.OnClickPracticeRemind, self)
  end
  self:ClearAllTimerHandle()
end
function RankCardMediator:OnClickedAdd()
  if roomDataProxy and not roomDataProxy.bIsReqJoinMatch then
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      ViewMgr:OpenPage(LuaGetWorld(), "FriendSidePullPage")
    else
      local sendBody = {}
      sendBody.target = UIPageNameDefine.FriendList
      GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, sendBody)
    end
  end
end
function RankCardMediator:OnPressedAdd()
end
function RankCardMediator:OnReleasedAdd()
end
function RankCardMediator:ResetSmallSpeakerPlayerID()
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.playerID = -1
  end
end
function RankCardMediator:SetPlayerState(playerState)
  local oldState = self.currentState
  self.currentState = playerState
  if playerState == CardEnum.PlayerState.None then
    self:SetEmptyCardStyle()
  elseif playerState == CardEnum.PlayerState.Normal then
    self:SetNormalStateCardStyle()
  elseif playerState == CardEnum.PlayerState.Ready then
    self:SetReadyStateCardStyle()
  elseif playerState == CardEnum.PlayerState.Leave then
    if oldState and oldState == CardEnum.PlayerState.Ready then
      self:SetLeaveStateCardStyleFromReady()
    elseif oldState and oldState == CardEnum.PlayerState.Normal then
      self:SetLeaveStateCardStyleFromNormal()
    else
      self:SetEmptyCardStyle()
    end
  elseif playerState == CardEnum.PlayerState.Settle then
    self:SetSettleStateCardStyle()
  elseif playerState == CardEnum.PlayerState.LostConnection then
    self:SetOfflineStateCardStyle()
  end
  self:SetCanvasInviteVisible()
end
function RankCardMediator:SetPlayerData(playerInfo)
  self:GetViewComponent().memberInfo = playerInfo
  local selfPlayerID = self:GetViewComponent().memberInfo.playerId
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.playerID = selfPlayerID
  end
  GameFacade:SendNotification(NotificationDefines.SmallSpeakerStateChanged, selfPlayerID)
  self:SetCardDetailInfo(playerInfo)
  if roomDataProxy:PlayerIsTeamLeader(playerInfo.playerId) then
    self:SetPlayerHost(true)
  else
    self:SetPlayerHost(false)
  end
  if playerInfo.status == RoomEnum.TeamMemberStatusType.NotReady then
    self:SetPlayerState(CardEnum.PlayerState.Normal)
  elseif playerInfo.status == RoomEnum.TeamMemberStatusType.Ready then
    self:SetPlayerState(CardEnum.PlayerState.Ready)
    if playerInfo.rankCardPlayAnimStatus == RoomEnum.RankCardPlayAnimStatus.UnPlayPrepareAnim or playerInfo.rankCardPlayAnimStatus == RoomEnum.RankCardPlayAnimStatus.First then
      playerInfo.rankCardPlayAnimStatus = RoomEnum.RankCardPlayAnimStatus.PlayedPrepareAnim
      playerInfo.bIsReflection = true
      self:GetViewComponent():PlayPrepareAnim(true, true)
    elseif playerInfo.rankCardPlayAnimStatus == RoomEnum.RankCardPlayAnimStatus.PlayedPrepareAnim and not playerInfo.bIsReflection then
      self:GetViewComponent():PlayPrepareAnim(false, false)
    elseif playerInfo.bIsReflection then
      playerInfo.bIsReflection = false
      self:GetViewComponent():PlayPrepareAnim(true, true)
    end
  end
  local gameModeType = roomDataProxy:GetGameMode()
  if gameModeType == GameModeSelectNum.GameModeType.RankBomb or gameModeType == GameModeSelectNum.GameModeType.RankTeam then
    self:ShowRankDivision(true)
  end
end
function RankCardMediator:SetEmptyCardStyle()
  self:GetViewComponent():StopAllAnimations()
  if self:GetViewComponent().CanvasPanel_Total then
    self:GetViewComponent().CanvasPanel_Total:SetRenderScale(UE4.FVector2D(1, 1))
  end
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_Cancel, 0.3, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if self:GetViewComponent().CanvasPanel_Card and self:GetViewComponent().CanvasPanel_Empty then
    self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:OnSetPracticeInfoVisibility(false)
  end
  if self:GetViewComponent().CanvasPanel_LostConnection then
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().Effect_Card then
    self:GetViewComponent().Effect_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:GetViewComponent().memberInfo = nil
end
function RankCardMediator:SetNormalStateCardStyle()
  if self:GetViewComponent().Image_Ready then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().CanvasPanel_Card and self:GetViewComponent().CanvasPanel_Empty then
    self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().CanvasPanel_LostConnection then
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().Effect_Card then
    self:GetViewComponent().Effect_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function RankCardMediator:SetReadyStateCardStyle()
  if self:GetViewComponent().Image_Ready then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self:GetViewComponent().CanvasPanel_LostConnection then
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().CanvasPanel_Card and self:GetViewComponent().CanvasPanel_Empty then
    self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function RankCardMediator:SetLeaveStateCardStyleFromReady()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_Cancel, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:GetViewComponent():K2_PostAkEvent(self:GetViewComponent().bp_animCancelAudio)
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_Leave, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:ClearAllTimerHandle()
  self.SetLeaveStateCardStyleFromReadyTimerHandle = TimerMgr:AddTimeTask(0.2, 0, 1, function()
    self:GetViewComponent():StopAllAnimations()
    self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_Start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self:SetEmptyCardStyle()
  end)
end
function RankCardMediator:SetLeaveStateCardStyleFromNormal()
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Anim_Leave, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:ClearAllTimerHandle()
  self.SetLeaveStateCardStyleFromNormalTimerHandle = TimerMgr:AddTimeTask(0.3, 0, 1, function()
    self:SetEmptyCardStyle()
  end)
end
function RankCardMediator:ClearAllTimerHandle()
  if self.SetLeaveStateCardStyleFromNormalTimerHandle then
    self.SetLeaveStateCardStyleFromNormalTimerHandle:EndTask()
    self.SetLeaveStateCardStyleFromNormalTimerHandle = nil
  end
  if self.SetLeaveStateCardStyleFromReadyTimerHandle then
    self.SetLeaveStateCardStyleFromReadyTimerHandle:EndTask()
    self.SetLeaveStateCardStyleFromReadyTimerHandle = nil
  end
end
function RankCardMediator:SetSettleStateCardStyle()
  if self:GetViewComponent().Image_Ready then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().CanvasPanel_LostConnection then
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function RankCardMediator:SetOfflineStateCardStyle()
  if self:GetViewComponent().Image_Ready then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().CanvasPanel_LostConnection then
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.mediators[1].isSpeaking = false
  end
end
function RankCardMediator:SetPlayerHost(inIsHost)
  self.bIsHost = inIsHost
  if self:GetViewComponent().WS_Host then
    if self.bIsHost then
      self:GetViewComponent().WS_Host:SetActiveWidgetIndex(0)
    else
      self:GetViewComponent().WS_Host:SetActiveWidgetIndex(1)
    end
  end
end
function RankCardMediator:ShowRankDivision(shouldShow)
  if self:GetViewComponent().BP_CardPanel then
    self:GetViewComponent().BP_CardPanel:ShowRankDivision(shouldShow)
  end
end
function RankCardMediator:SetCardDetailInfo(playerInfo)
  if cardDataProxy then
    local avatarId = playerInfo.avatarId
    if 0 == playerInfo.avatarId then
      avatarId = cardDataProxy:GetDefaultAvatarId()
    end
    local frameId = playerInfo.frameId
    if 0 == playerInfo.frameId then
      frameId = cardDataProxy:GetDefaultFrameId()
    end
    self:GetViewComponent().prepareAnimId = frameId % 10
    local cardInfo = {}
    cardInfo.cardId = {}
    cardInfo.cardId[businessCardEnum.cardType.avatar] = avatarId
    cardInfo.cardId[businessCardEnum.cardType.frame] = frameId
    cardInfo.cardId[businessCardEnum.cardType.achieve] = playerInfo.achievementId
    cardInfo.playerAttr = {}
    cardInfo.playerAttr.nickName = playerInfo.nick
    cardInfo.playerAttr.sex = playerInfo.sex
    cardInfo.playerAttr.level = playerInfo.level
    cardInfo.stars = self:GetViewComponent().memberInfo.stars
    self:GetViewComponent().BP_CardPanel:InitView(cardInfo, playerInfo.playerId == roomDataProxy:GetPlayerID())
    local frameIdTableRow = cardDataProxy:GetCardResourceTableFromId(frameId)
    if frameIdTableRow then
      local cardOtherTextureInfo = {}
      cardOtherTextureInfo.backTexture = frameIdTableRow.IconIdcardFrameBack
      cardOtherTextureInfo.sideTexture = frameIdTableRow.IconIdcardFrameSide
      self:SetCardBackAndSideTexture(cardOtherTextureInfo)
    end
  end
  local bEnterPractice = self:GetViewComponent().memberInfo.bEnterPractice
  self:OnSetPracticeInfoVisibility(bEnterPractice)
  local bPlayerAlreadyPracticeRemind = roomDataProxy:PlayerIsAlreadyPracticeRemind(playerInfo.playerId)
  if self:GetViewComponent().Btn_PracticeRemind then
    self:GetViewComponent().Btn_PracticeRemind:SetIsEnabled(not bPlayerAlreadyPracticeRemind)
  end
end
function RankCardMediator:OnSetPracticeInfoVisibility(bEnterPractice)
  if bEnterPractice then
    self:GetViewComponent().CanvasPanel_PlayerEnterPractice:SetVisibility(UE4.ESlateVisibility.Visible)
    if self:GetViewComponent().Btn_PracticeRemind then
      self:GetViewComponent().Btn_PracticeRemind:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif not bEnterPractice then
    self:GetViewComponent().CanvasPanel_PlayerEnterPractice:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self:GetViewComponent().Btn_PracticeRemind then
      self:GetViewComponent().Btn_PracticeRemind:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function RankCardMediator:OnClickPracticeRemind()
  local selfPlayerID = self:GetViewComponent().memberInfo.playerId
  roomDataProxy:ReqPracticeRemind(selfPlayerID)
end
function RankCardMediator:SetCardBackAndSideTexture(textureInfo)
  if textureInfo.backTexture and self:GetViewComponent().Image_CardBack then
    self:GetViewComponent():SetImageByTexture2D(self:GetViewComponent().Image_CardBack, textureInfo.backTexture)
  end
  if textureInfo.sideTexture and self:GetViewComponent().Image_Side then
    self:GetViewComponent():SetImageByTexture2D(self:GetViewComponent().Image_Side, textureInfo.sideTexture)
  end
end
function RankCardMediator:OnTeamModeModify(newMode)
  self:SetCanvasInviteVisible()
end
function RankCardMediator:SetCanvasInviteVisible()
  local bShow = true
  local viewComponent = self:GetViewComponent()
  if roomDataProxy:GetCurrentModeIsTeam3v3v3Mode() and viewComponent.position and viewComponent.position > 3 then
    bShow = false
  end
  if viewComponent.Canvas_InviteFriend then
    local showType = UE4.ESlateVisibility.SelfHitTestInvisible
    if not bShow then
      showType = UE4.ESlateVisibility.Collapsed
    end
    viewComponent.Canvas_InviteFriend:SetVisibility(showType)
  end
end
return RankCardMediator
