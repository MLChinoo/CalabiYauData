local MichellePlaytimeTaskItem = class("MichellePlaytimeTaskItem", PureMVC.ViewComponentPage)
local MichellePlaytimeTaskItemMediator = require("Business/Activities/MichellePlaytime/Mediators/MichellePlaytimeTaskItemMediator")
function MichellePlaytimeTaskItem:ListNeededMediators()
  return {MichellePlaytimeTaskItemMediator}
end
local ETaskFinishedStateType = {}
ETaskFinishedStateType.None = 0
ETaskFinishedStateType.Progressing = 1
ETaskFinishedStateType.RewardToBeClaimed = 2
ETaskFinishedStateType.Finish = 3
local ETaskJumpPageType = {}
ETaskJumpPageType.None = 0
ETaskJumpPageType.Battle = 1
ETaskJumpPageType.MainLobby = 2
ETaskJumpPageType.BPTask = 3
function MichellePlaytimeTaskItem:Construct()
  MichellePlaytimeTaskItem.super.Construct(self)
  self.Btn_GoFinishTask.OnClicked:Add(self, self.OnClickGoFinishTask)
  self.Btn_GetReward.OnClicked:Add(self, self.OnClickGetReward)
end
function MichellePlaytimeTaskItem:Destruct()
  MichellePlaytimeTaskItem.super.Destruct(self)
  self.Btn_GoFinishTask.OnClicked:Remove(self, self.OnClickGoFinishTask)
  self.Btn_GetReward.OnClicked:Remove(self, self.OnClickGetReward)
end
function MichellePlaytimeTaskItem:InitTaskItemData()
  self.bIsCompeleted = false
  self.taskRewardTimes = 0
  if self.bp_taskId and self.bp_taskId > 0 then
    local taskCfg = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy):GetActivityTaskCfgById(self.bp_taskId)
    if taskCfg then
      self.Txt_TaskName:SetText(taskCfg.desc)
      if taskCfg.prize:Get(1) then
        self.taskRewardTimes = taskCfg.prize:Get(1).ItemAmount
        self.Txt_TaskFlipTimes:SetText(taskCfg.prize:Get(1).ItemAmount)
      else
        LogInfo("InitTaskItemData:", "taskCfg.prize:Get(1) is nil")
      end
      if taskCfg.taskConditions:Get(1) then
        local taskCondition = taskCfg.taskConditions:Get(1)
        if taskCondition.MainCondition and taskCondition.MainCondition.Num then
          self.Txt_TotalTaskTimes:SetText(tostring(taskCondition.MainCondition.Num))
        else
          LogInfo("InitTaskItemData:", "MainCondition is nil")
        end
      else
        LogInfo("InitTaskItemData:", "taskCfg.taskConditions:Get(1) is nil")
      end
      local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
      local activityTasks = BattlePassProxy:GetActivityTasks()
      if activityTasks then
        for key, value in pairs(activityTasks) do
          if value and value.taskId == self.bp_taskId then
            self:SetTaskFinishedState(value.state)
            if value.progressMap and #value.progressMap > 0 and not self.bIsCompeleted then
              for key1, value1 in pairs(value.progressMap) do
                self.Txt_CurrentTaskTimes:SetText(tostring(value1))
              end
              break
            end
            LogInfo("InitTaskItemData:", "task progressMap is nil, taskId is " .. tostring(value.taskId))
            break
          end
        end
      else
        LogInfo("InitTaskItemData:", "activityTasks is nil")
      end
    else
      LogInfo("InitTaskItemData:", "taskCfg is nil")
    end
    if self.bp_taskImage then
      self:SetImageByTexture2D(self.Image_task, self.bp_taskImage)
    else
      LogInfo("InitTaskItemData:", "bp_taskImage is nil")
    end
  else
    LogInfo("InitTaskItemData:", "bp_taskId is nil")
  end
end
function MichellePlaytimeTaskItem:OnClickGoFinishTask()
  if self.bp_taskJumpPageType then
    if self.bp_taskJumpPageType == ETaskJumpPageType.Battle then
      GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
        target = UIPageNameDefine.GameModeSelectPage
      })
    elseif self.bp_taskJumpPageType == ETaskJumpPageType.MainLobby then
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
      ViewMgr:ClosePage(self, UIPageNameDefine.MichellePlaytimeMainPage)
      ViewMgr:ClosePage(self, UIPageNameDefine.MichellePlaytimeTaskPage)
    elseif self.bp_taskJumpPageType == ETaskJumpPageType.BPTask then
      ViewMgr:ClosePage(self, UIPageNameDefine.MichellePlaytimeMainPage)
      ViewMgr:ClosePage(self, UIPageNameDefine.MichellePlaytimeTaskPage)
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, {
        pageType = UE4.EPMFunctionTypes.BattlePass,
        secondIndex = 3
      })
    end
    ViewMgr:ClosePage(self, UIPageNameDefine.ActivityEntryListPage)
  else
    LogInfo("MichellePlaytimeTaskItem", "bp_taskJumpPageType is nil")
  end
end
function MichellePlaytimeTaskItem:OnClickGetReward()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  SummerThemeSongProxy:ReqGetTaskReward(self.bp_taskId)
end
function MichellePlaytimeTaskItem:SetTaskFinishedState(state)
  if state == Pb_ncmd_cs.ETaskState.TaskState_PROGRESSING then
    self.Txt_CurrentTaskTimes:SetText("0")
    self.WS_TaskFinishedState:SetActiveWidgetIndex(ETaskFinishedStateType.Progressing)
    self.bIsCompeleted = false
  elseif state == Pb_ncmd_cs.ETaskState.TaskState_FINISH then
    self.Txt_CurrentTaskTimes:SetText(self.Txt_TotalTaskTimes:GetText())
    self.WS_TaskFinishedState:SetActiveWidgetIndex(ETaskFinishedStateType.RewardToBeClaimed)
    self.bIsCompeleted = true
  elseif state == Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN then
    self.Txt_CurrentTaskTimes:SetText(self.Txt_TotalTaskTimes:GetText())
    self.WS_TaskFinishedState:SetActiveWidgetIndex(ETaskFinishedStateType.Finish)
    self.bIsCompeleted = true
  end
  GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.ShowOneClickClaimBtn)
end
function MichellePlaytimeTaskItem:TaskCanbeReceiveReward()
  if self.WS_TaskFinishedState:GetActiveWidgetIndex() == ETaskFinishedStateType.RewardToBeClaimed then
    return true
  end
  return false
end
function MichellePlaytimeTaskItem:SetTaskId(taskId)
  self.bp_taskId = taskId
end
function MichellePlaytimeTaskItem:GetTaskNumber()
  if not self.bp_taskNum or self.bp_taskNum <= 0 then
    LogInfo("MP GetTaskNumber:", "bp_taskNum is invalid")
    return nil
  end
  return self.bp_taskNum
end
return MichellePlaytimeTaskItem
