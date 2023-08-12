local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local RandomTouchState = class("RandomTouchState", BaseState)
local ApartmentStateMachineConfigProxy
local ApartmentRoomEnum = require("Business/Apartment/Proxies/ApartmentRoomEnum")
local ETouchModel = {Once = 1, Twice = 2}
function RandomTouchState:Start()
  self.super.Start(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnClickLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self, "OnClickLobbyCharacterCallBack")
  end
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  self.touchModel = ETouchModel.Twice
  self.bSwitchState = false
  self:GetTouchType()
end
function RandomTouchState:Stop()
  self.super.Stop(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self.OnClickLobbyCharacterDelegate)
  end
  self:StopToucehTimer()
end
function RandomTouchState:OnClickLobbyCharacterCallBack(cickPartType)
  LogDebug("RandomTouchState:OnClickLobbyCharacterCallBack", "CickPartType is : " .. cickPartType)
  if 0 ~= self.currentPlayingSequenceID then
    LogDebug("RandomTouchState:OnClickLobbyCharacterCallBack", "sequence is playing,not click")
    return
  end
  if cickPartType == UE4.EPMApartmentWholeBodyType.None then
    return
  end
  if self.touchModel == ETouchModel.Once then
    LogDebug("RandomTouchState:OnClickLobbyCharacterCallBack", "Current TouchModel is " .. self.touchModel .. " ,Not Click")
    return
  end
  if self.toucehTimer == nil then
    LogDebug("RandomTouchState:OnClickLobbyCharacterCallBack", "self.toucehTimer is nil ,Not Click")
    return
  end
  LogDebug("RandomTouchState:OnClickLobbyCharacterCallBack", "twice Click")
  self:StopToucehTimer()
  self:SwitchEnterSceneCenterState()
end
function RandomTouchState:GetTouchType()
  local clickType = ""
  local random = math.random(100)
  local randomConfig = ApartmentStateMachineConfigProxy:GetOnceTouchProb()
  if random >= randomConfig then
    self.touchModel = ETouchModel.Once
    self:SwitchEnterSceneCenterState()
  else
    self.touchModel = ETouchModel.Twice
    self:PlaySequence(ApartmentStateMachineConfigProxy:GetTouchSequence(""))
  end
  LogDebug("RandomTouchState:GetTouchType", "current Touch Type ：" .. self.touchModel)
end
function RandomTouchState:StartTouchTimer()
  LogDebug("RandomTouchState:StartTouchTimer", "Start ToucehTimer")
  self.toucehTimer = TimerMgr:AddTimeTask(ApartmentStateMachineConfigProxy:GetTouchTwiceTime(), 0, 1, function()
    self:SwitchIdleState()
  end)
end
function RandomTouchState:StopToucehTimer()
  if self.toucehTimer then
    self.toucehTimer:EndTask()
    self.toucehTimer = nil
    LogDebug("RandomTouchState:StopToucehTimer", "Stop ToucehTimer")
  end
end
function RandomTouchState:SwitchIdleState()
  self:StopToucehTimer()
  if self.bSwitchState then
    return
  end
  self.bSwitchState = true
  self:SwitchState("SceneChangeIdle")
end
function RandomTouchState:SwitchEnterSceneCenterState()
  if self.bSwitchState then
    return
  end
  self.bSwitchState = true
  ApartmentStateMachineConfigProxy:SetCharacterEnterSceneCenterMood(UE4.ECyApartmentRoleEnterSceneCenterMood.Normal)
  self:SwitchState("EnterSceneCenter")
end
function RandomTouchState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self.currentPlayingSequenceID = 0
    self:StartTouchTimer()
  end
end
return RandomTouchState
