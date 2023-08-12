local ApartmentContractProxy = class("ApartmentContractProxy", PureMVC.Proxy)
function ApartmentContractProxy:OnRegister()
  self.super.OnRegister(self)
  self.PreOpenPct = -1
  self.PreOpenLv = -1
  self.ResTaskRewardsNum = 0
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_GET_ROLE_UPGRAD_REWARD_RES, FuncSlot(self.GetRoleIntimacyReward, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_RES, FuncSlot(self.GetTaskReward, self))
end
function ApartmentContractProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_GET_ROLE_UPGRAD_REWARD_RES, FuncSlot(self.GetRoleIntimacyReward, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_RES, FuncSlot(self.GetTaskReward, self))
end
function ApartmentContractProxy:ReqGetTaskReward(taskId)
  local reqData = {task_id = taskId}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_TAKE_TASK_PRIZE_REQ, pb.encode(Pb_ncmd_cs_lobby.take_task_prize_req, reqData))
end
function ApartmentContractProxy:GetTaskReward(ServerData)
  local getInfo = DeCode(Pb_ncmd_cs_lobby.take_task_prize_res, ServerData)
  if getInfo and getInfo.code and getInfo.code > 0 then
    return
  end
end
function ApartmentContractProxy:ReqGetRoleIntimacyReward(roleId, rewardLv)
  local reqData = {
    role_id = roleId,
    level = rewardLv,
    mode = 1
  }
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_GET_ROLE_UPGRAD_REWARD_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_get_role_upgrad_reward_req, reqData))
end
function ApartmentContractProxy:GetRoleIntimacyReward(ServerData)
  local getInfo = DeCode(Pb_ncmd_cs_lobby.salon_get_role_upgrad_reward_res, ServerData)
  if getInfo and getInfo.code and getInfo.code > 0 then
    return
  end
  local obtainData = {}
  obtainData.overflowItemList = {}
  obtainData.itemList = {}
  for index, itemData in ipairs(getInfo) do
    local info = {}
    info.itemId = itemData.itemId
    info.itemCnt = itemData.itemAmount
    table.insert(obtainData.itemList, info)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RewardDisplayPage, false, obtainData)
  GameFacade:SendNotification(NotificationDefines.ReqApartmentPromisePageData)
end
function ApartmentContractProxy:GetRoleAvailableTaskRewards(roleId)
  if not roleId then
    return
  end
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local taskInfo = BattlePassProxy:GetApartmentRoleAllTask(roleId) or {}
  local rewardAvailableTasks = {}
  for idx, value in ipairs(taskInfo) do
    if value.taskState and value.taskState == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
      table.insert(rewardAvailableTasks, value.taskId)
    end
  end
  return rewardAvailableTasks
end
function ApartmentContractProxy:CheckContractSequence()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local rewardAvailableTasks = self:GetRoleAvailableTaskRewards(CurrentRoleId)
  local rewardsAvailable = #rewardAvailableTasks > 0 and true or false
  if rewardsAvailable then
  end
  return rewardsAvailable
end
function ApartmentContractProxy:CheckContractAnimUpgrade()
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  return RoleAttrMap.CheckFunc(RoleAttrMap.EnumConditionType.IntimacyLvCond)
end
function ApartmentContractProxy:CheckPlayTaskRewardsAnim()
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  return RoleAttrMap.CheckFunc(RoleAttrMap.EnumConditionType.RewardNeedReceiveCond)
end
function ApartmentContractProxy:GetContractUpgradeData()
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local roleApartmentInfo = KaPhoneProxy:GetRoleProperties(CurrentRoleId)
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  local preLv = ConditionProxy:GetValueByRoleIDAndKey(CurrentRoleId, RoleAttrMap.RoleSettingKey.RoleLikeLv) or 1
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleProp = RoleProxy:GetRoleProfile(CurrentRoleId)
  local data = {}
  data.roleId = CurrentRoleId
  data.roleIntimacy = roleApartmentInfo.intimacy
  data.roleIntimacyLv = roleApartmentInfo.intimacy_lv
  data.preIntimacyLv = preLv
  data.roleNameCn = roleProp.NameShortCn
  local roleFavorible = RoleProxy:GetRoleFavoribility(data.roleIntimacyLv)
  data.roleIntimacyNickName = roleFavorible.Name
  data.bodyNewUnlock = {}
  data.areaNewUnlock = {}
  local favorSectionCfgs = RoleProxy:GetRoleFavorabilityEventSectionCfg(CurrentRoleId, data.roleIntimacyLv, data.preIntimacyLv)
  for _, favorCfg in ipairs(favorSectionCfgs) do
    for idx = 1, favorCfg.PartUnlock:Length() do
      local partId = favorCfg.PartUnlock:Get(idx)
      if partId > 0 then
        table.insert(data.bodyNewUnlock, partId)
      end
    end
    for idx = 1, favorCfg.AreaUnlock:Length() do
      local areaId = favorCfg.AreaUnlock:Get(idx)
      if areaId > 0 then
        table.insert(data.areaNewUnlock, areaId)
      end
    end
  end
  return data
end
function ApartmentContractProxy:ShowContractUpgrade()
  local isMathcCondi10 = self:CheckContractAnimUpgrade()
  if not isMathcCondi10 then
    return false
  end
  local data = self:GetContractUpgradeData()
  GameFacade:SendNotification(NotificationDefines.PMApartmentMainCmd, data, NotificationDefines.ApartmentContract.ShowUpGradeEff)
  return true
end
return ApartmentContractProxy
