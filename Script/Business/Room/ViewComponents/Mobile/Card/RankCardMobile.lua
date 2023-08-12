local RankCardMobileMediator = require("Business/Room/Mediators/Card/RankCardMediator")
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy
local RankCardMobile = class("RankCardMobile", PureMVC.ViewComponentPanel)
function RankCardMobile:OnInitialized()
  RankCardMobile.super.OnInitialized(self)
end
function RankCardMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RankCardMobile:ListNeededMediators()
  return {RankCardMobileMediator}
end
function RankCardMobile:InitializeLuaEvent()
  self.actionOnClickedAdd = LuaEvent.new()
  self.actionOnPressedAdd = LuaEvent.new()
  self.actionOnReleasedAdd = LuaEvent.new()
  self.actionSetPlayerStateBaseCard = LuaEvent.new()
  self.actionSetPlayerData = LuaEvent.new()
  self.actionSetPlayerHost = LuaEvent.new()
  self.actionOnMouseButtonDownEvent = LuaEvent.new()
  self.actionOnClickPracticeRemind = LuaEvent.new()
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.position = 0
  self.memberInfo = nil
end
function RankCardMobile:Construct()
  RankCardMobile.super.Construct(self)
  self.Button_Add.OnClicked:Add(self, self.OnClickedAdd)
  self.Btn_TouchInput.OnPressed:Add(self, self.OnPressedTouchInput)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
  self.Btn_PracticeRemind.OnClicked:Add(self, self.OnClickPracticeRemind)
end
function RankCardMobile:Destruct()
  RankCardMobile.super.Destruct(self)
  self.Button_Add.OnClicked:Remove(self, self.OnClickedAdd)
  self.Btn_TouchInput.OnPressed:Remove(self, self.OnPressedTouchInput)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Unbind()
  self.Btn_PracticeRemind.OnClicked:Remove(self, self.OnClickPracticeRemind)
  self:ClearTimeHandle()
end
function RankCardMobile:ClearTimeHandle()
  if self.timeHandlerCardPrepareOffset then
    self.timeHandlerCardPrepareOffset:EndTask()
    self.timeHandlerCardPrepareOffset = nil
  end
  if self.cardPrepareAnimationTimeHandle then
    self.cardPrepareAnimationTimeHandle:EndTask()
    self.cardPrepareAnimationTimeHandle = nil
  end
  if self.timeHandlerCardUnPrepareOffset then
    self.timeHandlerCardUnPrepareOffset:EndTask()
    self.timeHandlerCardUnPrepareOffset = nil
  end
end
function RankCardMobile:OnClickedAdd()
  self.actionOnClickedAdd()
end
function RankCardMobile:OnPressedTouchInput()
  if roomDataProxy and roomDataProxy:GetPlayerID() ~= self.memberInfo.playerId then
    self.MenuAnchor_Card:Open(true)
  end
end
function RankCardMobile:OnClickPracticeRemind()
  self.actionOnClickPracticeRemind()
