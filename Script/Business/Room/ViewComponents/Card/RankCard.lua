local RankCardMediator = require("Business/Room/Mediators/Card/RankCardMediator")
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy
local RankCard = class("RankCard", PureMVC.ViewComponentPanel)
function RankCard:OnInitialized()
  RankCard.super.OnInitialized(self)
end
function RankCard:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RankCard:ListNeededMediators()
  return {RankCardMediator}
end
function RankCard:InitializeLuaEvent()
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
function RankCard:Construct()
  RankCard.super.Construct(self)
  self:UIOperateBind()
  self.bClickEmptyCard = false
end
function RankCard:Destruct()
  RankCard.super.Destruct(self)
  self:UIOperateUnBind()
  self:ClearTimeHandle()
end
function RankCard:UIOperateBind()
  self.Img_ClickBackground.OnMouseButtonDownEvent:Bind(self, self.OnRightClick)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
  self.Btn_PracticeRemind.OnClicked:Add(self, self.OnClickPracticeRemind)
  if self.Btn_InviteFriend then
    self.Btn_InviteFriend.OnClicked:Add(self, self.OnClickInviteFriend)
    self.Btn_InviteFriend.OnHovered:Add(self, self.OnHoveredInviteFriend)
    self.Btn_InviteFriend.OnUnhovered:Add(self, self.OnUnhoveredInviteFriend)
  end
  if self.Btn_ReqSwitchCardPos then
    self.Btn_ReqSwitchCardPos.OnClicked:Add(self, self.OnClickReqSwitchCardPos)
    self.Btn_ReqSwitchCardPos.OnHovered:Add(self, self.OnHoveredReqSwitchCardPos)
    self.Btn_ReqSwitchCardPos.OnUnhovered:Add(self, self.OnUnhoveredReqSwitchCardPos)
  end
end
function RankCard:UIOperateUnBind()
  self.Img_ClickBackground.OnMouseButtonDownEvent:Unbind()
  self.MenuAnchor_Card.OnGetMenuContentEvent:Unbind()
  self.Btn_PracticeRemind.OnClicked:Remove(self, self.OnClickPracticeRemind)
  if self.Btn_InviteFriend then
    self.Btn_InviteFriend.OnClicked:Remove(self, self.OnClickInviteFriend)
    self.Btn_InviteFriend.OnHovered:Remove(self, self.OnHoveredInviteFriend)
    self.Btn_InviteFriend.OnUnhovered:Remove(self, self.OnUnhoveredInviteFriend)
  end
  if self.Btn_ReqSwitchCardPos then
    self.Btn_ReqSwitchCardPos.OnClicked:Remove(self, self.OnClickReqSwitchCardPos)
    self.Btn_ReqSwitchCardPos.OnHovered:Remove(self, self.OnHoveredReqSwitchCardPos)
    self.Btn_ReqSwitchCardPos.OnUnhovered:Remove(self, self.OnUnhoveredReqSwitchCardPos)
  end
end
function RankCard:ClearTimeHandle()
  if self.FirstPrepareAnimFinishTimerHandle then
    self.FirstPrepareAnimFinishTimerHandle:EndTask()
    self.FirstPrepareAnimFinishTimerHandle = nil
  end
end
function RankCard:OnClickInviteFriend()
  if not self.bp_bIsReflection then
    self.actionOnClickedAdd()
  end
end
function RankCard:OnHoveredInviteFriend()
  self:PlayHoveredInviteFriend()
  if self.position then
    GameFacade:SendNotification(NotificationDefines.Card.PlayerHoverInviteFriendBtn, self.position)
  end
