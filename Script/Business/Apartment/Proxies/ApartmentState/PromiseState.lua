local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local PromiseState = class("PromiseState", BaseState)
local ApartmentStateMachineConfigProxy
function PromiseState:Start()
  self.super.Start(self)
end
function PromiseState:Tick()
end
function PromiseState:Stop()
  self.super.Stop(self)
end
function PromiseState:OnSequenceStop(sequenceId, reasonType)
end
return PromiseState
