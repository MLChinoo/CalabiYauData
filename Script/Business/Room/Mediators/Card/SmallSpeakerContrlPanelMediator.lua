local SmallSpeakerContrlPanelMediator = class("SmallSpeakerContrlPanelMediator", PureMVC.Mediator)
function SmallSpeakerContrlPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.SmallSpeakerStateChanged,
    NotificationDefines.SmallSpeakerStateChangedList
  }
end
function SmallSpeakerContrlPanelMediator:HandleNotification(notification)
  if NotificationDefines.SmallSpeakerStateChanged == notification:GetName() then
    self.isSpeaking = false
    local _playerID = notification:GetBody()
    self:OnSmallSpeakerStateChanged(_playerID)
  elseif NotificationDefines.SmallSpeakerStateChangedList == notification:GetName() then
    self:OnSmallSpeakerStateChangedList()
  end
end
function SmallSpeakerContrlPanelMediator:OnSmallSpeakerStateChangedList()
  local MplayerID = self:GetViewComponent().playerID
  if 0 == MplayerID or nil == MplayerID or -1 == MplayerID then
    self:GetViewComponent().WS_VoiceState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if self:GetIsSelf() then
    self:GetViewComponent().WS_VoiceState:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self:GetViewComponent().WS_VoiceState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:UpdataView()
  LogDebug("SmallSpeakerContrlPanelMediator.OnSmallSpeakerStateChangedList", "MplayerID = %s", tostring(MplayerID))
end
function SmallSpeakerContrlPanelMediator:OnSmallSpeakerStateChanged(_playerID)
  local MplayerID = self:GetViewComponent().playerID
  if 0 == MplayerID or nil == MplayerID or -1 == MplayerID then
    self:GetViewComponent().WS_VoiceState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if tostring(MplayerID) ~= tostring(_playerID) then
    return
  end
  if self:GetIsSelf() then
    self:GetViewComponent().WS_VoiceState:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self:GetViewComponent().WS_VoiceState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:UpdataView()
  LogDebug("SmallSpeakerContrlPanelMediator.OnSmallSpeakerStateChanged", "MplayerID = %s", tostring(MplayerID))
end
function SmallSpeakerContrlPanelMediator:UpdataView()
  self.index = 0
  if self.voiceManager:GetPlayreForbidVoiceState(self:GetViewComponent().playerID) == true then
    self.index = 2
  elseif true == self.isSpeaking then
    self.index = 1
  elseif self.voiceManager:GetSpeakerIsEnable() == false then
    if self:GetIsSelf() then
      if self.voiceManager:GetMicIsEnable() then
        self.index = 0
      else
        self.index = 3
      end
    else
      self.index = 3
    end
  elseif self:GetIsSelf() then
    if self.voiceManager:GetMicIsEnable() then
      self.index = 0
    else
      self.index = 3
    end
  else
    local bMicIsEnable = UE4.UPMVoiceManager.Get(LuaGetWorld()):GetMicIsEnableStateMap(self:GetViewComponent().playerID)
    if bMicIsEnable then
      self.index = 0
    else
      self.index = 3
    end
  end
  self:GetViewComponent().WS_VoiceState:SetActiveWidgetIndex(self.index)
end
function SmallSpeakerContrlPanelMediator:OnRegister()
  self.MicDeviceCount = -1
  self.voiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  self.isSpeaking = false
  self:GetViewComponent().actionOnClickedNormalVoiceState:Add(self.OnClickedNormalVoiceState, self)
  self:GetViewComponent().actionOnClickedSpeakVoiceState:Add(self.OnClickedSpeakVoiceState, self)
  self:GetViewComponent().actionOnClickedShieldVoiceState:Add(self.OnClickedShieldVoiceState, self)
  local global_delegate_manager = GetGlobalDelegateManager()
  self.OnMemberVoiceCallbackHandle = DelegateMgr:AddDelegate(global_delegate_manager.OnMemberVoiceCallback, self, "OnMemberVoice")
  self.SmallSpeakerStateChangedHandle = DelegateMgr:AddDelegate(global_delegate_manager.SmallSpeakerStateChanged, self, "OnSmallSpeakerStateChanged")
  self.OnMicDeviceChangeEventHandler = DelegateMgr:AddDelegate(self.voiceManager.OnMicDeviceChangeEvent, self, "OnMicDeviceChangeEvent")
  self.OnJoinVoiceRoomHandler = DelegateMgr:AddDelegate(UE4.UPMVoiceManager.Get(LuaGetWorld()).OnJoinVoiceRoom, self, "OnJoinVoiceRoom")
  self.OnPlayreForbidStateChangeHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnPlayreForbidStateChangeDelegate, self, "OnPlayreForbidStateChange")
