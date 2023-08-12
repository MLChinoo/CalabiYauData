local AddFriendCmd = class("AddFriendCmd", PureMVC.Command)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function AddFriendCmd:Execute(notification)
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  local addFriendPlayerId = notification:GetBody().playerId
  local addFriendNick = notification:GetBody().nick
  if friendDataProxy then
    local selfPlayerId = friendDataProxy:GetPlayerID()
    if addFriendPlayerId and selfPlayerId ~= addFriendPlayerId then
      local newMsg = {}
      newMsg.playerName = addFriendNick
      local arg1 = UE4.FFormatArgumentData()
      arg1.ArgumentName = "0"
      arg1.ArgumentValue = addFriendNick
      arg1.ArgumentValueType = 4
      local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
      inArgsTarry:Add(arg1)
      if friendDataProxy.allFriendMap and friendDataProxy.allFriendMap[addFriendPlayerId] then
        newMsg.msgType = FriendEnum.FriendMsgType.IsFriend
        local isFriendText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "IsFriendText")
        isFriendText = UE4.UKismetTextLibrary.Format(isFriendText, inArgsTarry)
        GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, isFriendText)
      elseif friendDataProxy:GetShieldlist()[addFriendPlayerId] then
        newMsg.msgType = FriendEnum.FriendMsgType.Shield
        local isBlackListText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "IsInBlackListText")
        isBlackListText = UE4.UKismetTextLibrary.Format(isBlackListText, inArgsTarry)
        GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, isBlackListText)
      elseif friendDataProxy:HasFriendReq(addFriendPlayerId) then
        newMsg.msgType = FriendEnum.FriendMsgType.AlreadySendFriendRequest
        local textAlreadySend = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "AlreadySendFriendRequestText")
        textAlreadySend = UE4.UKismetTextLibrary.Format(textAlreadySend, inArgsTarry)
        GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, textAlreadySend)
      else
        friendDataProxy:AddNewFriendReq(addFriendPlayerId)
        self.addFriendReqCountdownTime = 15
        self.timeHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
          if self.addFriendReqCountdownTime then
            if 0 == self.addFriendReqCountdownTime then
              if friendDataProxy then
                friendDataProxy:RemoveOldFriendReq(addFriendPlayerId)
                self.timeHandle:EndTask()
                self.timeHandle = nil
              end
            else
              self.addFriendReqCountdownTime = self.addFriendReqCountdownTime - 1
            end
          end
        end)
        friendDataProxy:ReqFriendAdd(addFriendNick, addFriendPlayerId, FriendEnum.FriendType.Apply)
        return
      end
    end
  end
end
return AddFriendCmd
