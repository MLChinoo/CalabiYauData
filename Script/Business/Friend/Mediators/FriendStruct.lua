local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local FriendStruct = {}
FriendStruct.FriendGroup = {
  groupId = 0,
  groupName = "",
  index = 0
}
FriendStruct.PlayerBattleInfo = {
  winCount = 0,
  mvpCount = 0,
  total = 0
}
FriendStruct.FriendPlayer = {
  playerId = 0,
  nick = "",
  icon = 0,
  sex = 0,
  rank = 0,
  status = 0,
  teamId = 0,
  roomId = 0,
  lastTime = 0,
  onlineStatus = 0,
  battleInfo = {},
  freqRoles = {},
  groupId = 0,
  intimacy = 0,
  remarks = "",
  likabilityLv = 1,
  friendType = FriendEnum.FriendType.Friend,
  socialType = FriendEnum.SocialSecretType.None
}
FriendStruct.FriendPanelData = {
  playerId = 0,
  nick = "",
  icon = 0,
  sex = 0,
  rank = 0,
  status = FriendEnum.FriendStateType.None,
  onlineStatus = FriendEnum.FriendStateType.None,
  teamId = 0,
  roomId = 0,
  lastTime = 0,
  battleInfo = {},
  groupId = 0,
  likabilityLv = 0,
  intimacy = 0,
  remarks = ""
}
FriendStruct.PulledFriendList = {
  friendType = 0,
  friends = {}
}
FriendStruct.GroupData = {
  groupID = 0,
  groupName = "",
  index = 0
}
FriendStruct.FriendGroupData = {
  parentList = nil,
  groupData = {},
  playerDatas = {},
  bBindProcessNum = false,
  bOpenAsDefault = false,
  bHindPlayerNum = false,
  bCanRename = false,
  bCanRightClick = false,
  bCanDragDrop = false,
  groupType = FriendEnum.FriendMsgType.None
}
return FriendStruct
