local RoleWarmUpTaskItemMediator = require("Business/Activities/MeredithRoleWarmUp/Mediators/RoleWarmUpTaskItemMediator")
local RoleWarmUpTaskItem = class("RoleWarmUpTaskItem", PureMVC.ViewComponentPanel)
function RoleWarmUpTaskItem:ListNeededMediators()
  return {RoleWarmUpTaskItemMediator}
end
function RoleWarmUpTaskItem:Construct()
  RoleWarmUpTaskItem.super.Construct(self)
  self.GotoBtn.OnClicked:Add(self, self.OnClickGotoBtn)
  self.ReceiveBtn.OnClicked:Add(self, self.OnClickReceiveBtn)
end
function RoleWarmUpTaskItem:Destruct()
  RoleWarmUpTaskItem.super.Destruct(self)
  self.GotoBtn.OnClicked:Remove(self, self.OnClickGotoBtn)
  self.ReceiveBtn.OnClicked:Add(self, self.OnClickReceiveBtn)
end
function RoleWarmUpTaskItem:OnClickGotoBtn()
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local taskCfg = BattlePassProxy:GetActivityTaskCfgById(self.taskId)
  if taskCfg then
    if taskCfg.TaskConditions:Get(1) then
      local taskCondition = taskCfg.TaskConditions:Get(1)
      if taskCondition.MainCondition and taskCondition.MainCondition.MainType then
        if UE4.ECyTaskMainConditionType.Lobby == taskCondition.MainCondition.MainType then
          ViewMgr:ClosePage(self, UIPageNameDefine.RoleWarmUpPage)
          ViewMgr:ClosePage(self, UIPageNameDefine.ActivityEntryListPage)
          GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
        elseif UE4.ECyTaskMainConditionType.Game == taskCondition.MainCondition.MainType or UE4.ECyTaskMainConditionType.Battle == taskCondition.MainCondition.MainType then
          GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
            target = UIPageNameDefine.GameModeSelectPage
          })
        else
          LogDebug("OnClickGotoBtn:", "taskCondition.MainCondition.MainType = " .. tostring(taskCondition.MainCondition.MainType))
        end
      else
        LogDebug("OnClickGotoBtn:", "MainCondition is nil")
      end
    else
      LogDebug("OnClickGotoBtn:", "taskCfg.TaskConditions:Get(1) is nil")
    end
  else
    LogDebug("OnClickGotoBtn:", "taskCfg is nil")
  end
end
function RoleWarmUpTaskItem:OnClickReceiveBtn()
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    if self.taskId == nil or 0 == self.taskId then
      LogError("RoleWarmUpTaskItem", "OnClickReceiveBtn self.taskId = " .. tostring(self.taskId))
      return
    end
    LogDebug("RoleWarmUpTaskItem", "OnClickReceiveBtn self.taskId = " .. tostring(self.taskId))
    RoleWarmUpProxy:ReqGetTaskReward(self.taskId)
    self.ReceiveRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function RoleWarmUpTaskItem:UpdataTaskItem()
  if self.taskId then
    self:InitTaskItem(self.taskId)
  end
end
function RoleWarmUpTaskItem:InitTaskItem(taskId)
  self.taskId = taskId
  local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if BattlePassProxy then
    local taskCfg = BattlePassProxy:GetActivityTaskCfgById(taskId)
    if taskCfg then
      self.TitleText:SetText(taskCfg.title)
      self.DescText:SetText(taskCfg.Desc)
      if taskCfg.prize and taskCfg.prize:Get(1) then
        self.RewardNum:SetText(taskCfg.prize:Get(1).ItemAmount)
      else
        LogDebug("InitTaskItem:", "taskCfg.prize:Get(1) is nil")
      end
      if taskCfg.TaskConditions:Get(1) then
        local taskCondition = taskCfg.TaskConditions:Get(1)
        if taskCondition.MainCondition and taskCondition.MainCondition.Num then
          self.SumPointsNum = taskCondition.MainCondition.Num
          self.SumPoints:SetText(tostring(taskCondition.MainCondition.Num))
        else
          LogDebug("InitTaskItem:", "MainCondition is nil")
        end
      else
        LogDebug("InitTaskItem:", "taskCfg.TaskConditions:Get(1) is nil")
      end
      local activityTasks = BattlePassProxy:GetActivityTasks()
      if activityTasks then
        for key, value in pairs(activityTasks) do
          if value and value.taskId == taskId then
            self:SetTaskFinishedState(value.state)
            if value.progressMap and #value.progressMap > 0 then
              if value.state == Pb_ncmd_cs.ETaskState.TaskState_PROGRESSING then
                for key1, value1 in pairs(value.progressMap) do
                  self.CurrentPoints:SetText(tostring(value1))
                  self.ProgressBar:SetPercent(value1 / self.SumPointsNum)
                end
                break
              end
              if value.state == Pb_ncmd_cs.ETaskState.TaskState_FINISH or value.state == Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN then
                self.ProgressBar:SetPercent(1)
                break
              end
              LogDebug("InitTaskItem:", "value.state = " .. tostring(value.state))
              break
            end
            LogDebug("InitTaskItem:", "task progressMap is nil, taskId is " .. tostring(value.taskId))
            break
          end
        end
      else
        LogDebug("InitTaskItem:", "activityTasks is nil")
      end
    else
      LogDebug("InitTaskItem:", "taskCfg is nil")
    end
  end
end
function RoleWarmUpTaskItem:SetTaskFinishedState(state)
  if state == Pb_ncmd_cs.ETaskState.TaskState_PROGRESSING then
    self.ReceiveRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FinishRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.GotoRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
    self.ReceiveRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.FinishRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.GotoRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif state == Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN then
    self.ReceiveRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FinishRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.GotoRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return RoleWarmUpTaskItem
