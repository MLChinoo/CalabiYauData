local HighQualityItemDisplayMediator = class("HighQualityItemDisplayMediator", PureMVC.Mediator)
function HighQualityItemDisplayMediator:ListNotificationInterests()
  return {
    NotificationDefines.OnResRoleSkinSelect,
    NotificationDefines.OnResEquipWeapon,
    NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle
  }
end
function HighQualityItemDisplayMediator:OnRegister()
  HighQualityItemDisplayMediator.super.OnRegister(self)
end
function HighQualityItemDisplayMediator:OnRemove()
  HighQualityItemDisplayMediator.super.OnRemove(self)
end
function HighQualityItemDisplayMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.OnResRoleSkinSelect then
    self:GetViewComponent():ItemUseSucceed()
  end
  if notification:GetName() == NotificationDefines.OnResEquipWeapon then
    self:GetViewComponent():ItemUseSucceed()
  end
  if notification:GetName() == NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle then
    self:GetViewComponent():ItemUseSucceed()
  end
end
return HighQualityItemDisplayMediator
