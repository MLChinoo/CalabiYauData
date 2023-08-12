local SeasonPrizeMediator = class("SeasonPrizeMediator", PureMVC.Mediator)
function SeasonPrizeMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.CareerRank.GetSeasonPrize,
    NotificationDefines.Career.CareerRank.ShowPage,
    NotificationDefines.Career.CareerRank.AcquireRankPrize
  }
end
function SeasonPrizeMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.GetSeasonPrize then
    self:GetViewComponent():InitView(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Career.CareerRank.ShowPage then
    self:GetViewComponent():ShowPage(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Career.CareerRank.AcquireRankPrize and 0 == notification:GetBody().code then
    self:GetViewComponent():UpdatePrizeState(notification:GetBody().reward_id, notification:GetBody().status)
  end
end
function SeasonPrizeMediator:OnRegister()
  SeasonPrizeMediator.super.OnRegister(self)
end
function SeasonPrizeMediator:OnRemove()
  SeasonPrizeMediator.super.OnRemove(self)
end
return SeasonPrizeMediator
