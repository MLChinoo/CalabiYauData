local DelegateMgr = {}
local GetBridgeObject = _G.GetBridgeObject
function DelegateMgr:BindDelegate(dynamicDelegate, obj, funcName)
  local bridgeObj = GetBridgeObject()
  if bridgeObj then
    return bridgeObj:BindDelegate(dynamicDelegate, obj, funcName)
  end
end
function DelegateMgr:UnbindDelegate(dynamicDelegate, handle)
  local bridgeObj = GetBridgeObject()
  if bridgeObj then
    return bridgeObj:UnbindDelegate(dynamicDelegate, handle)
  end
end
function DelegateMgr:AddDelegate(dynamicMulticastDelegate, obj, funcName)
  local bridgeObj = GetBridgeObject()
  if bridgeObj then
    return bridgeObj:AddDelegate(dynamicMulticastDelegate, obj, funcName)
  end
end
function DelegateMgr:RemoveDelegate(dynamicMulticastDelegate, handle)
  local bridgeObj = GetBridgeObject()
  if bridgeObj then
    return bridgeObj:RemoveDelegate(dynamicMulticastDelegate, handle)
  end
end
function DelegateMgr:ClearDelegate(dynamicMulticastDelegate)
  local bridgeObj = GetBridgeObject()
  if bridgeObj then
    return bridgeObj:ClearDelegate(dynamicMulticastDelegate)
  end
end
return DelegateMgr
