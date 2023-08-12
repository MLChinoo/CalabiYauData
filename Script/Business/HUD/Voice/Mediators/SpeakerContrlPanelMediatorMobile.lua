local SpeakerContrlPanelMediatorMobile = class("SpeakerContrlPanelMediatorMobile", PureMVC.Mediator)
local VoiceEnum = require("Business/HUD/Voice/VoiceEnum")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local VoiceSlotName = "VoiceSlot"
local PMVoiceManager
function SpeakerContrlPanelMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.Chat.ChatPanelStatusChange
  }
end
function SpeakerContrlPanelMediatorMobile:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Chat.ChatPanelStatusChange then
    self:ChangeChatState(notification:GetBody())
  end
end
function SpeakerContrlPanelMediatorMobile:OnRegister()
  self.SpeakerBtn_List = {
    "Speaker_Team",
    "Speaker_Room",
    "Speaker_Close"
  }
  self:GetViewComponent().actionOnClickSpeakerTeamBtn:Add(self.OnClickSpeakerTeamBtn, self)
  self:GetViewComponent().actionOnClickSpeakerRoomBtn:Add(self.OnClickSpeakerRoomBtn, self)
  self:GetViewComponent().actionOnClickSpeakerCloseBtn:Add(self.OnClickSpeakerCloseBtn, self)
  PMVoiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  if PMVoiceManager:IsInRoomVoiceChannel() or PMVoiceManager:IsInTeamVoiceChannel() then
    self:InitView()
  end
  self.OnJoinVoiceRoomHandler = DelegateMgr:AddDelegate(PMVoiceManager.OnJoinVoiceRoom, self, "OnJoinVoiceRoom")
  local global_delegate_manager = GetGlobalDelegateManager()
  self.OnPlayreForbidStateChangeHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnPlayreForbidStateChangeDelegate, self, "OnPlayreForbidStateChange")
end
function SpeakerContrlPanelMediatorMobile:OnJoinVoiceRoom()
  self:InitView()
end
function SpeakerContrlPanelMediatorMobile:OnPlayreForbidStateChange()
  self:UpdataItemView()
end
function SpeakerContrlPanelMediatorMobile:InitView()
  LogDebug("SpeakerContrlPanelMediatorMobile", "InitView")
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  if nil == saveGameData then
    LogDebug("SpeakerContrlPanelMediatorMobile", "saveGameData = nil")
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  else
    LogDebug("SpeakerContrlPanelMediatorMobile", "InitView MicIndex = " .. tostring(saveGameData.MicIndex))
    LogDebug("SpeakerContrlPanelMediatorMobile", "InitView SpeakerIndex =" .. tostring(saveGameData.SpeakerIndex))
  end
  if not self:CheckValid(saveGameData.MicIndex, VoiceEnum.MicChannelType) then
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
  end
  if not self:CheckValid(saveGameData.SpeakerIndex, VoiceEnum.SpeakerChannelType) then
    saveGameData.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  end
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  self.SpeakerIndex = saveGameData.SpeakerIndex
  self:UpdataSpeakerPanel()
  self:ApplySpeakerSetting()
end
function SpeakerContrlPanelMediatorMobile:CheckValid(index, channelType)
  for k, v in pairs(channelType) do
    if v == index then
      return true
    end
  end
  return false
end
function SpeakerContrlPanelMediatorMobile:ChangeChatState(isOpen)
  if isOpen then
    self.timerHandler = TimerMgr:AddTimeTask(0, 1, 0, function()
      self:UpdataItemView()
    end)
  elseif self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
