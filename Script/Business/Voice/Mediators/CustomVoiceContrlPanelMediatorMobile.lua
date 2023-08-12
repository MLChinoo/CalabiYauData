local CustomVoiceContrlPanelMobile = class("CustomVoiceContrlPanelMobile", PureMVC.Mediator)
local VoiceEnum = require("Business/HUD/Voice/VoiceEnum")
local VoiceSlotName = "CustomVoiceSlot"
local PMVoiceManager
function CustomVoiceContrlPanelMobile:ListNotificationInterests()
  return {}
end
function CustomVoiceContrlPanelMobile:OnRegister()
  self.MicBtn_List = {
    "Mic_Always_Team",
    "Mic_Always_Room",
    "Mic_Always_Close",
    "Mic_Press_Team",
    "Mic_Press_Room"
  }
  self.SpeakerBtn_List = {
    "Speaker_Team",
    "Speaker_Room",
    "Speaker_Close"
  }
  self:GetViewComponent().actionOnClickMicRootBtn:Add(self.OnClickMicRootBtn, self)
  self:GetViewComponent().actionOnClickSpeakerRootBtn:Add(self.OnClickSpeakerRootBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysTeamBtn:Add(self.OnClickMicAlwaysTeamBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysRoomBtn:Add(self.OnClickMicAlwaysRoomBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysCloseBtn:Add(self.OnClickMicAlwaysCloseBtn, self)
  self:GetViewComponent().actionOnClickMicPressTeamBtn:Add(self.OnClickMicPressTeamBtn, self)
  self:GetViewComponent().actionOnClickMicPressRoomBtn:Add(self.OnClickMicPressRoomBtn, self)
  self:GetViewComponent().actionOnClickSpeakerTeamBtn:Add(self.OnClickSpeakerTeamBtn, self)
  self:GetViewComponent().actionOnClickSpeakerRoomBtn:Add(self.OnClickSpeakerRoomBtn, self)
  self:GetViewComponent().actionOnClickSpeakerCloseBtn:Add(self.OnClickSpeakerCloseBtn, self)
  self:SetEnableUI(false)
  PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  if PMVoiceManager:IsInRoomVoiceChannel() or PMVoiceManager:IsInTeamVoiceChannel() then
    self:InitView()
  end
  self.OnJoinVoiceRoomHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnJoinVoiceRoom, self, "OnJoinVoiceRoom")
  local global_delegate_manager = GetGlobalDelegateManager()
  self.OnPlayerJoinVoiceRoomHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnPlayerJoinVoiceRoom, self, "OnPlayerJoinVoiceRoom")
  self.OnPlayerQuitVoiceRoomHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnPlayerQuitVoiceRoom, self, "OnPlayerQuitVoiceRoom")
end
function CustomVoiceContrlPanelMobile:OnJoinVoiceRoom()
  self:InitView()
end
function CustomVoiceContrlPanelMobile:OnPlayerJoinVoiceRoom(RoomName, PlayerIDCh)
  LogDebug("CustomVoiceContrlPanelMobile", "OnPlayerJoinVoiceRoom  PlayerIDCh = " .. PlayerIDCh .. "  RoomName = " .. RoomName)
  self:SetPlayreState(PlayerIDCh)
end
function CustomVoiceContrlPanelMobile:OnPlayerQuitVoiceRoom(RoomName, PlayerIDCh)
  LogDebug("CustomVoiceContrlPanelMobile", "OnPlayerQuitVoiceRoom  PlayerIDCh = " .. PlayerIDCh .. "  RoomName = " .. RoomName)
  self:SetPlayreState(PlayerIDCh)
