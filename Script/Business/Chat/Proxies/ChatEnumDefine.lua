local ChatEnum = {}
ChatEnum.EChatState = {
  deactive = 0,
  active = 1,
  newMsg = 2
}
ChatEnum.EChatChannel = {
  world = Pb_ncmd_cs.EChatType.ChatType_WORLD,
  system = Pb_ncmd_cs.EChatType.ChatType_SYSTEM,
  team = Pb_ncmd_cs.EChatType.ChatType_TEAM,
  room = Pb_ncmd_cs.EChatType.ChatType_ROOM,
  fight = Pb_ncmd_cs.EChatType.ChatType_FIGHT,
  private = 99
}
ChatEnum.ChannelName = {
  world = "WorldChatTabName",
  room = "MatchChatTabName",
  team = "TeamChatTabName",
  system = "SystemChatTabName",
  private = "PrivateChatTabName"
}
ChatEnum.EWorldMsgSetting = {
  display = 1,
  receive = 2,
  ignore = 3
}
return ChatEnum
