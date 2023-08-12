local SummerThemeSongMilestoneRewardPanelMediator = class("SummerThemeSongMilestoneRewardPanelMediator", PureMVC.Mediator)
function SummerThemeSongMilestoneRewardPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SummerThemeSong.UpdateData,
    NotificationDefines.Activities.SummerThemeSong.UpdateAwardPhase,
    NotificationDefines.Activities.SummerThemeSong.UpdateOpenCard
  }
end
function SummerThemeSongMilestoneRewardPanelMediator:OnRegister()
end
function SummerThemeSongMilestoneRewardPanelMediator:OnRemove()
end
function SummerThemeSongMilestoneRewardPanelMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  if noteName == NotificationDefines.Activities.SummerThemeSong.UpdateData then
    self:InitPanelData(noteBody)
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.UpdateAwardPhase then
    self:UpdateMilestoneRewardItemReceiveStatus(noteBody)
  elseif noteName == NotificationDefines.Activities.SummerThemeSong.UpdateOpenCard then
    self:UpdateMilestoneRewardProgress(noteBody)
  end
end
function SummerThemeSongMilestoneRewardPanelMediator:InitPanelData(noteBody)
  if noteBody and noteBody.cur_phase and noteBody.phase_reward and noteBody.cfg.summer_concert.max_phase then
    local phaseReward = noteBody.phase_reward
    local maxPhase = noteBody.cfg.summer_concert.max_phase
    local curPhase = noteBody.cur_phase
    self.currentPhase = curPhase
    local MilestoneRewardItemStatus = 0
    local NeedReceiveRewardCnt = 0
    local viewComponent = self:GetViewComponent()
    for index = 1, maxPhase do
      MilestoneRewardItemStatus = 0
      local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
      if curPhase > 0 and index < curPhase then
        MilestoneRewardItemStatus = 1
        NeedReceiveRewardCnt = NeedReceiveRewardCnt + 1
      elseif index == curPhase and SummerThemeSongProxy:IsFinishedAllFlipRound() then
        MilestoneRewardItemStatus = 1
        NeedReceiveRewardCnt = NeedReceiveRewardCnt + 1
      end
      viewComponent["MilestoneRewardsItem_" .. tostring(index)]:InitMilestoneRewardItem(MilestoneRewardItemStatus)
    end
    MilestoneRewardItemStatus = 2
    for key, value in pairs(phaseReward) do
      viewComponent["MilestoneRewardsItem_" .. tostring(value)]:InitMilestoneRewardItem(MilestoneRewardItemStatus)
    end
    self:InitMilestoneRewardProgress(noteBody)
  end
end
function SummerThemeSongMilestoneRewardPanelMediator:UpdateMilestoneRewardItemReceiveStatus(noteBody)
  if noteBody.phase and noteBody.phase > 0 then
    self:GetViewComponent()["MilestoneRewardsItem_" .. tostring(noteBody.phase)]:InitMilestoneRewardItem(2)
  end
end
function SummerThemeSongMilestoneRewardPanelMediator:InitMilestoneRewardProgress(noteBody)
  if noteBody and noteBody.phase_prize then
    local curPhase = self.currentPhase
    if curPhase and curPhase > 0 then
      local viewComponent = self:GetViewComponent()
      local subProgressCount = 0
      for key, value in pairs(noteBody.phase_prize) do
        if value.cue and value.cue == true and value.phase == self.currentPhase then
          subProgressCount = subProgressCount + 1
        end
      end
      self.subProgressCount = subProgressCount
      self:SetMilestoneRewardProgressUI()
    end
  end
end
function SummerThemeSongMilestoneRewardPanelMediator:UpdateMilestoneRewardProgress(noteBody)
  if noteBody and noteBody.cue and noteBody.cue == true and self.subProgressCount and self.currentPhase then
    self.subProgressCount = self.subProgressCount + 1
    self:SetMilestoneRewardProgressUI()
  end
end
function SummerThemeSongMilestoneRewardPanelMediator:SetMilestoneRewardProgressUI()
  if self.subProgressCount and self.currentPhase then
    local viewComponent = self:GetViewComponent()
    for index = 1, self.currentPhase do
      local progressCount = 0
      if index == self.currentPhase then
        progressCount = self.subProgressCount
      else
        progressCount = 2
      end
      if progressCount > 0 then
        for index1 = 1, progressCount do
          local imagePregressName = "Image_Round" .. tostring(index) .. "-" .. tostring(index1)
          if viewComponent[imagePregressName] then
            viewComponent[imagePregressName]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          end
        end
      end
    end
  end
end
return SummerThemeSongMilestoneRewardPanelMediator
