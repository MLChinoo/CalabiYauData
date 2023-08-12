local AchievementMediator = class("AchievementMediator", PureMVC.Mediator)
function AchievementMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.Achievement.RefreshData,
    NotificationDefines.Career.Achievement.ShowAchievementTip,
    NotificationDefines.Career.Achievement.ShowMedalTipCmd,
    NotificationDefines.Career.Achievement.ShowMedalTip
  }
end
function AchievementMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.Achievement.RefreshData then
    self:GetViewComponent():InitView(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowAchievementTip then
    self:GetViewComponent():ShowAchievementTypeInfo()
    if self.medalChosen then
      self.medalChosen:SetUnchosen()
      self.medalChosen = nil
    end
  end
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowMedalTipCmd then
    LogDebug("AchievementMediator", "Set medal selected")
    if self.medalChosen then
      self.medalChosen:SetUnchosen()
    end
    self.medalChosen = notification:GetBody()
  end
  if notification:GetName() == NotificationDefines.Career.Achievement.ShowMedalTip then
    self:GetViewComponent():ShowMedalInfo()
  end
end
function AchievementMediator:OnRegister()
  LogDebug("AchievementMediator", "On register")
  AchievementMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnRefresh:Add(self.RefreshAchievementData, self)
end
function AchievementMediator:OnRemove()
  self:GetViewComponent().actionOnRefresh:Remove(self.RefreshAchievementData, self)
  AchievementMediator.super.OnRemove(self)
end
function AchievementMediator:RefreshAchievementData()
  LogDebug("AchievementMediator", "Send note to require data")
  GameFacade:SendNotification(NotificationDefines.Career.Achievement.RequireDataCmd)
end
return AchievementMediator