end
function CustomVoiceContrlPanelMobile:OnRemove()
  self:GetViewComponent().actionOnClickMicRootBtn:Remove(self.OnClickMicRootBtn, self)
  self:GetViewComponent().actionOnClickSpeakerRootBtn:Remove(self.OnClickSpeakerRootBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysTeamBtn:Remove(self.OnClickMicAlwaysTeamBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysRoomBtn:Remove(self.OnClickMicAlwaysRoomBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysCloseBtn:Remove(self.OnClickMicAlwaysCloseBtn, self)
  self:GetViewComponent().actionOnClickMicPressTeamBtn:Remove(self.OnClickMicPressTeamBtn, self)
  self:GetViewComponent().actionOnClickMicPressRoomBtn:Remove(self.OnClickMicPressRoomBtn, self)
  self:GetViewComponent().actionOnClickSpeakerTeamBtn:Remove(self.OnClickSpeakerTeamBtn, self)
  self:GetViewComponent().actionOnClickSpeakerRoomBtn:Remove(self.OnClickSpeakerRoomBtn, self)
  self:GetViewComponent().actionOnClickSpeakerCloseBtn:Remove(self.OnClickSpeakerCloseBtn, self)
  if self.OnJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnJoinVoiceRoom, self.OnJoinVoiceRoomHandler)
    self.OnJoinVoiceRoomHandler = nil
  end
  local global_delegate_manager = GetGlobalDelegateManager()
  if self.OnPlayerJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(global_delegate_manager.OnPlayerJoinVoiceRoom, self.OnPlayerJoinVoiceRoomHandler)
    self.OnPlayerJoinVoiceRoomHandler = nil
  end
  if self.OnPlayerQuitVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(global_delegate_manager.OnPlayerQuitVoiceRoom, self.OnPlayerQuitVoiceRoomHandler)
    self.OnPlayerQuitVoiceRoomHandler = nil
  end
  if self.TeamPressTask then
    self.TeamPressTask:EndTask()
    self.TeamPressTask = nil
  end
  if self.RoomPressTask then
    self.RoomPressTask:EndTask()
    self.RoomPressTask = nil
  end
  if self.MicIndex == VoiceEnum.MicChannelType.TeamPress or self.MicIndex == VoiceEnum.MicChannelType.RoomPress then
    self.MicIndex = VoiceEnum.MicChannelType.Close
    self:SaveGame()
  end
end
function CustomVoiceContrlPanelMobile:HandleNotification(notification)
end
function CustomVoiceContrlPanelMobile:SetEnableUI(isEnable)
  if isEnable then
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CustomVoiceContrlPanelMobile:InitView()
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  if nil == saveGameData then
    LogDebug("CustomVoiceContrlPanelMobile", "saveGameData = nil")
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  else
    LogDebug("CustomVoiceContrlPanelMobile", "InitView MicIndex = " .. tostring(saveGameData.MicIndex))
    LogDebug("CustomVoiceContrlPanelMobile", "InitView SpeakerIndex =" .. tostring(saveGameData.SpeakerIndex))
  end
  if not self:CheckValid(saveGameData.MicIndex, VoiceEnum.MicChannelType) then
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
  end
  if not self:CheckValid(saveGameData.SpeakerIndex, VoiceEnum.SpeakerChannelType) then
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  end
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  self.MicIndex = saveGameData.MicIndex
  self.SpeakerIndex = saveGameData.SpeakerIndex
  self:HideSpeakerPanel()
  self.bIsShowSpeaker = false
  self:HideMicPanel()
  self.bIsShowMic = false
  self:ApplyMicSetting()
  self:ApplySpeakerSetting()
  self:SetEnableUI(true)
end
function CustomVoiceContrlPanelMobile:UpdataMicPanel()
  for i = 1, #self.MicBtn_List do
    if self.MicIndex == i then
      self:GetViewComponent()[self.MicBtn_List[i] .. "_Selected"]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:GetViewComponent()[self.MicBtn_List[i] .. "_UnSelected"]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:GetViewComponent()[self.MicBtn_List[i] .. "_Selected"]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:GetViewComponent()[self.MicBtn_List[i] .. "_UnSelected"]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function CustomVoiceContrlPanelMobile:ShowMicPanel()
  self:HideSpeakerPanel()
  self:UpdataMicPanel()
  self:GetViewComponent().MicPanelRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self:GetViewComponent().WidgetSwitcher_Mic:GetChildrenCount() - 1)
  self.bIsShowMic = true
end
function CustomVoiceContrlPanelMobile:UpdataSpeakerPanel()
  for i = 1, #self.SpeakerBtn_List do
    if self.SpeakerIndex == i then
      self:GetViewComponent()[self.SpeakerBtn_List[i] .. "_Selected"]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:GetViewComponent()[self.SpeakerBtn_List[i] .. "_UnSelected"]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:GetViewComponent()[self.SpeakerBtn_List[i] .. "_Selected"]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:GetViewComponent()[self.SpeakerBtn_List[i] .. "_UnSelected"]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function CustomVoiceContrlPanelMobile:ShowSpeakerPanel()
  self:HideMicPanel()
  self:UpdataSpeakerPanel()
  self:GetViewComponent().SpeakerPanelRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:GetViewComponent().WidgetSwitcher_Speaker:SetActiveWidgetIndex(self:GetViewComponent().WidgetSwitcher_Speaker:GetChildrenCount() - 1)
  self.bIsShowSpeaker = true
end
function CustomVoiceContrlPanelMobile:HideMicPanel()
  self:GetViewComponent().MicPanelRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self.MicIndex - 1)
  self.bIsShowMic = false
