local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local PauseState = class("PauseState", BaseState)
local ApartmentStateMachineConfigProxy
function PauseState:Start()
  self.super.Start(self)
  UE4.UCySequenceManager.Get(LuaGetWorld()):StopSequence()
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
end
function PauseState:Tick()
end
function PauseState:Stop()
  self.super.Stop(self)
end
function PauseState:OnSequenceStop(sequenceId, reasonType)
end
return PauseState
