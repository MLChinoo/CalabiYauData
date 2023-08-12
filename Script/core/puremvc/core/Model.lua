local PureMVCConfig = puremvc_require("PureMVCConfig")
local Model = class("Model")
Model.instanceMap = {}
function Model:ctor(key)
  if Model.instanceMap[key] then
    PureMVC_Log(PureMVCConfig.LogLevel_Error, "Model instance for this Multiton key already constructed!")
  end
  self.multitonKey = key
  Model.instanceMap[key] = self
  self.proxyMap = {}
  self:InitializeModel()
end
function Model:InitializeModel()
end
function Model.GetInstance(key)
  if nil == key then
    return nil
  end
  if nil == Model.instanceMap[key] then
    return Model.new(key)
  else
    return Model.instanceMap[key]
  end
end
function Model:RegisterProxy(proxy)
  proxy:InitializeNotifier(self.multitonKey)
  self.proxyMap[proxy:GetProxyName()] = proxy
  local ret, errmsg = pcall(proxy.OnRegister, proxy)
  if not ret then
    LogError("puremvc", "regist proxy [%s] error %s", proxy:GetProxyName(), tostring(errmsg))
  end
end
function Model:RetrieveProxy(proxyName)
  return self.proxyMap[proxyName]
end
function Model:HasProxy(proxyName)
  return self.proxyMap[proxyName] ~= nil
end
function Model:RemoveProxy(proxyName)
  local proxy = self.proxyMap[proxyName]
  if nil ~= proxy then
    self.proxyMap[proxyName] = nil
    proxy:OnRemove()
  end
  return proxy
end
function Model.RemoveModel(key)
  Model.instanceMap[key] = nil
end
return Model
