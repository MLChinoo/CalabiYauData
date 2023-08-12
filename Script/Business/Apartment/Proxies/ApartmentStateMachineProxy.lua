local ApartmentStateMachineProxy = class("ApartmentStateMachineProxy", PureMVC.Proxy)
function ApartmentStateMachineProxy:OnRegister()
  self.StateMap = {}
  self.StateMachineConfigTable = {}
  local arrRows = ConfigMgr:GetApartmentStateMachineTableRow()
  if arrRows then
    self.StateMachineConfigTable = arrRows:ToLuaTable()
    for key, value in pairs(self.StateMachineConfigTable) do
      if value then
        local state = require(value.LuaClass)
        if state then
          local inst = state.new()
          if inst then
            inst:Init(value, self)
            self.StateMap[value.State] = inst
          end
        else
          LogError("ApartmentStateMachineProxy:OnRegister", "路径无效" .. value.LuaClass)
        end
      end
    end
  end
  self.bIsTwoStage = false
end
function ApartmentStateMachineProxy:OnRemove()
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
  if self.currentState then
    self.currentState:Stop()
    self.currentState = nil
  end
end
function ApartmentStateMachineProxy:GetStateConfig(id)
  if self.StateMachineConfigTable then
    return self.StateMachineConfigTable[tostring(id)]
  end
  return nil
end
function ApartmentStateMachineProxy:SwitchState(stateName)
  if UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):GetApartmentCharacter() == nil then
    LogError("ApartmentStateMachineProxy:SwitchState", "Character is nil,ban chang State")
    return
  end
  if nil == stateName then
    LogError("ApartmentStateMachineProxy:SwitchState", "stateName is nil,ban chang State")
    return
  end
  if nil == self.StateMap[stateName] then
    LogError("ApartmentStateMachineProxy:SwitchState", "state is nil,stateName is " .. stateName)
    return
  end
  if nil == self.timerHandler then
    self.timerHandler = TimerMgr:AddTimeTask(0, 1, 0, function()
      self:Tick()
    end)
  end
  if self.currentState then
    self.currentState:Stop()
    self.lastStateName = self.currentState.StateConfigRow.State
    self.lastStateID = self.currentState.StateConfigRow.StateID
    self.currentState = nil
    LogDebug("ApartmentStateMachineProxy:SwitchState", "Current State is " .. self.lastStateName .. " , next State is " .. stateName)
  end
  self.currentState = self.StateMap[stateName]
  self.currentState:Start()
end
function ApartmentStateMachineProxy:GetCurrentState()
  return self.currentState
end
function ApartmentStateMachineProxy:GetCurrentStateID()
  if self.currentState and self.currentState.StateConfigRow then
    return self.currentState.StateConfigRow.StateID
  end
  return 0
end
function ApartmentStateMachineProxy:SwitchStateByStateID(stateID)
  local stateCfg = self:GetStateConfig(stateID)
  if stateCfg then
    self:SwitchState(stateCfg.State)
  end
end
function ApartmentStateMachineProxy:Tick()
  if self.currentState == nil then
    return
  end
  self.currentState:Tick()
end
function ApartmentStateMachineProxy:StartStateMachine()
  if self.currentState then
    LogWarn("ApartmentStateMachineProxy:StartStateMachine", "StateMachine is already Start")
    return
  end
  LogDebug("ApartmentStateMachineProxy:StartStateMachine", "=============================Start Apartment StateMachine==============================")
  GameFacade:RetrieveProxy(ProxyNames.ApartmentTLogProxy):EntryApartmentTime()
  if GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy):IsAllGuideComplete() then
    self:SwitchState("Entry")
  else
    self:SwitchStateByStateID(UE4.ECyApartmentState.BeginnerGuidance)
  end
end
function ApartmentStateMachineProxy:StopStateMachine()
  if self.currentState then
    self.currentState:Stop()
    self.currentState = nil
  end
  self.lastStateName = nil
  self.lastStateID = nil
  if UE4.UCySequenceManager.Get(LuaGetWorld()):IsPlayingSequence() then
    UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
    UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
  end
  UE4.UCySequenceManager.Get(LuaGetWorld()):PlaySequence(15146061)
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentTLogProxy):LeaveApartmentTime()
  LogDebug("ApartmentStateMachineProxy:StopStateMachine", "=============================Stop Apartment StateMachine==============================")
