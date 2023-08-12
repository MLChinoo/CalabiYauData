local MicContrlPanelPanelMediatorMobile = class("MicContrlPanelPanelMediatorMobile", PureMVC.Mediator)
local VoiceEnum = require("Business/HUD/Voice/VoiceEnum")
local VoiceSlotName = "VoiceSlot"
local PMVoiceManager
function MicContrlPanelPanelMediatorMobile:ListNotificationInterests()
  return {}
end
function MicContrlPanelPanelMediatorMobile:OnRegister()
  self.MicBtn_List = {
    "Mic_Always_Team",
    "Mic_Always_Room",
    "Mic_Always_Close",
    "Mic_Press_Team",
    "Mic_Press_Room"
  }
  self:GetViewComponent().actionOnClickMicRootBtn:Add(self.OnClickMicRootBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysTeamBtn:Add(self.OnClickMicAlwaysTeamBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysRoomBtn:Add(self.OnClickMicAlwaysRoomBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysCloseBtn:Add(self.OnClickMicAlwaysCloseBtn, self)
  self:GetViewComponent().actionOnClickMicPressTeamBtn:Add(self.OnClickMicPressTeamBtn, self)
  self:GetViewComponent().actionOnClickMicPressRoomBtn:Add(self.OnClickMicPressRoomBtn, self)
  self:GetViewComponent().actionOnClickCloseBtn:Add(self.OnClickCloseBtn, self)
  self:SetEnableUI(false)
  PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  if PMVoiceManager:IsInRoomVoiceChannel() or PMVoiceManager:IsInTeamVoiceChannel() then
    self:InitView()
  end
  self.OnJoinVoiceRoomHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnJoinVoiceRoom, self, "OnJoinVoiceRoom")
  self.OnQuitVoiceRoomHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnQuitVoiceRoom, self, "OnQuitVoiceRoom")
end
function MicContrlPanelPanelMediatorMobile:OnJoinVoiceRoom()
  self:InitView()
end
function MicContrlPanelPanelMediatorMobile:OnQuitVoiceRoom()
  if not PMVoiceManager:IsInRoomVoiceChannel() and not PMVoiceManager:IsInTeamVoiceChannel() then
    self:SetEnableUI(false)
  end
end
function MicContrlPanelPanelMediatorMobile:SetEnableUI(isEnable)
  if isEnable then
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function MicContrlPanelPanelMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnClickMicRootBtn:Remove(self.OnClickMicRootBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysTeamBtn:Remove(self.OnClickMicAlwaysTeamBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysRoomBtn:Remove(self.OnClickMicAlwaysRoomBtn, self)
  self:GetViewComponent().actionOnClickMicAlwaysCloseBtn:Remove(self.OnClickMicAlwaysCloseBtn, self)
  self:GetViewComponent().actionOnClickMicPressTeamBtn:Remove(self.OnClickMicPressTeamBtn, self)
  self:GetViewComponent().actionOnClickMicPressRoomBtn:Remove(self.OnClickMicPressRoomBtn, self)
  self:GetViewComponent().actionOnClickCloseBtn:Remove(self.OnClickCloseBtn, self)
  if self.OnJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnJoinVoiceRoom, self.OnJoinVoiceRoomHandler)
    self.OnJoinVoiceRoomHandler = nil
  end
  if self.OnQuitVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnQuitVoiceRoom, self.OnQuitVoiceRoomHandler)
    self.OnQuitVoiceRoomHandler = nil
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
function MicContrlPanelPanelMediatorMobile:InitView()
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  if nil == saveGameData then
    LogDebug("MicContrlPanelPanelMediatorMobile", "saveGameData = nil")
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  else
    LogInfo("MicContrlPanelPanelMediatorMobile", "InitView MicIndex = " .. tostring(saveGameData.MicIndex))
    LogInfo("MicContrlPanelPanelMediatorMobile", "InitView SpeakerIndex =" .. tostring(saveGameData.SpeakerIndex))
  end
  if not self:CheckValid(saveGameData.MicIndex, VoiceEnum.MicChannelType) then
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
  end
  if not self:CheckValid(saveGameData.SpeakerIndex, VoiceEnum.SpeakerChannelType) then
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  end
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  self.MicIndex = saveGameData.MicIndex
  self:HideMicPanel()
  self.bIsShowMic = false
  self:ApplyMicSetting()
  self:SetEnableUI(true)
end
function MicContrlPanelPanelMediatorMobile:ApplyMicSetting()
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
function MicContrlPanelPanelMediatorMobile:MicTeamAuto()
  LogDebug("MicContrlPanelPanelMediatorMobile", "MicTeamAuto")
  PMVoiceManager:OpenRoomVoiceMic(true)
  PMVoiceManager:OpenTeamVoiceMic(true)
  PMVoiceManager:SetCurrentVoiceChannel(PMVoiceManager:GetTeamVoiceChannel())
end
function MicContrlPanelPanelMediatorMobile:MicRoomAuto()
  LogDebug("MicContrlPanelPanelMediatorMobile", "MicRoomAuto")
  PMVoiceManager:OpenTeamVoiceMic(false)
  PMVoiceManager:OpenRoomVoiceMic(true)
  PMVoiceManager:SetCurrentVoiceChannel(PMVoiceManager:GetRoomVoiceChannel())
end
function MicContrlPanelPanelMediatorMobile:MicClose()
  LogDebug("MicContrlPanelPanelMediatorMobile", "MicClose")
  PMVoiceManager:SetMicIsEnable(false)
  PMVoiceManager:OpenRoomVoiceMic(false)
  PMVoiceManager:OpenTeamVoiceMic(false)
  PMVoiceManager:SetCurrentVoiceChannel("")
end
function MicContrlPanelPanelMediatorMobile:CheckValid(index, channelType)
  for k, v in pairs(channelType) do
    if v == index then
      return true
    end
  end
  return false
end
function MicContrlPanelPanelMediatorMobile:OnClickMicRootBtn()
  LogDebug("MicContrlPanelPanelMediatorMobile", "OnClickMicRootBtn")
  if self.bIsShowMic then
    self:HideMicPanel()
  else
    self:ShowMicPanel()
  end
end
function MicContrlPanelPanelMediatorMobile:OnClickMicAlwaysTeamBtn()
  LogDebug("MicContrlPanelPanelMediatorMobile", "OnClickMicAlwaysTeamBtn")
  self.MicIndex = VoiceEnum.MicChannelType.TeamAuto
  self:OnClickMicBtn()
end
function MicContrlPanelPanelMediatorMobile:OnClickMicAlwaysRoomBtn()
  LogDebug("MicContrlPanelPanelMediatorMobile", "OnClickMicAlwaysRoomBtn")
  self.MicIndex = VoiceEnum.MicChannelType.RoomAuto
  self:OnClickMicBtn()
end
function MicContrlPanelPanelMediatorMobile:OnClickMicAlwaysCloseBtn()
  LogDebug("MicContrlPanelPanelMediatorMobile", "OnClickMicAlwaysCloseBtn")
  self.MicIndex = VoiceEnum.MicChannelType.Close
  self:OnClickMicBtn()
end
function MicContrlPanelPanelMediatorMobile:OnClickMicPressTeamBtn()
  LogDebug("MicContrlPanelPanelMediatorMobile", "OnClickMicPressTeamBtn")
  self.MicIndex = VoiceEnum.MicChannelType.TeamPress
  self:OnClickMicBtn()
end
function MicContrlPanelPanelMediatorMobile:OnClickMicPressRoomBtn()
  LogDebug("MicContrlPanelPanelMediatorMobile", "OnClickMicPressRoomBtn")
  self.MicIndex = VoiceEnum.MicChannelType.RoomPress
  self:OnClickMicBtn()
end
function MicContrlPanelPanelMediatorMobile:HideMicPanel()
  self:GetViewComponent().MicPanelRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self.MicIndex - 1)
  self.bIsShowMic = false
