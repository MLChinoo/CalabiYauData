local SpectatorCardMediator = require("Business/Room/Mediators/Card/SpectatorCardMediator")
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local SpectatorCard = class("SpectatorCard", PureMVC.ViewComponentPanel)
local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
function SpectatorCard:OnInitialized()
  SpectatorCard.super.OnInitialized(self)
end
function SpectatorCard:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function SpectatorCard:ListNeededMediators()
  return {SpectatorCardMediator}
end
function SpectatorCard:InitializeLuaEvent()
  self.actionOnCreateAchievementTipMenu = LuaEvent.new()
  self.actionOnClickSwitch = LuaEvent.new()
  self.actionOnHoverImageAchievement = LuaEvent.new()
  self.actionOnUnhoverImageAchievement = LuaEvent.new()
  self:OnInit()
end
function SpectatorCard:OnInit()
  self.Button_Switch.OnClicked:Add(self, self.OnSwitchClick)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnRightClick)
end
function SpectatorCard:Construct()
  SpectatorCard.super.Construct(self)
  local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  self.contextMenu = nil
  self.clientPlayerID = roomDataProxy:GetPlayerID()
  self.memberInfo = cardDataProxy:GetDefaultMemberInfo()
  self.position = 0
  self.currentState = CardEnum.PlayerState.None
end
function SpectatorCard:Destruct()
  SpectatorCard.super.Destruct(self)
  self.Button_Switch.OnClicked:Remove(self, self.OnSwitchClick)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Unbind()
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
end
function SpectatorCard:GetCurrentMediator()
  return self.mediators[1]
end
function SpectatorCard:OnGetMenuContent()
  if self.MenuAnchor_Card then
    local contextMenu = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Card.MenuClass)
    if contextMenu then
      if roomDataProxy and self.memberInfo then
        local playerId = roomDataProxy:GetPlayerID()
        local contextMenuInitData = {}
        contextMenuInitData.playerInfo = {}
        contextMenuInitData.playerInfo.playerId = self.memberInfo.playerId
        contextMenuInitData.playerInfo.nick = self.memberInfo.nick
        contextMenuInitData.playerInfo.position = self.position
        contextMenuInitData.playerInfo.bIsRobot = self.memberInfo.bIsRobot
        local roomInfo = roomDataProxy:GetTeamInfo()
        if roomInfo and roomInfo.teamId then
          contextMenuInitData.playerInfo.roomId = roomInfo.teamId
        end
        contextMenuInitData.playerInfo.contextMenuType = 1
        local rankContextType = CardEnum.RankContextType.None
        if self.currentState == CardEnum.PlayerState.Leave then
          contextMenu:SetContextMenuType(rankContextType, contextMenuInitData)
        else
          if roomInfo and roomInfo.leaderId == playerId then
            if self.memberInfo.playerId == playerId then
              rankContextType = CardEnum.RankContextType.LeaderSelf
            elseif not self.memberInfo.bIsRobot then
              rankContextType = CardEnum.RankContextType.LeaderOther
              contextMenu:PlayAnimation(self.Main, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
            else
              rankContextType = CardEnum.RankContextType.LeaderRobot
              contextMenu:PlayAnimation(self.Main, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
            end
          elseif self.memberInfo.playerId == playerId then
            rankContextType = CardEnum.RankContextType.MemberSelf
          elseif not self.memberInfo.bIsRobot then
            rankContextType = CardEnum.RankContextType.MemberOther
            contextMenu:PlayAnimation(self.Other, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
          else
            if roomDataProxy:IsRoomMaster() then
              rankContextType = CardEnum.RankContextType.LeaderRobot
            else
              rankContextType = CardEnum.RankContextType.MemberRobot
            end
            contextMenu:PlayAnimation(self.Other, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
          end
          contextMenu:SetContextMenuType(rankContextType, contextMenuInitData)
        end
      end
      return contextMenu
    end
  end
end
function SpectatorCard:OnSwitchClick()
  if self.clientPlayerID == self.memberInfo.playerId then
    return
  end
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomDataProxy:ReqRoomSwitch(roomInfo.teamId, self.position, 0, 0)
  end
end
function SpectatorCard:OnRightClick(inMyGeometry, inMouseEvent)
  local keyName = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(inMouseEvent).KeyName
  if "RightMouseButton" == keyName then
    if self.clientPlayerID == self.memberInfo.playerId or 0 == self.memberInfo.playerId then
      return UE4.UWidgetBlueprintLibrary.Unhandled()
    end
    self.MenuAnchor_Card:Open(true)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SpectatorCard:OnCreateAchievementTipMenu()
  self.actionOnCreateAchievementTipMenu()
end
function SpectatorCard:OnHoverImageAchievement()
  self.actionOnHoverImageAchievement()
end
function SpectatorCard:OnUnhoverImageAchievement()
  self.actionOnUnhoverImageAchievement()
end
return SpectatorCard
