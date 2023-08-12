local BuffEnum = require("Business/Activities/Framework/Proxies/BuffEnum")
local BuffProxy = class("BuffProxy", PureMVC.Proxy)
function BuffProxy:OnRegister()
  BuffProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_BATTLE_REWARD_GET_DATA_RES, FuncSlot(self.OnResBattleRewardGetData, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_BUFF_LIST_NTF, FuncSlot(self.OnNtfBuffList, self))
end
function BuffProxy:OnRemove()
  BuffProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BATTLE_REWARD_GET_DATA_RES, FuncSlot(self.OnResBattleRewardGetData, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_BUFF_LIST_NTF, FuncSlot(self.OnNtfBuffList, self))
  end
end
function BuffProxy:ReqBattleRewardGetData(actId)
  SendRequest(Pb_ncmd_cs.NCmdId.NID_BATTLE_REWARD_GET_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.battle_reward_get_data_req, {activity_id = actId}))
end
function BuffProxy:OnResBattleRewardGetData(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.battle_reward_get_data_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  LogDebug("ActivitiesInfo", "//BuffProxy服务器返回资源加成数据")
  if netData.cfg_list then
    table.print(netData.cfg_list)
  end
  self.cfg_list = netData.cfg_list
  if #netData.cfg_list > 0 then
    GameFacade:SendNotification(NotificationDefines.Activities.BuffShowData, {
      data = {
        cfg_list = self.cfg_list,
        actInfo = self.curActivityInfo
      },
      sourceType = BuffEnum.Source.Activity
    })
  end
end
function BuffProxy:CheckReqBattleRewardGetData()
  local targetType = Pb_ncmd_cs.EActivityType.ActivityType_SETTLE_MULTI_REWARD
  local activitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  local ActivityInfo = activitiesProxy:GetActivityByActType(targetType)
  if nil == ActivityInfo then
    return
  end
  if ActivityInfo.status == GlobalEnumDefine.EActivityStatus.Closed then
    return
  end
  self.curActivityInfo = ActivityInfo
  if self:CheckActBuffIsExpired() then
    return
  end
  self:ReqBattleRewardGetData(ActivityInfo.activityId)
end
function BuffProxy:CheckShowBuff()
  local targetType = Pb_ncmd_cs.EActivityType.ActivityType_SETTLE_MULTI_REWARD
  local activitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  table.print(activitiesProxy.activitiesPreTable)
  if self.cfg_list then
    local ActivityInfo = activitiesProxy:GetActivityByActType(targetType)
    if nil ~= ActivityInfo and ActivityInfo.status ~= GlobalEnumDefine.EActivityStatus.Closed and not self:CheckActBuffIsExpired() then
      GameFacade:SendNotification(NotificationDefines.Activities.BuffShowData, {
        data = {
          cfg_list = self.cfg_list,
          actInfo = self.curActivityInfo
        },
        sourceType = BuffEnum.Source.Activity
      })
    end
  else
    self:CheckReqBattleRewardGetData()
  end
  if self.buff_list then
    GameFacade:SendNotification(NotificationDefines.Activities.BuffShowData, {
      data = self.buff_list,
      sourceType = BuffEnum.Source.System
    })
  end
  if self:CheckQQPrivilege() then
    LogDebug("BuffProxy", "QQ Privilege")
    GameFacade:SendNotification(NotificationDefines.Activities.BuffShowData, {
      data = true,
      sourceType = BuffEnum.Source.QQ
    })
  end
  GameFacade:SendNotification(NotificationDefines.OnNtfCafePrivilegeCfg)
end
function BuffProxy:CheckActBuffIsExpired()
  local actInfo = self.curActivityInfo
  if self.curActivityInfo == nil then
    return true
  end
  if self.curActivityInfo.status == GlobalEnumDefine.EActivityStatus.Closed then
    return true
  end
  local expire_time = actInfo.cfg.expire_time
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  local duration_time = expire_time - servertime
  if 0 == expire_time or duration_time > 0 then
    return false
  end
  return true
end
function BuffProxy:OnNtfBuffList(data)
  local netData = pb.decode(Pb_ncmd_cs_lobby.buff_list_ntf, data)
  table.print(netData)
  self.buff_list = netData.buff_list
  if netData.buff_list then
    GameFacade:SendNotification(NotificationDefines.Activities.BuffShowData, {
      data = self.buff_list,
      sourceType = BuffEnum.Source.System
    })
  end
end
local CheckIsLaunchedFromQQGCToday = function(lastLaunchedTime)
  local TodayLaunched = false
  if lastLaunchedTime and lastLaunchedTime > 0 then
    local curDate = os.date("*t")
    local lastDate = os.date("*t", lastLaunchedTime)
    if curDate.year == lastDate.year and curDate.month == lastDate.month and curDate.day == lastDate.day then
      TodayLaunched = true
    end
  end
  return TodayLaunched
end
function BuffProxy:CheckQQPrivilege()
  local PlayerDC = UE4.UPMPlayerDataCenter.Get(LuaGetWorld())
  local lastQQLoginTime = PlayerDC:GetLastQQLaunchTime()
  LogDebug("lastQQLoginTime", "%s", lastQQLoginTime)
  if CheckIsLaunchedFromQQGCToday(lastQQLoginTime) then
    return true
  else
    return false
  end
end
function BuffProxy:SecondToStrFormat(time)
  local day = math.floor(time / 86400)
  local hour = math.floor(time / 3600) - day * 24
  local minute = math.ceil((time - day * 24 - hour * 3600) / 60)
  if day > 0 then
    local showTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "DayWithHour")
    local stringMap = {
      [0] = tostring(day),
      [1] = tostring(hour)
    }
    local text = ObjectUtil:GetTextFromFormat(showTxt, stringMap)
    return text
  elseif hour > 0 then
    local showTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "HourWithMin")
    local stringMap = {
      [0] = tostring(hour),
      [1] = tostring(minute)
    }
    local text = ObjectUtil:GetTextFromFormat(showTxt, stringMap)
    return text
  else
    local showTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "OnlyMin")
    local stringMap = {
      [0] = tostring(minute)
    }
    local text = ObjectUtil:GetTextFromFormat(showTxt, stringMap)
    return text
  end
end
return BuffProxy
