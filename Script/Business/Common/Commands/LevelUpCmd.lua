local LevelUpCmd = class("LevelUpCmd", PureMVC.Command)
function LevelUpCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerAttrChanged then
    local attrIdsChanged = notification:GetBody()
    if not table.index(attrIdsChanged, GlobalEnumDefine.PlayerAttributeType.emLevel) then
      return
    end
    local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
    if not GameState then
      LogError("Get GameState Error")
      return
    end
    if not GameState.GetModeType or GameState:GetModeType() == UE4.EPMGameModeType.FrontEnd then
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.UpgradePage)
      local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
      local lv = playerAttrProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
      if lv > 1 then
        ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.UpgradePage, nil, lv)
      end
    end
  end
end
return LevelUpCmd
