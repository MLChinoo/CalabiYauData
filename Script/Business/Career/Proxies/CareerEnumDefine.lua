local CareerEnumDefine = {}
CareerEnumDefine.textSize = {}
CareerEnumDefine.textSize.small = 0
CareerEnumDefine.textSize.medium = 1
CareerEnumDefine.textSize.large = 2
CareerEnumDefine.achievementType = {}
CareerEnumDefine.achievementType.combat = 1
CareerEnumDefine.achievementType.hornor = 3
CareerEnumDefine.achievementType.glory = 4
CareerEnumDefine.achievementType.hero = 5
CareerEnumDefine.achievementName = {
  "Combat",
  "Epic",
  "Hornor",
  "Glory",
  "Hero"
}
CareerEnumDefine.achievementLevel = {
  "D",
  "C",
  "B",
  "A",
  "S"
}
CareerEnumDefine.rankType = {}
CareerEnumDefine.rankType.stars = 1
CareerEnumDefine.starsRankField = {}
CareerEnumDefine.starsRankField.playerId = 1
CareerEnumDefine.starsRankField.rankPos = 2
CareerEnumDefine.starsRankField.nick = 3
CareerEnumDefine.starsRankField.icon = 4
CareerEnumDefine.starsRankField.stars = 5
CareerEnumDefine.starsRankField.totalGames = 6
CareerEnumDefine.starsRankField.freqRoles = 7
CareerEnumDefine.starsRankField.lastPrivilegeLaunchTime = 14
CareerEnumDefine.rewardStatus = {}
CareerEnumDefine.rewardStatus.locked = 0
CareerEnumDefine.rewardStatus.unlocked = 1
CareerEnumDefine.rewardStatus.hasAcquired = 2
CareerEnumDefine.rewardStatus.expired = 3
CareerEnumDefine.rankDivisionStar = {
  min = 0,
  bestPlayerDivision = 145,
  maxDivision = 145
}
CareerEnumDefine.winType = {}
CareerEnumDefine.winType.draw = 0
CareerEnumDefine.winType.win = 1
CareerEnumDefine.winType.lose = 2
CareerEnumDefine.BattleMode = {}
CareerEnumDefine.BattleMode.None = 0
CareerEnumDefine.BattleMode.Bomb = 1
CareerEnumDefine.BattleMode.Team = 2
CareerEnumDefine.BattleMode.Mine = 3
CareerEnumDefine.LeaderboardType = {}
CareerEnumDefine.LeaderboardType.None = 0
CareerEnumDefine.LeaderboardType.StarsRank = 1
CareerEnumDefine.LeaderboardType.TeamRank = 2
CareerEnumDefine.LeaderboardType.HeroRank = 4
CareerEnumDefine.LeaderboardRelationshipChain = {}
CareerEnumDefine.LeaderboardRelationshipChain.None = 0
CareerEnumDefine.LeaderboardRelationshipChain.All = 1
CareerEnumDefine.LeaderboardRelationshipChain.Friend = 2
CareerEnumDefine.RoleAchvHeadItemType = {}
CareerEnumDefine.RoleAchvHeadItemType.General = 1
CareerEnumDefine.RoleAchvHeadItemType.Hero = 2
return CareerEnumDefine
