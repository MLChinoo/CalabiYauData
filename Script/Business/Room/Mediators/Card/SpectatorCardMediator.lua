local SpectatorCardMediator = class("SpectatorCardMediator", PureMVC.Mediator)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy
function SpectatorCardMediator:ListNotificationInterests()
  return {}
end
function SpectatorCardMediator:HandleNotification(notification)
end
function SpectatorCardMediator:OnRegister()
  self:OnInit()
end
function SpectatorCardMediator:OnInit()
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self:GetViewComponent().clientPlayerID = roomDataProxy:GetPlayerID()
end
function SpectatorCardMediator:OnRemove()
end
function SpectatorCardMediator:SetPlayerData(playerInfo, bIsSelf)
  self:GetViewComponent().memberInfo = playerInfo
  self.selfPlayerID = playerInfo.playerId
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.playerID = self.selfPlayerID
  end
  GameFacade:SendNotification(NotificationDefines.SmallSpeakerStateChanged, self.selfPlayerID)
  if playerInfo.playerId == self:GetViewComponent().clientPlayerID then
    self:GetViewComponent().Button_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().CanvasPanel_Card and self:GetViewComponent().CanvasPanel_Empty then
    self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().VB_CardInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:GetViewComponent().TextBlock_NickName:SetText(playerInfo.nick)
  self:GetViewComponent().TextBlock_Level:SetText(playerInfo.level)
  if bIsSelf then
    self:GetViewComponent().TextBlock_NickName:SelectAlternativeColorAndOpacity("Self")
  else
    self:GetViewComponent().TextBlock_NickName:SelectAlternativeColorAndOpacity("Others")
  end
  self:SetPlayerState(CardEnum.PlayerState.Normal)
end
function SpectatorCardMediator:ResetSmallSpeakerPlayerID()
  local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
  if SmallSpeaker then
    SmallSpeaker.playerID = -1
  end
end
function SpectatorCardMediator:SetPlayerState(playerState)
  self:GetViewComponent().currentState = playerState
  if playerState == CardEnum.PlayerState.Normal then
    if self:GetViewComponent().CanvasPanel_LostConnection then
      self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.PC then
      self:GetViewComponent().Button_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif playerState == CardEnum.PlayerState.Leave then
    if self:GetViewComponent().CanvasPanel_Card and self:GetViewComponent().CanvasPanel_Empty then
      self:GetViewComponent().CanvasPanel_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:GetViewComponent().VB_CardInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:GetViewComponent().CanvasPanel_Empty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self:GetViewComponent().CanvasPanel_LostConnection then
      self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
    self:GetViewComponent().memberInfo = cardDataProxy:GetDefaultMemberInfo()
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      self:GetViewComponent().Button_Switch:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif playerState == CardEnum.PlayerState.LostConnection then
    if self:GetViewComponent().CanvasPanel_LostConnection then
      self:GetViewComponent().CanvasPanel_LostConnection:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    local SmallSpeaker = self:GetViewComponent().SmallSpeakerContrlPanel
    if SmallSpeaker then
      SmallSpeaker.mediators[1].isSpeaking = false
    end
  end
end
function SpectatorCardMediator:SetPlayerHost(inIsHost)
  self.bIsHost = inIsHost
  if self.bIsHost then
    self:GetViewComponent().WS_Host:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:GetViewComponent().WS_Host:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpectatorCardMediator:GetPosition()
  local vc = self:GetViewComponent()
  if vc then
    return vc.position
  end
  return 0
end
return SpectatorCardMediator