end
function CustomVoiceContrlPanelMobile:HideSpeakerPanel()
  self:GetViewComponent().SpeakerPanelRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WidgetSwitcher_Speaker:SetActiveWidgetIndex(self.SpeakerIndex - 1)
  self.bIsShowSpeaker = false
end
function CustomVoiceContrlPanelMobile:CheckValid(index, channelType)
  for k, v in pairs(channelType) do
    if v == index then
      return true
    end
  end
  return false
end
function CustomVoiceContrlPanelMobile:OnClickMicRootBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickMicRootBtn")
  if self.bIsShowMic then
    self:HideMicPanel()
  else
    self:ShowMicPanel()
  end
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerRootBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickSpeakerRootBtn")
  if self.bIsShowSpeaker then
    self:HideSpeakerPanel()
  else
    self:ShowSpeakerPanel()
  end
end
function CustomVoiceContrlPanelMobile:OnClickMicAlwaysTeamBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickMicAlwaysTeamBtn")
  self.MicIndex = VoiceEnum.MicChannelType.TeamAuto
  self:OnClickMicBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicAlwaysRoomBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickMicAlwaysRoomBtn")
  self.MicIndex = VoiceEnum.MicChannelType.RoomAuto
  self:OnClickMicBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicAlwaysCloseBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickMicAlwaysCloseBtn")
  self.MicIndex = VoiceEnum.MicChannelType.Close
  self:OnClickMicBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicPressTeamBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickMicPressTeamBtn")
  self.MicIndex = VoiceEnum.MicChannelType.TeamPress
  self:OnClickMicBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicPressRoomBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickMicPressRoomBtn")
  self.MicIndex = VoiceEnum.MicChannelType.RoomPress
  self:OnClickMicBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicBtn()
  self:HideMicPanel()
  self:SaveGame()
  self:ApplyMicSetting()
end
function CustomVoiceContrlPanelMobile:ApplyMicSetting()
  if self.TeamPressTask then
    self.TeamPressTask:EndTask()
    self.TeamPressTask = nil
  end
  if self.RoomPressTask then
    self.RoomPressTask:EndTask()
    self.RoomPressTask = nil
  end
  PMVoiceManager:SetMicIsEnable(true)
  if self.MicIndex == VoiceEnum.MicChannelType.TeamAuto then
    self:MicTeamAuto()
  elseif self.MicIndex == VoiceEnum.MicChannelType.RoomAuto then
    self:MicRoomAuto()
  elseif self.MicIndex == VoiceEnum.MicChannelType.Close then
    self:MicClose()
  elseif self.MicIndex == VoiceEnum.MicChannelType.TeamPress then
    self:MicTeamAuto()
    self.TeamPressTask = TimerMgr:AddTimeTask(10, 0, 1, function()
      self.MicIndex = VoiceEnum.MicChannelType.Close
      self:SaveGame()
      self:MicClose()
      if not self.bIsShowMic then
        self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self.MicIndex - 1)
      end
    end)
  elseif self.MicIndex == VoiceEnum.MicChannelType.RoomPress then
    self:MicRoomAuto()
    self.RoomPressTask = TimerMgr:AddTimeTask(10, 0, 1, function()
      self.MicIndex = VoiceEnum.MicChannelType.Close
      self:SaveGame()
      self:MicClose()
      if not self.bIsShowMic then
        self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self.MicIndex - 1)
      end
    end)
  end
  local chatDataProxy = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy)
  if chatDataProxy then
    chatDataProxy:SendMicStateReq()
  end
