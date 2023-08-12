local ResultBPMediator = class("ResultBPMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultBPMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultBPTaskUpdated
  }
end
function ResultBPMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("ResultBPMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.BattleResultBPTaskUpdated then
    self:ViewAddBPTask(body)
  end
end
function ResultBPMediator:OnRegister()
  LogDebug("ResultBPMediator", "OnRegister")
  ResultBPMediator.super.OnRegister(self)
  self.viewComponent.ListView_BPTasks:ClearChildren()
  self:UpdateView()
end
function ResultBPMediator:UpdateView()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  if battleResultProxy.MyObTeamId then
    return
  end
  local BPTasksUpdated = battleResultProxy:GetBPTasksUpdated()
  LogDebug("UpdateBPTasks", TableToString(BPTasksUpdated))
  self.viewComponent:UpdateBPTasks(BPTasksUpdated)
end
function ResultBPMediator:ViewAddBPTask(Task)
  LogDebug("AddBPTask", TableToString(Task))
  self.viewComponent:AddBPTask(Task)
end
function ResultBPMediator:OnRemove()
  LogDebug("ResultBPMediator", "OnRemove")
  ResultBPMediator.super.OnRemove(self)
end
return ResultBPMediator
