local ResultRankMediator = class("ResultRankMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultRankMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.ResultRankDataRecv
  }
end
function ResultRankMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("ResultRankMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.ResultRankDataRecv then
    self:UpdateView()
  end
end
function ResultRankMediator:OnRegister()
  LogDebug("ResultRankMediator", "OnRegister")
  ResultRankMediator.super.OnRegister(self)
  self:UpdateView()
end
function ResultRankMediator:UpdateView()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  if battleResultProxy.MyObTeamId then
    return
  end
  local SettleQualifyingData = battleResultProxy:GetSettleQualifyingData()
  if SettleQualifyingData then
    self.viewComponent:Update(SettleQualifyingData)
  end
end
function ResultRankMediator:OnRemove()
  LogDebug("ResultRankMediator", "OnRemove")
  ResultRankMediator.super.OnRemove(self)
end
return ResultRankMediator
