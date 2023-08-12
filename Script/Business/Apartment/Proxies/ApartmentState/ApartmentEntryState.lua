local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local ApartmentEntryState = class("ApartmentEntryState", BaseState)
function ApartmentEntryState:Start()
  self.super.Start(self)
  if 0 == self.StateConfigRow.SequenceProxyId then
    self:JudgeCond()
  end
end
function ApartmentEntryState:Stop()
  self.super.Stop(self)
end
function ApartmentEntryState:Tick(time)
end
function ApartmentEntryState:PlaySequence(sequenceID)
end
return ApartmentEntryState
