local _G = _G
local PM_VERSION = "1.0.1"
local pb = require("pb")
local LogDebug = _G.LogDebug
local LogError = _G.LogError
local PureMVC = _G.PureMVC
local FuncSlot = _G.FuncSlot
local GameFacade = require("business/GameFacade")
_G.GameFacade = GameFacade
PureMVC.ViewComponentPage = require("base/puremvcadaptor/ViewComponentPage")
PureMVC.ViewComponentPanel = require("base/puremvcadaptor/ViewComponentPanel")
PureMVC.ModuleInit = require("base/puremvcadaptor/ModuleInit")
local SetLobbyServiceHandle = function(serviceHandle)
  LogDebug("ServiceHandle", "SetLobbyServiceHandle%s", tostring(serviceHandle))
  _G.g_lobbyServiceHandle = serviceHandle
end
local GetLobbyServiceHandle = function()
  return _G.g_lobbyServiceHandle
end
local DeCode = function(Pb_ncmd, Data)
  return pb.decode(Pb_ncmd, Data)
end
local SendRequest = function(cmdid, requestData, responseCmdid, responseFuncslot)
  if _G.g_lobbyServiceHandle then
    _G.g_lobbyServiceHandle:SendRequest(cmdid, requestData, responseCmdid, responseFuncslot)
  else
    LogError("GlobalMgr", "g_lobbyServiceHandle is nil")
  end
end
local LuaGetWorld = function()
  local g_LuaBridgeSubsystem = _G.g_LuaBridgeSubsystem
  return g_LuaBridgeSubsystem and g_LuaBridgeSubsystem:GetLuaDefaultWorld() or nil
end
local pairsByKeys = function(t, func)
  local tableKeys = {}
  for key, value in pairs(t) do
    table.insert(tableKeys, key)
  end
  table.sort(tableKeys, func)
  local index = 0
  local iter = function()
    index = index + 1
    if nil == tableKeys[index] then
      return nil
    else
      return tableKeys[index], t[tableKeys[index]]
    end
  end
  return iter
end
local g_tick_queue = {}
local AddToTickQueue = function(funcSlot)
  for _, v in ipairs(g_tick_queue) do
    if v == funcSlot then
      LogError("tick", "have added to tick queue %s", tostring(funcSlot))
      return
    end
  end
  table.insert(g_tick_queue, funcSlot)
end
local TickGlobal = function(deltaTime)
  for _, v in ipairs(g_tick_queue) do
    v(deltaTime)
  end
end
local GetGlobalDelegateManager = function()
  local g_LuaBridgeSubsystem = _G.g_LuaBridgeSubsystem
  if g_LuaBridgeSubsystem then
    return UE4.UPMLuaBridgeBlueprintLibrary.GetGlobalDelegateManager(g_LuaBridgeSubsystem)
  end
end
local GetGamePlayDelegateManager = function()
  local g_LuaBridgeSubsystem = _G.g_LuaBridgeSubsystem
  if g_LuaBridgeSubsystem then
    return UE4.UPMLuaBridgeBlueprintLibrary.GetGamePlayDelegateManager(g_LuaBridgeSubsystem)
  else
    LogError("LuaGlobalMgr", "LuaBridgeObject havent initailized")
  end
end
local OnLuaBridgePostInit = function(luaBridgeObject)
  _G.g_LuaBridgeObject = luaBridgeObject
  GameFacade:SetupGameProxy()
  GameFacade:Setup()
  LogDebug("OnLuaBridgePostInit", "Create Global GameFacade %s", tostring(GameFacade))
end
local GetBridgeObject = function()
  if not _G.g_LuaBridgeObject then
    LogError("DelegateMgr", "LuaBridgeObject havent initailized")
  end
  return _G.g_LuaBridgeObject
