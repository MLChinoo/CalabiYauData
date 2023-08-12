local MichellePlaytimeMainPageMediator = class("MichellePlaytimeMainPageMediator", PureMVC.Mediator)
function MichellePlaytimeMainPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.MichellePlaytime.UpdateMichellePlaytimeData,
    NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum,
    NotificationDefines.BattlePass.TaskUpdate
  }
end
function MichellePlaytimeMainPageMediator:OnRegister()
end
function MichellePlaytimeMainPageMediator:OnRemove()
end
function MichellePlaytimeMainPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local ViewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.MichellePlaytime.UpdateMichellePlaytimeData then
    ViewComponent:UpdateConsumeNum()
  elseif noteName == NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum then
    ViewComponent:UpdateConsumeNum()
  elseif noteName == NotificationDefines.BattlePass.TaskUpdate then
    ViewComponent:SetGamePointRedDot()
  end
end
function MichellePlaytimeMainPageMediator:InitPageData(pageData)
  if pageData then
    local ViewComponent = self:GetViewComponent()
    self.InviteCodeList = {}
    for index = 1, 3 do
      self.InviteCodeList[index] = ViewComponent["InvitationCode_" .. tostring(index)]
    end
    local invitationCode_CfgList = pageData.cfgList
    if invitationCode_CfgList then
      for key, value in pairs(invitationCode_CfgList) do
        local subActivityId = value.sub_activity_id
        if subActivityId and self.InviteCodeList[subActivityId] then
          self.InviteCodeList[subActivityId]:InitCfgList(value)
        end
      end
    end
    local invitationCode_DataList = pageData.dataList
    if invitationCode_DataList then
      if pageData.bIsArray then
        for key, value in pairs(invitationCode_DataList) do
          local subActivityId = value.sub_activity_id
          if subActivityId and self.InviteCodeList[subActivityId] then
            self.InviteCodeList[subActivityId]:InitDataList(value)
          end
        end
      else
        local subActivityId = invitationCode_DataList.sub_activity_id
        if subActivityId and self.InviteCodeList[subActivityId] then
          self.InviteCodeList[subActivityId]:InitDataList(invitationCode_DataList)
        end
      end
    end
  end
end
return MichellePlaytimeMainPageMediator
