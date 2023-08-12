local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local GetGiftState = class("GetGiftState", BaseState)
function GetGiftState:Start()
  self.super.Start(self)
  self:PlayStateSeqence()
end
function GetGiftState:Stop()
  self.super.Stop(self)
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):ClearCharacterAllAttachActor()
end
function GetGiftState:Tick(time)
  self.super:Tick(time)
end
function GetGiftState:OnSequenceStop(sequenceId, reasonType)
end
function GetGiftState:OnReceiveAwardCallBack()
  self:JudgeCond()
end
return GetGiftState
