local TipoffCategoryChooseCmd = class("TipoffCategoryChooseCmd", PureMVC.Command)
function TipoffCategoryChooseCmd:Execute(notification)
  LogDebug("TipoffCategoryChooseCmd", "TipoffCategoryChooseCmd Execute .")
  if notification:GetName() ~= NotificationDefines.TipoffPlayer.TipoffCategoryChooseCmd then
    return
  end
  local data = notification:GetBody()
  if not data then
    return
  end
  local Proxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if Proxy then
    Proxy:UpdateCurCategoryType(data.CategoryType)
  end
  LogDebug("TipoffCategoryChooseCmd", "TipoffCategoryChooseCmd Execute Finish .")
end
return TipoffCategoryChooseCmd
