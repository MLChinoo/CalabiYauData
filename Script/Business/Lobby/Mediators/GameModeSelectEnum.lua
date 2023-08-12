local GameModeSelectEnum = {}
GameModeSelectEnum.GameModeType = {
  None = 0,
  Team = 1,
  Boomb = 2,
  Room = 3,
  RankTeam = 4,
  RankBomb = 5,
  CrystalScramble = 6,
  Team5V5V5 = 7,
  Team3V3V3 = 8
}
GameModeSelectEnum.GamePageType = {
  None = 0,
  Match = 1,
  CustomRoom = 2
}
GameModeSelectEnum.NavBtnType = {
  Boomb = 0,
  RankBomb = 1,
  Team = 2,
  CrystalScramble = 3,
  Custom = 4,
  Team5V5V5 = 5,
  Team3V3V3 = 6
}
return GameModeSelectEnum
