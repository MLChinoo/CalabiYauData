local SummerThemeSongFlipFunctionPanelMediator = class("SummerThemeSongFlipFunctionPanelMediator", PureMVC.Mediator)
function SummerThemeSongFlipFunctionPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.UpdateData,
    NotificationDefines.Activities.SummerThemeSong.PlayerFlipAnimation,
    NotificationDefines.Activities.SummerThemeSong.FlipRoundAllFinished
  }
end
function SummerThemeSongFlipFunctionPanelMediator:OnRegister()
  for index = 1, 16 do
    self:GetViewComponent()["FlipItem_" .. tostring(index)]:InitGrid(index)
  end
  self.curPhase = 0
end
function SummerThemeSongFlipFunctionPanelMediator:OnRemove()
end
function SummerThemeSongFlipFunctionPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateData then
    self:InitPanelData(noteBody)
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.PlayerFlipAnimation then
    local FlipItem = viewComponent["FlipItem_" .. tostring(noteBody.grid)]
    if FlipItem then
      FlipItem:InitData(noteBody.item_id, noteBody.cue, noteBody.grid)
      FlipItem:PlayFlipAnimation(noteBody.cue)
    end
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.FlipRoundAllFinished then
    viewComponent:PlayRoundFinishedAnim(true)
  end
end
function SummerThemeSongFlipFunctionPanelMediator:InitPanelData(noteBody)
  if noteBody and noteBody.cur_phase then
    local viewComponent = self:GetViewComponent()
    local currentPhase = noteBody.cur_phase
    local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
    if self.curPhase == currentPhase then
      return
    else
      local oldPhase = self.curPhase
      self.curPhase = currentPhase
      if 0 ~= oldPhase and currentPhase > 1 and currentPhase < 6 then
        GameFacade:SendNotification(NotificationDefines.Activities.InvitationLetter.RoundEnding)
      elseif SummerThemeSongProxy:GetAllPhaseFinished() then
        viewComponent:PlayRoundFinishedAnim(false)
        return
      end
    end
    viewComponent.Txt_FlipRound:SetText(currentPhase)
    local currentPhaseRuleDes = viewComponent.bp_phaseFlipRuleDesArray:Get(currentPhase)
    viewComponent.Txt_PhaseFlipRuleDes:SetText(currentPhaseRuleDes)
    if noteBody.cfg and noteBody.cfg.phase_reward then
      for key, value in pairs(noteBody.cfg.phase_reward) do
        if value.id == currentPhase and value.name then
          viewComponent.Txt_FlipRoundName:SetText(value.name)
        end
      end
    end
    for index = 1, viewComponent.FlipItemsList:GetChildrenCount() do
      viewComponent["FlipItem_" .. tostring(index)]:ResetPanel()
    end
    if noteBody.phase_prize then
      for key, value in pairs(noteBody.phase_prize) do
        if value.phase == currentPhase then
          viewComponent["FlipItem_" .. tostring(value.grid)]:InitData(value.item_id, value.cue, value.grid)
        end
      end
    end
  end
end
return SummerThemeSongFlipFunctionPanelMediator
