local OpenFriendApplyCmd = class("OpenFriendApplyCmd", PureMVC.Command)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function OpenFriendApplyCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.OpenFriendApplyCmd then
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.FriendList)
    else
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendList, false, FriendEnum.FriendType.Apply)
    end
  end
end
return OpenFriendApplyCmd