end
function CustomVoiceContrlPanelMobile:MicTeamAuto()
  LogDebug("CustomVoiceContrlPanelMobile", "MicTeamAuto")
  PMVoiceManager:OpenRoomVoiceMic(true)
  PMVoiceManager:OpenTeamVoiceMic(true)
  PMVoiceManager:SetCurrentVoiceChannel(PMVoiceManager:GetTeamVoiceChannel())
end
function CustomVoiceContrlPanelMobile:MicRoomAuto()
  LogDebug("CustomVoiceContrlPanelMobile", "MicRoomAuto")
  PMVoiceManager:OpenTeamVoiceMic(false)
  PMVoiceManager:OpenRoomVoiceMic(true)
  PMVoiceManager:SetCurrentVoiceChannel(PMVoiceManager:GetRoomVoiceChannel())
end
function CustomVoiceContrlPanelMobile:MicClose()
  LogDebug("CustomVoiceContrlPanelMobile", "MicClose")
  PMVoiceManager:SetMicIsEnable(false)
  PMVoiceManager:OpenRoomVoiceMic(false)
  PMVoiceManager:OpenTeamVoiceMic(false)
  PMVoiceManager:SetCurrentVoiceChannel("")
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerRoomBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickSpeakerRoomBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  self:OnClickSpeakerBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerTeamBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickSpeakerTeamBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Team
  self:OnClickSpeakerBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerCloseBtn()
  LogDebug("CustomVoiceContrlPanelMobile", "OnClickSpeakerCloseBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Close
  self:OnClickSpeakerBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerBtn()
  self:HideSpeakerPanel()
  self:SaveGame()
  self:ApplySpeakerSetting()
end
function CustomVoiceContrlPanelMobile:ApplySpeakerSetting()
  local PlayerIDList = PMVoiceManager:GetRoomMemberPlayerIDList()
  for index = 1, PlayerIDList:Length() do
    local playerID = PlayerIDList:Get(index)
    if playerID ~= PMVoiceManager.PlayerIDStr then
      self:SetPlayreState(playerID)
    end
  end
  if self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Close then
    PMVoiceManager:SetSpeakerIsEnable(false)
  else
    PMVoiceManager:SetSpeakerIsEnable(true)
  end
end
function CustomVoiceContrlPanelMobile:SetPlayreState(playerID)
  if self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Team then
    LogDebug("CustomVoiceContrlPanelMobile", "SpeakerTeam")
    local IsTeammate = PMVoiceManager:IsTeammate(playerID)
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, not IsTeammate)
  elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Room then
    LogDebug("CustomVoiceContrlPanelMobile", "SpeakerRoom")
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, false)
  elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Close then
    LogDebug("CustomVoiceContrlPanelMobile", "SpeakerClose")
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, true)
  end
end
function CustomVoiceContrlPanelMobile:SaveGame()
  LogInfo("CustomVoiceContrlPanelMobile", "SaveGame MicIndex =" .. tostring(self.MicIndex))
  LogInfo("CustomVoiceContrlPanelMobile", "SaveGame SpeakerIndex =" .. tostring(self.SpeakerIndex))
  local saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
  saveGameData.MicIndex = self.MicIndex
  saveGameData.SpeakerIndex = self.SpeakerIndex
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
end
return CustomVoiceContrlPanelMobile
