local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local LongTimeNotLogginState = class("LongTimeNotLogginState", BaseState)
function LongTimeNotLogginState:Start()
  self.super.Start(self)
  local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
  RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.LongTimeNotLogginCond)
  self:RecordLastID()
  local stateSeqenceID = self:GetCurrStateSequenceID()
  if 0 == stateSeqenceID then
    LogWarn(self.__cname .. ":PlayStateSeqence", "Sequence ID is nil,StateId : " .. self.StateConfigRow.StateId)
    self:JudgeCond()
    return
  end
  self.endSequence = 0
  local data = self:GetCurrStateSequenceConfig()
  if data and data.SequenceArray:Length() >= 2 then
    self.endSequence = data.SequenceArray:Get(2)
  end
  self:PlayStateSeqence()
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ReturnLetterPage, false, {
    CloseCallBack = function()
      print("CloseCallback@@@")
      self:OnRegressPageClose()
    end
  })
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy):SetApartmnetCurrentActivityArea(UE4.ECyApartmentRoleActivityArea.ComputerTable)
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy):SetApartmnetRolePose(UE4.EPMApartmentRoleStatusType.Sit)
  GameFacade:SendNotification(NotificationDefines.ApartmentStateSwitch, false)
end
function LongTimeNotLogginState:Stop()
  self.super.Stop(self)
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.ReturnLetterPage)
  GameFacade:SendNotification(NotificationDefines.ApartmentStateSwitch, true)
end
function LongTimeNotLogginState:Tick(time)
  self.super:Tick(time)
end
function LongTimeNotLogginState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType then
    if 0 ~= self.endSequence and self.endSequence ~= sequenceId then
      GameFacade:SendNotification(NotificationDefines.RetrunLetterPage.HideLetter)
    end
    if self.endSequence == sequenceId then
      self:JudgeCond()
    end
  end
end
function LongTimeNotLogginState:OnRegressPageClose()
  self:PlayEndSequence()
end
function LongTimeNotLogginState:PlayEndSequence()
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):StopLipSyncMorph()
  self:PlaySequence(self.endSequence)
end
function LongTimeNotLogginState:RecordLastID()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  local apartmentRoomProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  apartmentRoomProxy:SetLastRoleID(CurrentRoleId)
end
return LongTimeNotLogginState