end
function RankCard:PlayHoveredInviteFriend()
  self:PlayAnimation(self.Anim_HoverInviteFriendBtn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RankCard:OnUnhoveredInviteFriend()
  self:PlayUnhoveredInviteFriend()
  if self.position then
    GameFacade:SendNotification(NotificationDefines.Card.PlayerUnHoverInviteFriendBtn, self.position)
  end
end
function RankCard:PlayUnhoveredInviteFriend()
  self:PlayAnimation(self.Anim_UnhoverInviteFriendBtn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RankCard:OnClickReqSwitchCardPos()
  if not self.bp_bIsReflection then
    local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
    if roomDataProxy then
      local teamInfo = roomDataProxy:GetTeamInfo()
      local position = self.position
      if teamInfo and teamInfo.teamId and position then
        roomDataProxy:ReqRoomSwitch(teamInfo.teamId, position, 0, 0)
      end
    end
  end
end
function RankCard:OnHoveredReqSwitchCardPos()
end
function RankCard:OnUnhoveredReqSwitchCardPos()
end
function RankCard:OnRightClick(inGeometry, inMouseEvent)
  if UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(inMouseEvent).KeyName == "RightMouseButton" and roomDataProxy and self.memberInfo and self.memberInfo.playerId and roomDataProxy:GetPlayerID() ~= self.memberInfo.playerId then
    self.bClickEmptyCard = false
    self.MenuAnchor_Card:Open(true)
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end
function RankCard:OnGetMenuContent()
  if self.MenuAnchor_Card then
    local contextMenu = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Card.MenuClass)
    if contextMenu and roomDataProxy then
      local contextMenuInitData = {}
      if not self.bClickEmptyCard then
        contextMenuInitData.playerInfo = {}
        contextMenuInitData.playerInfo.playerId = self.memberInfo.playerId
        contextMenuInitData.playerInfo.nick = self.memberInfo.nick
        contextMenuInitData.playerInfo.position = self.position
        local teamInfo = roomDataProxy:GetTeamInfo()
        if teamInfo then
          if teamInfo.teamId then
            contextMenuInitData.playerInfo.roomId = teamInfo.teamId
          end
          contextMenuInitData.playerInfo.contextMenuType = 0
          local rankContextType = CardEnum.RankContextType.None
          local playerId = roomDataProxy:GetPlayerID()
          if teamInfo.leaderId and teamInfo.leaderId == playerId then
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
      else
        local rankContextType = CardEnum.RankContextType.None
        contextMenuInitData.playerInfo = {}
        contextMenuInitData.playerInfo.position = self.position
        local teamInfo = roomDataProxy:GetTeamInfo()
        if teamInfo and teamInfo.teamId then
          contextMenuInitData.playerInfo.roomId = teamInfo.teamId
        end
        contextMenu:SetContextMenuType(rankContextType, contextMenuInitData)
      end
      return contextMenu
    end
    return nil
  end
end
function RankCard:OnClickPracticeRemind()
  self.actionOnClickPracticeRemind()
end
function RankCard:SetPlayerHost(inIsHost)
  self.actionSetPlayerHost(inIsHost)
end
function RankCard:SetPlayerStateBaseCard(playerState)
  self.actionSetPlayerStateBaseCard(playerState)
end
function RankCard:SetPlayerData(playerInfo, bIsSelf)
  self.actionSetPlayerData(playerInfo, bIsSelf)
end
function RankCard:PlayPrepareAnim(bPlayAnimation, bFirst)
  self.WS_Host:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Image_Host:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Image_Ready:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if bPlayAnimation then
    self:ClearTimeHandle()
    self:PlayAnimation(self.Anim_Start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self:StopAllAnimations()
    self.Effect_Card:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    if bFirst then
      if not roomDataProxy:IsRoomMaster() and self.memberInfo.playerId == roomDataProxy:GetPlayerID() then
        GameFacade:SendNotification(NotificationDefines.Card.CardPrepareAnimationFinished, false)
        self.FirstPrepareAnimFinishTimerHandle = TimerMgr:AddTimeTask(2.5, 0, 1, function()
          GameFacade:SendNotification(NotificationDefines.Card.CardPrepareAnimationFinished, true)
          self:ClearTimeHandle()
        end)
      end
      if self.prepareAnimId and self["Anim_Line0" .. tostring(self.prepareAnimId)] then
        self:PlayAnimation(self["Anim_Line0" .. tostring(self.prepareAnimId)], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
      else
        LogInfo("RankCard PlayPrepareAnim", "prepareAnimId is invalid=" .. tostring(self.prepareAnimId))
      end
    elseif self.prepareAnimId and self["Anim_Line0" .. tostring(self.prepareAnimId)] then
      self:PlayAnimation(self["Anim_Line0" .. tostring(self.prepareAnimId)], 0.5, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
      LogInfo("RankCard PlayPrepareAnim", "prepareAnimId is invalid=" .. tostring(self.prepareAnimId))
    end
    self.WS_Host:SetRenderOpacity(1.0)
  elseif not bPlayAnimation and not bFirst then
    self:StopAllAnimations()
    if self.prepareAnimId > 0 then
      local AnimLoop = self.Anim_Line01_Loop
      if 6 == self.prepareAnimId then
        AnimLoop = self.Anim_Line06_Loop
      end
      if AnimLoop then
        self:PlayAnimation(AnimLoop, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
      else
        LogInfo("RankCard PlayPrepareAnim", "AnimLoop is invalid")
      end
    else
      LogInfo("RankCard PlayPrepareAnim", "prepareAnimId is invalid")
    end
  end
end
function RankCard:PlayUnPreparedAnim()
  self:ClearTimeHandle()
  if self.prepareAnimId and self["Anim_Line0" .. tostring(self.prepareAnimId)] then
    self:PlayAnimation(self["Anim_Line0" .. tostring(self.prepareAnimId)], 4.0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
  else
    LogInfo("RankCard PlayPrepareAnim", "prepareAnimId is invalid=" .. tostring(self.prepareAnimId))
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.Anim_Cancel, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:K2_PostAkEvent(self.bp_animCancelAudio)
  self.WS_Host:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Effect_Card:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BP_CardPanel:SetColorAndOpacity(self.bp_cardVisibleColor)
end
function RankCard:GetSlotPlayerId()
  if self.memberInfo and self.memberInfo.playerId then
    return self.memberInfo.playerId
  else
    return nil
  end
end
return RankCard
