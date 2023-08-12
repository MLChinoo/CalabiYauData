local RoomPlayerListPanelMediator = class("RoomPlayerListPanelMediator", PureMVC.Mediator)
function RoomPlayerListPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.OnRoomMemberNtf,
    NotificationDefines.TeamRoom.OnRoomInfoUpdate,
    NotificationDefines.TeamRoom.RefreshCard,
    NotificationDefines.TeamRoom.OnTeamTransLeaderNtf
  }
end
function RoomPlayerListPanelMediator:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  local viewComponent = self:GetViewComponent()
  if notifyName == NotificationDefines.TeamRoom.OnRoomMemberNtf then
    viewComponent:UpdatePlayerListInfo()
  elseif notifyName == NotificationDefines.TeamRoom.OnRoomInfoUpdate then
    viewComponent:UpdatePlayerListInfo()
  elseif notifyName == NotificationDefines.TeamRoom.RefreshCard then
    self:RefreshCard(notifyBody)
  elseif notifyName == NotificationDefines.TeamRoom.OnTeamTransLeaderNtf then
    viewComponent:UpdatePlayerListInfo()
  end
end
function RoomPlayerListPanelMediator:RefreshCard(data)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roleSkinId = data.roleSKinId
  local cardFrameId = data.cardFrameId
  local cardBorderId = data.cardBorderId
  local achievementId = data.achievementId
  local playerId = roomDataProxy:GetPlayerID()
  local playerList = roomDataProxy:GetTeamMemberList()
  if playerList then
    for i, v in ipairs(playerList) do
      if v.playerId == playerId then
        v.avatarId = roleSkinId
        v.frameId = cardFrameId
        v.borderId = cardBorderId
        v.achievementId = achievementId
        roomDataProxy:SetRoomPlayerList(playerList)
        break
      end
    end
  end
end
return RoomPlayerListPanelMediator
