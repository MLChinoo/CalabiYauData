local MapProxy = class("MapProxy", PureMVC.Proxy)
local mapCfgTable = {}
function MapProxy:OnRegister()
  MapProxy.super.OnRegister(self)
  mapCfgTable = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
end
function MapProxy:GetMapCfg(mapId)
  return mapCfgTable[tostring(mapId)]
end
function MapProxy:GetMapType(mapId)
  for key, value in pairs(mapCfgTable) do
    if value and value.Id == mapId then
      return value.Type
    end
  end
  return nil
end
return MapProxy
