local InvitationLetterMainPageMediator = class("InvitationLetterMainPageMediator", PureMVC.Mediator)
function InvitationLetterMainPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.InvitationLetter.UpdateInvitationLetterData
  }
end
function InvitationLetterMainPageMediator:OnRegister()
end
function InvitationLetterMainPageMediator:OnRemove()
end
function InvitationLetterMainPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local ViewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.InvitationLetter.UpdateInvitationLetterData then
    self:InitPageData(noteBody)
  end
end
function InvitationLetterMainPageMediator:InitPageData(pageData)
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
return InvitationLetterMainPageMediator
