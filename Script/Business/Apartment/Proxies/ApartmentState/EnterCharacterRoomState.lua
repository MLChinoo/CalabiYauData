local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local EnterCharacterRoomState = class("EnterCharacterRoomState", BaseState)
local ApartmentStateMachineConfigProxy
function EnterCharacterRoomState:Start()
  self.super.Start(self)
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  local sequenceID = ApartmentStateMachineConfigProxy:GetCharacterEnterSequenceID()
  self:PlaySequence(sequenceID)
  self:RecordLastID()
end
function EnterCharacterRoomState:Stop()
  self.super.Stop(self)
end
function EnterCharacterRoomState:Tick(time)
end
function EnterCharacterRoomState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self:JudgeCond()
  end
end
function EnterCharacterRoomState:RecordLastID()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local apartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  apartmentRoomProxy:SetLastRoleID(CurrentRoleId)
end
return EnterCharacterRoomState
