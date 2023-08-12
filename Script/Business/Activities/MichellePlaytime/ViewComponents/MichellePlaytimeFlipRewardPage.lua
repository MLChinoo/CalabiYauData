local MichellePlaytimeFlipRewardPage = class("MichellePlaytimeFlipRewardPage", PureMVC.ViewComponentPage)
local MichellePlaytimeFlipRewardPageMediator = require("Business/Activities/MichellePlaytime/Mediators/MichellePlaytimeFlipRewardPageMediator")
function MichellePlaytimeFlipRewardPage:ListNeededMediators()
  return {MichellePlaytimeFlipRewardPageMediator}
end
function MichellePlaytimeFlipRewardPage:Construct()
  MichellePlaytimeFlipRewardPage.super.Construct(self)
  self.Btn_ExchangeReward.OnClicked:Add(self, self.OnClickExchangeReward)
end
function MichellePlaytimeFlipRewardPage:Destruct()
  MichellePlaytimeFlipRewardPage.super.Destruct(self)
  self.Btn_ExchangeReward.OnClicked:Remove(self, self.OnClickExchangeReward)
end
function MichellePlaytimeFlipRewardPage:OnClickExchangeReward()
  ViewMgr:OpenPage(self, UIPageNameDefine.MichellePlaytimeExchangeRewardPage)
end
return MichellePlaytimeFlipRewardPage
