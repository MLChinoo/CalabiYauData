local M = class("Init", PureMVC.ModuleInit)
local ModuleProxyNames = ProxyNames
local ModuleNotificationNames = NotificationDefines
M.Proxys = {
  {
    Name = ModuleProxyNames.AchievementDataProxy,
    Path = "Business/Career/Proxies/Achievement/AchievementDataProxy"
  },
  {
    Name = ModuleProxyNames.BattleRecordDataProxy,
    Path = "Business/Career/Proxies/BattleRecord/BattleRecordDataProxy"
  },
  {
    Name = ModuleProxyNames.CareerRankDataProxy,
    Path = "Business/Career/Proxies/CareerRank/CareerRankDataProxy"
  },
  {
    Name = ModuleProxyNames.HonorRankDataProxy,
    Path = "Business/Career/Proxies/CareerRank/HonorRankDataProxy"
  }
}
M.Commands = {
  {
    Name = ModuleNotificationNames.Career.Achievement.RequireDataCmd,
    Path = "Business/Career/Commands/Achievement/RequireAchievementDataCmd"
  },
  {
    Name = ModuleNotificationNames.Career.Achievement.AcquireLevelRewardCmd,
    Path = "Business/Career/Commands/Achievement/AquireAchievementLevelRewardCmd"
  },
  {
    Name = ModuleNotificationNames.Career.Achievement.AcquireRewardCmd,
    Path = "Business/Career/Commands/Achievement/AquireAchievementRewardCmd"
  },
  {
    Name = ModuleNotificationNames.Career.Achievement.ShowAchievementTipCmd,
    Path = "Business/Career/Commands/Achievement/ShowAchievementTipCmd"
  },
  {
    Name = ModuleNotificationNames.Career.Achievement.ShowMedalTipCmd,
    Path = "Business/Career/Commands/Achievement/ShowMedalTipCmd"
  },
  {
    Name = ModuleNotificationNames.Career.Achievement.ShowAchievementShortTipCmd,
    Path = "Business/Career/Commands/Achievement/ShowAchievementShortTipCmd"
  },
  {
    Name = ModuleNotificationNames.Career.BattleRecord.RequireBattleInfoCmd,
    Path = "Business/Career/Commands/BattleRecord/RequireBattleInfoCmd"
  },
  {
    Name = ModuleNotificationNames.Career.BattleRecord.OnResBattleInfoCmd,
    Path = "Business/Career/Commands/BattleRecord/OnResBattleInfoCmd"
  },
  {
    Name = ModuleNotificationNames.Career.CareerRank.GetCareerRankDataCmd,
    Path = "Business/Career/Commands/CareerRank/GetCareerRankDataCmd"
  },
  {
    Name = ModuleNotificationNames.Career.CareerRank.ReqRankDataCmd,
    Path = "Business/Career/Commands/CareerRank/ReqRankDataCmd"
  },
  {
    Name = ModuleNotificationNames.Career.CareerRank.GetSeasonPrizeCmd,
    Path = "Business/Career/Commands/CareerRank/GetSeasonPrizeCmd"
  },
  {
    Name = ModuleNotificationNames.Career.CareerRank.AcquireRankPrizeCmd,
    Path = "Business/Career/Commands/CareerRank/AcquireRankPrizeCmd"
  }
}
return M
