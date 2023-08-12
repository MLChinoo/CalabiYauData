local LotteryResultMediator = class("LotteryResultMediator", PureMVC.Mediator)
function LotteryResultMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.BuyTicketCmd,
    NotificationDefines.OnResRoleSkinSelect,
    NotificationDefines.OnResEquipWeapon,
    NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle
  }
end
function LotteryResultMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.BuyTicketCmd then
    self:GetViewComponent():SetIsBuyingTicket()
  end
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
return LotteryResultMediator
