local CombatCardMediator = class("CombatCardMediator", PureMVC.Mediator)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy, cardDataProxy
function CombatCardMediator:ListNotificationInterests()
  return {
    NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged,
    NotificationDefines.Card.SetEnterPracticeStatus,
    NotificationDefines.Card.PracticeRemindClickStatus
  }
end
function CombatCardMediator:HandleNotification(notification)
  local body = notification:GetBody()
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged then
    if self.selfPlayerID == roomDataProxy:GetPlayerID() then
      local cardAvatarId = cardDataProxy:GetAvatarId()
      local cardFrameId = cardDataProxy:GetFrameId()
      self:UpdatePlayerAvatar(cardAvatarId, cardFrameId)
    end
  elseif notification:GetName() == NotificationDefines.Card.SetEnterPracticeStatus then
    if body and body.playerId and self:GetViewComponent().memberInfo and self:GetViewComponent().memberInfo.playerId and body.playerId == self:GetViewComponent().memberInfo.playerId then
      self:OnSetPracticeInfoVisibility(body.bEnter)
    end
  elseif notification:GetName() == NotificationDefines.Card.PracticeRemindClickStatus and body and body.playerId and self:GetViewComponent().memberInfo and self:GetViewComponent().memberInfo.playerId and body.playerId == self:GetViewComponent().memberInfo.playerId and self:GetViewComponent().Btn_PracticeRemind then
    self:GetViewComponent().Btn_PracticeRemind:SetIsEnabled(body.bClick)
  end
end
function CombatCardMediator:OnRegister()
  self:OnInit()
end
function CombatCardMediator:OnInit()
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  if self:GetViewComponent().actionOnClickPracticeRemind then
    self:GetViewComponent().actionOnClickPracticeRemind:Add(self.OnClickPracticeRemind, self)
  end
end
function CombatCardMediator:OnRemove()
  if self:GetViewComponent().actionOnClickPracticeRemind then
    self:GetViewComponent().actionOnClickPracticeRemind:Remove(self.OnClickPracticeRemind, self)
  end
end
function CombatCardMediator:UpdatePlayerAvatar(avatarId, frameId)
  GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self:GetViewComponent(), self:GetViewComponent().Img_HeadIcon, avatarId, self:GetViewComponent().Img_HeadIcon_Frame, frameId)
end
function CombatCardMediator:SetPlayerData(playerInfo, bIsSelf)
  self:GetViewComponent().memberInfo = playerInfo
  self.selfPlayerID = playerInfo.playerId
  self:SetCardSpeaker()
  self:SetCardUIInfo(playerInfo, bIsSelf)
  self:SetPlayerState(CardEnum.PlayerState.Normal)
end
function CombatCardMediator:SetCardSpeaker()
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.playerID = self.selfPlayerID
  end
  GameFacade:SendNotification(NotificationDefines.SmallSpeakerStateChanged, self.selfPlayerID)
end
function CombatCardMediator:ResetSmallSpeakerPlayerID()
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.playerID = -1
  end
end
function CombatCardMediator:SetCardUIInfo(playerInfo, bIsSelf)
  if self.selfPlayerID == self:GetViewComponent().clientPlayerID then
    self:GetViewComponent().Button_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self:GetViewComponent().VB_CardInfo then
    self:GetViewComponent().VB_CardInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local cardAvatarId = playerInfo.avatarId
  local cardFrameId = playerInfo.borderId
  if 0 == cardAvatarId then
    cardAvatarId = cardDataProxy:GetDefaultAvatarId()
  end
  if 0 == cardFrameId then
    cardFrameId = cardDataProxy:GetDefaultFrameId()
  end
  self:UpdatePlayerAvatar(cardAvatarId, cardFrameId)
  if playerInfo.nick then
    self:GetViewComponent().TextBlock_NickName:SetText(playerInfo.nick)
  end
  if playerInfo.level then
    self:GetViewComponent().TextBlock_Level:SetText(playerInfo.level)
  end
  if bIsSelf then
    self:GetViewComponent().TextBlock_NickName:SelectAlternativeColorAndOpacity("Self")
  else
    self:GetViewComponent().TextBlock_NickName:SelectAlternativeColorAndOpacity("Others")
    local bEnterPractice = self:GetViewComponent().memberInfo.bEnterPractice
    self:OnSetPracticeInfoVisibility(bEnterPractice)
  end
  local bPlayerAlreadyPracticeRemind = roomDataProxy:PlayerIsAlreadyPracticeRemind(playerInfo.playerId)
  if self:GetViewComponent().Btn_PracticeRemind then
    self:GetViewComponent().Btn_PracticeRemind:SetIsEnabled(not bPlayerAlreadyPracticeRemind)
  end
end
function CombatCardMediator:SetPlayerState(playerState)
  self:GetViewComponent().currentState = playerState
  if playerState == CardEnum.PlayerState.Normal then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_WaitingBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif playerState == CardEnum.PlayerState.Ready then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_WaitingBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif playerState == CardEnum.PlayerState.Leave then
    self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self:GetViewComponent().Img_Background then
      self:GetViewComponent().Img_Background:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self:GetViewComponent().memberInfo = cardDataProxy:GetDefaultMemberInfo()
    self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self:GetViewComponent().VB_CardInfo then
      self:GetViewComponent().VB_CardInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:GetViewComponent().CanvasPanel_PlayerEnterPractice:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_WaitingBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:OnSetPracticeInfoVisibility(false)
  elseif playerState == CardEnum.PlayerState.Settle then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_WaitingBack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif playerState == CardEnum.PlayerState.LostConnection then
    self:GetViewComponent().Image_Ready:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().CanvasPanel_WaitingBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
    if SmallSpeaker then
      SmallSpeaker.mediators[1].isSpeaking = false
    end
  end
end
function CombatCardMediator:SetPlayerHost(inIsHost)
  self.bIsHost = inIsHost
  if self.bIsHost then
    self:GetViewComponent().WS_Host:SetActiveWidgetIndex(0)
  else
    self:GetViewComponent().WS_Host:SetActiveWidgetIndex(1)
  end
end
function CombatCardMediator:GetPosition()
  local vc = self:GetViewComponent()
  if vc then
    return vc.position
  end
  return 0
end
function CombatCardMediator:OnClickPracticeRemind()
  local selfPlayerID = self:GetViewComponent().memberInfo.playerId
  roomDataProxy:ReqPracticeRemind(selfPlayerID)
end
function CombatCardMediator:OnSetPracticeInfoVisibility(bEnterPractice)
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  local viewComponent = self:GetViewComponent()
  if bEnterPractice then
    viewComponent.CanvasPanel_PlayerEnterPractice:SetVisibility(UE4.ESlateVisibility.Visible)
    if viewComponent.Btn_PracticeRemind then
      viewComponent.Btn_PracticeRemind:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if viewComponent.Button_Switch and platform == GlobalEnumDefine.EPlatformType.Mobile then
      viewComponent.Button_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if viewComponent.Btn_TouchInput and platform == GlobalEnumDefine.EPlatformType.Mobile then
      viewComponent.Btn_TouchInput:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif not bEnterPractice then
    viewComponent.CanvasPanel_PlayerEnterPractice:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if viewComponent.Btn_PracticeRemind then
      viewComponent.Btn_PracticeRemind:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if viewComponent.Button_Switch and platform == GlobalEnumDefine.EPlatformType.Mobile then
      viewComponent.Button_Switch:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if viewComponent.Btn_TouchInput and platform == GlobalEnumDefine.EPlatformType.Mobile then
      viewComponent.Btn_TouchInput:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end
return CombatCardMediator
