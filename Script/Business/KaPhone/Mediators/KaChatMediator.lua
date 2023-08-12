local KaChatMediator = class("KaChatMediator", PureMVC.Mediator)
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
local ChatPanel
function KaChatMediator:OnRegister()
  ChatPanel = self:GetViewComponent()
end
function KaChatMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfKaChatList,
    NotificationDefines.NtfKaChatDetail,
    NotificationDefines.NtfKaChatNewDetail,
    NotificationDefines.NtfKaChatItem,
    NotificationDefines.NtfKaChatSubItem,
    NotificationDefines.NtfKaChatSubItemState
  }
end
function KaChatMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  local Type = notification:GetType()
  if ChatPanel:GetIsActive() then
    if Name == NotificationDefines.NtfKaChatList then
      ChatPanel:UpdateList(Body)
    elseif Name == NotificationDefines.NtfKaChatDetail then
      ChatPanel:UpdateChatDetail(Body, Type)
    elseif Name == NotificationDefines.NtfKaChatNewDetail then
      ChatPanel.ChatDetailPanel:AddNewDetail(Body)
    elseif Name == NotificationDefines.NtfKaChatItem then
      if self.LastClickedChatItem then
        if self.LastClickedChatItem == Body then
          return nil
        end
        self.LastClickedChatItem:OnCloseSubList()
      end
      self.LastClickedChatItem = Body
    elseif Name == NotificationDefines.NtfKaChatSubItem then
      if self.LastClickedSubItem then
        if self.LastClickedSubItem == Body then
          return nil
        end
        self.LastClickedSubItem:ReSetState()
      end
      self.LastClickedSubItem = Body
    elseif Name == NotificationDefines.NtfKaChatSubItemState then
      if self.LastClickedSubItem then
        self.LastClickedSubItem:UpdateState()
      end
      if self.LastClickedChatItem then
        self.LastClickedChatItem:UpdateRedDot()
      end
    end
  end
end
return KaChatMediator
