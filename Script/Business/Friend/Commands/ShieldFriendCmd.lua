local ShieldFriendCmd = class("ShieldFriendCmd", PureMVC.Command)
function ShieldFriendCmd:Execute(notification)
  if not (notification:GetBody().playerId and notification:GetBody().playerId ~= "" and notification:GetBody().nick) or "" == notification:GetBody().nick then
    return
  end
  local sendData = {}
  sendData.playerId = notification:GetBody().playerId
  sendData.nick = notification:GetBody().nick
  LogInfo("ShieldFriendCmd playerId:", sendData.playerId)
  LogInfo("ShieldFriendCmd nick:", sendData.nick)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendBlackConfirmPage)
  GameFacade:SendNotification(NotificationDefines.FriendCmdType.SetShieldUserInfo, sendData)
end
return ShieldFriendCmd
