local NtfRedDotSyncCmd = class("NtfRedDotSyncCmd", PureMVC.Command)
function NtfRedDotSyncCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.RedDot.NtfRedDotSyncCmd then
    GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):InitRedDot()
    GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):InitRedDot()
    GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):InitRedDot()
  end
end
return NtfRedDotSyncCmd
