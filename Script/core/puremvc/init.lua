local puremvc_load_path = "core/puremvc/"
local puremvc_require = function(module)
  return require(puremvc_load_path .. module)
end
local PureMVC = {}
_G.puremvc_require = puremvc_require
_G.PureMVC = PureMVC
PureMVC.Facade = puremvc_require("patterns/Facade")
PureMVC.Mediator = puremvc_require("patterns/Mediator")
PureMVC.Proxy = puremvc_require("patterns/Proxy")
PureMVC.Command = puremvc_require("patterns/Command")
PureMVC.MacroCommand = puremvc_require("patterns/MacroCommand")
PureMVC.Notifier = puremvc_require("patterns/Notifier")
PureMVC.Notification = puremvc_require("patterns/Notification")
PureMVC.Observer = puremvc_require("patterns/Observer")
PureMVC.config = puremvc_require("PureMVCConfig")
PureMVC.config.SetLogFunc(function(tag, level, format, ...)
  if level == PureMVC.config.LogLevel_Debug then
    LogDebug(tag, format, ...)
  elseif level == PureMVC.config.LogLevel_Info then
    LogInfo(tag, format, ...)
  elseif level == PureMVC.config.LogLevel_Warn then
    LogWarn(tag, format, ...)
  elseif level == PureMVC.config.LogLevel_Error then
    LogError(tag, format, ...)
  end
end)
PureMVC.ViewComponent = nil
return PureMVC
