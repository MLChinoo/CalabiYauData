local InviteFriendCmd = class("InviteFriendCmd", PureMVC.Command)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function InviteFriendCmd:Execute(notification)
  local playerId = notification:GetBody()
  local playerInfo = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetFriendInfoFromPlayerID(playerId)
  local inviteFriendLevel = playerInfo.level
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomProxy then
    local teamInfo = roomProxy:GetTeamInfo()
    if teamInfo and teamInfo.teamId and teamInfo.teamId > 0 and teamInfo.mode then
      if teamInfo.teamId == playerInfo.teamId then
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 4005)
        return
      end
      if self:CheckTeamMembersIsFull(teamInfo) then
        return
      end
      local gameMode = teamInfo.mode
      if gameMode == GameModeSelectNum.GameModeType.RankBomb or gameMode == GameModeSelectNum.GameModeType.RankTeam then
        local levelLimit = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy):GetParameterIntValue("5908")
        if inviteFriendLevel < levelLimit then
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1077)
          return
        end
      end
      if roomProxy then
        roomProxy:ReqTeamInvite(teamInfo.teamId, playerId)
      end
    elseif roomProxy then
      roomProxy:ReqTeamCreate(GameModeSelectNum.GameModeType.Boomb, roomProxy:GetDefaultMapId(RoomEnum.MapType.BlastInvasion), 0)
      self.bInviteAfterCreate = true
      if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
        local sendData = {}
        sendData.pageType = UE4.EPMFunctionTypes.Play
        GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, sendData)
      elseif 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
        ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.GameModeSelectPage)
      end
      TimerMgr:AddTimeTask(0.3, 0, 0, function()
        local teamInfoTemp = roomProxy:GetTeamInfo()
        if teamInfoTemp and teamInfoTemp.teamId then
          roomProxy:ReqTeamInvite(teamInfoTemp.teamId, playerId)
        end
      end)
    end
  end
end
function InviteFriendCmd:CheckTeamMembersIsFull(tempTeamInfo)
  local teamFullSize = 5
  if tempTeamInfo and tempTeamInfo.members then
    if tempTeamInfo.mode and tempTeamInfo.mode == GameModeSelectNum.GameModeType.Room then
      teamFullSize = 12
      if tempTeamInfo.mapID then
        local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
        local mapPlayMode = roomProxy:GetMapType(tempTeamInfo.mapID)
        if mapPlayMode == RoomEnum.MapType.Team5V5V5 then
          teamFullSize = 15
        end
      end
    end
    local robotNum = 0
    for key, value in pairs(tempTeamInfo.members) do
      if value.bIsRobot then
        robotNum = robotNum + 1
      end
    end
    local roomRealMemberNum = table.count(tempTeamInfo.members) - robotNum
    if roomRealMemberNum == teamFullSize then
      local commonText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "TeamFull")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, commonText)
      return true
    end
  end
  return false
end
function InviteFriendCmd:CheckPlayerIsCanBeInivate(playerId)
  local FriendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  local playerData = FriendDataProxy:GetFriendInfoFromPlayerID(playerId)
  if playerData then
    if playerData.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_LOST or playerData.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1000)
      return false
    end
    if playerData.onlineStatus == Pb_ncmd_cs.EOnlineStatus.OnlineStatus_ONLINE and playerData.roomStatus == FriendEnum.RoomStatus.Running then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1002)
      return false
    end
  end
  return true
end
return InviteFriendCmd
