local ShowPlayerApplyTeamPopPageCmd = class("ShowPlayerApplyTeamPopPageCmd", PureMVC.Command)
function ShowPlayerApplyTeamPopPageCmd:Execute(notification)
  local applyNtfInfo = notification:GetBody().AppleyData
  local DataIndex = notification:GetBody().DataIndex
  local businessCardDataProxy = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy)
  local singleData = {}
  if applyNtfInfo then
    singleData.PlayerID = applyNtfInfo.player_id
    singleData.PlayerIcon = businessCardDataProxy:GetIconTexture(applyNtfInfo.icon)
    singleData.PlayerNickName = applyNtfInfo.nick
    singleData.RankName = self:GetRankName(applyNtfInfo.rank)
    singleData.RankIcon = self:GetRankIcon(applyNtfInfo.rank)
    singleData.RankLevelIcon = self:GetRankLevelIcon(applyNtfInfo.rank)
    singleData.PlayChannelName = self:GetPlayChannelName(applyNtfInfo.type)
    singleData.DataIndex = DataIndex
    singleData.InviteType = applyNtfInfo.InviteType
    singleData.Pos = applyNtfInfo.pos
    singleData.TeamId = applyNtfInfo.team_id
    singleData.RoomID = applyNtfInfo.room_id
    singleData.RoomMode = applyNtfInfo.mode
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.TeamApplyPC)
  GameFacade:SendNotification(NotificationDefines.UpdatePlayerApplyList, singleData)
end
function ShowPlayerApplyTeamPopPageCmd:GetRankName(rankLevel)
  local division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(rankLevel)
  if nil == division then
    division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(1)
  end
  if division and division.Name then
    return division.Name
  end
  return nil
end
function ShowPlayerApplyTeamPopPageCmd:GetRankIcon(rankLevel)
  local division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(rankLevel)
  if nil == division then
    division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(1)
  end
  if division and division.IconDivisions then
    return division.IconDivisions
  end
  return nil
end
function ShowPlayerApplyTeamPopPageCmd:GetRankLevelIcon(rankLevel)
  local division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(rankLevel)
  if nil == division then
    division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(1)
  end
  if division and division.IconDivisionLevel then
    return division.IconDivisionLevel
  end
  return nil
end
function ShowPlayerApplyTeamPopPageCmd:GetPlayChannelName(type)
  return ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PlayerChannel_" .. type)
end
return ShowPlayerApplyTeamPopPageCmd
