local CombatCardMediator = require("Business/Room/Mediators/Card/CombatCardMediator")
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local CombatCard = class("CombatCard", PureMVC.ViewComponentPanel)
local roomDataProxy
function CombatCard:OnInitialized()
  CombatCard.super.OnInitialized(self)
end
function CombatCard:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function CombatCard:ListNeededMediators()
  return {CombatCardMediator}
end
function CombatCard:InitializeLuaEvent()
  self.actionOnHoverShowSwitch = LuaEvent.new()
  self.actionOnUnhoverShowSwitch = LuaEvent.new()
  self.actionOnHoveredAdd = LuaEvent.new()
  self.actionOnUnhoveredAdd = LuaEvent.new()
  self.actionOnCreateAchievementTipMenu = LuaEvent.new()
  self.actionOnClickSwitch = LuaEvent.new()
  self.actionOnHoverImageAchievement = LuaEvent.new()
  self.actionOnUnhoverImageAchievement = LuaEvent.new()
  self.actionOnClickPracticeRemind = LuaEvent.new()
  self:OnInit()
end
function CombatCard:OnInit()
  self.Button_Switch.OnClicked:Add(self, self.OnSwitchClick)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
  self.Btn_TouchInput.OnPressed:Add(self, self.OnPressedTouchInput)
  self.Btn_InvitePlayer.OnClicked:Add(self, self.OnClickedAdd)
  self.Btn_PracticeRemind.OnClicked:Add(self, self.OnClickPracticeRemind)
end
function CombatCard:Construct()
  CombatCard.super.Construct(self)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  self.contextMenu = nil
  self.selfPlayerID = roomDataProxy:GetPlayerID()
  self.clientPlayerID = roomDataProxy:GetPlayerID()
  self.memberInfo = cardDataProxy:GetDefaultMemberInfo()
  self.bShowSwitchButton = false
  self.position = 0
  self.currentState = CardEnum.PlayerState.None
end
function CombatCard:Destruct()
  CombatCard.super.Destruct(self)
  self.Button_Switch.OnClicked:Remove(self, self.OnSwitchClick)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Unbind()
  self.Btn_TouchInput.OnPressed:Remove(self, self.OnPressedTouchInput)
  self.Btn_InvitePlayer.OnClicked:Remove(self, self.OnClickedAdd)
  self.Btn_PracticeRemind.OnClicked:Remove(self, self.OnClickPracticeRemind)
end
function CombatCard:OnClickPracticeRemind()
  self.actionOnClickPracticeRemind()
end
function CombatCard:OnPressedTouchInput()
  if roomDataProxy and roomDataProxy:GetPlayerID() ~= self.memberInfo.playerId then
    self.MenuAnchor_Card:Open(true)
  end
end
function CombatCard:GetCurrentMediator()
  return self.mediators[1]
end
function CombatCard:OnClickedAdd()
  if self.memberInfo.playerId and 0 == self.memberInfo.playerId and roomDataProxy then
    roomDataProxy.roomInvitePos = self.position
    ViewMgr:OpenPage(self, "FriendSidePullPage")
  end
end
function CombatCard:OnSwitchClick()
  if self.clientPlayerID == self.memberInfo.playerId then
    return
  end
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomInfo = roomProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId then
    roomProxy:ReqRoomSwitch(roomInfo.teamId, self.position, 0, 0)
  end
end
function CombatCard:OnGetMenuContent()
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
        contextMenuInitData.playerInfo.stars = self.memberInfo.stars
        contextMenuInitData.playerInfo.contextMenuType = 1
        local roomInfo = roomDataProxy:GetTeamInfo()
        if roomInfo and roomInfo.teamId then
          contextMenuInitData.playerInfo.roomId = roomInfo.teamId
        end
        local rankContextType = CardEnum.RankContextType.None
        if roomInfo and roomInfo.leaderId and roomInfo.leaderId == playerId then
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
          rankContextType = CardEnum.RankContextType.MemberRobot
          contextMenu:PlayAnimation(self.Other, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        end
        contextMenu:SetContextMenuType(rankContextType, contextMenuInitData)
      end
      return contextMenu
    end
  end
end
function CombatCard:OnCreateAchievementTipMenu()
  self.actionOnCreateAchievementTipMenu()
end
function CombatCard:OnHoverImageAchievement()
  self.actionOnHoverImageAchievement()
end
function CombatCard:OnUnhoverImageAchievement()
  self.actionOnUnhoverImageAchievement()
end
return CombatCard
