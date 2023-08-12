local GetCareerRankDataCmd = class("GetCareerRankDataCmd", PureMVC.Command)
function GetCareerRankDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.GetCareerRankDataCmd then
    local seasonRank = {}
    seasonRank.careerRankData = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetRankInfo()
    seasonRank.seasonInfo = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetSeasonInfo()
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetCareerRankData, seasonRank)
  end
end
return GetCareerRankDataCmd
