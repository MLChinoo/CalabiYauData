local MichellePlaytimeFlipRewardPageMediator = class("MichellePlaytimeFlipRewardPageMediator", PureMVC.Mediator)
function MichellePlaytimeFlipRewardPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.MichellePlaytime.UpdateMichellePlaytimeData,
    NotificationDefines.Activities.MichellePlaytime.UpdateUnlockReward,
    NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum
  }
end
function MichellePlaytimeFlipRewardPageMediator:OnRegister()
end
function MichellePlaytimeFlipRewardPageMediator:OnRemove()
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
function MichellePlaytimeFlipRewardPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local noteBody = notification:GetBody()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.MichellePlaytime.UpdateMichellePlaytimeData then
    self:OnHandleUpdateMichellePlaytimeData()
  elseif noteName == NotificationDefines.Activities.MichellePlaytime.UpdateUnlockReward then
    if type(noteBody) == "number" then
      viewComponent["RewardItem_" .. tostring(noteBody)]:SetItemReceivedState()
      self:HandleNextRewardPhaseState()
    end
  elseif noteName == NotificationDefines.Activities.MichellePlaytime.UpdateConsumeNum then
    self:HandleNextRewardPhaseState()
  end
end
function MichellePlaytimeFlipRewardPageMediator:OnHandleUpdateMichellePlaytimeData()
  self:UpdateActivityUnLockConfigData()
  self:UpdateActivityUnLockDatas()
  local viewComponent = self:GetViewComponent()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local currentRewardPhase = MichellePlaytimeProxy:GetCurrentRewardPhase()
  if not (currentRewardPhase > MichellePlaytimeProxy:GetActivityUnLockConfigDataNum()) then
    self.updateTimer = TimerMgr:AddTimeTask(1.0, 0, 1, function()
      GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.ShowPendingReceiveStateParticle)
    end)
  end
end
function MichellePlaytimeFlipRewardPageMediator:UpdateActivityUnLockConfigData()
  local viewComponent = self:GetViewComponent()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local activityUnLockConfigData = MichellePlaytimeProxy:GetActivityUnLockConfigData()
  if activityUnLockConfigData then
    for key, value in pairs(activityUnLockConfigData) do
      if value.grid and value.items then
        for key1, value1 in pairs(value.items) do
          viewComponent["RewardItem_" .. tostring(value.grid)]:InitItem(value1)
          break
        end
      else
        LogInfo("MichellePlaytime", "unlock config data is nil, gridId=" .. tostring(value.grid))
      end
    end
  else
    LogInfo("MichellePlaytime", "activityUnLockConfigData is nil")
  end
end
function MichellePlaytimeFlipRewardPageMediator:UpdateActivityUnLockDatas()
  local viewComponent = self:GetViewComponent()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local activityUnLockDatas = MichellePlaytimeProxy:GetActivityUnLockDatas()
  if activityUnLockDatas then
    for key, value in pairs(activityUnLockDatas) do
      if value then
        viewComponent["RewardItem_" .. tostring(value)]:SetItemReceivedState()
        if value > 1 and viewComponent["WS_Progress" .. tostring(value - 1)] then
          viewComponent["WS_Progress" .. tostring(value - 1)]:SetActiveWidgetIndex(1)
        end
      else
        LogInfo("MichellePlaytime", "unLock datas is nil, gridId=" .. tostring(value))
      end
    end
  else
    LogInfo("MichellePlaytime", "activityUnLockDatas is nil")
  end
  self:HandleNextRewardPhaseState()
end
function MichellePlaytimeFlipRewardPageMediator:HandleNextRewardPhaseState()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local itemCnt = MichellePlaytimeProxy:GetGamePointCnt()
  local viewComponent = self:GetViewComponent()
  local currentRewardPhase = MichellePlaytimeProxy:GetCurrentRewardPhase()
  if currentRewardPhase > MichellePlaytimeProxy:GetActivityUnLockConfigDataNum() then
    viewComponent.Canvas_FlipRewardFinished:SetVisibility(UE4.ESlateVisibility.Visible)
    viewComponent.Canvas_Rewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
    viewComponent:PlayAnimation(viewComponent.End, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    return
  elseif currentRewardPhase > 1 and viewComponent["WS_Progress" .. tostring(currentRewardPhase - 1)] then
    viewComponent["WS_Progress" .. tostring(currentRewardPhase - 1)]:SetActiveWidgetIndex(1)
  end
  if itemCnt > 0 and viewComponent["RewardItem_" .. tostring(currentRewardPhase)] then
    viewComponent["RewardItem_" .. tostring(currentRewardPhase)]:SetItemPendingState()
  end
end
return MichellePlaytimeFlipRewardPageMediator
