local GameUtil = {}
function GameUtil:IsBuildShipingOrTest()
  return BUILD_SHIPPING or BUILD_TEST
end
function GameUtil:IsWindowslatform()
  return PLATFORM_WINDOWS
end
function GameUtil:IsAndroidPlatform()
  return PLATFORM_ANDROID
end
function GameUtil:IsIOSPlatform()
  return PLATFORM_IOS
end
function GameUtil:IsNoLogging()
  return NO_LOGGING
end
return GameUtil
