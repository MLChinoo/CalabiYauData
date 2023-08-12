local GameSpectatorBtnPanelMediator = class("GameSpectatorBtnPanelMediator", PureMVC.Mediator)
function GameSpectatorBtnPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.TipoffPlayer.TipoffPlayerDataChange
  }
end
function GameSpectatorBtnPanelMediator:OnRegister()
  GameSpectatorBtnPanelMediator.super.OnRegister(self)
  self:ClearTipoffResTimer()
end
function GameSpectatorBtnPanelMediator:OnRemove()
  GameSpectatorBtnPanelMediator.super.OnRemove(self)
  self:ClearTipoffResTimer()
end
function GameSpectatorBtnPanelMediator:ClearTipoffResTimer()
  if self.Delay_RefreshResTipoff then
    self.Delay_RefreshResTipoff:EndTask()
    self.Delay_RefreshResTipoff = nil
  end
end
function GameSpectatorBtnPanelMediator:HandleNotification(notification)
  if not notification then
    return
  end
  local ntfName = notification:GetName()
  local ntfBody = notification:GetBody()
  if ntfName == NotificationDefines.TipoffPlayer.ResTipoffPlayerInfo then
    self:ResTipoffPlayerInfo()
  end
end
function GameSpectatorBtnPanelMediator:InitView(data)
end
function GameSpectatorBtnPanelMediator:CloseView()
end
function GameSpectatorBtnPanelMediator:ResTipoffPlayerInfo()
  self:ClearTipoffResTimer()
  self.Delay_RefreshResTipoff = TimerMgr:AddTimeTask(1, 0, 1, function()
    if self:GetViewComponent() then
      self:GetViewComponent():OnRefreshBtn()
    end
  end)
end
return GameSpectatorBtnPanelMediator
