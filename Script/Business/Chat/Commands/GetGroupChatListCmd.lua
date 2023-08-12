local GetGroupChatListCmd = class("GetGroupChatListCmd", PureMVC.Command)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function GetGroupChatListCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Chat.GetGroupChatListCmd then
    local groupChatList = {}
    groupChatList = table.clone(GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetGroupChatList())
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.PC then
      local worldChatInfo = GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):GetWorldChat()
      if worldChatInfo then
        groupChatList[ChatEnum.EChatChannel.world] = worldChatInfo
      end
    end
    if table.count(groupChatList) > 0 then
      GameFacade:SendNotification(NotificationDefines.Chat.GetGroupChatList, groupChatList)
    end
  end
end
return GetGroupChatListCmd
