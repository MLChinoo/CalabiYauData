local SummerThemeSongMainPageMediator = class("SummerThemeSongMainPageMediator", PureMVC.Mediator)
function SummerThemeSongMainPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes,
    NotificationDefines.Activities.SummerThemeSong.SetPageWidgetVisible,
    NotificationDefines.Activities.SummerThemeSong.ActiveMainPagePhaseFinishedParticle,
    NotificationDefines.Activities.SummerThemeSong.UpdateAwardPhase,
    NotificationDefines.Activities.InvitationLetter.RoundEnding,
    NotificationDefines.BattlePass.TaskUpdate,
    NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask,
    NotificationDefines.Activities.SummerThemeSong.SetFlipClick
  }
end
function SummerThemeSongMainPageMediator:OnRegister()
end
function SummerThemeSongMainPageMediator:OnRemove()
end
function SummerThemeSongMainPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local ViewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateRemainingFlipTimes then
    ViewComponent:UpdateRemainingFlipTimes()
    ViewComponent:SetOpenDeliverPageBtnState()
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.SetPageWidgetVisible then
    self:SetPageWidgetVisible(noteBody)
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.ActiveMainPagePhaseFinishedParticle then
    ViewComponent.lizi_bansui:SetReactivate(true)
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.UpdateAwardPhase then
    ViewComponent:SetOpenDeliverPageBtnState()
  elseif noteName == NotificationDefines.Activities.InvitationLetter.RoundEnding then
    ViewComponent:PlayAnimation(ViewComponent.Switch, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  elseif noteName == NotificationDefines.BattlePass.TaskUpdate then
    ViewComponent:UpdateFlipChanceState()
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.UpdateDailyTask then
    ViewComponent:UpdateFlipChanceState()
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.SetFlipClick then
    if not noteBody then
      ViewComponent.BP_STS_FlipFunctionPage_PC:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      ViewComponent.BP_STS_FlipFunctionPage_PC:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function SummerThemeSongMainPageMediator:SetPageWidgetVisible(bVisible)
  local visibleEnum = UE4.ESlateVisibility.SelfHitTestInvisible
  if not bVisible then
    visibleEnum = UE4.ESlateVisibility.Collapsed
  end
  local ViewComponent = self:GetViewComponent()
  ViewComponent.BP_STS_FlipFunctionPage_PC:SetVisibility(visibleEnum)
  ViewComponent.BP_STS_MilestoneRewardsPanel_PC:SetVisibility(visibleEnum)
  ViewComponent.Canvas_BtnArea:SetVisibility(visibleEnum)
  ViewComponent.Canvas_ActivityMainContentInfo:SetVisibility(visibleEnum)
  ViewComponent.Canvas_ActivityTimeAndRuleInfo:SetVisibility(visibleEnum)
end
return SummerThemeSongMainPageMediator
