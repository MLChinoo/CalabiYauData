local PureMVCConfig = {}
PureMVCConfig.LogTAG = "PureMVC"
PureMVCConfig.LogLevel_Debug = 1
PureMVCConfig.LogLevel_Info = 2
PureMVCConfig.LogLevel_Warn = 3
PureMVCConfig.LogLevel_Error = 4
PureMVCConfig.logFunc = nil
function PureMVCConfig.SetLogFunc(func)
  PureMVCConfig.logFunc = func
end
local PureMVC_Log = function(logLevel, format, ...)
  if PureMVCConfig.logFunc then
    PureMVCConfig.logFunc(PureMVCConfig.LogTAG, logLevel, format, ...)
  end
end
_G.PureMVC_Log = PureMVC_Log
return PureMVCConfig
