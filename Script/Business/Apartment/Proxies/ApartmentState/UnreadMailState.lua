local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local UnreadMailState = class("UnreadMailState", BaseState)
function UnreadMailState:Start()
  self.super.Start(self)
  self:PlayStateSeqence()
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.UnreadEmailCond)
end
function UnreadMailState:Stop()
  self.super.Stop(self)
end
function UnreadMailState:Tick(time)
  self.super:Tick(time)
end
function UnreadMailState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self:JudgeCond()
  end
end
return UnreadMailState
