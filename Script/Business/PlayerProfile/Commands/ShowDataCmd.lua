local ShowDataCmd = class("ShowDataCmd", PureMVC.Command)
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
function ShowDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.ShowDataCmd then
    local playerInfo = GameFacade:RetrieveProxy(ProxyNames.PlayerDataProxy):GetPlayerInfo()
    if playerInfo.player_id ~= GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId() then
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FriendProfilePage)
    end
    local cardInfo = {}
    cardInfo.cardId = {}
    cardInfo.cardId[businessCardEnum.cardType.avatar] = playerInfo.avatar_id
    cardInfo.cardId[businessCardEnum.cardType.frame] = playerInfo.border_id
    cardInfo.cardId[businessCardEnum.cardType.achieve] = playerInfo.achie_id
    cardInfo.playerAttr = {}
    cardInfo.playerAttr.playerId = playerInfo.player_id
    cardInfo.playerAttr.nickName = playerInfo.nick
    cardInfo.playerAttr.sex = playerInfo.sex
    cardInfo.playerAttr.level = playerInfo.level
    local collectionInfo = GameFacade:RetrieveProxy(ProxyNames.PlayerDataProxy):GetCollectionInfo()
    local privilegeInfo = {}
    privilegeInfo.lastQQLoginTime = playerInfo.last_qq_login_time or 0
    if playerInfo.player_id == GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId() then
      local PlayerDC = UE4.UPMPlayerDataCenter.Get(LuaGetWorld())
      privilegeInfo.lastQQLoginTime = PlayerDC:GetLastQQLaunchTime()
    end
    local playerProfileInfo = {}
    playerProfileInfo.cardInfo = cardInfo
    playerProfileInfo.collectionInfo = collectionInfo
    playerProfileInfo.privilegeInfo = privilegeInfo
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.PlayerData.ShowPlayerData, playerProfileInfo)
  end
end
return ShowDataCmd
