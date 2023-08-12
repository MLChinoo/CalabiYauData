local RoomEnum = {}
RoomEnum.InviteType = {
  None = 0,
  Team = 1,
  Room = 2
}
RoomEnum.MapType = {
  None = 0,
  TeamSports = 1,
  BlastInvasion = 2,
  CrystalWar = 3,
  Team5V5V5 = 4,
  TeamRiot3v3v3 = 5
}
RoomEnum.ClientPlayerPageType = {
  None = 0,
  Lobby = 1,
  Team = 2,
  Room = 3
}
RoomEnum.TeamMemberStatusType = {
  NotReady = 0,
  Ready = 1,
  Wait = 2,
  LostConnection = 3,
  Settle = 4
}
RoomEnum.GameModeType = {
  None = 0,
  Matching = 1,
  Custom = 2
}
RoomEnum.DsStatus = {
  DsStatus_CREATE = 0,
  DsStatus_RUN = 1,
  DsStatus_EXIT = 2,
  DsStatus_UNCONNECT = 3,
  DsStatus_CRASH = 4,
  DsStatus_SETTLE = 5
}
RoomEnum.AiLevelEnum = {
  Simple = 1,
  Normal = 2,
  Difficult = 3
}
RoomEnum.RankCardPlayAnimStatus = {
  First = 1,
  UnPlayPrepareAnim = 2,
  PlayedPrepareAnim = 3
}
RoomEnum.CustomRoomButtonStatus = {
  CanStart = 0,
  CantStart = 1,
  NotPrepared = 2,
  Ready = 3,
  CancelMatch = 4,
  RoomMasterEnterGame = 5,
  RoomMemberEnterGame = 6
}
RoomEnum.AcceptInviteType = {
  Refuse = 0,
  Accept = 1,
  Wait = 2
}
return RoomEnum
