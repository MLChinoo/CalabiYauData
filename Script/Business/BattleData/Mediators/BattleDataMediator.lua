local BattleDataMediator = class("BattleDataMediator", PureMVC.Mediator)
function BattleDataMediator:OnRegister()
  BattleDataMediator.super.OnRegister(self)
  LogDebug("BattleDataMediator", "OnRegister")
end
function BattleDataMediator:OnRemove()
  LogDebug("BattleDataMediator", "OnRemove")
  BattleDataMediator.super.OnRemove(self)
end
function BattleDataMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleData.UpdatePanelRecvMediator,
    NotificationDefines.BattleData.CleanAutoCollapsedTimer
  }
end
function BattleDataMediator:HandleNotification(notification)
  local BattleDataPage = self:GetViewComponent()
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.BattleData.UpdatePanelRecvMediator then
    BattleDataPage:Init(Body)
  elseif Name == NotificationDefines.BattleData.CleanAutoCollapsedTimer then
    BattleDataPage:CleanCollapsedTimer()
  end
end
return BattleDataMediator
