local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local GetEpicSkinState = class("GetEpicSkinState", BaseState)
function GetEpicSkinState:Start()
  self.super.Start(self)
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.EpicSkinCond)
  self:PlayStateSeqence()
end
function GetEpicSkinState:Stop()
  self.super.Stop(self)
end
function GetEpicSkinState:Tick(time)
  self.super:Tick(time)
end
function GetEpicSkinState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self:JudgeCond()
  end
end
return GetEpicSkinState
