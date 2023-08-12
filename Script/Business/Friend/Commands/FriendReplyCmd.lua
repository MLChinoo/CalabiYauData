local FriendReplyCmd = class("FriendReplyCmd", PureMVC.Command)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function FriendReplyCmd:Execute(notification)
  local replyType = notification:GetBody().replyType
  local playerId = notification:GetBody().playerId
  LogInfo("FriendReplyCmd replyType:", replyType)
  LogInfo("FriendReplyCmd playerId:", playerId)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    friendDataProxy:ReqFriendReply(replyType, playerId)
  end
end
return FriendReplyCmd
