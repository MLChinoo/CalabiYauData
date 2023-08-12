local EpicSkinCond = {}
function EpicSkinCond:BPGetMatchConditionCount(paramStr)
  LogDebug("EpicSkinCond", "default EpicSkinCond is false")
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  if ConditionProxy:GetEpicSkinFlag() then
    LogDebug("EpicSkinCond", "EpicSkinCond is true")
    return 1
  end
  LogDebug("EpicSkinCond", "EpicSkinCond is false")
  return 0
end
function EpicSkinCond:Update()
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  ConditionProxy:SetEpicSkinFlag(false)
  LogDebug("EpicSkinCond", "EpicSkinCond update false")
end
return EpicSkinCond
