local LotteryProxy = class("LotteryProxy", PureMVC.Proxy)
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
local maxBallNum = 10
local perHistoryReqNum = 80
local lotteryInfoAll = {}
local lotteryCfg = {}
local dropMap = {}
local curLotterySelected = 0
local lotteryHistoryList = {}
local bHasMore = true
local lotteryBallTypeSet = {}
local lotteryBallTypeSwitcherIndexSet = {}
local lotterySubsystem
function LotteryProxy:GetMaxCount()
  return maxBallNum
end
function LotteryProxy:GetAllLottery()
  return lotteryInfoAll
end
function LotteryProxy:GetLotteryInfo(lotteryId)
  return lotteryInfoAll[lotteryId or curLotterySelected]
end
function LotteryProxy:GetLotteryCfg(lotteryId)
  return lotteryCfg[tostring(lotteryId or curLotterySelected)]
end
function LotteryProxy:GetLotteryItems(lotteryId)
  local dropItems = {}
  local normalDropId = self:GetLotteryCfg(lotteryId).NormalDrop
  if dropMap[normalDropId] then
    table.insert(dropItems, dropMap[normalDropId])
  end
  return dropItems
end
function LotteryProxy:SetLotterySelected(lotteryId)
  curLotterySelected = lotteryId
  local lotteryInfoUpdate = {
    lotteryId = lotteryId,
    lotteryInfo = lotteryInfoAll[lotteryId]
  }
  GameFacade:SendNotification(NotificationDefines.Lottery.UpdateLotteryInfo, lotteryInfoUpdate)
end
function LotteryProxy:SetLotteryBallType(ballIndex, ballType)
  if ballType ~= LotteryEnum.ballItemType.Null then
    lotteryBallTypeSet[ballIndex] = ballType
  else
    lotteryBallTypeSet[ballIndex] = nil
  end
end
function LotteryProxy:SetLotteryBallSwitcherIndex(ballIndex, index)
  lotteryBallTypeSwitcherIndexSet[ballIndex] = index
end
function LotteryProxy:ClearLotteryBallSet()
  lotteryBallTypeSet = {}
  lotteryBallTypeSwitcherIndexSet = {}
end
function LotteryProxy:GetLotteryBallSet()
  return lotteryBallTypeSet
end
function LotteryProxy:GetLotteryBallSwitcherIndexSet()
  return lotteryBallTypeSwitcherIndexSet
end
function LotteryProxy:GetLotterySelected()
  return curLotterySelected
end
function LotteryProxy:GetLotteryObtained()
  return table.clone(self.obtainItems)
end
function LotteryProxy:ClearObtains()
  self.obtainItems = nil
end
function LotteryProxy:UpdateTicketCount(ticketId, count)
  for key, value in pairs(lotteryInfoAll) do
    if value.ticketId == ticketId then
      value.ticketCnt = count
      local lotteryInfoUpdate = {
        lotteryId = key,
        lotteryInfo = lotteryInfoAll[key]
      }
      GameFacade:SendNotification(NotificationDefines.Lottery.UpdateLotteryInfo, lotteryInfoUpdate)
      return
    end
  end
end
function LotteryProxy:EquipLotteryResultItem(itemId)
  if itemId then
    local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if itemType == UE4.EItemIdIntervalType.RoleSkin then
      local roleId = roleProxy:GetRoleSkin(itemId).RoleId
      if roleId then
        if roleProxy:IsUnlockRole(roleId) then
          roleProxy:ReqRoleSkinSelect(roleId, itemId)
        else
          local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoleNotUnlockTips")
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
        end
      end
    elseif itemType == UE4.EItemIdIntervalType.Weapon then
      local roleId = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetRoleIDByWeaponId(itemId)
      if roleId then
        if roleProxy:IsUnlockRole(roleId) then
          GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):ReqEquipWeaponByWeaponID(itemId, roleId)
        else
          local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomTips_1")
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
        end
      end
    elseif itemType == UE4.EItemIdIntervalType.VCardAvatar then
      local cardBorderId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardBorderID)
      local cardAchieveId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAchieId)
      local data = {
        itemId,
        cardBorderId,
        cardAchieveId
      }
      GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):ReqUpdateCard(data)
    elseif itemType == UE4.EItemIdIntervalType.VCardBg then
      local cardAvatarId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID)
      local cardAchieveId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAchieId)
      local data = {
        cardAvatarId,
        itemId,
        cardAchieveId
      }
      GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):ReqUpdateCard(data)
    end
  end
