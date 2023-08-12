local SpaceMusicProxy = class("SpaceMusicProxy", PureMVC.Proxy)
function SpaceMusicProxy:ctor(proxyName, data)
  SpaceMusicProxy.super.ctor(self, proxyName, data)
  self:CleanData()
end
function SpaceMusicProxy:CleanData()
  self.activityId = 0
  self.rewardDataList = {}
end
function SpaceMusicProxy:OnRegister()
  SpaceMusicProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_STM_DATA_NTF, FuncSlot(self.OnNtfGetCardList, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_STM_NEW_DAY_NTF, FuncSlot(self.OnNtfNewDay, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_STM_REWARD_RES, FuncSlot(self.OnResReward, self))
end
function SpaceMusicProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STM_DATA_NTF, FuncSlot(self.OnNtfGetCardList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STM_NEW_DAY_NTF, FuncSlot(self.OnNtfNewDay, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STM_REWARD_RES, FuncSlot(self.OnResReward, self))
end
function SpaceMusicProxy:ReqGetReward(inDay)
  local data = {
    activity_id = self.activityId,
    day = inDay
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_STM_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.stm_reward_req, data))
end
function SpaceMusicProxy:OnNtfGetCardList(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.stm_data_ntf, data)
  LogDebug("SpaceMusic", "//SpaceMusicProxy服务器推送《时空之音》数据")
  if netData then
    self.activityId = netData.activity_id
    if netData.cfg_list then
      for key, value in pairs(netData.cfg_list) do
        local rewardInfo = {}
        if value.items then
          local chooseOne = value.items[1]
          if chooseOne then
            rewardInfo.itemId = chooseOne.item_id
            rewardInfo.itemCnt = chooseOne.item_cnt
          else
            LogError("SpaceMusicProxy", "时空之音奖池配置有误,找策划！")
          end
        end
        if table.containsValue(netData.days, value.day) then
          rewardInfo.status = GlobalEnumDefine.EMusicRewardStatus.Get
        else
          rewardInfo.status = netData.cur_day < value.day and GlobalEnumDefine.EMusicRewardStatus.Locked or GlobalEnumDefine.EMusicRewardStatus.Activate
        end
        self.rewardDataList[value.day] = rewardInfo
      end
    end
  end
end
function SpaceMusicProxy:OnNtfNewDay(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.stm_new_day_ntf, data)
  if netData then
    LogDebug("SpaceMusic", "//SpaceMusicProxy服务器推送《新的一天》数据，netData.day = %d", netData.cur_day)
    local rewardInfo = self.rewardDataList[netData.cur_day]
    if rewardInfo then
      rewardInfo.status = GlobalEnumDefine.EMusicRewardStatus.Activate
      local data = {
        day = netData.cur_day,
        status = rewardInfo.status
      }
      GameFacade:SendNotification(NotificationDefines.Activities.SpaceMusic.UpdateReward, data)
    end
    self:CalculateRedDot()
  end
end
function SpaceMusicProxy:OnResReward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.stm_reward_res, data)
  LogDebug("SpaceMusic", "//SpaceMusicProxy服务器返回《领奖》数据")
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceMusic.UpdateReward)
    return
  end
  local rewardInfo = self.rewardDataList[netData.day]
  if rewardInfo then
    rewardInfo.status = GlobalEnumDefine.EMusicRewardStatus.Get
    local data = {
      day = netData.day,
      status = rewardInfo.status
    }
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceMusic.UpdateReward, data)
  end
  self:CalculateRedDot()
end
function SpaceMusicProxy:CalculateRedDot()
  local num = 0
  for index, value in ipairs(self.rewardDataList) do
    if value.status == GlobalEnumDefine.EMusicRewardStatus.Activate then
      num = num + 1
    end
  end
  GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(self.activityId, num)
end
function SpaceMusicProxy:GetRewardList()
  return self.rewardDataList
end
function SpaceMusicProxy:GetActivityId()
  return self.activityId
end
return SpaceMusicProxy
