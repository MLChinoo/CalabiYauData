local MatchVoiceContrlPanelMediatorMobile = class("MatchVoiceContrlPanelMediatorMobile", PureMVC.Mediator)
local VoiceEnum = require("Business/HUD/Voice/VoiceEnum")
local VoiceSlotName = "VoiceSlot"
local PMVoiceManager
function MatchVoiceContrlPanelMediatorMobile:ListNotificationInterests()
  return {}
end
function MatchVoiceContrlPanelMediatorMobile:OnRegister()
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
end
function MatchVoiceContrlPanelMediatorMobile:OnJoinVoiceRoom()
  self:InitView()
end
function MatchVoiceContrlPanelMediatorMobile:OnRemove()
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
function MatchVoiceContrlPanelMediatorMobile:HandleNotification(notification)
end
function MatchVoiceContrlPanelMediatorMobile:SetEnableUI(isEnable)
  if isEnable then
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function MatchVoiceContrlPanelMediatorMobile:InitView()
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  if nil == saveGameData then
    LogInfo("MatchVoiceContrlPanelMediatorMobile", "saveGameData = nil")
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  else
    LogInfo("MatchVoiceContrlPanelMediatorMobile", "InitView MicIndex = " .. tostring(saveGameData.MicIndex))
    LogInfo("MatchVoiceContrlPanelMediatorMobile", "InitView SpeakerIndex =" .. tostring(saveGameData.SpeakerIndex))
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
function MatchVoiceContrlPanelMediatorMobile:UpdataMicPanel()
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
function MatchVoiceContrlPanelMediatorMobile:ShowMicPanel()
  self:HideSpeakerPanel()
  self:UpdataMicPanel()
  self:GetViewComponent().MicPanelRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self:GetViewComponent().WidgetSwitcher_Mic:GetChildrenCount() - 1)
  self.bIsShowMic = true
end
function MatchVoiceContrlPanelMediatorMobile:UpdataSpeakerPanel()
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
function MatchVoiceContrlPanelMediatorMobile:ShowSpeakerPanel()
  self:HideMicPanel()
  self:UpdataSpeakerPanel()
  self:GetViewComponent().SpeakerPanelRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:GetViewComponent().WidgetSwitcher_Speaker:SetActiveWidgetIndex(self:GetViewComponent().WidgetSwitcher_Speaker:GetChildrenCount() - 1)
  self.bIsShowSpeaker = true
end
function MatchVoiceContrlPanelMediatorMobile:HideMicPanel()
  self:GetViewComponent().MicPanelRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self.MicIndex - 1)
  self.bIsShowMic = false
end
function MatchVoiceContrlPanelMediatorMobile:HideSpeakerPanel()
  self:GetViewComponent().SpeakerPanelRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WidgetSwitcher_Speaker:SetActiveWidgetIndex(self.SpeakerIndex - 1)
  self.bIsShowSpeaker = false
end
function MatchVoiceContrlPanelMediatorMobile:CheckValid(index, channelType)
  for k, v in pairs(channelType) do
    if v == index then
      return true
    end
  end
  return false
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicRootBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickMicRootBtn")
  if self.bIsShowMic then
    self:HideMicPanel()
  else
    self:ShowMicPanel()
  end
end
function MatchVoiceContrlPanelMediatorMobile:OnClickSpeakerRootBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickSpeakerRootBtn")
  if self.bIsShowSpeaker then
    self:HideSpeakerPanel()
  else
    self:ShowSpeakerPanel()
  end
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicAlwaysTeamBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickMicAlwaysTeamBtn")
  self.MicIndex = VoiceEnum.MicChannelType.TeamAuto
  self:OnClickMicBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicAlwaysRoomBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickMicAlwaysRoomBtn")
  self.MicIndex = VoiceEnum.MicChannelType.RoomAuto
  self:OnClickMicBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicAlwaysCloseBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickMicAlwaysCloseBtn")
  self.MicIndex = VoiceEnum.MicChannelType.Close
  self:OnClickMicBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicPressTeamBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickMicPressTeamBtn")
  self.MicIndex = VoiceEnum.MicChannelType.TeamPress
  self:OnClickMicBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicPressRoomBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickMicPressRoomBtn")
  self.MicIndex = VoiceEnum.MicChannelType.RoomPress
  self:OnClickMicBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickMicBtn()
  self:HideMicPanel()
  self:SaveGame()
  self:ApplyMicSetting()
end
function MatchVoiceContrlPanelMediatorMobile:ApplyMicSetting()
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
function MatchVoiceContrlPanelMediatorMobile:MicTeamAuto()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "MicTeamAuto")
  PMVoiceManager:OpenRoomVoiceMic(true)
  PMVoiceManager:OpenTeamVoiceMic(true)
  PMVoiceManager:SetCurrentVoiceChannel(PMVoiceManager:GetTeamVoiceChannel())
end
function MatchVoiceContrlPanelMediatorMobile:MicRoomAuto()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "MicRoomAuto")
  PMVoiceManager:OpenTeamVoiceMic(false)
  PMVoiceManager:OpenRoomVoiceMic(true)
  PMVoiceManager:SetCurrentVoiceChannel(PMVoiceManager:GetRoomVoiceChannel())
end
function MatchVoiceContrlPanelMediatorMobile:MicClose()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "MicClose")
  PMVoiceManager:SetMicIsEnable(false)
  PMVoiceManager:OpenRoomVoiceMic(false)
  PMVoiceManager:OpenTeamVoiceMic(false)
  PMVoiceManager:SetCurrentVoiceChannel("")
end
function MatchVoiceContrlPanelMediatorMobile:OnClickSpeakerRoomBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickSpeakerRoomBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  self:OnClickSpeakerBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickSpeakerTeamBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickSpeakerTeamBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Team
  self:OnClickSpeakerBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickSpeakerCloseBtn()
  LogDebug("MatchVoiceContrlPanelMediatorMobile", "OnClickSpeakerCloseBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Close
  self:OnClickSpeakerBtn()
end
function MatchVoiceContrlPanelMediatorMobile:OnClickSpeakerBtn()
  self:HideSpeakerPanel()
  self:SaveGame()
  self:ApplySpeakerSetting()
end
function MatchVoiceContrlPanelMediatorMobile:ApplySpeakerSetting()
  local PlayerIDList = PMVoiceManager:GetTeamMemberPlayerIDList()
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
function MatchVoiceContrlPanelMediatorMobile:SetPlayreState(playerID)
  if self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Team then
    LogDebug("MatchVoiceContrlPanelMediatorMobile", "SpeakerTeam")
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, false)
  elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Room then
    LogDebug("MatchVoiceContrlPanelMediatorMobile", "SpeakerRoom")
    local IsRoommate = PMVoiceManager:IsRoommate(playerID)
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, not IsRoommate)
  elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Close then
    LogDebug("MatchVoiceContrlPanelMediatorMobile", "SpeakerClose")
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, true)
  end
end
function MatchVoiceContrlPanelMediatorMobile:SaveGame()
  LogInfo("MatchVoiceContrlPanelMediatorMobile", "SaveGame MicIndex =" .. tostring(self.MicIndex))
  LogInfo("MatchVoiceContrlPanelMediatorMobile", "SaveGame SpeakerIndex =" .. tostring(self.SpeakerIndex))
  local saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
  saveGameData.MicIndex = self.MicIndex
  saveGameData.SpeakerIndex = self.SpeakerIndex
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
end
return MatchVoiceContrlPanelMediatorMobile
