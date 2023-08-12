local ShowLotteryResultCmd = class("ShowLotteryResultCmd", PureMVC.Command)
function ShowLotteryResultCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Lottery.ShowLotteryResultCmd then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.LotterySettingPage)
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ResultDisplayPage)
  end
end
return ShowLotteryResultCmd
