local GameSpectatorBtnPanelMediator = require("Business/InGame/Spectator/Mobile/Mediator/GameSpectatorBtnPanelMediator")
local GameSpectatorBtnPanel = class("GameSpectatorBtnPanel", PureMVC.ViewComponentPage)
function GameSpectatorBtnPanel:ListNeededMediators()
  return {GameSpectatorBtnPanelMediator}
end
function GameSpectatorBtnPanel:InitializeLuaEvent()
end
function GameSpectatorBtnPanel:OnShow(luaData, originOpenData)
  self:OnRefreshView()
end
function GameSpectatorBtnPanel:Construct()
  GameSpectatorBtnPanel.super.Construct(self)
  self.Button_Report.OnClicked:Add(self, self.OnClickedReportBtn)
  self.Button_AddFriend.OnClicked:Add(self, self.OnClickedAddFriend)
end
function GameSpectatorBtnPanel:Destruct()
  self.Button_Report.OnClicked:Remove(self, GameSpectatorBtnPanel.OnClickedReportBtn)
  self.Button_AddFriend.OnClicked:Remove(self, GameSpectatorBtnPanel.OnClickedAddFriend)
  GameSpectatorBtnPanel.super.Destruct(self)
end
function GameSpectatorBtnPanel:OnRefreshView()
  self:RefreshFriendBtn()
  self:RefreshTipoffBtn()
  self:RefreshViewPlayerName()
end
function GameSpectatorBtnPanel:OnClickedReportBtn()
  local PlayerState = self:TryGetViewPlayerState()
  if nil == PlayerState then
    return
  end
  local PMPlayerState = PlayerState:Cast(UE4.APMPlayerState)
  if nil == PMPlayerState then
    return
  end
  if PMPlayerState.bIsABot then
    return
  end
  local TipoffPageParam = {
    TargetUID = PMPlayerState.UID,
    EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_INGAME,
    SceneType = UE4.ECyTipoffSceneType.IN_GAME
  }
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.OpenTipOffPlayerCmd, TipoffPageParam)
end
function GameSpectatorBtnPanel:OnClickedAddFriend()
  local PlayerState = self:TryGetViewPlayerState()
  if nil == PlayerState then
    return
  end
  local PMPlayerState = PlayerState:Cast(UE4.APMPlayerState)
  if nil == PMPlayerState then
    return
  end
  local ViewPlayerUID = self:GetViewPlayerUID()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and ViewPlayerUID > 0 and friendDataProxy:IsFriend(ViewPlayerUID) then
    return
  end
  local addFriendData = {}
  addFriendData.playerId = PMPlayerState.UID
  addFriendData.nick = PMPlayerState:GetPlayerName()
  GameFacade:SendNotification(NotificationDefines.AddFriendCmd, addFriendData)
  self:OnRefreshView()
end
function GameSpectatorBtnPanel:GetViewPlayerUID()
  local PlayerState = self:TryGetViewPlayerState()
  if nil == PlayerState then
    return -1
  end
  local PMPlayerState = PlayerState:Cast(UE4.APMPlayerState)
  if nil == PMPlayerState then
    return -1
  end
  return PMPlayerState.UID
end
function GameSpectatorBtnPanel:GetViewPlayerState()
  local PlayerState = self:TryGetViewPlayerState()
  if nil == PlayerState then
    return nil
  end
  local PMPlayerState = PlayerState:Cast(UE4.APMPlayerState)
  if nil == PMPlayerState then
    return nil
  end
  return PMPlayerState
end
function GameSpectatorBtnPanel:RefreshTipoffBtn()
  local SelectIndex = 1
  local PlayerState = self:GetViewPlayerState()
  if PlayerState then
    local tipoffData = {
      UID = PlayerState.UID,
      EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_INGAME
    }
    if PlayerState.bIsABot then
      SelectIndex = 2
    end
    local tipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.InGameTipoffPlayerDataProxy)
    if tipoffPlayerDataProxy then
      local bMaxTipoff = tipoffPlayerDataProxy:CheckPlayerTipoffMax(tipoffData.UID, tipoffData.EnteranceType)
      if bMaxTipoff then
        SelectIndex = 2
      end
    end
  end
  if SelectIndex <= self.Style_Report:Num() then
    self.Button_Report:SetStyle(self.Style_Report:Get(SelectIndex))
  end
end
function GameSpectatorBtnPanel:RefreshFriendBtn()
  local SelectIndex = 1
  local ViewPlayerUID = self:GetViewPlayerUID()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and ViewPlayerUID > 0 then
    if friendDataProxy:IsFriend(ViewPlayerUID) then
      SelectIndex = 2
    end
    if friendDataProxy:HasFriendReq(ViewPlayerUID) then
      SelectIndex = 3
    end
  end
  if SelectIndex <= self.Style_Friend:Num() then
    self.Button_AddFriend:SetStyle(self.Style_Friend:Get(SelectIndex))
  end
end
function GameSpectatorBtnPanel:RefreshViewPlayerName()
  local ViewPlayerState = self:GetViewPlayerState()
  if not ViewPlayerState then
    return
  end
  local HeaderStr = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "ObSpectator_ViewPlayer")
  if self.ViewPlayerName then
    if HeaderStr then
      self.ViewPlayerName:SetText(HeaderStr .. ViewPlayerState:GetPlayerName())
    else
      self.ViewPlayerName:SetText(ViewPlayerState:GetPlayerName())
    end
  end
end
function GameSpectatorBtnPanel:K2_OnViewTargetChanged(InViewTarget)
  self:OnRefreshView()
end
return GameSpectatorBtnPanel
