local ChatTabPanel = class("ChatTabPanel", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function ChatTabPanel:ListNeededMediators()
  return {}
end
function ChatTabPanel:InitializeLuaEvent()
  self.actionOnSelectChannel = LuaEvent.new(tabName)
  self.actionOnCloseChannel = LuaEvent.new(tabName)
end
function ChatTabPanel:Construct()
  ChatTabPanel.super.Construct(self)
  self.channelType = ChatEnum.EChatChannel.world
  self.channelTabName = ""
  self.tabState = ChatEnum.EChatState.deactive
  self.hasAlartVoice = true
  self.alwaysShow = true
  self.chatId = 0
  self.unreadNum = 0
  self.isTabSettingShow = false
  if self.Button_SelectTab then
    self.Button_SelectTab.OnClicked:Add(self, self.OnSelect)
  end
  if self.CloseBtn then
    self.CloseBtn.OnClicked:Add(self, self.OnClickClose)
  end
  if self.SettingBtn then
    self.SettingBtn.OnClicked:Add(self, self.OnClickSetting)
  end
  if self.DownBtn then
    self.DownBtn.OnClicked:Add(self, self.ShowTabSettings)
  end
  if self.AllTabShowBtn1 and self.AllTabShowBtn2 then
    self.AllTabShowBtn1.OnHovered:Add(self, self.OnAllTabShowHovered)
    self.AllTabShowBtn1.OnUnhovered:Add(self, self.OnAllTabShowUnhovered)
    self.AllTabShowBtn1.OnClicked:Add(self, self.OnClickAllTabUnshow)
    self.AllTabShowBtn2.OnHovered:Add(self, self.OnAllTabShowHovered)
    self.AllTabShowBtn2.OnUnhovered:Add(self, self.OnAllTabShowUnhovered)
    self.AllTabShowBtn2.OnClicked:Add(self, self.OnClickAllTabShow)
  end
  if self.MessageAudioBtn1 and self.MessageAudioBtn2 then
    self.MessageAudioBtn1.OnHovered:Add(self, self.OnMessageAudioHovered)
    self.MessageAudioBtn1.OnUnhovered:Add(self, self.OnMessageAudioUnhovered)
    self.MessageAudioBtn1.OnClicked:Add(self, self.OnClickNoAlart)
    self.MessageAudioBtn2.OnHovered:Add(self, self.OnMessageAudioHovered)
    self.MessageAudioBtn2.OnUnhovered:Add(self, self.OnMessageAudioUnhovered)
    self.MessageAudioBtn2.OnClicked:Add(self, self.OnClickHasAlart)
  end
end
function ChatTabPanel:Destruct()
  if self.Button_SelectTab then
    self.Button_SelectTab.OnClicked:Remove(self, self.OnSelect)
  end
  if self.CloseBtn then
    self.CloseBtn.OnClicked:Remove(self, self.OnClickClose)
  end
  if self.SettingBtn then
    self.SettingBtn.OnClicked:Remove(self, self.OnClickSetting)
  end
  if self.DownBtn then
    self.DownBtn.OnClicked:Remove(self, self.ShowTabSettings)
  end
  if self.AllTabShowBtn1 and self.AllTabShowBtn2 then
    self.AllTabShowBtn1.OnHovered:Remove(self, self.OnAllTabShowHovered)
    self.AllTabShowBtn1.OnUnhovered:Remove(self, self.OnAllTabShowUnhovered)
    self.AllTabShowBtn1.OnClicked:Remove(self, self.OnClickAllTabUnshow)
    self.AllTabShowBtn2.OnHovered:Remove(self, self.OnAllTabShowHovered)
    self.AllTabShowBtn2.OnUnhovered:Remove(self, self.OnAllTabShowUnhovered)
    self.AllTabShowBtn2.OnClicked:Remove(self, self.OnClickAllTabShow)
  end
  if self.MessageAudioBtn1 and self.MessageAudioBtn2 then
    self.MessageAudioBtn1.OnHovered:Add(self, self.OnMessageAudioHovered)
    self.MessageAudioBtn1.OnUnhovered:Add(self, self.OnMessageAudioUnhovered)
    self.MessageAudioBtn1.OnClicked:Add(self, self.OnClickNoAlart)
    self.MessageAudioBtn2.OnHovered:Add(self, self.OnMessageAudioHovered)
    self.MessageAudioBtn2.OnUnhovered:Add(self, self.OnMessageAudioUnhovered)
    self.MessageAudioBtn2.OnClicked:Add(self, self.OnClickHasAlart)
  end
  ChatTabPanel.super.Destruct(self)
end
function ChatTabPanel:InitProps(name, chatType, chatId)
  self:SetTabType(chatType)
  self:SetTabName(name)
  self:SetChatId(chatId)
end
function ChatTabPanel:SetTabType(newType)
  self.channelType = newType
  if self.WidgetSwitcher_TabType then
    if self.channelType == ChatEnum.EChatChannel.private then
      self.WidgetSwitcher_TabType:SetActiveWidgetIndex(0)
      self.WidgetSwitcher_TabType:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif self.channelType == ChatEnum.EChatChannel.world then
      self.WidgetSwitcher_TabType:SetActiveWidgetIndex(1)
      self.WidgetSwitcher_TabType:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.WidgetSwitcher_TabType:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
  if self.channelType == ChatEnum.EChatChannel.world then
    self:SetAlwaysShow(false)
    self:SetHasAlartVoice(false)
  else
    self:SetAlwaysShow(false)
    self:SetHasAlartVoice(false)
  end
end
function ChatTabPanel:SetTabName(newName)
  self.channelTabName = newName
  if self.TabName then
    local nameShow = ""
    if self.channelType == ChatEnum.EChatChannel.private then
      nameShow = newName
    else
      nameShow = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, newName)
    end
    if UE4.UKismetStringLibrary.Len(nameShow) > 2 then
      nameShow = UE4.UKismetStringLibrary.Left(nameShow, 2) .. " ..."
    end
    self.TabName:SetText(nameShow)
  end
