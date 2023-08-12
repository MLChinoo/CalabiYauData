local DeleteFriendCmd = class("DeleteFriendCmd", PureMVC.Command)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function DeleteFriendCmd:Execute(notification)
  local sendData = {}
  sendData.playerId = notification:GetBody().playerId
  sendData.friendType = notification:GetBody().friendType
  sendData.nick = notification:GetBody().nick
  LogInfo("DeleteFriendCmd playerId:", sendData.playerId)
  LogInfo("DeleteFriendCmd friendType:", sendData.friendType)
  LogInfo("DeleteFriendCmd nick:", sendData.nick)
  if sendData.friendType == FriendEnum.FriendType.Friend then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendDeleteConfirmPage)
    GameFacade:SendNotification(NotificationDefines.FriendCmdType.SetDeleteInfo, sendData)
  else
    GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):ReqFriendDel(sendData.playerId, sendData.friendType)
  end
end
return DeleteFriendCmd
