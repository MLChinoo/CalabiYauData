local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local SincerityInteractionState = class("SincerityInteractionState", BaseState)
function SincerityInteractionState:Start()
  self.super.Start(self)
  self:HideUI()
  self:PlayEventSequence()
end
function SincerityInteractionState:Tick()
end
function SincerityInteractionState:Stop()
  self.super.Stop(self)
  self:ShowUI()
end
function SincerityInteractionState:OnSequenceStop(sequenceId, reasonType)
  if reasonType == UE4.ESequenceStopReason.Reason_Completed or reasonType == UE4.ESequenceStopReason.Reason_Skip then
    self:SwitchLastState()
  end
end
function SincerityInteractionState:PlayEventSequence()
  local sequenceID = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy):RandomGetMainPageGalSequenceID()
  if sequenceID and 0 ~= sequenceID then
    self:PlaySequence(sequenceID)
  else
    LogWarn("SincerityInteractionState:PlayEventSequence", "sequenceID is nil")
    self:SwitchLastState()
  end
end
function SincerityInteractionState:SwitchLastState()
  local lastStateID = self:GetLastStateID()
  if nil == lastStateID or 0 == lastStateID then
    lastStateID = UE4.ECyApartmentState.SceneInterpretationIdle
  end
  self:SwitchStateByID(lastStateID)
end
return SincerityInteractionState
