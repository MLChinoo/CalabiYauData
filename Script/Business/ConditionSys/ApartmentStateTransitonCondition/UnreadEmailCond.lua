local UnreadEmailCond = {}
function UnreadEmailCond:BPGetMatchConditionCount(paramStr)
  local KaMailProxy = GameFacade:RetrieveProxy(ProxyNames.KaMailProxy)
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local unreadMailCount = KaMailProxy:GetCurrentUnReadMailNum()
  LogInfo("UnreadEmailCond", "unread count " .. tostring(unreadMailCount))
  if unreadMailCount > 0 then
    if ConditionProxy.initShowEmailFlag == true then
      LogInfo("ConditionProxy initShowEmailFlag", "true")
      return 1
    end
    if ConditionProxy.newEmailFlag then
      LogInfo("ConditionProxy initShowEmailFlag", "true")
      return 1
    end
  end
  return 0
end
function UnreadEmailCond:Update()
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  if ConditionProxy.initShowEmailFlag == true then
    ConditionProxy.initShowEmailFlag = false
  end
  if ConditionProxy.newEmailFlag then
    ConditionProxy.newEmailFlag = false
  end
end
return UnreadEmailCond
