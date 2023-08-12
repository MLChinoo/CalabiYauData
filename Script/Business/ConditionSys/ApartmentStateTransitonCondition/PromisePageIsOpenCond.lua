local PromisePageIsOpenCond = {}
function PromisePageIsOpenCond:BPGetMatchConditionCount(paramStr)
  local bShow = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy):GetPromisePageOpenState()
  if bShow then
    LogDebug("PromisePageIsOpenCond", "PromisePageIsOpenCond is 1")
    return 1
  end
  LogDebug("PromisePageIsOpenCond", "PromisePageIsOpenCond is 0")
  return 0
end
return PromisePageIsOpenCond
