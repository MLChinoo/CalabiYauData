local BattleInfoMediator = class("BattleInfoMediator", PureMVC.Mediator)
function BattleInfoMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.BattleRecord.ShowBattleInfo,
    NotificationDefines.Career.BattleRecord.RequireBattleInfo
  }
end
function BattleInfoMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.BattleRecord.ShowBattleInfo then
    local roomInfo = notification:GetBody()
    if roomInfo.room_id == self.currentRoomInfo.room_id then
      self.needFresh = false
    else
      self.needFresh = true
      self.currentRoomInfo = roomInfo
    end
    GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.RequireBattleInfoCmd, roomInfo.room_id)
  end
  if notification:GetName() == NotificationDefines.Career.BattleRecord.RequireBattleInfo and self.needFresh then
    if 0 == notification:GetType() then
      self:GetViewComponent():UpdateInfoShown(self.currentRoomInfo, notification:GetBody())
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, notification:GetType())
    end
  end
end
function BattleInfoMediator:OnRegister()
  BattleInfoMediator.super.OnRegister(self)
  self.currentRoomInfo = {}
  self.needFresh = true
end
function BattleInfoMediator:OnRemove()
  BattleInfoMediator.super.OnRemove(self)
end
return BattleInfoMediator
