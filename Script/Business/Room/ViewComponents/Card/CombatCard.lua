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
  self.actionOnUnhoveredAdd = LuaEvent.new()
  self.actionOnPressedAdd = LuaEvent.new()
  self.actionOnReleasedAdd = LuaEvent.new()
  self.actionOnHoverSwitch = LuaEvent.new()
  self.actionOnUnhoverSwitch = LuaEvent.new()
  self.actionOnCreateAchievementTipMenu = LuaEvent.new()
  self.actionOnClickSwitch = LuaEvent.new()
  self.actionOnHoverImageAchievement = LuaEvent.new()
  self.actionOnUnhoverImageAchievement = LuaEvent.new()
  self.actionOnClickPracticeRemind = LuaEvent.new()
  self:OnInit()
end
function CombatCard:OnInit()
  self.ShowSwitchBtn.OnHovered:Add(self, self.OnHoveredAdd)
  self.ShowSwitchBtn.OnUnhovered:Add(self, self.OnUnhoveredAdd)
  self.Img_Background.OnMouseEnterEvent:Bind(self, self.OnHoveredAdd)
  self.Img_Background.OnMouseLeaveEvent:Bind(self, self.OnUnhoveredAdd)
  self.Button_Add.OnPressed:Add(self, self.OnPressedAdd)
  self.Button_Add.OnReleased:Add(self, self.OnReleasedAdd)
  self.Button_Switch.OnClicked:Add(self, self.OnSwitchClick)
  self.Button_Switch.OnHovered:Add(self, self.OnHoverSwitch)
  self.Button_Switch.OnUnhovered:Add(self, self.OnUnhoverSwitch)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnRightClick)
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
  self.ShowSwitchBtn.OnHovered:Remove(self, self.OnHoveredAdd)
  self.ShowSwitchBtn.OnUnhovered:Remove(self, self.OnUnhoveredAdd)
  self.Img_Background.OnMouseEnterEvent:Unbind()
  self.Img_Background.OnMouseLeaveEvent:Unbind()
  self.Button_Add.OnPressed:Remove(self, self.OnPressedAdd)
  self.Button_Add.OnReleased:Remove(self, self.OnReleasedAdd)
  self.Button_Switch.OnClicked:Remove(self, self.OnSwitchClick)
  self.Button_Switch.OnHovered:Remove(self, self.OnHoverSwitch)
  self.Button_Switch.OnUnhovered:Remove(self, self.OnUnhoverSwitch)
  self.MenuAnchor_Card.OnGetMenuContentEvent:Unbind()
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self.Btn_PracticeRemind.OnClicked:Remove(self, self.OnClickPracticeRemind)
end
function CombatCard:GetCurrentMediator()
  return self.mediators[1]
end
function CombatCard:OnHoveredAdd()
  local bInPractice = self.CanvasPanel_PlayerEnterPractice:GetVisibility() == UE4.ESlateVisibility.Visible
  if self.bShowSwitchButton == false and self.clientPlayerID ~= self.memberInfo.playerId and not bInPractice then
    self.Button_Switch:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function CombatCard:OnUnhoveredAdd()
  local bInPractice = self.CanvasPanel_PlayerEnterPractice:GetVisibility() == UE4.ESlateVisibility.Visible
  if self.bShowSwitchButton == false and not bInPractice then
    self.Button_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CombatCard:OnHoverSwitch()
  local bInPractice = self.CanvasPanel_PlayerEnterPractice:GetVisibility() == UE4.ESlateVisibility.Visible
  if not bInPractice then
    self.bShowSwitchButton = true
    self.Button_Switch:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function CombatCard:OnUnhoverSwitch()
  local bInPractice = self.CanvasPanel_PlayerEnterPractice:GetVisibility() == UE4.ESlateVisibility.Visible
  if not bInPractice then
    self.bShowSwitchButton = false
    self.Button_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CombatCard:OnClickPracticeRemind()
  self.actionOnClickPracticeRemind()
end
function CombatCard:OnClickedAdd()
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.FriendList
  })
end
function CombatCard:OnPressedAdd()
  self.actionOnPressedAdd()
end
function CombatCard:OnReleasedAdd()
  self.actionOnReleasedAdd()
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
function CombatCard:OnSwitchClick()
  if self.clientPlayerID == self.memberInfo.playerId then
    return
  end
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo and roomInfo.teamId and self.position then
    roomDataProxy:ReqRoomSwitch(roomInfo.teamId, self.position, 0, 0)
  end
end
function CombatCard:OnRightClick(inMyGeometry, inMouseEvent)
  local keyName = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(inMouseEvent).KeyName
  if "RightMouseButton" == keyName then
    if self.clientPlayerID == self.memberInfo.playerId or 0 == self.memberInfo.playerId then
      return UE4.UWidgetBlueprintLibrary.Unhandled()
    end
    self.MenuAnchor_Card:Open(true)
  elseif "LeftMouseButton" == keyName and self.memberInfo.playerId and 0 == self.memberInfo.playerId then
    self:OnClickedAdd()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
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
