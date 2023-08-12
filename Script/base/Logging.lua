local _G = _G
_G.print = _G.UEPrint
local logLevel = {}
logLevel.fatal = 1
logLevel.Error = 2
logLevel.Warning = 3
logLevel.Display = 4
logLevel.Log = 5
logLevel.Verbose = 6
logLevel.VeryVerbose = 7
logLevel.All = 8
_G.LogLevel = logLevel.All
local WithoutLogging = function(log_level)
  if _G.NO_LOGGING then
    return true
  end
  if log_level > _G.LogLevel then
    return true
  end
end
local GetLogContent = function(tag, format, ...)
  if tag and not format then
    return tag
  else
    return string.format("[%s] " .. format, tag, ...)
  end
end
function _G.DisableLog()
  _G.NO_LOGGING = true
  LogInfo("lualog", "disable lua log")
end
function _G.SetLogLevel(level)
  LogInfo("lualog", "Set Log %s to %s", tostring(_G.LogLevel), tostring(level))
  _G.LogLevel = level
end
function _G.LogDebug(tag, format, ...)
  if WithoutLogging(logLevel.Verbose) then
    return
  end
  local log = GetLogContent(tag, format, ...)
  UE4.UPMLuaBridgeBlueprintLibrary.Lua_UELOG(logLevel.Display, log)
end
function _G.LogInfo(tag, format, ...)
  if WithoutLogging(logLevel.Log) then
    return
  end
  local log = GetLogContent(tag, format, ...)
  UE4.UPMLuaBridgeBlueprintLibrary.Lua_UELOG(logLevel.Log, log)
end
function _G.LogWarn(tag, format, ...)
  if WithoutLogging(logLevel.Warning) then
    return
  end
  local log = GetLogContent(tag, format, ...)
  UE4.UPMLuaBridgeBlueprintLibrary.Lua_UELOG(logLevel.Warning, log)
end
function _G.LogError(tag, format, ...)
  if WithoutLogging(logLevel.Error) then
    return
  end
  local log = GetLogContent(tag, format, ...)
  if debug then
    log = log .. debug.traceback([[

Lua Error:]])
  end
  UE4.UPMLuaBridgeBlueprintLibrary.Lua_UELOG(logLevel.Error, log)
end
function _G.LogErrorP(tag, format, ...)
  if WithoutLogging(logLevel.Error) then
    return
  end
  local log = GetLogContent(tag, format, ...)
  UE4.UPMLuaBridgeBlueprintLibrary.Lua_UELOG(logLevel.All, log)
end
