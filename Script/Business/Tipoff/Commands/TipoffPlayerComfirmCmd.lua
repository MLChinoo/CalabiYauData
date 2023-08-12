local TipoffPlayerComfirmCmd = class("TipoffPlayerComfirmCmd", PureMVC.Command)
function TipoffPlayerComfirmCmd:Execute(notification)
  if notification:GetName() ~= NotificationDefines.TipoffPlayer.TipoffPlayerComfirmCmd then
    return
  end
  local proxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if proxy then
    local bSuccess, retCode = self:CheckFilter(proxy)
    if not bSuccess then
      LogDebug("TipoffPlayerComfirmCmd", "retCode: " .. retCode)
      return
    end
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.ReqTipoffPlayerInfoCmd)
  end
end
function TipoffPlayerComfirmCmd:CheckFilter(proxy)
  if proxy then
    local content = proxy:GetTipoffContent()
    if utf8.len(content) > proxy:GetMaxTipoffContentNum() then
      ShowCommonTip(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_ContentOverflow"))
      return false, "Tipoff_ContentOverflow"
    end
    if proxy:GetTipoffReasonSelectedNum() <= 0 then
      ShowCommonTip(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_BehaviorInValid"))
      return false, "Tipoff_BehaviorInValid"
    end
  end
  return true, ""
end
return TipoffPlayerComfirmCmd
