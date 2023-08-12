local TeamCompetitionPage = class("TeamCompetitionPage", PureMVC.ViewComponentPage)
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function TeamCompetitionPage:ListNeededMediators()
  return {}
end
function TeamCompetitionPage:Construct()
  TeamCompetitionPage.super.Construct(self)
end
function TeamCompetitionPage:Destruct()
  TeamCompetitionPage.super.Destruct(self)
end
function TeamCompetitionPage:OnOpen(luaOpenData)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.NewGuidePage, nil, {
    GuideName = "TeamFightGuide"
  })
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.TeamCompetitionPage)
end
function TeamCompetitionPage:OnClickTeamCompetitionPage()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  roomDataProxy:ReqTeamCreate(GameModeSelectNum.GameModeType.Room, 111, 1)
  self.WS_BtnStartGame:SetActiveWidgetIndex(1)
  self.btnStartGameResetTimeHandle = TimerMgr:AddTimeTask(3, 0, 1, function()
    self.WS_BtnStartGame:SetActiveWidgetIndex(0)
  end)
end
return TeamCompetitionPage
