local GetCareerDataCmd = class("GetCareerDataCmd", PureMVC.Command)
function GetCareerDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.PlayerProfile.PlayerData.GetCareerDataCmd then
    local careerData = {}
    local playerInfo = GameFacade:RetrieveProxy(ProxyNames.PlayerDataProxy):GetPlayerInfo()
    careerData.firstTime = playerInfo.flogin_time
    careerData.praise = playerInfo.laud
    local gameModeSelect = notification:GetBody() or 1
    local battleInfo = GameFacade:RetrieveProxy(ProxyNames.PlayerDataProxy):GetBattleInfo()
    for key, value in pairs(battleInfo) do
      if value.game_mode == gameModeSelect then
        careerData.battleInfo = value
        break
      end
    end
    GameFacade:SendNotification(NotificationDefines.PlayerProfile.PlayerData.GetCareerData, careerData)
  end
end
return GetCareerDataCmd
