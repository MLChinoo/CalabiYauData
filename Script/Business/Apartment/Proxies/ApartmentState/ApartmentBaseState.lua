local ApartmentBaseState = class("ApartmentBaseState")
function ApartmentBaseState:Init(stateConfigRow, stateMachine)
  self.StateConfigRow = stateConfigRow
  self.ApartmentEntryStateMachine = stateMachine
  LogDebug("ApartmentBaseState:Init", self.__cname .. " is Init")
end
function ApartmentBaseState:Start()
  LogDebug(self.__cname .. ":Start", self.__cname .. " is Start")
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnSequenceStopDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self, "OnSequenceStopCallBack")
  end
  self.currentPlayingSequenceID = 0
end
function ApartmentBaseState:Stop()
  LogDebug(self.__cname .. ":Stop", self.__cname .. " is Stop")
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self.OnSequenceStopDelegate)
  end
  self.currentPlayingSequenceID = 0
  self:SetTextBubblesVisible(false)
  self:StopGalTextBubblesTimer()
end
function ApartmentBaseState:Tick(time)
end
function ApartmentBaseState:JudgeCond()
  LogDebug(self.__cname .. ":JudgeCond", self.__cname .. " Transiton JudgeCond")
  if self.StateConfigRow.TransitionStateConditions then
    local count = self.StateConfigRow.TransitionStateConditions:Length()
    for index = 1, count do
      local condition = self.StateConfigRow.TransitionStateConditions:Get(index)
      if self:JudgeConditionMeet(condition.ConditionID) then
        self:SwitchState(condition.NextState)
        break
      end
    end
  end
end
function ApartmentBaseState:JudgeConditionMeet(conditionID)
  LogDebug(self.__cname .. ":JudgeConditionMeet", " ConditionID is" .. conditionID)
  if 0 == conditionID then
    return true
  end
  return UE4.UCyConditionGameInstanceSubsystem.Get(LuaGetWorld()):IsMatchCondition(conditionID, "")
end
function ApartmentBaseState:SwitchState(stateName)
  if self.ApartmentEntryStateMachine then
    LogDebug(self.__cname .. ":SwitchState", "current state is " .. self.__cname .. ", Next state is " .. stateName)
    self.ApartmentEntryStateMachine:SwitchState(stateName)
  end
end
function ApartmentBaseState:SwitchStateByID(stateID)
  if self.ApartmentEntryStateMachine then
    self.ApartmentEntryStateMachine:SwitchStateByStateID(stateID)
  end
end
function ApartmentBaseState:PlaySequence(sequenceID)
  if nil == sequenceID then
    LogWarn(self.__cname .. ":PlaySequence", " sequenceID is nil")
    return
  end
  LogDebug(self.__cname .. ":PlaySequence", " Current Sequence ID : " .. sequenceID)
  self.currentPlayingSequenceID = sequenceID
  UE4.UCySequenceManager.Get(LuaGetWorld()):PlaySequence(sequenceID)
end
function ApartmentBaseState:OnSequenceStopCallBack(sequenceId, reasonType)
  LogDebug(self.__cname .. ":OnSequenceStopCallBack", self.__cname .. " Stop Sequence ID is:" .. sequenceId)
  self.sequenceId = sequenceId
  self.reasonType = reasonType
  self.waitCallBackTimer = TimerMgr:AddFrameTask(1, 0, 1, function()
    self:OnSequenceStopCallBackWaitFrame()
  end)
end
function ApartmentBaseState:OnSequenceStopCallBackWaitFrame()
  if self.waitCallBackTimer then
    self.waitCallBackTimer:EndTask()
    self.waitCallBackTimer = nil
  end
  self:OnSequenceStop(self.sequenceId, self.reasonType)
end
function ApartmentBaseState:GetStateType()
  if self.StateConfigRow then
    return self.StateConfigRow.StateType
  end
  return 0
end
function ApartmentBaseState:GetCurrStateSequenceID()
  local data = self:GetCurrStateSequenceConfig()
  if data and data.SequenceArray and data.SequenceArray:Length() >= 1 then
    return data.SequenceArray:Get(1)
  end
  LogWarn(self.__cname .. ":GetCurrStateSequenceID", "Current SequenceArray Config is nil")
  return 0
end
function ApartmentBaseState:GetCurrStateSequenceConfig()
  local apartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  return apartmentRoomProxy:GetStateSequenceConfig(self.StateConfigRow.StateId)
end
function ApartmentBaseState:PlayStateSeqence()
  LogDebug("ApartmentBaseState:PlayStateSeqence", "PlayStateSeqence")
  local sequenceID = self:GetCurrStateSequenceID()
  if nil == sequenceID or 0 == sequenceID then
    LogWarn(self.__cname .. ":PlayStateSeqence", "Sequence ID is nil,StateId : " .. self.StateConfigRow.StateId)
    self:JudgeCond()
    return
  end
  self:PlaySequence(sequenceID)
end
function ApartmentBaseState:GetLastStateID()
  return self.ApartmentEntryStateMachine:GetLastStateID()
end
function ApartmentBaseState:GetCurrentRoleStateAesst()
  local apartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  return apartmentStateMachineConfigProxy:GetCurrentRoleStateAesst(self.StateConfigRow.StateId)
end
function ApartmentBaseState:PlayLastStateTransSequence()
  local data = self:GetCurrStateSequenceConfig()
  if data then
    local lastStateID = self:GetLastStateID()
    local sequenceID = data.LastStateTransitionMap:Find(lastStateID)
    self:PlaySequence(sequenceID)
  end
end
function ApartmentBaseState:SetLookAtEnable(bEnable)
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):SetLookAtEnable(bEnable)
end
function ApartmentBaseState:SetTextBubblesVisible(bVisible)
  self.bGalTextBubblesVisible = bVisible
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):SetGalTextBubblesVisible(bVisible)
end
function ApartmentBaseState:StartGalTextBubblesTimer()
  if self.bGalTextBubblesVisible then
    LogDebug(self.__cname .. ":StartGalTextBubblesTimer", "GalTextBubbles Is Visible")
    return
  end
  local stateConfig = self:GetCurrStateSequenceConfig()
  if stateConfig and stateConfig.GalTextBubblesConfig and stateConfig.GalTextBubblesConfig.bShowGalTextBubbles then
    LogDebug(self.__cname .. ":StartGalTextBubblesTimer", "StartGalTextBubblesTimer")
    self.showGalTextBubblesTimer = TimerMgr:AddTimeTask(stateConfig.GalTextBubblesConfig.HowLongTimeShow, 0, 1, function()
      self:SetTextBubblesVisible(true)
      self:StopGalTextBubblesTimer()
    end)
  end
end
function ApartmentBaseState:StopGalTextBubblesTimer()
  if self.showGalTextBubblesTimer then
    LogDebug(self.__cname .. ":StopGalTextBubblesTimer", "StopGalTextBubblesTimer")
    self.showGalTextBubblesTimer:EndTask()
    self.showGalTextBubblesTimer = nil
  end
end
function ApartmentBaseState:HideUI()
  GameFacade:SendNotification(NotificationDefines.ApartmentStateMachine.EnterSincerityInteractionState)
end
function ApartmentBaseState:ShowUI()
  GameFacade:SendNotification(NotificationDefines.ApartmentStateMachine.ExitSincerityInteractionState)
end
return ApartmentBaseState
