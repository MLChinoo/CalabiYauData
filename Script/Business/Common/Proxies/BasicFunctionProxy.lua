local BasicFunctionProxy = class("BasicFunctionProxy", PureMVC.Proxy)
local functionCfg = {}
local parameterCfg = {}
local functionMobileCfg = {}
local SHARE_ID = "8401"
function BasicFunctionProxy:InitTableCfg()
  self:InitFunction()
  self:InitParameter()
  self:InitFunctionMobile()
end
function BasicFunctionProxy:InitFunction()
  local arrRows = ConfigMgr:GetFunctionUnlockTableRows()
  if arrRows then
    functionCfg = arrRows:ToLuaTable()
  end
end
function BasicFunctionProxy:InitParameter()
  local arrRows = ConfigMgr:GetParameterTableRows()
  if arrRows then
    parameterCfg = arrRows:ToLuaTable()
  end
end
function BasicFunctionProxy:InitFunctionMobile()
  local arrRows = ConfigMgr:GetFunctionUnlockMobileTableRows()
  if arrRows then
    functionMobileCfg = arrRows:ToLuaTable()
  end
end
function BasicFunctionProxy:ctor(proxyName, data)
  BasicFunctionProxy.super.ctor(self, proxyName, data)
end
function BasicFunctionProxy:OnRegister()
  BasicFunctionProxy.super.OnRegister(self)
  self:InitTableCfg()
end
function BasicFunctionProxy:GetFunctionById(functionId)
  return functionCfg[tostring(functionId)]
end
function BasicFunctionProxy:GetParameterIntValue(inParameterId)
  local value = parameterCfg[tostring(inParameterId)]
  local intValue = 0
  if value then
    intValue = tonumber(value.ParaValue)
  end
  return intValue
end
function BasicFunctionProxy:GetFunctionMobileById(functionId)
  return functionMobileCfg[tostring(functionId)]
end
function BasicFunctionProxy:IsShareOpen()
  return 1 == self:GetParameterIntValue(SHARE_ID)
end
return BasicFunctionProxy
