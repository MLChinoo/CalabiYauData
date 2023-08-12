local ActivitiesProxy = class("ActivitiesProxy", PureMVC.Proxy)
function ActivitiesProxy:ctor(proxyName, data)
  ActivitiesProxy.super.ctor(self, proxyName, data)
  self:CleanData()
end
function ActivitiesProxy:CleanData()
  self.activitiesPreTable = {}
  self.autoShowPageTable = {}
  self.ActivityRedList = {}
end
function ActivitiesProxy:OnRegister()
  ActivitiesProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ACTIVITY_PREVIEW_LIST_RES, FuncSlot(self.OnResActivitiesPreList, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_ACTIVITY_PREVIEW_LIST_NTF, FuncSlot(self.OnNtfActivitiesPreList, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_ACTICITY_UPDATE_ACTIVITY_NTF, FuncSlot(self.OnNtfActivityUpdate, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_ACTICITY_STATUE_CHANGE_NTF, FuncSlot(self.OnNtfActivityStatusChange, self))
  self.ActivityRedList = {}
end
function ActivitiesProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACTIVITY_PREVIEW_LIST_RES, FuncSlot(self.OnResActivitiesPreList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACTIVITY_PREVIEW_LIST_NTF, FuncSlot(self.OnNtfActivitiesPreList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACTICITY_UPDATE_ACTIVITY_NTF, FuncSlot(self.OnNtfActivityUpdate, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ACTICITY_STATUE_CHANGE_NTF, FuncSlot(self.OnNtfActivityStatusChange, self))
  self:CleanData()
end
function ActivitiesProxy:ReqActivitiesPreList()
  if table.count(self.activitiesPreTable) <= 0 then
    LogDebug("ActivitiesInfo", "//ActivitiesProxy客户端请求网络拉《所有预览活动》数据")
    SendRequest(Pb_ncmd_cs.NCmdId.NID_ACTIVITY_PREVIEW_LIST_REQ, pb.encode(Pb_ncmd_cs_lobby.activity_preview_list_req, {}))
  else
    LogDebug("ActivitiesInfo", "//ActivitiesProxy客户端本地有《所有预览活动》数据")
    GameFacade:SendNotification(NotificationDefines.Activities.PreviewUpdate)
  end
end
function ActivitiesProxy:OnResActivitiesPreList(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.activity_preview_list_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    return
  end
  LogDebug("ActivitiesInfo", "//ActivitiesProxy服务器返回《所有预览活动》数据")
  if netData.data_list then
    self:ProcessActivities(netData.data_list)
  end
end
function ActivitiesProxy:OnNtfActivitiesPreList(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.activity_preview_list_ntf, data)
  LogDebug("ActivitiesInfo", "//ActivitiesProxy服务器推送《所有预览活动》数据")
  if netData.data_list then
    self:ProcessActivities(netData.data_list)
  end
end
function ActivitiesProxy:ProcessActivities(data)
  if data then
    self.activitiesPreTable = {}
    self.autoShowPageTable = {}
    for key, value in pairs(data) do
      if value.id then
        local activeInfo = {}
        activeInfo.activityId = value.id
        activeInfo.cfg = value.cfg
        activeInfo.status = value.status
        if value.reddot then
          activeInfo.reddot = 1
        else
          activeInfo.reddot = 0
        end
        self.activitiesPreTable[value.id] = activeInfo
        self:SetRedNumByActivityID(activeInfo.activityId, activeInfo.reddot)
        if activeInfo.status < GlobalEnumDefine.EActivityStatus.Closed and activeInfo.reddot > 0 and activeInfo.cfg.auto_sort > 0 then
          table.insert(self.autoShowPageTable, activeInfo)
        end
      else
        LogError("ActivitiesProxy:OnResActivityPreList", "//ActivitiesProxy服务器下发的活动id为空，activity_preview_list_res.id = nil")
      end
    end
    if #self.autoShowPageTable > 0 then
      table.sort(self.autoShowPageTable, function(a, b)
        return a.cfg.auto_sort < a.cfg.auto_sort
      end)
    end
    GameFacade:SendNotification(NotificationDefines.Activities.PreviewUpdate)
    GameFacade:SendNotification(NotificationDefines.Activities.EntryListUpdate)
  end
end
function ActivitiesProxy:OnNtfActivityUpdate(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.acticity_update_activity_ntf, data)
  LogDebug("ActivitiesInfo", "//ActivitiesProxy服务器推送《活动更新》数据")
  if netData.data then
    if netData.data.id then
      local activeInfo = {}
      activeInfo.activityId = netData.data.id
      activeInfo.cfg = netData.data.cfg
      activeInfo.status = netData.data.status
      if netData.data.reddot then
        activeInfo.reddot = 1
      else
        activeInfo.reddot = 0
      end
      self.activitiesPreTable[netData.data.id] = activeInfo
      self:SetRedNumByActivityID(activeInfo.activityId, activeInfo.reddot)
      GameFacade:SendNotification(NotificationDefines.Activities.PreviewUpdate)
      GameFacade:SendNotification(NotificationDefines.Activities.EntryListUpdate)
    else
      LogError("ActivitiesProxy:OnNtfActivityUpdate", "//ActivitiesProxy服务器下发的活动id为空，acticity_update_activity_ntf.id = nil")
    end
  end
end
function ActivitiesProxy:OnNtfActivityStatusChange(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.acticity_statue_change_ntf, data)
  LogDebug("ActivitiesInfo", "//ActivitiesProxy服务器推送《活动状态变更》数据，activity_id = %d, status = %d", netData.activity_id, netData.status)
  if netData.activity_id then
    local Activity = self.activitiesPreTable[netData.activity_id]
    if Activity then
      Activity.status = netData.status
      GameFacade:SendNotification(NotificationDefines.Activities.PreviewUpdate)
      if Activity.status == GlobalEnumDefine.EActivityStatus.Runing then
        local sendData = {
          activityId = netData.activity_id,
          reddotNum = 1
        }
      end
      if Activity.status == GlobalEnumDefine.EActivityStatus.Closed then
        GameFacade:SendNotification(NotificationDefines.Activities.EntryListUpdate)
      end
    end
  end
end
function ActivitiesProxy:GetAutoShowPageActivity()
  return table.remove(self.autoShowPageTable, 1)
end
function ActivitiesProxy:GetActivityById(inActivityId)
  return self.activitiesPreTable[inActivityId]
end
function ActivitiesProxy:GetActivityPreTable()
  return self.activitiesPreTable
end
function ActivitiesProxy:GetActivityByActType(actType)
  for k, v in pairs(self.activitiesPreTable) do
    if v.cfg and v.cfg.type == actType then
      return v
    end
  end
end
function ActivitiesProxy:GetAllEnableActivities()
  local activities = {}
  for key, value in pairs(self.activitiesPreTable) do
    if value.cfg then
      local enable = value.status < GlobalEnumDefine.EActivityStatus.Closed
      if enable then
        table.insert(activities, value)
      end
    end
  end
  return activities
end
function ActivitiesProxy:GetMainActivitie()
  local activities = self:GetAllEnableActivities()
  if table.count(activities) > 0 then
    table.sort(activities, function(a, b)
      return a.cfg.sort > b.cfg.sort
    end)
  else
    return nil
  end
  return activities[1]
end
function ActivitiesProxy:GetOtherActivities()
  local activities = self:GetAllEnableActivities()
  if table.count(activities) > 1 then
    table.sort(activities, function(a, b)
      return a.cfg.sort > b.cfg.sort
    end)
  else
    return nil
  end
  table.remove(activities, 1)
  return activities
end
function ActivitiesProxy:GetEnableActivitiesByStyle(inStyle)
  local activities = {}
  for key, value in pairs(self.activitiesPreTable) do
    if value.cfg then
      local cfg = value.cfg
      local enable = value.status < GlobalEnumDefine.EActivityStatus.Closed
      if cfg.display_type == inStyle and enable then
        table.insert(activities, value)
      end
    end
  end
  return activities
end
function ActivitiesProxy:SetRedNumByActivityID(_activityId, num)
  local activityId = tostring(_activityId)
  LogDebug("ActivitiesProxy", "SetRedNumByActivityID activityId = " .. activityId .. "  num = " .. tostring(num))
  self.ActivityRedList[activityId] = num
  local sendBody = {activityId = activityId, reddotNum = num}
  GameFacade:SendNotification(NotificationDefines.Activities.ActivityRedDotUpdate, sendBody)
end
function ActivitiesProxy:GetRedNumByActivityID(_activityId)
  local activityId = tostring(_activityId)
  LogDebug("ActivitiesProxy", "GetRedNumByActivityID activityId = " .. activityId .. "  num = " .. tostring(self.ActivityRedList[activityId]))
  return self.ActivityRedList[activityId]
end
function ActivitiesProxy:GetActivityRedList()
  return self.ActivityRedList
end
function ActivitiesProxy:GetActivityTableCfg(_activityId)
  local arrRows = ConfigMgr:GetActivityTableRow()
  if arrRows then
    return arrRows:ToLuaTable()[tostring(_activityId)]
  end
end
function ActivitiesProxy:IsEndActivity(activityId)
  local activeInfo = self:GetActivityById(activityId)
  if activeInfo then
    return activeInfo.status == GlobalEnumDefine.EActivityStatus.Closed
  end
  return true
end
return ActivitiesProxy
