local SurveyEntryPanelMediator = class("SurveyEntryPanelMediator", PureMVC.Mediator)
function SurveyEntryPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.OnResQuestionnaire,
    NotificationDefines.ReceiveSurveyReward
  }
end
function SurveyEntryPanelMediator:OnRegister()
end
function SurveyEntryPanelMediator:OnRemove()
end
function SurveyEntryPanelMediator:UpdateViewData()
  GameFacade:SendNotification(NotificationDefines.Activities.ReqActivitiesCmd)
end
function SurveyEntryPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  if noteName == NotificationDefines.OnResQuestionnaire or noteName == NotificationDefines.ReceiveSurveyReward then
    self:CheckSurveyStatus()
  end
end
function SurveyEntryPanelMediator:CheckSurveyStatus()
  local viewComponent = self:GetViewComponent()
  if not viewComponent.apartmentVisible then
    viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
  local isOpen = GameFacade:RetrieveProxy(ProxyNames.QuestionnaireProxy):GetQuestionIsOpen()
  if SuveyDC:IsReward() or not isOpen then
    viewComponent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    viewComponent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
return SurveyEntryPanelMediator
