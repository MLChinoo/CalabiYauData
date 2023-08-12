local MatchPreparePageMobile = class("MatchPreparePageMobile", PureMVC.ViewComponentPage)
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local RankPreparePanelEnum = {Number10Panel = 0, Number9Panel = 1}
function MatchPreparePageMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function MatchPreparePageMobile:ListNeededMediators()
  return {}
end
function MatchPreparePageMobile:InitializeLuaEvent()
  self.actionOnClickPrepare = LuaEvent.new()
end
function MatchPreparePageMobile:Construct()
  MatchPreparePageMobile.super.Construct(self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
  local showUiInfo = {}
  showUiInfo.bShow = false
  showUiInfo.bDelay = false
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ShowGameModeSelectUI, showUiInfo)
  self:InitNumberPanel()
end
function MatchPreparePageMobile:Destruct()
  MatchPreparePageMobile.super.Destruct(self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
  local showUiInfo = {}
  showUiInfo.bShow = true
  showUiInfo.bDelay = true
  showUiInfo.delayTime = 1.5
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ShowGameModeSelectUI, showUiInfo)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.ResetRoomPrepareAnimation)
end
function MatchPreparePageMobile:InitNumberPanel()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local gameMode = roomDataProxy:GetGameMode()
  if gameMode and gameMode ~= GameModeSelectNum.GameModeType.None then
    if gameMode == GameModeSelectNum.GameModeType.Boomb or gameMode == GameModeSelectNum.GameModeType.RankBomb or gameMode == GameModeSelectNum.GameModeType.RankTeam or gameMode == GameModeSelectNum.GameModeType.Team or gameMode == GameModeSelectNum.GameModeType.CrystalScramble then
      self.WS_PreparePanel:SetActiveWidgetIndex(RankPreparePanelEnum.Number10Panel)
    elseif gameMode == GameModeSelectNum.GameModeType.Team3V3V3 then
      self.WS_PreparePanel:SetActiveWidgetIndex(RankPreparePanelEnum.Number9Panel)
    end
  end
end
function MatchPreparePageMobile:LuaHandleKeyEvent(key, inputEvent)
  return self.WS_PreparePanel:GetActiveWidget():LuaHandleKeyEvent(key, inputEvent)
end
return MatchPreparePageMobile
