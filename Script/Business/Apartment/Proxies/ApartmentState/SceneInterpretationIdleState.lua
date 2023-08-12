local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local SceneInterpretationIdleState = class("SceneInterpretationIdleState", BaseState)
local ApartmentRoomEnum = require("Business/Apartment/Proxies/ApartmentRoomEnum")
local ApartmentStateMachineConfigProxy
function SceneInterpretationIdleState:Start()
  self.super.Start(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnClickLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self, "OnClickLobbyCharacterCallBack")
  end
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  self:PlayLastStateTransSequence()
  self:UpdateChangeTime()
  local lastStateID = self:GetLastStateID()
  if lastStateID ~= UE4.ECyApartmentState.EnterSceneCenter then
    ApartmentStateMachineConfigProxy:SetCharacterEnterSceneCenterMood(UE4.ECyApartmentRoleEnterSceneCenterMood.None)
  end
  self.currentMood = ApartmentStateMachineConfigProxy:GetCharacterEnterSceneCenterMood()
  self.bPlayedMoodSequence = false
  self.bStartMoodTimer = false
  if self.currentMood == UE4.ECyApartmentRoleEnterSceneCenterMood.Bored then
    self:StartPlayDispiritedSequenceTimer()
  end
  self:SetLookAtEnable(true)
  self:StartGalTextBubblesTimer()
  self:StartLookAtMouseTimer()
end
function SceneInterpretationIdleState:Stop()
  self.super.Stop(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self.OnClickLobbyCharacterDelegate)
  end
  self:StopPlayHappySequenceTimer()
  self:StopPlayDispiritedSequenceTimer()
  self:SetLookAtEnable(false)
  self:StopLookAtMouseTimer()
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):RecoverLookAt()
end
function SceneInterpretationIdleState:Tick()
  if 0 ~= self.currentPlayingSequenceID then
    return
  end
  if self.bStartMoodTimer == true then
    return
  end
  self.changeTime = self.changeTime - 1
  if self.changeTime <= 0 then
    self:SwitchState("SceneChangeIdle")
  end
end
function SceneInterpretationIdleState:OnClickLobbyCharacterCallBack(cickPartType)
  LogDebug("SceneInterpretationIdleState:OnClickLobbyCharacterCallBack", "cickPartType is : " .. cickPartType)
  if 0 ~= self.currentPlayingSequenceID then
    LogDebug("SceneInterpretationIdleState:OnClickLobbyCharacterCallBack", "sequence is playing,not click")
    return
  end
  if cickPartType == UE4.EPMApartmentWholeBodyType.None then
    return
  end
  if self.currentMood == ApartmentRoomEnum.CharacterEnterSceneCenterMood.Bored then
    self:StopPlayDispiritedSequenceTimer()
  end
  self:StopGalTextBubblesTimer()
  self:PlayClickSequence(cickPartType)
  GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomTouchProxy):TouchRole()
end
function SceneInterpretationIdleState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self:UpdateChangeTime()
    self.currentPlayingSequenceID = 0
    if self.clickSequenceID == sequenceId then
      if self.currentMood == ApartmentRoomEnum.CharacterEnterSceneCenterMood.Bored and self.bPlayedMoodSequence == false then
        self:StartPlayHappySequenceTimer()
      end
      self:StartGalTextBubblesTimer()
    end
  end
end
function SceneInterpretationIdleState:UpdateChangeTime()
  LogDebug("SceneInterpretationIdleState:UpdateChangeTime", " UpdateChangeTime")
  self.changeTime = ApartmentStateMachineConfigProxy:GeInterpretationIdleTime()
end
function SceneInterpretationIdleState:PlayClickSequence(cickPartType)
  LogDebug("SceneInterpretationIdleState:PlayClickSequence", " Play Click Sequence")
  self.clickSequenceID = ApartmentStateMachineConfigProxy:GetSceneInterpretationClickSequenceID(cickPartType)
  if self.clickSequenceID == nil or 0 == self.clickSequenceID then
    return
  end
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):RecoverLookAt()
  self:PlaySequence(self.clickSequenceID)