end
_G.GetBridgeObject = GetBridgeObject
local LuaEvent = require("core/event/LuaEvent")
require("business/NotificationDefines")
require("business/ProxyNames")
require("base/global/StringTablePath")
require("base/global/GlobalEnumDefine")
require("base/global/UIPageNameDefine")
_G.ViewMgr = require("base/global/ViewMgr")
_G.DelegateMgr = require("base/global/DelegateMgr")
_G.GameUtil = require("base/global/utils/GameUtil")
_G.ObjectUtil = require("base/global/utils/ObjectUtil")
_G.FunctionUtil = require("base/global/utils/FunctionUtil")
local tickHandle = LuaEvent.new()
local TimerMgrClazz = require("base/global/TimerMgr")
_G.TimerMgr = TimerMgrClazz.new(tickHandle)
local tickSlot = FuncSlot(function(...)
  tickHandle(...)
end)
AddToTickQueue(tickSlot)
require("base/global/PerfMgr")
local RedDotModuleDef = require("Business/RedDot/RedDotModuleDef")
_G.RedDotModuleDef = RedDotModuleDef
local RedDotTree = require("Business/RedDot/RedDotTree")
_G.RedDotTree = RedDotTree
local InitRedDot = function()
  RedDotModuleDef:Init()
  RedDotTree:Init()
end
_G.InitRedDot = InitRedDot
_G.Pb_ncmd_cs = require("LuaProto/LuaProtoPublicDef/ncmd_cs")
_G.Pb_ncmd_cs_dir = require("LuaProto/LuaProtoPublicDef/ncmd_cs_dir")
_G.Pb_ncmd_cs_lobby = require("LuaProto/LuaProtoPublicDef/ncmd_cs_lobby")
_G.Pb_ncmd_ds = require("LuaProto/LuaProtoPublicDef/ncmd_ds")
_G.Pb_err = require("LuaProto/LuaProtoPublicDef/err")
_G.Pb_proto_errcode = require("LuaProto/LuaProtoPublicDef/proto_errcode")
local TableToString = function(TableToPrint, MaxIntent)
  local HandlerdTable = {}
  local function ItretePrintTable(TP, Indent)
    Indent = Indent or 0
    if type(TP) ~= "table" then
      return tostring(TP)
    end
    if Indent > MaxIntent then
      return tostring(TP)
    end
    if HandlerdTable[TP] then
      return ""
    end
    HandlerdTable[TP] = true
    local StrToPrint = string.rep(" ", Indent) .. "{\r\n"
    Indent = Indent + 2
    for k, v in pairs(TP) do
      StrToPrint = StrToPrint .. string.rep(" ", Indent)
      if type(k) == "number" then
        StrToPrint = StrToPrint .. "[" .. k .. "] = "
      elseif type(k) == "string" then
        StrToPrint = StrToPrint .. k .. "= "
      else
        StrToPrint = StrToPrint .. tostring(k) .. " = "
      end
      if type(v) == "number" then
        StrToPrint = StrToPrint .. v .. ",\r\n"
      elseif type(v) == "string" then
        StrToPrint = StrToPrint .. "\"" .. v .. "\",\r\n"
      elseif type(v) == "table" then
        StrToPrint = StrToPrint .. tostring(v) .. ItretePrintTable(v, Indent + 2) .. ",\r\n"
      else
        StrToPrint = StrToPrint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    StrToPrint = StrToPrint .. string.rep(" ", Indent - 2) .. "}"
    return StrToPrint
  end
  if nil == MaxIntent then
    MaxIntent = 64
  end
  return ItretePrintTable(TableToPrint)
end
_G.pb = pb
_G.PM_VERSION = PM_VERSION
_G.LuaEvent = LuaEvent
_G.g_tick_queue = g_tick_queue
_G.SetLobbyServiceHandle = SetLobbyServiceHandle
_G.GetLobbyServiceHandle = GetLobbyServiceHandle
_G.DeCode = DeCode
_G.SendRequest = SendRequest
_G.LuaGetWorld = LuaGetWorld
_G.pairsByKeys = pairsByKeys
_G.AddToTickQueue = AddToTickQueue
_G.TickGlobal = TickGlobal
_G.GetGamePlayDelegateManager = GetGamePlayDelegateManager
_G.GetGlobalDelegateManager = GetGlobalDelegateManager
_G.OnLuaBridgePostInit = OnLuaBridgePostInit
_G.TableToString = TableToString
