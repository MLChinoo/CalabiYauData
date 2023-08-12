local TipoffBehaviorChooseCmd = class("TipoffBehaviorChooseCmd", PureMVC.Command)
function TipoffBehaviorChooseCmd:Execute(notification)
  if notification:GetName() ~= NotificationDefines.TipoffPlayer.TipoffBehaviorChooseCmd then
    return
  end
  local proxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if proxy then
    local bCancel, errCode = self:CheckFilter(notification, proxy)
    LogDebug("TipoffBehaviorChooseCmd", "ErrCode:", errCode)
    if bCancel then
      if "INVALID_DATA" == errCode then
      elseif "TIPOFFBEHAVIOR_MAX" == errCode then
        GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffBehaviorChooseMax, notification:GetBody())
      end
      return
    end
    proxy:UpdateTipBehaviorData(notification:GetBody())
  end
end
function TipoffBehaviorChooseCmd:CheckFilter(notification, proxy)
  local data = notification:GetBody()
  if not data then
    return true, "INVALID_DATA"
  end
  local bChoose = data.bChoose
  local TipoffReasonType = data.ReasonType
  if bChoose and not proxy:IsTipoffReasonDataExist(TipoffReasonType) and proxy:GetTipoffReasonSelectedNum() >= proxy:GetMaxTipoffReasonNum() then
    return true, "TIPOFFBEHAVIOR_MAX"
  else
  end
  return false
end
return TipoffBehaviorChooseCmd