end
function LotteryProxy:GetLotteryHistory(startPos, endPos)
  if lotteryHistoryList[startPos] then
    local ret = {}
    local bMoreData = true
    for i = startPos, endPos do
      if lotteryHistoryList[i] then
        table.insert(ret, lotteryHistoryList[i])
      end
    end
    if nil == lotteryHistoryList[endPos + 1] then
      bMoreData = false
    else
      local cachedNum = table.count(lotteryHistoryList)
      if cachedNum <= endPos + (endPos - startPos + 1) * 2 and bHasMore then
        self:ReqLotteryHistory(cachedNum + 1, cachedNum + perHistoryReqNum)
      end
    end
    return ret, bMoreData
  else
    LogError("LotteryProxy", "Require start position error")
    return nil
  end
end
function LotteryProxy:OnRegister()
  LogDebug("LotteryProxy", "Register Lottery Proxy")
  LotteryProxy.super.OnRegister(self)
  self.bInLotteryModule = false
  curLotterySelected = 1
  lotteryCfg = ConfigMgr:GetLotteryTableRows():ToLuaTable()
  local dropCfg = ConfigMgr:GetDropTableRows():ToLuaTable()
  for _, value in pairs(dropCfg) do
    if dropMap[value.GroupId] == nil then
      dropMap[value.GroupId] = {}
    end
    if value.Items:Length() > 0 then
      table.insert(dropMap[value.GroupId], value.Items:Get(1))
    end
  end
  lotteryBallTypeSet = {}
  self.deskCameraTagName = nil
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOTTERY_INFO_NTF, FuncSlot(self.OnNtfLotteryInfo, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_INFO_RES, FuncSlot(self.OnResLotteryInfo, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_DO_LOTTERY_RES, FuncSlot(self.OnResDoLottery, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_HISTORY_RES, FuncSlot(self.OnResLotteryHistory, self))
  end
  self.showProb = false
  self.lotteryProb = {}
  self.printString = nil
  self.OnToggleDisplayLotteryProbHandle = DelegateMgr:AddDelegate(GetGlobalDelegateManager().OnToggleDisplayLotteryProb, self, "ToggleDisplayProb")
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_PROB_RES, FuncSlot(self.OnResLotteryProb, self))
  end
end
function LotteryProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOTTERY_INFO_NTF, FuncSlot(self.OnNtfLotteryInfo, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_INFO_RES, FuncSlot(self.OnResLotteryInfo, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_DO_LOTTERY_RES, FuncSlot(self.OnResDoLottery, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_HISTORY_RES, FuncSlot(self.OnResLotteryHistory, self))
  end
  DelegateMgr:RemoveDelegate(GetGlobalDelegateManager().OnToggleDisplayLotteryProb, self.OnToggleDisplayLotteryProbHandle)
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_PROB_RES, FuncSlot(self.OnResLotteryProb, self))
  end
  LotteryProxy.super.OnRemove(self)
end
function LotteryProxy:OnNtfLotteryInfo(data)
  local lotteryInfoNtf = pb.decode(Pb_ncmd_cs_lobby.lottery_info_ntf, data)
  LogDebug("LotteryProxy", "On ntf lottery info: " .. TableToString(lotteryInfoNtf))
  self:InitLotteryAllInfo(lotteryInfoNtf.items)
end
function LotteryProxy:ReqLotteryInfo()
  LogDebug("LotteryProxy", "Request lottery info")
  local data = {}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_INFO_REQ, pb.encode(Pb_ncmd_cs_lobby.get_lottery_info_req, data))
end
function LotteryProxy:OnResLotteryInfo(data)
  local lotteryInfoRes = pb.decode(Pb_ncmd_cs_lobby.get_lottery_info_res, data)
  LogDebug("LotteryProxy", "On receive lottery info: " .. TableToString(lotteryInfoRes))
  if 0 ~= lotteryInfoRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, lotteryInfoRes.code)
    return
  end
  self:InitLotteryAllInfo(lotteryInfoRes.items)