end
function ChatTabPanel:SetTabState(newState)
  self.tabState = newState
  if self.TipsImg then
    if self.tabState == ChatEnum.EChatState.newMsg then
      self.TipsImg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.TipsImg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.tabState == ChatEnum.EChatState.active then
    self:SetUnreadNum(0)
    self.Button_SelectTab:SetIsEnabled(false)
  else
    self.Button_SelectTab:SetIsEnabled(true)
  end
  self:ShowTabSettings(true)
end
function ChatTabPanel:SetHasAlartVoice(hasVoice)
  self.hasAlartVoice = hasVoice
  if self.WidgetSwitcher_MessageAudio then
    if self.hasAlartVoice then
      self.WidgetSwitcher_MessageAudio:SetActiveWidgetIndex(0)
    else
      self.WidgetSwitcher_MessageAudio:SetActiveWidgetIndex(1)
    end
  end
end
function ChatTabPanel:SetAlwaysShow(alwaysShow)
  self.alwaysShow = alwaysShow
  if self.WidgetSwitcher_AllTabShow then
    if self.alwaysShow then
      self.WidgetSwitcher_AllTabShow:SetActiveWidgetIndex(0)
    else
      self.WidgetSwitcher_AllTabShow:SetActiveWidgetIndex(1)
    end
  end
end
function ChatTabPanel:SetChatId(newChatId)
  self.chatId = newChatId
end
function ChatTabPanel:SetUnreadNum(newUnreadNum)
  self.unreadNum = newUnreadNum
  if self.unreadNum > 0 then
    local numberShow = tostring(self.unreadNum)
    if self.unreadNum > 99 then
      numberShow = "99+"
    end
    if self.Text_UnreadNum then
      self.Text_UnreadNum:SetText(numberShow)
    end
    self.UnreadPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UnreadPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ChatTabPanel:CopyTabProps(targetTab)
  self:SetTabType(targetTab.channelType)
  self:SetTabName(targetTab.channelTabName)
  self:SetTabState(targetTab.tabState)
  if self.tabState == ChatEnum.EChatState.active then
    self.actionOnSelectChannel(self.channelTabName)
  end
  self:SetHasAlartVoice(targetTab.hasAlartVoice)
  self:SetAlwaysShow(targetTab.alwaysShow)
  self:SetChatId(targetTab.chatId)
  self:SetUnreadNum(targetTab.unreadNum)
end
function ChatTabPanel:AddMsg()
  self:SetTabState(ChatEnum.EChatState.newMsg)
  self:SetUnreadNum(self.unreadNum + 1)
end
function ChatTabPanel:ShowTabSettings(close)
  if self.DownPanel then
    if self.isTabSettingShow or close then
      self.DownPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.DownBtn:SetRenderScale(UE4.FVector2D(1, -1))
      self.isTabSettingShow = false
    else
      self.DownPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.DownBtn:SetRenderScale(UE4.FVector2D(1, 1))
      self.isTabSettingShow = true
    end
  end
end
function ChatTabPanel:OnSelect()
  if self.chatState ~= ChatEnum.EChatState.active then
    self.actionOnSelectChannel(self.channelTabName)
  end
end
function ChatTabPanel:OnClickClose()
  self.actionOnCloseChannel(self.channelTabName)
end
function ChatTabPanel:OnClickSetting()
  LogDebug("ChatTabPanel", "Click setting")
  ViewMgr:OpenPage(self, UIPageNameDefine.WorldChatSettings)
end
function ChatTabPanel:OnClickAllTabShow()
  self:SetAlwaysShow(true)
end
function ChatTabPanel:OnClickAllTabUnshow()
  self:SetAlwaysShow(false)
end
function ChatTabPanel:OnClickHasAlart()
  self:SetHasAlartVoice(true)
end
function ChatTabPanel:OnClickNoAlart()
  self:SetHasAlartVoice(false)
end
function ChatTabPanel:OnAllTabShowHovered()
  if self.WidgetSwitcher_Tip then
    self.WidgetSwitcher_Tip:SetActiveWidgetIndex(0)
    self.WidgetSwitcher_Tip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ChatTabPanel:OnAllTabShowUnhovered()
  if self.WidgetSwitcher_Tip then
    self.WidgetSwitcher_Tip:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ChatTabPanel:OnMessageAudioHovered()
  if self.WidgetSwitcher_Tip then
    self.WidgetSwitcher_Tip:SetActiveWidgetIndex(1)
    self.WidgetSwitcher_Tip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ChatTabPanel:OnMessageAudioUnhovered()
  if self.WidgetSwitcher_Tip then
    self.WidgetSwitcher_Tip:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ChatTabPanel:OnRemovedFromFocusPath(inFocusEvent)
  self:ShowTabSettings(true)
end
return ChatTabPanel
