local KaMailMediator = class("KaMailMediator", PureMVC.Mediator)
local MailPanel
function KaMailMediator:OnRegister()
  MailPanel = self:GetViewComponent()
  self.LastClickMailItem = nil
end
function KaMailMediator:OnRemove()
  self.LastClickMailItem = nil
end
function KaMailMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfMailDataList,
    NotificationDefines.NtfMailDataDetail,
    NotificationDefines.NtfMailDataNewMail,
    NotificationDefines.NtfClickMailItem,
    NotificationDefines.DeleteCurMail
  }
end
function KaMailMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  local Type = notification:GetType()
  if not MailPanel:GetIsActive() then
    return
  end
  if Body then
    if Name == NotificationDefines.NtfMailDataList then
      MailPanel:Update(Body)
      MailPanel:RefreshSelfMailDetail()
    elseif Name == NotificationDefines.NtfMailDataDetail then
      MailPanel:UpdateMailDetail(Body)
      if self.LastClickMailItem then
        self.LastClickMailItem:RefreshMainItemState(Body)
      end
    elseif Name == NotificationDefines.NtfMailDataNewMail then
      MailPanel:Update(Body)
    elseif Name == NotificationDefines.NtfClickMailItem then
      if self.LastClickMailItem then
        if self.LastClickMailItem == Body then
          return nil
        end
        self.LastClickMailItem:ResetState()
      end
      self.LastClickMailItem = Body
    end
  else
    if Name == NotificationDefines.DeleteCurMail then
      MailPanel:ClearCurMailDetail()
    end
    self.LastClickMailItem = nil
  end
end
return KaMailMediator
