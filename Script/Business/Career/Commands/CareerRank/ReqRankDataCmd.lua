local ReqRankDataCmd = class("ReqRankDataCmd", PureMVC.Command)
function ReqRankDataCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.ReqRankDataCmd then
    local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
    local leadboardType = honorRankDataProxy:GetCurrentReqLeadboardType()
    local subType = honorRankDataProxy:GetCurrentReqRoleID()
    local seasonId = honorRankDataProxy:GetCurrentReqSeasonId()
    local relationshipChain = honorRankDataProxy:GetLeaderboardRelationshipChain()
    local inPage = notification:GetBody().inPage
    local leadboardData = honorRankDataProxy:GetLeadboardData(leadboardType, subType, seasonId, relationshipChain, inPage)
    if leadboardData then
      GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetHonorRankData, leadboardData)
    end
  end
end
return ReqRankDataCmd
