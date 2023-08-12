local RequireAchievementDataCmd = class("RequireAchievementDataCmd", PureMVC.Command)
function RequireAchievementDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.RequireDataCmd then
    local achievementMap = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchievementMap()
    local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_REACH_ACHIEVEMENT)
    if redDotList then
      for _, value in pairs(redDotList) do
        local achieveId = 0 ~= value.event_id and value.event_id or value.reddot_rid
        for k, v in pairs(achievementMap) do
          if v.achievementList and v.achievementList[achieveId] and value.mark then
            v.achievementList[achieveId].redDotId = value.reddot_id
          end
        end
      end
    end
    GameFacade:SendNotification(NotificationDefines.Career.Achievement.RefreshData, achievementMap)
  end
end
return RequireAchievementDataCmd
