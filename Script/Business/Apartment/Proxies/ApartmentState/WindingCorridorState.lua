local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local WindingCorridorState = class("WindingCorridorState", BaseState)
local ApartmentStateMachineConfigProxy
function WindingCorridorState:Start()
  self.super.Start(self)
  self:PlayStateSeqence()
end
function WindingCorridorState:Tick()
end
function WindingCorridorState:Stop()
  self.super.Stop(self)
end
function WindingCorridorState:OnSequenceStop(sequenceId, reasonType)
end
return WindingCorridorState
