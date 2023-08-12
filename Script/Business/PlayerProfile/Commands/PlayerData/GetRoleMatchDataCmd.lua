local GetRoleMatchDataCmd = class("GetRoleMatchDataCmd", PureMVC.Command)
function GetRoleMatchDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.GetRoleMatchDataCmd then
    local gameMode = notification:GetBody() or 0
    local roleMatchInfo = GameFacade:RetrieveProxy(ProxyNames.PlayerDataProxy):GetRoleEmployInfo()
    local retInfo = {
      totalMatchNum = 0,
      roleMatch = {}
    }
    local matchToShow = {}
    if 0 == gameMode then
      for key, value in pairs(roleMatchInfo) do
        for k, v in pairs(value) do
          if nil == matchToShow[k] then
            matchToShow[k] = {}
            table.copy(v, matchToShow[k])
          else
            matchToShow[k].count = matchToShow[k].count + v.count
            matchToShow[k].winCount = matchToShow[k].winCount + v.winCount
          end
        end
      end
    elseif roleMatchInfo[gameMode] then
      matchToShow = roleMatchInfo[gameMode]
    end
    for key, value in pairs(matchToShow) do
      retInfo.totalMatchNum = math.max(retInfo.totalMatchNum, value.count)
      local matchInfoOfRole = {}
      local roleSkinId = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCurrentWearSkinID(key)
      matchInfoOfRole.roleConfig = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleProfile(key)
      matchInfoOfRole.roleSkinConfig = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleSkin(roleSkinId)
      matchInfoOfRole.matchCount = value
      retInfo.roleMatch[key] = matchInfoOfRole
    end
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.PlayerData.GetRoleMatchData, retInfo)
  end
end
return GetRoleMatchDataCmd
