local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local FirstEnterCharacterRoomState = class("FirstEnterCharacterRoomState", BaseState)
local ApartmentConditionProxy, ApartmentStateMachineConfigProxy
function FirstEnterCharacterRoomState:Start()
  self.super.Start(self)
  ApartmentConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local CyAVGMgr = UE4.UCyAVGEventManager.Get(LuaGetWorld())
  if CyAVGMgr and DelegateMgr then
    self.OnAVGEventStopDelegate = DelegateMgr:AddDelegate(CyAVGMgr.OnAVGEventStopDelegate, self, "OnAVGEventStopCallBack")
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentTurnOffBgm)
  self:HideUI()
  self:PlayStateAvg()
end
function FirstEnterCharacterRoomState:Stop()
  self.super.Stop(self)
  self:ShowUI()
  local CyAVGMgr = UE4.UCyAVGEventManager.Get(LuaGetWorld())
  if DelegateMgr and CyAVGMgr and self.OnAVGEventStopDelegate then
    DelegateMgr:RemoveDelegate(CyAVGMgr.OnAVGEventStopDelegate, self.OnAVGEventStopDelegate)
    self.OnAVGEventStopDelegate = nil
  end
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  if RoleAttrMap then
    RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.FirstEnterCharacterRoomCond)
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentTurnOnBgm)
  self:RecordLastID()
end
function FirstEnterCharacterRoomState:Tick(time)
  self.super:Tick(time)
end
function FirstEnterCharacterRoomState:OnSequenceStop(sequenceId, reasonType)
  if (reasonType == UE4.ESequenceStopReason.Reason_Completed or reasonType == UE4.ESequenceStopReason.Reason_Skip) and self.currentPlayingSequenceID == sequenceId then
    self:JudgeCond()
  end
end
function FirstEnterCharacterRoomState:OnAVGEventStopCallBack(avgEventID)
  if self.currentAvgEventID == avgEventID then
    self:JudgeCond()
  end
end
function FirstEnterCharacterRoomState:RecordLastID()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local apartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  apartmentRoomProxy:SetLastRoleID(CurrentRoleId)
end
function FirstEnterCharacterRoomState:PlayAvg(avgEventID)
  local CyAVGMgr = UE4.UCyAVGEventManager.Get(LuaGetWorld())
  if CyAVGMgr then
    self.currentAvgEventID = avgEventID
    CyAVGMgr:PlayAVGEvent(avgEventID)
  end
end
function FirstEnterCharacterRoomState:PlayStateAvg()
  LogDebug("FirstEnterCharacterRoomState:PlayStateAvg", "PlayStateAvg")
  local avgEventID = self:GetCurrStateSequenceID()
  if nil == avgEventID or 0 == avgEventID then
    LogDebug("FirstEnterCharacterRoomState:PlayStateAvg", "avgEventID is nil")
    self:JudgeCond()
    return
  end
  self:PlayAvg(avgEventID)
end
return FirstEnterCharacterRoomState
