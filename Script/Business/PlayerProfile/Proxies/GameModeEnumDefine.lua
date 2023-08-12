local GameModeEnumDefine = {}
GameModeEnumDefine.gameModeMap = {
  GameModeBomb = Pb_ncmd_cs.ERoomMode.RoomMode_BOMB,
  GameModeTeam = Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_5V5V5,
  GameModeTeam3 = Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_3V3V3,
  GameModeRankBomb = Pb_ncmd_cs.ERoomMode.RoomMode_RANK_BOMB,
  GameModeMine = Pb_ncmd_cs.ERoomMode.RoomMode_MINE
}
GameModeEnumDefine.gameModeName = {
  "GameModeRankBomb",
  "GameModeBomb",
  "GameModeTeam",
  "GameModeTeam3"
}
return GameModeEnumDefine
