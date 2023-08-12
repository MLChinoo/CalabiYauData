local BattleRecordMediator = class("BattleRecordMediator", PureMVC.Mediator)
local recordPerPage = 20
local maxRecordNum = 200
function BattleRecordMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.BattleRecord.RequireRecordData,
    NotificationDefines.Career.BattleRecord.RequirePlayerRecord,
    NotificationDefines.Career.BattleRecord.HasAvailableRecord
  }
end
function BattleRecordMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.BattleRecord.RequireRecordData then
    self:GetViewComponent():ShowRecord(notification:GetBody())
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
  end
  if notification:GetName() == NotificationDefines.Career.BattleRecord.RequirePlayerRecord then
    self.playerId = notification:GetBody()
    self:GetViewComponent():ClearRecord()
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
    self:RequireRecordData(1)
  end
  if notification:GetName() == NotificationDefines.Career.BattleRecord.HasAvailableRecord then
    local info = notification:GetBody()
    self:GetViewComponent():UpdateRecordList(info.standings, info.selectedBattle)
  end
end
function BattleRecordMediator:OnRegister()
  BattleRecordMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnReqRecordList:Add(self.RequireRecordData, self)
end
function BattleRecordMediator:OnRemove()
  self:GetViewComponent().actionOnReqRecordList:Remove(self.RequireRecordData, self)
  BattleRecordMediator.super.OnRemove(self)
end
function BattleRecordMediator:RequireRecordData(page)
  if page > maxRecordNum / recordPerPage then
    LogDebug("BattleRecordMediator", "No more record...")
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "NoMoreRecord")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
  else
    LogDebug("BattleRecordMediator", "Require record page: " .. page)
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
    GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):ReqBattleRecord(page, self.playerId)
  end
end
return BattleRecordMediator
