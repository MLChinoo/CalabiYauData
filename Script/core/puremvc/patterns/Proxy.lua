local Notifier = puremvc_require("patterns/Notifier")
local Proxy = class("Proxy", Notifier)
Proxy.NAME = "Proxy"
function Proxy:ctor(proxyName, data)
  if EditMode_Print_Proxy_lifecycle then
  end
  Proxy.super.ctor(self)
  self.proxyName = proxyName or Proxy.NAME
  if nil ~= data then
    self:SetData(data)
  end
end
function Proxy:GetProxyName()
  return self.proxyName
end
function Proxy:GetData()
  return self.data
end
function Proxy:SetData(value)
  self.data = value
end
function Proxy:OnRegister()
end
function Proxy:OnRemove()
end
return Proxy
