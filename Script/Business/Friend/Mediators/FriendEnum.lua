local FriendEnum = {}
FriendEnum.FriendSetupType = {
  None = 0,
  OnlineState = 1,
  TeamLimit = 2
}
FriendEnum.SocialSecretType = {
  Public = 0,
  Friend = 1,
  Private = 2
}
FriendEnum.FriendStateType = {
  None = 0,
  Online = 1,
  Room = 2,
  Watch = 3,
  Training = 4,
  Matching = 5,
  Contest = 6,
  Summary = 7,
  Replay = 8,
  Leave = 9,
  LostLine = 10,
  OffOnline = 11,
  Invisible = 12
}
FriendEnum.FriendStateMobileType = {
  None = 0,
  Online = 1,
  Room = 2,
  Ready = 3,
  Contest = 4,
  OffOnline = 5
}
FriendEnum.FriendMsgType = {
  AddFriend = 0,
  FriendRequest = 1,
  NotFound = 2,
  IsFriend = 3,
  RecvFriendApply = 4,
  FriendIsLimit = 5,
  Shield = 6,
  SearchSelf = 7,
  ApplyIsLimit = 8,
  NewMsg = 9,
  OtherFriendListFull = 10,
  AlreadySendFriendRequest = 11,
  NewMail = 12
}
FriendEnum.FriendType = {
  None = 0,
  Friend = Pb_ncmd_cs.EFriendType.FriendType_FRIEND,
  Blacklist = Pb_ncmd_cs.EFriendType.FriendType_BLACK,
  Apply = Pb_ncmd_cs.EFriendType.FriendType_APPLY,
  Near = Pb_ncmd_cs.EFriendType.FriendType_NEAR,
  Social = Pb_ncmd_cs.EFriendType.FriendType_SOCIAL,
  Search = Pb_ncmd_cs.EFriendType.FriendType_SOCIAL + 1
}
FriendEnum.ReplyType = {
  None = 0,
  Refuse = 1,
  Agree = 2,
  Wait = 3
}
FriendEnum.FriendErrCode = {FriendNumberIsLimit = 20109, FriendApplyIsLimit = 20110}
FriendEnum.GameType = {
  None = 0,
  Team = 1,
  Bomb = 2,
  Room = 3
}
FriendEnum.AcceptInviteType = {
  Refuse = 0,
  Accept = 1,
  Wait = 2
}
FriendEnum.FriendSortLevel = {
  InRoom = 0,
  InGame = 1,
  Online = 2,
  Leave = 3
}
FriendEnum.RoomStatus = {
  None = 0,
  Ready = 1,
  Waiting = 2,
  Running = 3,
  Ending = 4,
  Closed = 5
}
FriendEnum.SelectCheckStatus = {
  None = 0,
  PlatformFriend = 1,
  GameFriend = 2,
  ShieldedFriend = 3,
  AddFriend = 4,
  ViewReq = 5,
  SetState = 6
}
FriendEnum.AddFriendPageStatus = {
  None = 0,
  normal = 1,
  search = 2,
  RecentPlayers = 3
}
FriendEnum.FriendBehaviorEnum = {
  None = 0,
  PlayerInfo = 1,
  AddFriend = 2,
  InviteTeam = 3,
  JoinTeam = 4,
  SendMsg = 5,
  Remark = 7,
  Move = 8,
  DeleteFriend = 9,
  Shield = 10,
  CancelShield = 11,
  Report = 12
}
return FriendEnum
