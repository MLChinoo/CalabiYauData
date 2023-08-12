local EnterCharacterRoomCond = {}
function EnterCharacterRoomCond:BPGetMatchConditionCount(paramStr)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local apartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  local lastRoleID = apartmentRoomProxy:GetLastRoleID()
  local result = 0
  LogInfo("EnterCharacterRoomCond ", "BPGetMatchConditionCount CurrentRoleId" .. " : " .. tostring(CurrentRoleId) .. " lastRoleID :" .. tostring(lastRoleID))
  if CurrentRoleId ~= lastRoleID then
    result = 1
  end
  return result
end
return EnterCharacterRoomCond
