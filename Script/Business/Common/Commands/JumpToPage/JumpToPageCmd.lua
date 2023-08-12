local JumpToPageBody = {target = "", exData = ""}
local JumpToPageCmd = class("JumpToPageCmd", PureMVC.Command)
function JumpToPageCmd:Execute(notification)
  local body = notification:GetBody()
  local type = notification:GetType()
  if body then
    if body.target == UIPageNameDefine.FriendList then
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchRightSideWidget, body)
    elseif body.target == UIPageNameDefine.KaPhonePage then
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchRightSideWidget, body, type)
    elseif body.target == UIPageNameDefine.NavigationMenuPage then
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchRightSideWidget, body)
    elseif body.target == UIPageNameDefine.BattleRecordPage then
      local navBarbody = {}
      navBarbody.pageType = UE4.EPMFunctionTypes.Career
      navBarbody.secondIndex = 4
      navBarbody.exData = body.exData
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, navBarbody)
    elseif body.target == UIPageNameDefine.Achievement then
      local navBarbody = {}
      navBarbody.pageType = UE4.EPMFunctionTypes.Career
      navBarbody.secondIndex = 2
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, navBarbody)
    elseif body.target == UIPageNameDefine.GameModeSelectPage then
      local exclude = {
        UIPageNameDefine.PopUpPromptPage,
        UIPageNameDefine.ChatPage,
        UIPageNameDefine.CommonNotifyPage,
        UIPageNameDefine.NavigationPage,
        UIPageNameDefine.GameModeSelectPage,
        UIPageNameDefine.RoomPagePC,
        UIPageNameDefine.RankPCPage,
        UIPageNameDefine.MatchTimeCounterPage
      }
      ViewMgr:CloseAllPageExclude(LuaGetWorld(), exclude)
      local navBarbody = {}
      navBarbody.pageType = UE4.EPMFunctionTypes.Play
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, navBarbody)
    elseif body.target == UIPageNameDefine.HermesHotListPage then
      local exclude = {
        UIPageNameDefine.PopUpPromptPage,
        UIPageNameDefine.ChatPage,
        UIPageNameDefine.CommonNotifyPage,
        UIPageNameDefine.NavigationPage,
        UIPageNameDefine.MatchTimeCounterPage
      }
      ViewMgr:CloseAllPageExclude(LuaGetWorld(), exclude)
      local navBarbody = {}
      navBarbody.pageType = UE4.EPMFunctionTypes.Shop
      navBarbody.secondIndex = body.pageIndex or 2
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, navBarbody)
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
    end
  end
end
return JumpToPageCmd
