local RankIntroPage = class("RankIntroPage", PureMVC.ViewComponentPage)
function RankIntroPage:ListNeededMediators()
  return {}
end
function RankIntroPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("RankIntroPage", "Lua implement OnOpen")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, false)
  self.parentPage = luaOpenData
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Add(self.ClosePage, self)
  end
  if self.Button_Return_MB then
    self.Button_Return_MB.OnClickEvent:Add(self, self.ClosePage)
  end
end
function RankIntroPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, true)
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Remove(self.ClosePage, self)
  end
end
function RankIntroPage:ClosePage()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:PopPage(self, UIPageNameDefine.CareerRankIntro)
  else
    ViewMgr:ClosePage(self)
  end
end
function RankIntroPage:LuaHandleKeyEvent(key, inputEvent)
  if self.Button_Return then
    return self.Button_Return:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
return RankIntroPage
