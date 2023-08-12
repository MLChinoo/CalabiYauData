local BuyTicketCmd = class("BuyTicketCmd", PureMVC.Command)
function BuyTicketCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Lottery.BuyTicketCmd then
    local ticketId = notification:GetBody().ticketId
    local itemCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemCfg(tostring(ticketId))
    if itemCfg and itemCfg.GainParam1:Length() > 0 then
      local storeId = itemCfg.GainParam1:Get(1)
      local data = {
        StoreId = storeId,
        OriginalItemNum = notification:GetBody().originalItemNum,
        PageName = UIPageNameDefine.LotteryEntryPage
      }
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.BuyItemPage, false, data)
    end
  end
end
return BuyTicketCmd
