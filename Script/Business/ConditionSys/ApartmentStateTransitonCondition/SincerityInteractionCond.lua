local SincerityInteractionCond = {}
function SincerityInteractionCond:BPGetMatchConditionCount(paramStr)
  local buttonStatus = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy):GetClickedJumpButtonStatus()
  if true == buttonStatus then
    LogDebug("SincerityInteractionCond:BPGetMatchConditionCount", "Condition is true")
    return 1
  end
  return 0
end
return SincerityInteractionCond