end
function SmallSpeakerContrlPanelMediator:GetIsSelf()
  return tostring(self:GetViewComponent().playerID) == tostring(GameFacade:RetrieveProxy(ProxyNames.RoomProxy):GetPlayerID())
end
function SmallSpeakerContrlPanelMediator:OnPlayreForbidStateChange(playerID, bIsForbid)
  self:OnSmallSpeakerStateChanged(playerID)
  LogDebug("SmallSpeakerContrlPanelMediator", "OnPlayreForbidStateChange")
end
function SmallSpeakerContrlPanelMediator:OnRemove()
  self:GetViewComponent().actionOnClickedNormalVoiceState:Remove(self.OnClickedNormalVoiceState, self)
  self:GetViewComponent().actionOnClickedSpeakVoiceState:Remove(self.OnClickedSpeakVoiceState, self)
  self:GetViewComponent().actionOnClickedShieldVoiceState:Remove(self.OnClickedShieldVoiceState, self)
  local global_delegate_manager = GetGlobalDelegateManager()
  if self.OnMemberVoiceCallbackHandle then
    DelegateMgr:RemoveDelegate(global_delegate_manager.OnMemberVoiceCallback, self.OnMemberVoiceCallbackHandle)
    self.OnMemberVoiceCallbackHandle = nil
  end
  if self.SmallSpeakerStateChangedHandle then
    DelegateMgr:RemoveDelegate(global_delegate_manager.SmallSpeakerStateChanged, self.SmallSpeakerStateChangedHandle)
    self.SmallSpeakerStateChangedHandle = nil
  end
  if self.OnMicDeviceChangeEventHandler then
    DelegateMgr:RemoveDelegate(self.voiceManager.OnMicDeviceChangeEvent, self.OnMicDeviceChangeEventHandler)
    self.OnMicDeviceChangeEventHandler = nil
  end
  if self.OnJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMVoiceManager.Get(LuaGetWorld()).OnJoinVoiceRoom, self.OnJoinVoiceRoomHandler)
    self.OnJoinVoiceRoomHandler = nil
  end
  if self.OnPlayreForbidStateChangeHandler then
    DelegateMgr:RemoveDelegate(global_delegate_manager.OnPlayreForbidStateChangeDelegate, self.OnPlayreForbidStateChangeHandler)
    self.OnPlayreForbidStateChangeHandler = nil
  end
end
function SmallSpeakerContrlPanelMediator:OnJoinVoiceRoom()
  self:UpdataView()
end
function SmallSpeakerContrlPanelMediator:ShieldVoice()
  self.voiceManager:SetPlayreForbidVoiceState(self:GetViewComponent().playerID, true)
  self:UpdataView()
end
function SmallSpeakerContrlPanelMediator:OnClickedNormalVoiceState()
  self:ShieldVoice()
end
function SmallSpeakerContrlPanelMediator:OnClickedSpeakVoiceState()
  self:ShieldVoice()
end
function SmallSpeakerContrlPanelMediator:OnClickedShieldVoiceState()
  self.voiceManager:SetPlayreForbidVoiceState(self:GetViewComponent().playerID, false)
  self:UpdataView()
end
function SmallSpeakerContrlPanelMediator:OnMemberVoice(roomName, member, status)
  if self.voiceManager then
    if self:GetIsSelf() and 0 == self.MicDeviceCount then
      self.isSpeaking = false
      self:UpdataView()
      return
    end
    if self.voiceManager:GetPlayerIDByMemberID(roomName, member) == tostring(self:GetViewComponent().playerID) then
      if 0 == status then
        self.isSpeaking = false
      elseif 1 == status or 2 == status then
        self.isSpeaking = true
      end
      self:UpdataView()
    end
  end
end
function SmallSpeakerContrlPanelMediator:OnMicDeviceChangeEvent()
  self.MicDeviceCount = self.voiceManager:GetMicDeviceCount()
end
return SmallSpeakerContrlPanelMediator
