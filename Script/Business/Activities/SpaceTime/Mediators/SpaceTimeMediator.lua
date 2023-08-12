local SpaceTimeMediator = class("SpaceTimeMediator", PureMVC.Mediator)
function SpaceTimeMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SpaceTime.CardFlip,
    NotificationDefines.Activities.SpaceTime.CardSend,
    NotificationDefines.Activities.SpaceTime.NewDay
  }
end
function SpaceTimeMediator:OnRegister()
  self:GetViewComponent().updateViewEvent:Add(self.InitCardData, self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function SpaceTimeMediator:OnRemove()
  self:GetViewComponent().updateViewEvent:Remove(self.InitCardData, self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
end
function SpaceTimeMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.SpaceTimeProxy)
  if noteName == NotificationDefines.Activities.SpaceTime.CardFlip then
    local noteBody = notification:GetBody()
    ViewMgr:ClosePage(viewComponent, UIPageNameDefine.PendingPage)
    if noteBody.success then
      viewComponent:FlipCardWidget(proxy:GetSpaceTimeCardDataByDay(noteBody.day))
    end
  elseif noteName == NotificationDefines.Activities.SpaceTime.CardSend then
    ViewMgr:ClosePage(viewComponent, UIPageNameDefine.PendingPage)
    local noteBody = notification:GetBody()
    if noteBody.success then
      viewComponent:SendCardWidget(proxy:GetSpaceTimeCardSend())
    end
  elseif noteName == NotificationDefines.Activities.SpaceTime.NewDay then
    local day = proxy:GetCurrentDay()
    local currentDayCardData = proxy:GetSpaceTimeCardDataByDay(day)
    viewComponent:SetSpaceTimeDay(day, proxy:GetSpaceTimeCardSendDay())
    viewComponent:SetSpaceTimeStage(proxy:GetSpaceTimeStage())
    viewComponent:UpdateCardWidget(currentDayCardData)
  end
end
function SpaceTimeMediator:InitCardData()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.SpaceTimeProxy)
  if proxy then
    self:GetViewComponent():SetSpaceTimeDay(proxy:GetCurrentDay(), proxy:GetSpaceTimeCardSendDay())
    self:GetViewComponent():SetSpaceTimeStage(proxy:GetSpaceTimeStage())
    self:GetViewComponent():InitCardWidget(proxy:GetSpaceTimeCardDataList(), proxy:GetSpaceTimeCardSend())
  end
end
return SpaceTimeMediator
