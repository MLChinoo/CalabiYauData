local RankPreparePage = class("RankPreparePage", PureMVC.ViewComponentPage)
local roomDataProxy
function RankPreparePage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RankPreparePage:ListNeededMediators()
  return {}
end
function RankPreparePage:InitializeLuaEvent()
  self.actionOnClickPrepare = LuaEvent.new()
end
function RankPreparePage:Construct()
  RankPreparePage.super.Construct(self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  local showUiInfo = {}
  showUiInfo.bShow = false
  showUiInfo.bDelay = false
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ShowGameModeSelectUI, showUiInfo)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  roomDataProxy:SetInMatchPrepareState(true)
end
function RankPreparePage:Destruct()
  RankPreparePage.super.Destruct(self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  local showUiInfo = {}
  showUiInfo.bShow = true
  showUiInfo.bDelay = true
  showUiInfo.delayTime = 1.5
  GameFacade:SendNotification(NotificationDefines.GameModeSelect.ShowGameModeSelectUI, showUiInfo)
  GameFacade:SendNotification(NotificationDefines.TeamRoom.ResetRoomPrepareAnimation)
  roomDataProxy:SetInMatchPrepareState(false)
end
function RankPreparePage:LuaHandleKeyEvent(key, inputEvent)
  if self.WS_PreparePanel and self.WS_PreparePanel:GetActiveWidget() then
    return self.WS_PreparePanel:GetActiveWidget():LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
return RankPreparePage
