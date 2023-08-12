local RewardNeedReceiveCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function RewardNeedReceiveCond:BPGetMatchConditionCount(paramStr)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local apartmentContractProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy)
  local rewards = apartmentContractProxy:GetRoleAvailableTaskRewards(CurrentRoleId)
  local bPromisePage = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy):GetCurrentPageType() == GlobalEnumDefine.EApartmentPageType.Promise
  if #rewards > 0 and bPromisePage then
    LogInfo("RewardNeedReceiveCond:BPGetMatchConditionCount", "rewards >0 ")
    return 1
  end
  LogInfo("RewardNeedReceiveCond:BPGetMatchConditionCount", " no rewards")
  return 0
end
function RewardNeedReceiveCond:Update()
end
return RewardNeedReceiveCond
