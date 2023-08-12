local ActivitiesRechargeBateUpdateDataCmd = class("ActivitiesRechargeBateUpdateDataCmd", PureMVC.Command)
function ActivitiesRechargeBateUpdateDataCmd:Execute(notification)
  local Body = notification:GetBody()
  local ActivityIndex = 10011
  local ActivityProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  local ActivityTable = ActivityProxy:GetActivityPreTable()
  local StartTimespan = ActivityTable[ActivityIndex].cfg.start_time
  local EndTimespan = ActivityTable[ActivityIndex].cfg.expire_time > os.time() and ActivityTable[ActivityIndex].cfg.expire_time or os.time()
  local TempLeftTime = FunctionUtil:FormatTime(EndTimespan - os.time()).PMGameUtil_Format_DaysHours
  local TempStartTime = os.date("*t", StartTimespan)
  local TempEndTime = os.date("*t", EndTimespan)
  local strY = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Year")
  local strM = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Month")
  local strD = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Day")
  GameFacade:SendNotification(NotificationDefines.ActivitiesRechargeBateUpdatePage, {
    ChargeNum = Body.recharge_amount,
    RebateNum = Body.rebate_amount,
    bHasTaken = Body.has_take,
    LeftTimeText = TempLeftTime,
    OpenTimeText = TempStartTime.month .. strM .. TempStartTime.day .. strD .. "-" .. TempEndTime.month .. strM .. TempEndTime.day .. strD
  })
end
return ActivitiesRechargeBateUpdateDataCmd