end
function MicContrlPanelPanelMediatorMobile:UpdataMicPanel()
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
function MicContrlPanelPanelMediatorMobile:ShowMicPanel()
  self:SetMicPanelLoc()
  self:UpdataMicPanel()
  self:GetViewComponent().MicPanelRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:GetViewComponent().CloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self:GetViewComponent().WidgetSwitcher_Mic:SetActiveWidgetIndex(self:GetViewComponent().WidgetSwitcher_Mic:GetChildrenCount() - 1)
  self.bIsShowMic = true
end
function MicContrlPanelPanelMediatorMobile:OnClickMicBtn()
  self:HideMicPanel()
  self:SaveGame()
  self:ApplyMicSetting()
end
function MicContrlPanelPanelMediatorMobile:HandleNotification(notification)
end
function MicContrlPanelPanelMediatorMobile:SaveGame()
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  if nil == saveGameData then
    LogDebug("MicContrlPanelPanelMediatorMobile", "saveGameData = nil")
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  end
  saveGameData.MicIndex = self.MicIndex
  LogInfo("MicContrlPanelPanelMediatorMobile", "SaveGame MicIndex =" .. tostring(saveGameData.MicIndex))
  LogInfo("MicContrlPanelPanelMediatorMobile", "SaveGame SpeakerIndex =" .. tostring(saveGameData.SpeakerIndex))
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
end
function MicContrlPanelPanelMediatorMobile:SetMicPanelLoc()
  if self:GetViewComponent().Panel_MicChannel == nil or nil == self:GetViewComponent().BelowRight or nil == self:GetViewComponent().AboveRight or nil == self:GetViewComponent().AboveLeft or nil == self:GetViewComponent().BelowLeft or nil == self:GetViewComponent().MicPanelRoot then
    return
  end
  local position = UE4.UPMWidgetBlueprintLibrary.GetWidgetCenterPosition(self:GetViewComponent().Panel_MicChannel, self:GetViewComponent())
  local size = self:GetViewComponent().Panel_MicChannel:GetDesiredSize()
  local scale = self:GetViewComponent().Panel_MicChannel.RenderTransform.Scale
  local desiredSize = size * scale
  local posType = self:GetPanelAlignmentType(position, desiredSize)
  LogDebug("MicContrlPanelPanelMediatorMobile", "posType = " .. posType)
  if posType == GlobalEnumDefine.ESecondPanelAlignment.BelowRight then
    self:GetViewComponent().BelowRight:AddChild(self:GetViewComponent().MicPanelRoot)
  elseif posType == GlobalEnumDefine.ESecondPanelAlignment.AboveRight then
    self:GetViewComponent().AboveRight:AddChild(self:GetViewComponent().MicPanelRoot)
  elseif posType == GlobalEnumDefine.ESecondPanelAlignment.BelowLeft then
    self:GetViewComponent().BelowLeft:AddChild(self:GetViewComponent().MicPanelRoot)
  elseif posType == GlobalEnumDefine.ESecondPanelAlignment.AboveLeft then
    self:GetViewComponent().AboveLeft:AddChild(self:GetViewComponent().MicPanelRoot)
  end
end
function MicContrlPanelPanelMediatorMobile:GetPanelAlignmentType(position, desiredSize)
  if nil == position or nil == desiredSize then
    return nil
  end
  local centerX = position.X + desiredSize.X / 2
  local centerY = position.Y + desiredSize.Y / 2
  if centerX and centerY then
    if centerX < 960.0 then
      return centerY < 540.0 and GlobalEnumDefine.ESecondPanelAlignment.BelowRight or GlobalEnumDefine.ESecondPanelAlignment.AboveRight
    else
      return centerY < 540.0 and GlobalEnumDefine.ESecondPanelAlignment.BelowLeft or GlobalEnumDefine.ESecondPanelAlignment.AboveLeft
    end
  end
end
function MicContrlPanelPanelMediatorMobile:OnClickCloseBtn()
  self:HideMicPanel()
end
return MicContrlPanelPanelMediatorMobile
