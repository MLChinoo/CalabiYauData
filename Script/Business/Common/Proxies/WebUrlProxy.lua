local WebUrlProxy = class("WebUrlProxy", PureMVC.Proxy)
local WebUrlMap = require("Business/Common/Proxies/WebUrlMap")
function WebUrlProxy:OnRegister()
  WebUrlProxy.super.OnRegister(self)
  local data = ConfigMgr:GetWebUrlTableRow()
  local configTbl = data:ToLuaTable()
  local mapWebUrl = {}
  local arr = {}
  for _, v in pairs(configTbl) do
    mapWebUrl[v.Name] = v
  end
  self.mapWebUrl = mapWebUrl
end
function WebUrlProxy:GetWebUrlByIndex(index)
  local name = WebUrlMap.Enum_ReverseWebUrl[index]
  if self.mapWebUrl and name and self.mapWebUrl[name] then
    return self.mapWebUrl[name].url
  end
end
function WebUrlProxy:GetWebUrlMap()
  return WebUrlMap
end
function WebUrlProxy:OnRemove()
  WebUrlProxy.super.OnRemove(self)
  self.mapWebUrl = {}
end
return WebUrlProxy