end
function SceneInterpretationIdleState:PlayHappySequence()
  self.bPlayedMoodSequence = true
  LogDebug("SceneInterpretationIdleState:PlayHappySequence", " Play Happy Sequence")
  self:StopPlayHappySequenceTimer()
  local sequenceID = ApartmentStateMachineConfigProxy:GetHappySequenceID()
  self:PlaySequence(sequenceID)
end
function SceneInterpretationIdleState:PlayDispiritedSequence()
  self.bPlayedMoodSequence = true
  LogDebug("SceneInterpretationIdleState:PlayHappySequence", " Play Dispirited Sequence")
  local sequenceID = ApartmentStateMachineConfigProxy:GetDispiritedSequenceID()
  self:PlaySequence(sequenceID)
  self:StopPlayDispiritedSequenceTimer()
end
function SceneInterpretationIdleState:StartPlayHappySequenceTimer()
  self.bStartMoodTimer = true
  LogDebug("SceneInterpretationIdleState:StartPlayHappySequenceTimer", " StartPlayHappySequenceTimer")
  self.playHappySequenceTimer = TimerMgr:AddTimeTask(ApartmentStateMachineConfigProxy:GetPlayHappySequenceTime(), 0, 1, function()
    self:PlayHappySequence()
  end)
end
function SceneInterpretationIdleState:StopPlayHappySequenceTimer()
  LogDebug("SceneInterpretationIdleState:StopPlayHappySequenceTimer", " StopPlayHappySequenceTimer")
  self.bStartMoodTimer = false
  if self.playHappySequenceTimer then
    self.playHappySequenceTimer:EndTask()
    self.playHappySequenceTimer = nil
  end
end
function SceneInterpretationIdleState:StartPlayDispiritedSequenceTimer()
  self.bStartMoodTimer = true
  LogDebug("SceneInterpretationIdleState:StartPlayDispiritedSequenceTimer", " StartPlayDispiritedSequenceTimer")
  self.playDispiritedSequenceTimer = TimerMgr:AddTimeTask(ApartmentStateMachineConfigProxy:GetPlayDispiritedSequenceTime(), 0, 1, function()
    self:PlayDispiritedSequence()
  end)
end
function SceneInterpretationIdleState:StopPlayDispiritedSequenceTimer()
  LogDebug("SceneInterpretationIdleState:StopPlayDispiritedSequenceTimer", " StopPlayDispiritedSequenceTimer")
  self.bStartMoodTimer = false
  if self.playDispiritedSequenceTimer then
    self.playDispiritedSequenceTimer:EndTask()
    self.playDispiritedSequenceTimer = nil
  end
end
function SceneInterpretationIdleState:StartLookAtMouseTimer()
  LogDebug("SceneInterpretationIdleState:StartLookAtMouseTimer", " StartLookAtMouseTimer")
  local apartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  local configData = apartmentStateMachineConfigProxy:GetApartmentConfigData()
  if configData then
    local delayTime = configData.AutoLookAtTime
    if 0 == delayTime then
      LogError("SceneInterpretationIdleState:StartLookAtMouseTimer", " AutoLookAtTime is 0")
      return
    end
    self.lookatMouseTimer = TimerMgr:AddTimeTask(delayTime, 0, 1, function()
      self:AutoLookAtMouse()
    end)
  end
end
function SceneInterpretationIdleState:StopLookAtMouseTimer()
  LogDebug("SceneInterpretationIdleState:StopLookAtMouseTimer", " StopLookAtMouseTimer")
  if self.lookatMouseTimer then
    self.lookatMouseTimer:EndTask()
    self.lookatMouseTimer = nil
  end
end
function SceneInterpretationIdleState:AutoLookAtMouse()
  LogDebug("SceneInterpretationIdleState:AutoLookAtMouse", " AutoLookAtMouse")
  self:StopLookAtMouseTimer()
  if 0 == self.currentPlayingSequenceID then
    UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):AutoLookAt()
  end
  self:StartLookAtMouseTimer()
end
return SceneInterpretationIdleState