end
function LotteryProxy:InitLotteryAllInfo(lotteryInfoItems)
  lotteryInfoAll = {}
  if lotteryInfoItems then
    local warehouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
    for _, value in pairs(lotteryInfoItems) do
      local lotteryPoolInfo = {}
      lotteryPoolInfo.bonus = {}
      if self:GetLotteryCfg(value.id) then
        lotteryPoolInfo.ticketId = tonumber(self:GetLotteryCfg(value.id).ItemId)
        lotteryPoolInfo.ticketCnt = warehouseProxy:GetItemCnt(lotteryPoolInfo.ticketId)
        if 0 == curLotterySelected then
          curLotterySelected = value.id
        end
      else
        LogError("LotteryProxy", "Lottery %d config doesn't exist, 配置问题@陈冠宇", value.id)
      end
      for _, v in pairs(value.bonuses) do
        lotteryPoolInfo.bonus[v.quality] = v.count
      end
      lotteryInfoAll[value.id] = lotteryPoolInfo
    end
  end
  GameFacade:SendNotification(NotificationDefines.Lottery.InitLotteryCmd)
end
function LotteryProxy:ReqDoLottery(lotteryId, cnt)
  LogDebug("LotteryProxy", "Request do lottery: id %d, count %d", lotteryId, cnt)
  if self.cancelDoLotteryState then
    self.cancelDoLotteryState:EndTask()
  end
  self.cancelDoLotteryState = TimerMgr:AddTimeTask(2, 0, 1, function()
    self:EnableOperationDesk(true)
    if self.cancelDoLotteryState then
      self.cancelDoLotteryState:EndTask()
      self.cancelDoLotteryState = nil
    end
  end)
  local data = {id = lotteryId, count = cnt}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_DO_LOTTERY_REQ, pb.encode(Pb_ncmd_cs_lobby.do_lottery_req, data))
end
function LotteryProxy:OnResDoLottery(data)
  LogDebug("LotteryProxy", "On res do lottery")
  if self.cancelDoLotteryState then
    self.cancelDoLotteryState:EndTask()
    self.cancelDoLotteryState = nil
  end
  local doLotteryRes = pb.decode(Pb_ncmd_cs_lobby.do_lottery_res, data)
  if 0 ~= doLotteryRes.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, doLotteryRes.code)
    self:EnableOperationDesk(true)
    return
  end
  LogDebug("LotteryProxy", "Lottery result:%s", TableToString(doLotteryRes))
  local id = doLotteryRes.req.id
  if nil == id or nil == lotteryInfoAll[id] then
    LogError("LotteryProxy", "Invalid lottery id:%d", id or -1)
  end
  lotteryInfoAll[id].bonus = {}
  for _, value in pairs(doLotteryRes.bonuses) do
    lotteryInfoAll[id].bonus[value.quality] = value.count
  end
  local obtainItems = doLotteryRes.obtain_list
  self.obtainItems = {}
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  for _, obtainData in pairs(obtainItems) do
    if obtainData.result_list then
      for _, item in pairs(obtainData.result_list) do
        item.quality = itemProxy:GetAnyItemQuality(item.item_id)
        table.insert(self.obtainItems, item)
      end
    end
    if obtainData.convert_list then
      for _, item in pairs(obtainData.convert_list) do
        item.quality = itemProxy:GetAnyItemQuality(item.item_id)
        table.insert(self.obtainItems, item)
      end
    end
  end
  if self.bInLotteryModule then
    GameFacade:SendNotification(NotificationDefines.Lottery.StartLotteryProcessCmd)
  end
  if self.showProb then
    self:ReqLotteryProb()
  end
