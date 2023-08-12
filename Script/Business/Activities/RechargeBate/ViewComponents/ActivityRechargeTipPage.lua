local ActivityRechargeTipPage = class("ActivityRechargeTipPage", PureMVC.ViewComponentPage)
local Valid
function ActivityRechargeTipPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function ActivityRechargeTipPage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.OnClickReturn, self)
  Valid = self.TextBlock_OpenTime and self.TextBlock_OpenTime:SetText(luaOpenData)
end
function ActivityRechargeTipPage:OnClose()
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.OnClickReturn, self)
end
function ActivityRechargeTipPage:OnClickReturn()
  ViewMgr:ClosePage(self)
end
return ActivityRechargeTipPage
