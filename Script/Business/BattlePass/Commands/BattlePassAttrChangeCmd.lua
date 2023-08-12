local BattlePassAttrChangeCmd = class("BattlePassAttrChangeCmd", PureMVC.Command)
function BattlePassAttrChangeCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerAttrChanged then
    local body = notification:GetBody()
    if body then
      local exploreChange = table.containsValue(body, GlobalEnumDefine.PlayerAttributeType.emExplore)
      if exploreChange then
        local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
        if bpProxy then
          bpProxy:CalculatePregressRedDot()
          bpProxy:CalculateClueRedDot()
        end
      end
    end
  end
end
return BattlePassAttrChangeCmd
