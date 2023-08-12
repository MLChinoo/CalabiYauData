local SpaceTimeProxy = class("SpaceTimeProxy", PureMVC.Proxy)
function SpaceTimeProxy:ctor(proxyName, data)
  SpaceTimeProxy.super.ctor(self, proxyName, data)
  self:CleanData()
end
function SpaceTimeProxy:CleanData()
  self.activityId = 0
  self.spaceTimeStage = GlobalEnumDefine.ESpaceTimeStages.None
  self.cardDataList = {}
  self.cardSend = nil
  self.cardSendDay = -1
  self.currentDay = -1
  self.autoShowPage = false
end
function SpaceTimeProxy:OnRegister()
  SpaceTimeProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_STA_GET_DATA_RES, FuncSlot(self.OnResGetCardList, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_STA_DATA_NTF, FuncSlot(self.OnNtfGetCardList, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_STA_OPEN_CARD_RES, FuncSlot(self.OnResOpenCard, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_STA_CHOOSE_REWARD_RES, FuncSlot(self.OnResChooseReward, self))
  lobbyService:RegistNty(Pb_ncmd_cs.NCmdId.NID_STA_NEW_DAY_NTF, FuncSlot(self.OnNtfNewDay, self))
end
function SpaceTimeProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if nil == lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STA_GET_DATA_RES, FuncSlot(self.OnResGetCardList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STA_DATA_NTF, FuncSlot(self.OnNtfGetCardList, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STA_OPEN_CARD_RES, FuncSlot(self.OnResOpenCard, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STA_CHOOSE_REWARD_RES, FuncSlot(self.OnResChooseReward, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_STA_NEW_DAY_NTF, FuncSlot(self.OnNtfNewDay, self))
  self:CleanData()
end
function SpaceTimeProxy:ReqGetCardList(activityId)
  self.activityId = activityId
  if table.count(self.cardDataList) <= 0 then
    LogDebug("ActivitiesInfo", "//SpaceTimeProxy客户端请求网络拉《时空之约》数据")
    local data = {activity_id = activityId}
    SendRequest(Pb_ncmd_cs.NCmdId.NID_STA_GET_DATA_REQ, pb.encode(Pb_ncmd_cs_lobby.sta_get_data_req, data))
  else
    LogDebug("ActivitiesInfo", "//SpaceTimeProxy客户端本地有《时空之约》数据")
    self:ProcessData(true)
  end
end
function SpaceTimeProxy:ReqOpenCard(inDay)
  local data = {
    activity_id = self.activityId,
    day = inDay
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_STA_OPEN_CARD_REQ, pb.encode(Pb_ncmd_cs_lobby.sta_open_card_req, data))
end
function SpaceTimeProxy:ReqChooseReward(inDay)
  local data = {
    activity_id = self.activityId,
    day = inDay
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_STA_CHOOSE_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.sta_choose_reward_req, data))
end
function SpaceTimeProxy:OnResGetCardList(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sta_get_data_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    self:ProcessData(false)
    return
  end
  LogDebug("ActivitiesInfo", "//SpaceTimeProxy服务器返回《时空之约》数据")
  self:ProcessNetData(netData)
end
function SpaceTimeProxy:OnNtfGetCardList(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sta_data_ntf, data)
  LogDebug("ActivitiesInfo", "//SpaceTimeProxy服务器推送《时空之约》数据")
  self:ProcessNetData(netData, true)
end
function SpaceTimeProxy:ProcessNetData(netData, isNtf)
  if netData.activity_id then
    self.activityId = netData.activity_id
  end
  if netData.data then
    local loginDays = netData.data.days
    if loginDays then
      self.currentDay = math.max(table.unpack(loginDays))
    end
  end
  self:PrintCurrentDay()
  if netData.cfg_list then
    local cfgList = netData.cfg_list
    local cfgNum = table.count(cfgList)
    self.cardDataList = {}
    if cfgNum <= 0 then
      LogError("SpaceTimeProxy:OnResGetCardList", "//SpaceTimeProxy服务器下发的时空之约数据为空，sta_get_data_res.cfg_list = nil")
      return
    end
    self:CalculateCurrentStage(cfgNum)
    for key, value in pairs(cfgList) do
      local someone = value.items[1]
      if someone then
        local cardInfo = {}
        cardInfo.itemId = someone.item_id
        cardInfo.itemCnt = someone.item_cnt
        cardInfo.day = value.day
        if cardInfo.day < self.currentDay then
          cardInfo.status = GlobalEnumDefine.ECardStatus.Expire
        elseif cardInfo.day == self.currentDay then
          cardInfo.status = GlobalEnumDefine.ECardStatus.Activate
        elseif cardInfo.day > self.currentDay then
          cardInfo.status = GlobalEnumDefine.ECardStatus.Locked
        else
          cardInfo.status = GlobalEnumDefine.ECardStatus.None
        end
        self.cardDataList[value.day] = cardInfo
      end
    end
    self.cardSendDay = table.count(self.cardDataList) + 1
  end
  if netData.data then
    local flipData = netData.data.cards
    if flipData then
      for key, value in pairs(flipData) do
        local cardInfo = self.cardDataList[value.day]
        if cardInfo then
          cardInfo.itemId = value.item_id
          cardInfo.itemCnt = value.item_cnt
          cardInfo.status = GlobalEnumDefine.ECardStatus.Opened
        end
      end
    end
    local loginData = netData.data.days
    if loginData then
      for key, value in pairs(loginData) do
        local cardInfo = self.cardDataList[value]
        if cardInfo and cardInfo.status == GlobalEnumDefine.ECardStatus.Expire then
          cardInfo.status = GlobalEnumDefine.ECardStatus.Activate
        end
      end
    end
    local sendData = netData.data.send_item
    if sendData then
      self.cardSend = {}
      self.cardSend.day = sendData.day
      self.cardSend.itemId = sendData.item_id
      self.cardSend.itemCnt = sendData.item_cnt
      self.cardSend.status = GlobalEnumDefine.ECardStatus.Opened
    end
  end
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if itemProxy then
    for index, value in ipairs(self.cardDataList) do
      local itemCfg = itemProxy:GetAnyItemInfoById(value.itemId)
      if itemCfg then
        value.name = itemCfg.name
        value.image = itemCfg.image
        value.quality = itemCfg.quality
      end
    end
    if self.cardSend then
      local itemCfg = itemProxy:GetAnyItemInfoById(self.cardSend.itemId)
      if itemCfg then
        self.cardSend.name = itemCfg.name
        self.cardSend.image = itemCfg.image
        self.cardSend.quality = itemCfg.quality
      end
    end
  end
  self:ProcessData(true, isNtf)
end
function SpaceTimeProxy:ProcessData(success, isNtf)
  if success then
    local body = {
      activityId = self.activityId,
      isSuccess = success,
      isServerNtf = isNtf
    }
    GameFacade:SendNotification(NotificationDefines.Activities.ActivityOperateCmd, body, NotificationDefines.Activities.ActivityResType)
  end
end
function SpaceTimeProxy:OnNtfNewDay(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sta_new_day_ntf, data)
  if netData.day then
    self.currentDay = netData.day
    LogDebug("ActivitiesInfo", "//SpaceTimeProxy服务器推送《新的一天》数据，netData.day = %d", netData.day)
    self:CalculateCurrentStage(#self.cardDataList)
    local currentDayCardData = self.cardDataList[self.currentDay]
    if currentDayCardData then
      currentDayCardData.status = GlobalEnumDefine.ECardStatus.Activate
    end
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.NewDay)
    self:CalculateRedDot()
  end
end
function SpaceTimeProxy:OnResOpenCard(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sta_open_card_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.CardFlip, {success = false})
    return
  end
  LogDebug("ActivitiesInfo", "//SpaceTimeProxy服务器返回《翻卡》数据")
  if netData.card then
    local card = netData.card
    local cardInfo = self.cardDataList[card.day]
    if cardInfo then
      cardInfo.itemId = card.item_id
      cardInfo.itemCnt = card.item_cnt
      cardInfo.day = card.day
      cardInfo.status = GlobalEnumDefine.ECardStatus.Opened
      local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
      if itemProxy then
        local itemCfg = itemProxy:GetAnyItemInfoById(card.item_id)
        if itemCfg then
          cardInfo.name = itemCfg.name
          cardInfo.image = itemCfg.image
          cardInfo.quality = itemCfg.quality
        end
      end
    end
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.CardFlip, {
      day = card.day,
      success = true
    })
    self:CalculateRedDot()
  end
end
function SpaceTimeProxy:OnResChooseReward(data)
  local netData = DeCode(Pb_ncmd_cs_lobby.sta_choose_reward_res, data)
  if 0 ~= netData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, netData.code)
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.CardSend, {success = false})
    return
  end
  LogDebug("ActivitiesInfo", "//SpaceTimeProxy服务器返回《寄送》数据")
  local sendData = self.cardDataList[netData.day]
  if sendData then
    self.cardSend = {}
    self.cardSend.day = sendData.day
    self.cardSend.itemId = sendData.itemId
    self.cardSend.itemCnt = sendData.itemCnt
    self.cardSend.status = GlobalEnumDefine.ECardStatus.Opened
    self.cardSend.name = sendData.name
    self.cardSend.image = sendData.image
    self.cardSend.quality = sendData.quality
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.CardSend, {success = true})
    self:CalculateRedDot()
  end
end
function SpaceTimeProxy:PrintCurrentDay()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if proxy then
    local activity = proxy:GetActivityById(self.activityId)
    if activity and activity.cfg then
      local nowTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
      LogDebug("ActivitiesInfo", "//SpaceTimeProxy活动开始时间%s,时间戳%d", os.date("%Y-%m-%d %H-%M-%S", activity.cfg.start_time), activity.cfg.start_time)
      LogDebug("ActivitiesInfo", "//SpaceTimeProxy服务器当前时间%s,时间戳%d", os.date("%Y-%m-%d %H-%M-%S", nowTime), nowTime)
      LogDebug("ActivitiesInfo", "//SpaceTimeProxy客户端计算当前是第几天 self.currentDay = %d", self.currentDay)
    end
  end
end
function SpaceTimeProxy:CalculateCurrentStage(InNum)
  if self.currentDay > 0 then
    if InNum >= self.currentDay then
      self.spaceTimeStage = GlobalEnumDefine.ESpaceTimeStages.Flip
    elseif self.currentDay == InNum + 1 then
      self.spaceTimeStage = GlobalEnumDefine.ESpaceTimeStages.Send
    else
      self.spaceTimeStage = GlobalEnumDefine.ESpaceTimeStages.Shut
    end
  end
end
function SpaceTimeProxy:CalculateRedDot()
  local num = 0
  for index, value in ipairs(self.cardDataList) do
    if value.status == GlobalEnumDefine.ECardStatus.Activate then
      num = num + 1
    end
  end
  if self.cardSend then
    num = 0
  end
  GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):SetRedNumByActivityID(self.activityId, num)
end
function SpaceTimeProxy:GetSpaceTimeStage()
  return self.spaceTimeStage
end
function SpaceTimeProxy:GetSpaceTimeCardDataList()
  return self.cardDataList
end
function SpaceTimeProxy:GetSpaceTimeCardDataByDay(inDay)
  return self.cardDataList[inDay]
end
function SpaceTimeProxy:GetSpaceTimeCardSend()
  return self.cardSend
end
function SpaceTimeProxy:GetSpaceTimeCardSendDay()
  return self.cardSendDay
end
function SpaceTimeProxy:GetCurrentDay()
  return self.currentDay
end
function SpaceTimeProxy:GetAutoShowPage()
  return self.autoShowPage
end
return SpaceTimeProxy
