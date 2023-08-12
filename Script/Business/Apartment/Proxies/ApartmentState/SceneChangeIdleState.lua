local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local SceneChangeIdleState = class("SceneChangeIdleState", BaseState)
local ApartmentStateMachineConfigProxy
local ApartmentRoomEnum = require("Business/Apartment/Proxies/ApartmentRoomEnum")
function SceneChangeIdleState:Start()
  self.super.Start(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnClickLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self, "OnClickLobbyCharacterCallBack")
  end
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  self.changeSceneTime = ApartmentStateMachineConfigProxy:GetChangSceneIdleTime()
  self.bSwitchState = false
  local sequenceID = ApartmentStateMachineConfigProxy:GetTransitionSequenceID()
  if 0 == sequenceID then
    self:StartRelaxTimer()
  else
    self:PlayTransSequence(sequenceID)
  end
  if ApartmentStateMachineConfigProxy:GetApartmnetCurrentActivityArea() ~= UE4.ECyApartmentRoleActivityArea.Bed or self.ApartmentEntryStateMachine:IsTwoStage() then
    self:StartGalTextBubblesTimer()
  end
end
function SceneChangeIdleState:Stop()
  self.super.Stop(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self.OnClickLobbyCharacterDelegate)
  end
  self:StopRelaxTimer()
end
function SceneChangeIdleState:Tick()
  if 0 ~= self.currentPlayingSequenceID then
    return
  end
  self.changeSceneTime = self.changeSceneTime - 1
  if self.changeSceneTime <= 0 then
    if self.bSwitchState == true then
      LogDebug("SceneChangeIdleState:Tick", " Change state ing")
      return
    end
    self.bSwitchState = true
    self:StopRelaxTimer()
    LogDebug("SceneChangeIdleState:Tick", "Change EnterScene state")
    ApartmentStateMachineConfigProxy:SetCharacterEnterSceneCenterMood(UE4.ECyApartmentRoleEnterSceneCenterMood.Bored)
    self:SwitchState("EnterSceneCenter")
  end
end
function SceneChangeIdleState:OnClickLobbyCharacterCallBack(cickPartType)
  LogDebug("SceneChangeIdleState:OnClickLobbyCharacterCallBack", "cickPartType is : " .. cickPartType)
  if 0 ~= self.currentPlayingSequenceID then
    LogDebug("SceneChangeIdleState:OnClickLobbyCharacterCallBack", "sequence is playing,not click")
    return
  end
  if cickPartType == UE4.EPMApartmentWholeBodyType.None then
    return
  end
  if self.bSwitchState == true then
    LogDebug("SceneChangeIdleState:OnClickLobbyCharacterCallBack", " Change state ing")
    return
  end
  self.bSwitchState = true
  LogDebug("SceneChangeIdleState:OnClickLobbyCharacterCallBack", " Change RandomTouch state")
  self:StopRelaxTimer()
  ApartmentStateMachineConfigProxy:SetCharacterEnterSceneCenterMood(UE4.ECyApartmentRoleEnterSceneCenterMood.Normal)
  self:SwitchStateByID(UE4.ECyApartmentState.PerformToInteractionTransition)
end
function SceneChangeIdleState:StartRelaxTimer()
  LogDebug("SceneChangeIdleState:StartRelaxTimer", "start relax timer")
  self.relaxTimer = TimerMgr:AddTimeTask(ApartmentStateMachineConfigProxy:GeRelaxTime(), 0, 0, function()
    self:PlayRelaxSequence()
  end)
end
function SceneChangeIdleState:StopRelaxTimer()
  if self.relaxTimer then
    self.relaxTimer:EndTask()
    self.relaxTimer = nil
    LogDebug("SceneChangeIdleState:StopRelaxTimer", "stop relax timer")
  end
end
function SceneChangeIdleState:PlayRelaxSequence()
  self:StopRelaxTimer()
  local currRelaxSequenceID = ApartmentStateMachineConfigProxy:GetRelaxSequenceID()
  LogDebug("SceneChangeIdleState:PlayRelaxSequence", "PlayRelaxSequence Sequence ID IS : " .. currRelaxSequenceID)
  self:PlaySequence(currRelaxSequenceID)
end
function SceneChangeIdleState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self.currentPlayingSequenceID = 0
    self:StartRelaxTimer()
  end
end
function SceneChangeIdleState:PlayTransSequence(sequenceID)
  LogDebug("SceneChangeIdleState:PlayTransSequence", "Play Transiton Sequence ")
  self:PlaySequence(sequenceID)
end
return SceneChangeIdleState
