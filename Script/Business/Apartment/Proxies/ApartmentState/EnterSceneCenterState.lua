local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local EnterSceneCenterState = class("EnterSceneCenterState", BaseState)
local ApartmentStateMachineConfigProxy
local ApartmentRoomEnum = require("Business/Apartment/Proxies/ApartmentRoomEnum")
function EnterSceneCenterState:Start()
  self.super.Start(self)
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  self.characterMood = ApartmentStateMachineConfigProxy:GetCharacterEnterSceneCenterMood()
  self:PlayEnterSceneCenterSequence()
end
function EnterSceneCenterState:Stop()
  self.super.Stop(self)
end
function EnterSceneCenterState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self.currentPlayingSequenceID = 0
    self:SwitchState("SceneInterpretationIdle")
  end
end
function EnterSceneCenterState:PlayEnterSceneCenterSequence()
  local sequenceID = ApartmentStateMachineConfigProxy:GetEnterSceneCenterSequenceID()
  self.enterSceneSequenceID = sequenceID
  self:PlaySequence(sequenceID)
  self.ApartmentEntryStateMachine:SetTwoStage(false)
end
return EnterSceneCenterState
