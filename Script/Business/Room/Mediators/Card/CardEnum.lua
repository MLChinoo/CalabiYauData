local CardEnum = {}
CardEnum.CardType = {
  None = 0,
  Rank = 1,
  Combat = 2,
  Spectator = 3
}
CardEnum.PlayerState = {
  None = 0,
  Normal = 1,
  Ready = 2,
  Leave = 3,
  LostConnection = 4,
  Settle = 5
}
CardEnum.VoiceChannelType = {Room = 0, Team = 1}
CardEnum.VoiceState = {
  Normal = 0,
  Speak = 1,
  Mute = 2,
  Shield = 3,
  Other = 4
}
CardEnum.GameModeType = {
  None = 0,
  Matching = 1,
  Custom = 2
}
CardEnum.CardResourceType = {
  None = 0,
  Avatar = 1,
  Frame = 2,
  Border = 3
}
CardEnum.MoveState = {
  Reset = 0,
  Select = 1,
  Move = 2
}
CardEnum.RankContextType = {
  None = 0,
  LeaderSelf = 1,
  LeaderOther = 2,
  MemberSelf = 3,
  MemberOther = 4,
  LeaderRobot = 5,
  MemberRobot = 6
}
CardEnum.FriendType = {
  None = 0,
  Friend = 1,
  BlackList = 2,
  Apply = 3,
  Near = 4,
  Search = 5
}
return CardEnum
