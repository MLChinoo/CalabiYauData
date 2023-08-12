require("UnLua")
local OnLuaBridgePostInit = _G.OnLuaBridgePostInit
local TickGlobal = _G.TickGlobal
local LogDebug = _G.LogDebug
local LogError = _G.LogError
local LuaBridge = Class()
local autoRegistDelegates = {}
local Delegates = {}
local PrintDelegatesNum = function()
  local count = 0
  for key, value in pairs(Delegates) do
    count = count + value
  end
  UE4.UKismetSystemLibrary.PrintString(LuaGetWorld(), "//DelegateMgr-当前委托数量 = " .. count, true, false, UE4.FLinearColor(0, 1, 0, 1), 5)
end
local CheckDelegate = function(delegate, num)
  if Delegates[delegate] and num > 0 then
    LogDebug("ShowLuaCallDelegateCnt", "//委托重复绑定！！！")
    return
  end
  if not Delegates[delegate] and num < 0 then
    LogDebug("ShowLuaCallDelegateCnt", "//委托已经解绑！！！")
    return
  end
  if Delegates[delegate] then
    Delegates[delegate] = nil
    LogDebug("ShowLuaCallDelegateCnt", "//委托 -1")
  else
    Delegates[delegate] = num
    LogDebug("ShowLuaCallDelegateCnt", "//委托 +1")
  end
end
local CheckMulticastDelegate = function(delegate, num)
  if not Delegates[delegate] and num <= 0 then
    LogDebug("lua", "//多播委托已经解绑！！！")
    return
  end
  if Delegates[delegate] then
    Delegates[delegate] = Delegates[delegate] + num
  else
    Delegates[delegate] = num
  end
  if 0 == num or 0 == Delegates[delegate] then
    Delegates[delegate] = nil
  end
  local str = 0 == num and "清零" or string.format("%+d", num)
  LogDebug("ShowLuaCallDelegateCnt", "//多播委托 %s", str)
end
function LuaBridge:ShowDelegates()
  PrintDelegatesNum()
end
function LuaBridge:Initialize()
  OnLuaBridgePostInit(self)
end
local GetBindFuncName = function(ins, funcKey)
  return ins.__cname .. "_" .. funcKey
end
local ReplaceUpvalue = function(func, ins)
  local idx = 1
  repeat
    local name, value = debug.getupvalue(func, idx)
    if ins.__cname == value.__cname then
      LogDebug("lua", "auto replace binded func upvalue %s clazz to %s", tostring(value), tostring(ins))
      debug.setupvalue(func, idx, ins)
    end
    idx = idx + 1
  until nil == value
end
function LuaBridge:TickLuaBridge(deltaTime)
  TickGlobal(deltaTime)
end
function LuaBridge:OnAutoRegist()
  LogDebug("lua", "LuaBridge:OnAutoRegiste count %d ", #autoRegistDelegates)
  for _, v in ipairs(autoRegistDelegates) do
    LogDebug("lua", "auto bind delegate %s , func %s", tostring(v[1]), v[2])
    local func = self[v[2]]
    if nil == func then
      LogError("lua", "%s not registed", v[2])
      break
    end
    v[1]:Add(self, self[v[2]])
  end
end
function LuaBridge:SetupDelegates(event_proxy_path)
  LogDebug("lua", "Setup delegate for %s", event_proxy_path)
  local clazz = require(event_proxy_path)
  LogDebug("lua", "%s return class with name %s", event_proxy_path, clazz.__cname)
  local config_arr = clazz.SetUpDelegates()
  for _, v in ipairs(config_arr) do
    local tmp_func_name = GetBindFuncName(clazz, v[2])
    local tmp_func = function(_, ...)
      clazz[v[2]](clazz, ...)
    end
    LuaBridge[tmp_func_name] = tmp_func
    local bind = v[3]
    if bind then
      LogDebug("lua", "%s its bind function is %s", tostring(v[1]), tostring(v[1].Add))
      table.insert(autoRegistDelegates, {
        v[1],
        tmp_func_name
      })
    end
  end
  LogDebug("lua", "collect %d needed auto bind functions", #autoRegistDelegates)
end
function LuaBridge:OnUnBindGlobalDelegate()
end
function LuaBridge:OnBindBattleWorldDelegate()
end
function LuaBridge:GetTempName(prefix)
  if not self.idx then
    self.idx = 0
  end
  self.idx = self.idx + 1
  return (prefix or "") .. self.idx
end
function LuaBridge:CreateWrapDelegateFunc(obj, funcName)
  local registName, func, contextObj
  if type(obj) == "function" then
    registName = string.format("%s_%s", obj.__cname or self:GetTempName("o"), funcName or "0")
    func = obj
  elseif type(obj) == "table" then
    if type(funcName) == "function" then
      func = funcName
      registName = string.format("%s_%s", obj.__cname or self:GetTempName("o"), self:GetTempName("f"))
    else
      local f = obj[funcName]
      if type(f) == "function" then
        func = f
        registName = string.format("%s_%s", obj.__cname or self:GetTempName("o"), funcName)
      end
    end
    contextObj = obj
  end
  if not func or not registName then
    LogError("LuaBridge", "can't wrap for delegate with params %s.%s ", tostring(obj), tostring(funcName))
    return
  end
  local newFunc = function(_, ...)
    if contextObj then
      func(contextObj, ...)
    else
      func(...)
    end
  end
  return newFunc
end
function LuaBridge:BindDelegate(dynamicDelegate, obj, funcName)
  local handleFunc = self:CreateWrapDelegateFunc(obj, funcName)
  dynamicDelegate:Bind(self, handleFunc)
  if WITH_EDITOR then
    CheckDelegate(dynamicDelegate, 1)
  end
  return handleFunc
end
function LuaBridge:UnbindDelegate(dynamicDelegate, handle)
  dynamicDelegate:Unbind()
  if WITH_EDITOR then
    CheckDelegate(dynamicDelegate, -1)
  end
end
function LuaBridge:AddDelegate(dynamicMulticastDelegate, obj, funcName)
  local handleFunc = self:CreateWrapDelegateFunc(obj, funcName)
  dynamicMulticastDelegate:Add(self, handleFunc)
  if WITH_EDITOR then
    CheckMulticastDelegate(dynamicMulticastDelegate, 1)
  end
  return handleFunc
end
function LuaBridge:RemoveDelegate(dynamicMulticastDelegate, handle)
  dynamicMulticastDelegate:Remove(self, handle)
  if WITH_EDITOR then
    CheckMulticastDelegate(dynamicMulticastDelegate, -1)
  end
end
function LuaBridge:ClearDelegate(dynamicMulticastDelegate)
  dynamicMulticastDelegate:Clear()
  if WITH_EDITOR then
    CheckMulticastDelegate(dynamicMulticastDelegate, 0)
  end
end
return LuaBridge