end
function LotteryProxy:ReqLotteryHistory(startPos, endPos)
  local data = {
    start_pos = startPos,
    end_pos = endPos,
    lottery_id = curLotterySelected
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_HISTORY_REQ, pb.encode(Pb_ncmd_cs_lobby.get_lottery_history_req, data))
end
function LotteryProxy:OnResLotteryHistory(data)
  LogDebug("LotteryProxy", "On res get lottery history")
  local lotteryHistoryRes = pb.decode(Pb_ncmd_cs_lobby.get_lottery_history_res, data)
  if 0 == lotteryHistoryRes.code then
    local startPos = lotteryHistoryRes.start_pos
    local endPos = lotteryHistoryRes.end_pos
    if 1 == startPos then
      bHasMore = true
      if lotteryHistoryList[startPos] then
        if lotteryHistoryRes.lottery_history_list[startPos] ~= lotteryHistoryList[startPos] then
          lotteryHistoryList = {}
        else
          GameFacade:SendNotification(NotificationDefines.Lottery.HistoryDataPrepared, true)
          return
        end
      elseif 0 == table.count(lotteryHistoryRes.lottery_history_list) then
        GameFacade:SendNotification(NotificationDefines.Lottery.HistoryDataPrepared, false)
        return
      end
    end
    local gotNum = 0
    for key, value in pairs(lotteryHistoryRes.lottery_history_list) do
      table.insert(lotteryHistoryList, value)
      gotNum = gotNum + 1
    end
    if gotNum < endPos - startPos + 1 then
      bHasMore = false
    end
    GameFacade:SendNotification(NotificationDefines.Lottery.HistoryDataPrepared, true)
  else
    GameFacade:SendNotification(NotificationDefines.Lottery.HistoryDataPrepared, false)
  end
end
function LotteryProxy:ReqLotteryProb()
  local data = {id = curLotterySelected}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_GET_LOTTERY_PROB_REQ, pb.encode(Pb_ncmd_cs_lobby.get_lottery_prob_req, data))
end
function LotteryProxy:OnResLotteryProb(data)
  local getLotteryProbRes = pb.decode(Pb_ncmd_cs_lobby.get_lottery_prob_res, data)
  self.printString = nil
  if 0 == getLotteryProbRes.code then
    for key, value in pairs(getLotteryProbRes.lottery_prob_list) do
      self.lotteryProb[value.id] = {}
      for k, v in pairs(value.lottery_cell_prob_list) do
        self.lotteryProb[value.id][v.quality] = v.prob
      end
    end
    for key, value in pairs(self.lotteryProb) do
      local newString = string.format("奖池 %d 当前抽奖概率：红色%s%%，橙色%s%%，紫色%s%%", key, value[GlobalEnumDefine.EItemQuality.Legendary] / 100 or 0, value[GlobalEnumDefine.EItemQuality.Perfect] / 100 or 0, value[GlobalEnumDefine.EItemQuality.Superior] / 100 or 0)
      if self.printString then
        self.printString = self.printString .. "\n" .. newString
      else
        self.printString = newString
      end
    end
    self:PrintProbMsg()
  end
end
function LotteryProxy:ToggleDisplayProb()
  self.showProb = not self.showProb
  if self.showProb then
    self:ReqLotteryProb()
  else
    self.printString = ""
    self:PrintProbMsg()
  end
end
function LotteryProxy:PrintProbMsg()
  if self.printString and lotterySubsystem then
    lotterySubsystem:UpdateLotteryProb(self.printString)
  end
end
function LotteryProxy:GetEnableList()
  local lotteryList = {}
  local nowTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  for index, value in pairs(lotteryCfg) do
    local startT = UE4.UPMLuaBridgeBlueprintLibrary.ToUnixTimestamp(value.start)
    local finishT = UE4.UPMLuaBridgeBlueprintLibrary.ToUnixTimestamp(value.finish)
    if nowTime >= startT and nowTime < finishT then
      local lotteryInfo = {}
      lotteryInfo.strCustom = value.id
      lotteryInfo.name = value.name
      lotteryInfo.pageName = value.PageName
      table.insert(lotteryList, lotteryInfo)
    end
  end
  table.sort(lotteryList, function(a, b)
    return a.strCustom < b.strCustom
  end)
  return lotteryList