end
function RankCardMobile:OnGetMenuContent()
  if self.MenuAnchor_Card then
    local contextMenu = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Card.MenuClass)
    if contextMenu then
      if roomDataProxy then
        local contextMenuInitData = {}
        contextMenuInitData.playerInfo = {}
        contextMenuInitData.playerInfo.playerId = self.memberInfo.playerId
        contextMenuInitData.playerInfo.nick = self.memberInfo.nick
        contextMenuInitData.playerInfo.position = self.position
        contextMenuInitData.playerInfo.stars = self.memberInfo.stars
        contextMenuInitData.cardType = CardEnum.GameModeType.Matching
        local teamInfo = roomDataProxy:GetTeamInfo()
        if teamInfo and teamInfo.teamId then
          contextMenuInitData.playerInfo.roomId = teamInfo.teamId
        end
        contextMenuInitData.playerInfo.contextMenuType = 0
        local rankContextType = CardEnum.RankContextType.None
        local playerId = roomDataProxy:GetPlayerID()
        if teamInfo and teamInfo.leaderId == playerId then
          if self.memberInfo.playerId == playerId then
            rankContextType = CardEnum.RankContextType.LeaderSelf
          else
            rankContextType = CardEnum.RankContextType.LeaderOther
            contextMenu:PlayAnimation(self.Main, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
          end
        elseif self.memberInfo.playerId == playerId then
          rankContextType = CardEnum.RankContextType.MemberSelf
        else
          rankContextType = CardEnum.RankContextType.MemberOther
          contextMenu:PlayAnimation(self.Other, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        end
        contextMenu:SetContextMenuType(rankContextType, contextMenuInitData)
      end
      return contextMenu
    end
    return nil
  end
end
function RankCardMobile:SetPlayerHost(inIsHost)
  self.actionSetPlayerHost(inIsHost)
end
function RankCardMobile:SetPlayerStateBaseCard(playerState)
  self.actionSetPlayerStateBaseCard(playerState)
end
function RankCardMobile:SetPlayerData(playerInfo, bIsSelf)
  self.actionSetPlayerData(playerInfo, bIsSelf)
end
function RankCardMobile:PlayPrepareAnim(bPlayAnimation, bFirst)
  self.WS_Host:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if bPlayAnimation then
    self:ClearTimeHandle()
    self:PlayAnimation(self.Anim_Start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self.Effect_Card:SetVisibility(UE4.ESlateVisibility.Visible)
    self.cardPrepareOffsetCount = 0
    self.timeHandlerCardPrepareOffset = TimerMgr:AddTimeTask(0.45, 0.01, 20, function()
      self.cardPrepareOffsetCount = self.cardPrepareOffsetCount + 0.005
      self.BP_CardPanel:SetBaseCardPrepareOffset(self.cardPrepareOffsetCount)
    end)
    if self.prepareAnimId and self["Anim_Line0" .. tostring(self.prepareAnimId)] then
      self:PlayAnimation(self["Anim_Line0" .. tostring(self.prepareAnimId)], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
      LogInfo("RankCardMobile PlayPrepareAnim", "prepareAnimId is invalid=" .. tostring(self.prepareAnimId))
    end
    self.WS_Host:SetRenderOpacity(1.0)
  elseif not bPlayAnimation and not bFirst then
    self.BP_CardPanel:SetBaseCardPrepareOffset(0.22)
    self.Effect_Card:SetVisibility(UE4.ESlateVisibility.Visible)
    self.WS_Host:SetRenderOpacity(1.0)
    self:PlayAnimation(self.Anim_Stop, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.prepareAnimId and self["Anim_Line0" .. tostring(self.prepareAnimId)] then
      self:PlayAnimation(self["Anim_Line0" .. tostring(self.prepareAnimId)], 1.2, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
      LogInfo("RankCardMobile PlayPrepareAnim", "prepareAnimId is invalid=" .. tostring(self.prepareAnimId))
    end
  end
end
function RankCardMobile:PlayUnPreparedAnim()
  self:ClearTimeHandle()
  self.cardPrepareOffsetCount = 0.1
  self.BP_CardPanel:SetBaseCardPrepareOffset(self.cardPrepareOffsetCount)
  self:StopAllAnimations()
  self:PlayAnimation(self.Anim_Stop, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.Effect_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayAnimation(self.Anim_Cancel, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:K2_PostAkEvent(self.bp_animCancelAudio)
  self.timeHandlerCardUnPrepareOffset = TimerMgr:AddTimeTask(0.01, 0.01, 20, function()
    self.cardPrepareOffsetCount = self.cardPrepareOffsetCount - 0.005
    self.BP_CardPanel:SetBaseCardPrepareOffset(self.cardPrepareOffsetCount)
  end)
  self.WS_Host:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankCardMobile:GetSlotPlayerId()
  if self.memberInfo and self.memberInfo.playerId then
    return self.memberInfo.playerId
  else
    return nil
  end
end
return RankCardMobile
