local GoodsProxy = class("GoodsProxy", PureMVC.Proxy)
local GoodsCfg
function GoodsProxy:GetGoodsCfg(GoodsId)
  return GoodsCfg[tostring(GoodsId)]
end
function GoodsProxy:GetAnyGoodsOwned(GoodsId)
  if not GoodsId or not GoodsCfg[tostring(GoodsId)] then
    return false
  end
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  for i = 1, GoodsCfg[tostring(GoodsId)].Items:Length() do
    if not ItemsProxy:GetAnyItemOwned(GoodsCfg[tostring(GoodsId)].Items:Get(i).ItemId) then
      return false
    end
  end
  if GoodsCfg[tostring(GoodsId)].Items:Length() > 0 then
    return true
  else
    return false
  end
end
function GoodsProxy:ctor(proxyName, data)
  GoodsProxy.super.ctor(self, proxyName, data)
end
function GoodsProxy:OnRegister()
  GoodsProxy.super.OnRegister(self)
  self:InitTableCfg()
end
function GoodsProxy:InitTableCfg()
  self:InitGoodsTableCfg()
end
function GoodsProxy:InitGoodsTableCfg()
  local arrRows = ConfigMgr:GetGoodsTableRows()
  if arrRows then
    GoodsCfg = arrRows:ToLuaTable()
  end
end
return GoodsProxy
