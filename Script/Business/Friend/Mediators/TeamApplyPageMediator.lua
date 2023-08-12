local TeamApplyPageMediator = class("TeamApplyPageMediator", PureMVC.Mediator)
function TeamApplyPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.UpdatePlayerApplyList,
    NotificationDefines.TeamApply.ItemClickNtf,
    NotificationDefines.TeamApply.RemoveItemNtf
  }
end
function TeamApplyPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.UpdatePlayerApplyList then
    local applyInfoData = notify:GetBody()
    if nil == applyInfoData then
      return
    end
    self:GetViewComponent():UpdatePlayerApplyList(applyInfoData)
  elseif notify:GetName() == NotificationDefines.TeamApply.ItemClickNtf then
    local player = notify:GetBody()
    self:GetViewComponent():OnSelectPlayer(player)
  elseif notify:GetName() == NotificationDefines.TeamApply.RemoveItemNtf then
    local player = notify:GetBody()
    self:GetViewComponent():OnItemRemove(player)
  end
end
function TeamApplyPageMediator:OnRegister()
  self.ignorePlayerID = 0
end
function TeamApplyPageMediator:OnRemove()
end
return TeamApplyPageMediator