end
function LotteryProxy:SetInLottery(bInLottery)
  if self.bInLotteryModule == bInLottery then
    return
  end
  LogInfo("LotteryProxy", "Set is in lottery scene:%s", tostring(bInLottery))
  self.bInLotteryModule = bInLottery
  if bInLottery then
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
    self:PlayLotteryBGM()
  else
    self:EnableOperationDesk(false)
    self:ClearLotteryBallSet()
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.LotterySettingPage)
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.LotteryTransitionPage)
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.LotteryResultPage)
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.ResultDisplayPage)
    if not lotterySubsystem:IsValid() then
      return
    end
    self:SetLotteryStatus(UE4.ELotteryState.End)
    UE4.UCySequenceManager.Get(LuaGetWorld()):GoToEndAndStop()
    self:StopLotteryBGM()
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
    GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):OpenFriendMsgPage()
  end
end
function LotteryProxy:GetIsInLottery()
  return self.bInLotteryModule
end
function LotteryProxy:ReturnEntry()
  if self.bInLotteryModule then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.LotteryEntryPage, false, curLotterySelected)
  end
end
function LotteryProxy:SetLotteryBGM(inAudio)
  if self.lotteryBGM == nil then
    self.lotteryBGM = inAudio
  end
end
function LotteryProxy:PlayLotteryBGM()
  if self.lotteryBGM and lotterySubsystem then
    lotterySubsystem:PlayLotteryBGM(self.lotteryBGM)
  end
end
function LotteryProxy:StopLotteryBGM()
  if self.lotteryBGM and lotterySubsystem then
    lotterySubsystem:StopLotteryBGM(self.lotteryBGM)
  end
end
function LotteryProxy:SetLotterySubsystem()
  lotterySubsystem = UE4.UPMLotterySubsystem.Get(LuaGetWorld())
  if lotterySubsystem then
    lotterySubsystem.OnLotteryResultShown:Add(UE4.UPMLotterySubsystem.Get(LuaGetWorld()), self.BallHit)
  end
end
function LotteryProxy:BallHit(ballIndex)
  if ballIndex + 1 == table.count(lotteryBallTypeSet) then
    GameFacade:SendNotification(NotificationDefines.Lottery.OnLotteryEffectFinished)
  end
end
function LotteryProxy:SetSceneRoot(tagName)
  if lotterySubsystem then
    lotterySubsystem:GetTagActor(tagName, true)
  end
end
function LotteryProxy:SetOperationDesk(tagName)
  if lotterySubsystem then
    self.operationDesk = lotterySubsystem:GetOperationDesk(tagName)
  end
end
function LotteryProxy:SetPrintGuardBar(tagName)
  if lotterySubsystem then
    lotterySubsystem:GetPrintGuardBar(tagName)
  end
end
function LotteryProxy:EnableOperationDesk(bIsEnabled)
  if self.operationDesk and self.operationDesk:IsValid() then
    self.operationDesk:SetInputEnabled(bIsEnabled)
  end
  GameFacade:SendNotification(NotificationDefines.Lottery.EnableTableInput, bIsEnabled)
end
function LotteryProxy:PlayButtonEffect(buttonName, status, bIsLoop)
  if self.operationDesk then
    self.operationDesk:PlayParticle(buttonName, status, bIsLoop)
  end
end
function LotteryProxy:StopPlayParticle(buttonName, status)
  if self.operationDesk then
    self.operationDesk:StopParticle(buttonName, status)
  end
end
function LotteryProxy:StartLotteryEffect()
  self:SetLotteryStatus(UE4.ELotteryState.RiseUpCamera)
  if lotterySubsystem then
    local ballTypeArray = UE4.TArray(0)
    if lotteryBallTypeSet then
      for key, value in pairs(lotteryBallTypeSet) do
        ballTypeArray:Add(value)
      end
    end
    local itemsObtained = self:GetLotteryObtained()
    local resultArray = UE4.TArray(UE4.ECyItemQualityType)
    if itemsObtained then
      for key, value in pairs(itemsObtained) do
        resultArray:Add(value.quality)
      end
    end
    lotterySubsystem:SetBallsType(ballTypeArray, resultArray)
  end
end
function LotteryProxy:SetLotteryStatus(status)
  if lotterySubsystem then
    lotterySubsystem:SetLotteryProcessStatus(status)
  end
end
function LotteryProxy:SkipLotteryProcess()
  if lotterySubsystem then
    lotterySubsystem:SkipLotteryProcess()
  end
end
return LotteryProxy
