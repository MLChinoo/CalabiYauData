local CareerRankMediator = class("CareerRankMediator", PureMVC.Mediator)
function CareerRankMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.CareerRank.GetCareerRankData,
    NotificationDefines.Career.CareerRank.StarChange
  }
end
function CareerRankMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.GetCareerRankData then
    self:GetViewComponent():InitView(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Career.CareerRank.StarChange then
    self:GetViewComponent():UpdateDivision(notification:GetBody().stars, notification:GetBody().scores)
  end
end
function CareerRankMediator:OnRegister()
  CareerRankMediator.super.OnRegister(self)
  self.rankInfo = {}
end
function CareerRankMediator:OnRemove()
  CareerRankMediator.super.OnRemove(self)
end
return CareerRankMediator
