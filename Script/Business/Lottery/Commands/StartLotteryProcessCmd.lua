local StartLotteryProcessCmd = class("StartLotteryProcessCmd", PureMVC.Command)
function StartLotteryProcessCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Lottery.StartLotteryProcessCmd then
    local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
    local lotteryBallSet = lotteryProxy:GetLotteryBallSet()
    if table.count(lotteryBallSet) > 0 then
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.LotterySettingPage)
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.LotteryResultPage)
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.LotteryTransitionPage, false, lotteryBallSet)
    end
  end
end
return StartLotteryProcessCmd
