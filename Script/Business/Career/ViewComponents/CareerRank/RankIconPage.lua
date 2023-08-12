local RankIconPage = class("RankIconPage", PureMVC.ViewComponentPage)
function RankIconPage:ListNeededMediators()
  return {}
end
function RankIconPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("RankIconPage", "Lua implement OnOpen")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, false)
  self.parentPage = luaOpenData
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Add(self.OnClickReturn, self)
  end
end
function RankIconPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, true)
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Remove(self.OnClickReturn, self)
  end
end
function RankIconPage:LuaHandleKeyEvent(key, inputEvent)
  if self.Button_Return then
    return self.Button_Return:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function RankIconPage:OnClickReturn()
  ViewMgr:ClosePage(self)
end
return RankIconPage