end
function ApartmentStateMachineProxy:GetLastStateName()
  return self.lastStateName
end
function ApartmentStateMachineProxy:GetLastStateID()
  return self.lastStateID
end
function ApartmentStateMachineProxy:SwitchPromiseState()
  if UE4.UCySequenceManager.Get(LuaGetWorld()):IsPlayingSequence() then
    UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
    UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
  end
  self:SwitchState("Promise")
  LogDebug("ApartmentStateMachineProxy:SwitchPromiseState", "SwitchPromiseState")
end
function ApartmentStateMachineProxy:ExitPromiseState()
  if UE4.UCySequenceManager.Get(LuaGetWorld()):IsPlayingSequence() then
    UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
    UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
  end
  if GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy):IsAllGuideComplete() then
    self:SwitchStateByStateID(UE4.ECyApartmentState.SceneInterpretationIdle)
  else
    self:SwitchStateByStateID(UE4.ECyApartmentState.BeginnerGuidance)
  end
end
function ApartmentStateMachineProxy:SwitchFavorabilityUpState()
  if self.currentState == nil then
    return
  end
  if self.currentState and self.currentState.StateConfigRow.StateId == UE4.ECyApartmentState.FavorabilityUp then
    return
  end
  self:SwitchState("FavorabilityUp")
end
function ApartmentStateMachineProxy:SwitchWindingCorridorState()
  if UE4.UCySequenceManager.Get(LuaGetWorld()):IsPlayingSequence() then
    UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
  end
  self:SwitchStateByStateID(UE4.ECyApartmentState.WindingCorridorState)
  LogDebug("ApartmentStateMachineProxy:SwitchWindingCorridorState", "SwitchWindingCorridorState")
end
function ApartmentStateMachineProxy:ExitWindingCorridorState()
  self:SwitchPromiseState()
end
function ApartmentStateMachineProxy:SwithchGetGiftState()
  if UE4.UCySequenceManager.Get(LuaGetWorld()):IsPlayingSequence() then
    UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
    UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
  end
  self:SwitchStateByStateID(UE4.ECyApartmentState.GetGift)
  LogDebug("ApartmentStateMachineProxy:SwitcGetGiftState", "SwitcGetGiftState")
end
function ApartmentStateMachineProxy:OnScreenEffectsCallBack()
  if self.currentState and self.currentState.StateConfigRow.StateId == UE4.ECyApartmentState.FavorabilityUp then
    self.currentState:OnFullScreenEffectsCallBack()
  end
end
function ApartmentStateMachineProxy:OnReceiveAwardCallBack()
  if self.currentState and self.currentState.StateConfigRow.StateId == UE4.ECyApartmentState.GetGift then
    self.currentState:OnReceiveAwardCallBack()
  end
end
function ApartmentStateMachineProxy:PauseStateMachine()
  if self.currentState then
    LogDebug("ApartmentStateMachineProxy:SwitcGetGiftState", "PauseStateMachine")
    if UE4.UCySequenceManager.Get(LuaGetWorld()):IsPlayingSequence() then
      UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
      UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
      UE4.UCySequenceManager.Get(LuaGetWorld()):PlaySequence(15146061)
    end
    self:SwitchStateByStateID(UE4.ECyApartmentState.PauseState)
  end
end
function ApartmentStateMachineProxy:ReStartStateMachine()
  if self.currentState then
    LogDebug("ApartmentStateMachineProxy:SwitcGetGiftState", "ReStartStateMachine")
    self:SwitchStateByStateID(UE4.ECyApartmentState.Entry)
  end
end
function ApartmentStateMachineProxy:IsTwoStage()
  return self.bIsTwoStage
end
function ApartmentStateMachineProxy:SetTwoStage(bTwoStage)
  self.bIsTwoStage = bTwoStage
end
function ApartmentStateMachineProxy:GuideStepUpdate()
  if self.currentState and self.currentState.StateConfigRow.StateId == UE4.ECyApartmentState.BeginnerGuidance then
    self.currentState:NextStep()
  end
end
function ApartmentStateMachineProxy:OnRegressPageClose()
  if self.currentState and self.currentState.StateConfigRow.StateId == UE4.ECyApartmentState.LongTimeNotLoggin then
    self.currentState:OnRegressPageClose()
  end
end
return ApartmentStateMachineProxy
