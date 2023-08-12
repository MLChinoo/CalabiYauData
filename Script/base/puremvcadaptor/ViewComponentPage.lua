local ViewComponentPanel = require("base/puremvcadaptor/ViewComponentPanel")
local ViewComponentPage = class("ViewComponentPage", ViewComponentPanel)
function ViewComponentPage:OnOpen(luaOpenData, nativeOpenData)
end
function ViewComponentPage:OnShow(luaOpenData, nativeOpenData)
end
function ViewComponentPage:OnHide()
end
function ViewComponentPage:OnClose()
end
function ViewComponentPage:LuaHandleKeyEvent(key, inputEvent)
  return false
end
function ViewComponentPage:NotifyMediatorsPreOpenEvent(...)
  if not self.mediators then
    LogDebug("ViewComponentPage", self.__cname .. "--self.mediators = nil")
    return
  end
  for _, v in ipairs(self.mediators) do
    if v.OnViewComponentPagePreOpen then
      v:OnViewComponentPagePreOpen(...)
    end
  end
end
function ViewComponentPage:NotifyMediatorsPostOpenEvent(...)
  if not self.mediators then
    LogDebug("ViewComponentPage", self.__cname .. "--self.mediators = nil")
    return
  end
  for _, v in ipairs(self.mediators) do
    if v.OnViewComponentPagePostOpen then
      v:OnViewComponentPagePostOpen(...)
    end
  end
end
function ViewComponentPage:GetOpenData()
  local openData = self:NativeGetOpenData()
  LogDebug("ViewComponentPage", "NativeGetOpenData Result %s", tostring(openData))
  if not self.luaData and openData and openData.LuaOpenDataRef then
    self.luaData = UE4.LuaBridge.LuaGetRefObject(openData.LuaOpenDataRef)
  end
  return self.luaData, openData
end
function ViewComponentPage:OnLuaOpen()
  LogDebug("ViewComponentPage", "OnLuaOpen")
  local luaData, originOpenData = self:GetOpenData()
  self:NotifyMediatorsPreOpenEvent(luaData, originOpenData)
  self:OnOpen(luaData, originOpenData)
  self:NotifyMediatorsPostOpenEvent(luaData, originOpenData)
end
function ViewComponentPage:OnLuaShow()
  LogDebug("ViewComponentPage", "OnLuaShow")
  local luaData, originOpenData = self:GetOpenData()
  self:OnShow(luaData, originOpenData)
end
function ViewComponentPage:OnLuaHide()
  LogDebug("ViewComponentPage", "OnLuaHide")
  self:OnHide()
end
function ViewComponentPage:OnLuaClose()
  LogDebug("ViewComponentPage", "OnLuaClose")
  self:OnClose()
end
return ViewComponentPage
