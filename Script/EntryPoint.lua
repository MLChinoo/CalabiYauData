require("UnLua")
if UE4.UAkGameplayStatics.IsEditor() then
  require("core/debug/LuaPanda/LuaPanda").start("127.0.0.1", 8818)
end
print("[LuaSystem]begin require default files")
require("base/Logging")
LogInfo("UEMacro", "BUILD_SHIPPING=%s BUILD_TEST=%s BUILD_DEVELOPMENT=%s BUILD_DEBUG=%s PLATFORM_WINDOWS=%s PLATFORM_ANDROID=%s PLATFORM_IOS=%s", BUILD_SHIPPING, BUILD_TEST, BUILD_DEVELOPMENT, BUILD_DEBUG, PLATFORM_WINDOWS, PLATFORM_ANDROID, PLATFORM_IOS)
require("core/class")
require("core/table")
require("core/FuncSlot")
require("core/string")
require("core/math")
require("core/puremvc/init")
require("base/global/GlobalMgr")
require("base/config/ConfigMgr")
EditMode_Print_Proxy_lifecycle = true
local protobufMgr = require("base/global/ProtobufMgr")
protobufMgr:LoadAllPb()
