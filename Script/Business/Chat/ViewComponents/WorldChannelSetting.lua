local WorldChannelSetting = class("WorldChannelSetting", PureMVC.ViewComponentPage)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local WorldChannelSettingMediator = require("Business/Chat/Mediators/WorldChannelSettingMediator")
function WorldChannelSetting:ListNeededMediators()
  return {WorldChannelSettingMediator}
end
function WorldChannelSetting:InitializeLuaEvent()
end
function WorldChannelSetting:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("WorldChannelSetting", "Lua implement OnOpen")
  self.choiceList = {}
  self.worldMsgSetting = nil
  self.selectedChannel = nil
  if self.CheckBox_Display then
    self.CheckBox_Display.OnCheckStateChanged:Add(self, self.ChooseDisplay)
    self.choiceList[ChatEnum.EWorldMsgSetting.display] = self.CheckBox_Display
  end
  if self.CheckBox_Receive then
    self.CheckBox_Receive.OnCheckStateChanged:Add(self, self.ChooseReceive)
    self.choiceList[ChatEnum.EWorldMsgSetting.receive] = self.CheckBox_Receive
  end
  if self.CheckBox_Ignore then
    self.CheckBox_Ignore.OnCheckStateChanged:Add(self, self.ChooseIgnore)
    self.choiceList[ChatEnum.EWorldMsgSetting.ignore] = self.CheckBox_Ignore
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  end
  if self.Button_Confirm then
    self.Button_Confirm.OnClickEvent:Add(self, self.OnClickConfirm)
    self.Button_Confirm:SetIsEnabled(false)
  end
  if self.InputChannel then
    self.InputChannel.OnTextChanged:Add(self, self.OnInputChanged)
    self.InputChannel.OnTextCommitted:Add(self, self.OnCommitText)
  end
  if self.ChannelList then
    self.ChannelList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ChannelList.BP_OnItemSelectionChanged:Add(self, self.OnSelectionChanged)
  end
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Collapsed)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.HoldOn)
  ViewMgr:OpenPage(self, UIPageNameDefine.PendingPage)
  GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):QueryAllWorldChannel()
end
function WorldChannelSetting:OnClose()
  if self.CheckBox_Display then
    self.CheckBox_Display.OnCheckStateChanged:Remove(self, self.ChooseDisplay)
  end
  if self.CheckBox_Receive then
    self.CheckBox_Receive.OnCheckStateChanged:Remove(self, self.ChooseReceive)
  end
  if self.CheckBox_Ignore then
    self.CheckBox_Ignore.OnCheckStateChanged:Remove(self, self.ChooseIgnore)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  end
  if self.Button_Confirm then
    self.Button_Confirm.OnClickEvent:Remove(self, self.OnClickConfirm)
  end
  if self.ChannelList then
    self.ChannelList.BP_OnItemSelectionChanged:Remove(self, self.OnSelectionChanged)
  end
  if self.InputChannel then
    self.InputChannel.OnTextChanged:Remove(self, self.OnInputChanged)
    self.InputChannel.OnTextCommitted:Remove(self, self.OnCommitText)
  end
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.CancelHoldOn)
end
function WorldChannelSetting:InitView(allChannels)
  ViewMgr:ClosePage(self, UIPageNameDefine.PendingPage)
  local wordlChatProxy = GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy)
  if nil == wordlChatProxy then
    return
  end
  self.worldMsgSetting = wordlChatProxy:GetWorldMsgSetting()
  if self.worldMsgSetting then
    self:ChooseMsgSetting(self.worldMsgSetting)
  end
  if self.Text_CurChannel and wordlChatProxy:GetWorldChannelId() then
    self.Text_CurChannel:SetText(wordlChatProxy:GetWorldChannelId())
  end
  if self.ChannelList then
    for key, value in pairsByKeys(allChannels.items, function(a, b)
      return allChannels.items[a].count > allChannels.items[b].count
    end) do
      local itemObj = ObjectUtil:CreateLuaUObject(self)
      itemObj.data = value
      self.ChannelList:AddItem(itemObj)
    end
    if allChannels.all_channel > 0 then
      self.ChannelList:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end
function WorldChannelSetting:ChooseMsgSetting(worldMsgSetting)
  for key, value in pairs(self.choiceList) do
    value:SetIsChecked(worldMsgSetting == key)
  end
  if self.worldMsgSetting ~= worldMsgSetting then
    self.worldMsgSetting = worldMsgSetting
    if self.Button_Confirm then
      self.Button_Confirm:SetIsEnabled(true)
    end
  end
end
function WorldChannelSetting:ChooseDisplay(bCheck)
  if self.worldMsgSetting == ChatEnum.EWorldMsgSetting.display then
    self.CheckBox_Display:SetIsChecked(true)
  else
    self:ChooseMsgSetting(ChatEnum.EWorldMsgSetting.display)
  end
end
function WorldChannelSetting:ChooseReceive(bCheck)
  if self.worldMsgSetting == ChatEnum.EWorldMsgSetting.receive then
    self.CheckBox_Receive:SetIsChecked(true)
  else
    self:ChooseMsgSetting(ChatEnum.EWorldMsgSetting.receive)
  end
end
function WorldChannelSetting:ChooseIgnore(bCheck)
  if self.worldMsgSetting == ChatEnum.EWorldMsgSetting.ignore then
    self.CheckBox_Ignore:SetIsChecked(true)
  else
    self:ChooseMsgSetting(ChatEnum.EWorldMsgSetting.ignore)
  end
end
function WorldChannelSetting:OnSelectionChanged(itemObj, bIsSelected)
  if bIsSelected then
    self.selectedChannel = itemObj.data.channel
    if self.Button_Confirm then
      self.Button_Confirm:SetIsEnabled(true)
    end
  end
end
function WorldChannelSetting:OnClickConfirm()
  GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):SetWorldMsgSetting(self.worldMsgSetting)
  ViewMgr:ClosePage(self)
  if self.selectedChannel == nil or self.selectedChannel == GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):GetWorldChannelId() then
    return
  end
  LogDebug("WorldChannelSetting", "Confirm change to channel %d", self.selectedChannel)
  GameFacade:RetrieveProxy(ProxyNames.WorldChatProxy):ReqModifyWorldChannel(self.selectedChannel)
end
function WorldChannelSetting:OnClickReturn()
  ViewMgr:ClosePage(self)
end
function WorldChannelSetting:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.Button_Return and not ret then
    ret = self.Button_Return:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_Confirm and not ret then
    ret = self.Button_Confirm:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function WorldChannelSetting:OnInputChanged(text)
  if self.Text_InputHint then
    self.Text_InputHint:SetVisibility("" == text and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function WorldChannelSetting:OnCommitText(text, commitMethod)
  if "" ~= text and commitMethod == UE4.ETextCommit.OnEnter then
    if self.ChannelList then
      local listObjects = self.ChannelList:GetListItems()
      for i = 1, listObjects:Length() do
        local item = listObjects:Get(i)
        if item.data and item.data.channel == tonumber(text) then
          self.ChannelList:BP_ScrollItemIntoView(item)
          self.ChannelList:BP_SetSelectedItem(item)
          return
        end
      end
    end
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20314)
  end
end
return WorldChannelSetting
