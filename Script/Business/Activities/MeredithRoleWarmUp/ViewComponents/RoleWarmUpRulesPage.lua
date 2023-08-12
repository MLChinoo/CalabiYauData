local RoleWarmUpRulesPage = class("RoleWarmUpRulesPage", PureMVC.ViewComponentPage)
function RoleWarmUpRulesPage:ListNeededMediators()
  return {}
end
function RoleWarmUpRulesPage:InitializeLuaEvent()
end
function RoleWarmUpRulesPage:OnOpen(luaOpenData, nativeOpenData)
  self.Button_Blank.OnClicked:Add(self, self.OnClickCloseBtn)
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.EntryRewardRulesPage, 0)
  end
end
function RoleWarmUpRulesPage:OnClose()
  self.Button_Blank.OnClicked:Remove(self, self.OnClickCloseBtn)
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.QuitRewardRulesPage, 0)
  end
end
function RoleWarmUpRulesPage:OnClickCloseBtn()
  LogDebug("RoleWarmUpRulesPage", "OnClickCloseBtn")
  ViewMgr:ClosePage(self)
end
function RoleWarmUpRulesPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickCloseBtn()
    end
    return true
  else
    return false
  end
end
return RoleWarmUpRulesPage
