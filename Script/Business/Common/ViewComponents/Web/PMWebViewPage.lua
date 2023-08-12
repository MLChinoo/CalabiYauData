local PMWebViewPage = class("PMWebViewPage", PureMVC.ViewComponentPage)
function PMWebViewPage:ListNeededMediators()
  return {}
end
function PMWebViewPage:InitializeLuaEvent()
  self.CloseWebBtn.OnClicked:Add(self, self.OnClickClose)
  self.WBP_CommonHotKey_PC.OnClickEvent:Add(self, self.OnClickClose)
end
function PMWebViewPage:OnOpen(luaOpenData, nativeOpenData)
  self.url = luaOpenData.url or ""
  if self.url ~= "" then
    self.WebBrowser:LoadURL(self.url)
  end
end
function PMWebViewPage:OnClose()
end
function PMWebViewPage:OnClickClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.WebViewPage)
end
function PMWebViewPage:LuaHandleKeyEvent(key, inputEvent)
  return self.WBP_CommonHotKey_PC:MonitorKeyDown(key, inputEvent)
end
return PMWebViewPage
