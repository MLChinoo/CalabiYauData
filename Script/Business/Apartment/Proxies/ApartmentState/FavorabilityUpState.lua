local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local FavorabilityUpState = class("FavorabilityUpState", BaseState)
function FavorabilityUpState:Start()
  self.super.Start(self)
  self:PlayStateSeqence()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):ShowContractUpgrade()
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.IntimacyLvCond)
end
function FavorabilityUpState:Stop()
  self.super.Stop(self)
end
function FavorabilityUpState:Tick(time)
  self.super:Tick(time)
end
function FavorabilityUpState:OnSequenceStop(sequenceId, reasonType)
end
function FavorabilityUpState:OnFullScreenEffectsCallBack()
  self:JudgeCond()
end
return FavorabilityUpState