end
function SpeakerContrlPanelMediatorMobile:UpdataItemView()
  if not PMVoiceManager:IsInRoomVoiceChannel() and not PMVoiceManager:IsInTeamVoiceChannel() then
    for index = 1, 5 do
      self:GetViewComponent()["SpeakerChatItem_" .. index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  local Team = GamePlayGlobal:GetTeam(LuaGetWorld())
  if nil == Team then
    return
  end
  local len = table.count(Team)
  for index = 1, 5 do
    self:GetViewComponent()["SpeakerChatItem_" .. index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if index <= len then
      local playerID = tostring(Team[index].UID)
      if playerID ~= PMVoiceManager.PlayerIDStr then
        self:GetViewComponent()["SpeakerChatItem_" .. index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:GetViewComponent()["SpeakerChatItem_" .. index]:InitView(playerID)
      end
    end
  end
end
function SpeakerContrlPanelMediatorMobile:UpdataSpeakerPanel()
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
function SpeakerContrlPanelMediatorMobile:OnRemove()
  self:GetViewComponent().actionOnClickSpeakerTeamBtn:Remove(self.OnClickSpeakerTeamBtn, self)
  self:GetViewComponent().actionOnClickSpeakerRoomBtn:Remove(self.OnClickSpeakerRoomBtn, self)
  self:GetViewComponent().actionOnClickSpeakerCloseBtn:Remove(self.OnClickSpeakerCloseBtn, self)
  if self.OnJoinVoiceRoomHandler then
    DelegateMgr:RemoveDelegate(PMVoiceManager.OnJoinVoiceRoom, self.OnJoinVoiceRoomHandler)
    self.OnJoinVoiceRoomHandler = nil
  end
  local global_delegate_manager = GetGlobalDelegateManager()
  if self.OnPlayreForbidStateChangeHandler then
    DelegateMgr:RemoveDelegate(global_delegate_manager.OnPlayreForbidStateChangeDelegate, self.OnPlayreForbidStateChangeHandler)
    self.OnPlayreForbidStateChangeHandler = nil
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
    self.timerHandler = nil
  end
end
function SpeakerContrlPanelMediatorMobile:OnClickSpeakerRoomBtn()
  LogDebug("SpeakerContrlPanelMediatorMobile", "OnClickSpeakerRoomBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Room
  self:OnClickSpeakerBtn()
end
function SpeakerContrlPanelMediatorMobile:OnClickSpeakerTeamBtn()
  LogDebug("SpeakerContrlPanelMediatorMobile", "OnClickSpeakerTeamBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Team
  self:OnClickSpeakerBtn()
end
function SpeakerContrlPanelMediatorMobile:OnClickSpeakerCloseBtn()
  LogDebug("SpeakerContrlPanelMediatorMobile", "OnClickSpeakerCloseBtn")
  self.SpeakerIndex = VoiceEnum.SpeakerChannelType.Close
  self:OnClickSpeakerBtn()
end
function SpeakerContrlPanelMediatorMobile:OnClickSpeakerBtn()
  self:SaveGame()
  self:ShowTip()
  self:ApplySpeakerSetting()
  self:UpdataSpeakerPanel()
end
function SpeakerContrlPanelMediatorMobile:ApplySpeakerSetting()
  local Team = GamePlayGlobal:GetTeam(LuaGetWorld())
  if nil == Team then
    return
  end
  local len = table.count(Team)
  for index = 1, len do
    local playerID = tostring(Team[index].UID)
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
function SpeakerContrlPanelMediatorMobile:SetPlayreState(playerID)
  if self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Team then
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, false)
  elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Room then
    local IsRoommate = PMVoiceManager:IsRoommate(playerID)
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, not IsRoommate)
  elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Close then
    PMVoiceManager:SetPlayreForbidVoiceState(playerID, true)
  end
end
function SpeakerContrlPanelMediatorMobile:ShowTip()
  if not PMVoiceManager:IsInRoomVoiceChannel() and not PMVoiceManager:IsInTeamVoiceChannel() then
    return
  end
  local Team = GamePlayGlobal:GetTeam(LuaGetWorld())
  if nil == Team then
    return
  end
  local len = table.count(Team)
  for index = 1, 5 do
    if index <= len then
      local playerID = tostring(Team[index].UID)
      if playerID ~= PMVoiceManager.PlayerIDStr then
        if self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Room then
          local IsRoommate = PMVoiceManager:IsRoommate(playerID)
          if PMVoiceManager:GetPlayreForbidVoiceState(playerID) == false and false == IsRoommate then
            local msg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Chat, "ForbidPlayerMsg")
            GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
            return
          end
        elseif self.SpeakerIndex == VoiceEnum.SpeakerChannelType.Close and PMVoiceManager:GetPlayreForbidVoiceState(playerID) == false then
          local msg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Chat, "ForbidPlayerMsg")
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
          return
        end
      end
    end
  end
end
function SpeakerContrlPanelMediatorMobile:SaveGame()
  local saveGameData = UE4.UGameplayStatics.LoadGameFromSlot(VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
  if nil == saveGameData then
    LogDebug("SpeakerContrlPanelMediatorMobile", "saveGameData = nil")
    saveGameData = UE4.UGameplayStatics.CreateSaveGameObject(UE4.UVoiceMBSaveGame)
    saveGameData.MicIndex = VoiceEnum.MicChannelType.Close
  end
  saveGameData.SpeakerIndex = self.SpeakerIndex
  LogInfo("SpeakerContrlPanelMediatorMobile", "SaveGame MicIndex =" .. tostring(saveGameData.MicIndex))
  LogInfo("SpeakerContrlPanelMediatorMobile", "SaveGame SpeakerIndex =" .. tostring(saveGameData.SpeakerIndex))
  UE4.UGameplayStatics.SaveGameToSlot(saveGameData, VoiceSlotName .. PMVoiceManager.PlayerIDStr, 0)
end
return SpeakerContrlPanelMediatorMobile
