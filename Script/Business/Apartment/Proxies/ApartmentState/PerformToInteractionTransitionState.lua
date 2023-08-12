local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local PerformToInteractionTransitionState = class("PerformToInteractionTransitionState", BaseState)
local ApartmentStateMachineConfigProxy
function PerformToInteractionTransitionState:Start()
  self.super.Start(self)
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  self.bSwitchState = false
  local asset = self:GetCurrentRoleStateAesst()
  if asset and asset.SequenceArray:Length() > 0 and 0 ~= asset.SequenceArray:Get(1) and not self.ApartmentEntryStateMachine:IsTwoStage() then
    self.ApartmentEntryStateMachine:SetTwoStage(true)
    self:PlaySequence(asset.SequenceArray:Get(1))
    local GlobalDelegateManager = GetGlobalDelegateManager()
    if GlobalDelegateManager and DelegateMgr then
      self.OnClickLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self, "OnClickLobbyCharacterCallBack")
    end
  else
    self:SwitchStateByID(UE4.ECyApartmentState.EnterSceneCenter)
  end
end
function PerformToInteractionTransitionState:Stop()
  self.super.Stop(self)
  if self.OnClickLobbyCharacterDelegate then
    local GlobalDelegateManager = GetGlobalDelegateManager()
    if GlobalDelegateManager and DelegateMgr then
      DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self.OnClickLobbyCharacterDelegate)
    end
  end
  self:StopToucehTimer()
end
function PerformToInteractionTransitionState:OnClickLobbyCharacterCallBack(cickPartType)
  LogDebug("PerformToInteractionTransitionState:OnClickLobbyCharacterCallBack", "CickPartType is : " .. cickPartType)
  if 0 ~= self.currentPlayingSequenceID then
    LogDebug("PerformToInteractionTransitionState:OnClickLobbyCharacterCallBack", "sequence is playing,not click")
    return
  end
  if cickPartType == UE4.EPMApartmentWholeBodyType.None then
    return
  end
  self:SwitchEnterSceneCenterState()
end
function PerformToInteractionTransitionState:SwitchEnterSceneCenterState()
  self:StopToucehTimer()
  if self.bSwitchState == true then
    return
  end
  self.bSwitchState = true
  self:SwitchState("EnterSceneCenter")
end
function PerformToInteractionTransitionState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self.currentPlayingSequenceID = 0
    self:StartTouchTimer()
  end
end
function PerformToInteractionTransitionState:StartTouchTimer()
  self.toucehTimer = TimerMgr:AddTimeTask(ApartmentStateMachineConfigProxy:GetTouchTwiceTime(), 0, 1, function()
    self:SwitchEnterSceneCenterState()
  end)
end
function PerformToInteractionTransitionState:StopToucehTimer()
  if self.toucehTimer then
    self.toucehTimer:EndTask()
    self.toucehTimer = nil
    LogDebug("PerformToInteractionTransitionState:StopToucehTimer", "Stop ToucehTimer")
  end
end
return PerformToInteractionTransitionState
