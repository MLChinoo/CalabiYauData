local GameChatPageMobile = class("GameChatPageMobile", PureMVC.ViewComponentPage)
local GameChatPageMediator = require("Business/Chat/Mediators/GameChatPageMediator")
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function GameChatPageMobile:ListNeededMediators()
  return {GameChatPageMediator}
end
function GameChatPageMobile:InitializeLuaEvent()
  self.actionOnPageInitFinished = LuaEvent.new()
  self.actionOnSendMsg = LuaEvent.new(msgInfo)
end
function GameChatPageMobile:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("GameChatPageMobile", "Lua implement OnOpen")
  self.roomId = 0
  self.teamId = 0
  self.isSendingMsg = false
  self.teamMsgQueue = {}
  self.roomMsgQueue = {}
  self.teamCoolDown = 0
  self.roomCoolDown = 0
  self:ClearScrollTask()
  self:ClearSendTask()
  self:ClearUpdateTask()
  self:ClearTeamTask()
  self:ClearRoomTask()
  self.isInBattle = false
  self.bUseNewSetting = true
  self.invalidTeamChannelText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "TeamInvalid")
  self.msgRecord = {}
  self.msgPanels_Content = {}
  if self.ChatTextPanelClass and self.ScrollBox_Content then
    self.ScrollBox_Content:ClearChildren()
    self.chatTextClass = ObjectUtil:LoadClass(self.ChatTextPanelClass)
    if self.chatTextClass then
      for i = 1, 10 do
        local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.chatTextClass)
        if panelIns then
          panelIns.actionOnDeleteMsg:Add(self.DeleteMsg, self)
          self.ScrollBox_Content:AddChild(panelIns)
          table.insert(self.msgPanels_Content, panelIns)
        end
      end
    else
      LogDebug("GameChatPageMobile", "Chat msg panel class load failed")
    end
  end
  if RedDotTree then
    RedDotTree:Bind(RedDotModuleDef.ModuleName.GameChatPrivate, function(cnt)
      self:UpdateRedDotGameChatPrivate(cnt)
    end)
  end
  if self.CheckBox_ShortcutText then
    self.CheckBox_ShortcutText.OnCheckStateChanged:Add(self, self.OnSelectShortcut)
  end
  if self.CheckBox_GroupChat then
    self.CheckBox_GroupChat.OnCheckStateChanged:Add(self, self.OnSelectGroupChat)
  end
  if self.CheckBox_PrivateChat then
    self.CheckBox_PrivateChat.OnCheckStateChanged:Add(self, self.OnSelectPrivateChat)
  end
  if self.CheckBox_Voice then
    self.CheckBox_Voice.OnCheckStateChanged:Add(self, self.OnSelectVoiceSetting)
  end
  if self.Button_OpenChat then
    self.Button_OpenChat.OnClicked:Add(self, self.OnClickOpen)
  end
  if self.WidgetSwitcher_ChatPanel then
    self.childPanels = self.WidgetSwitcher_ChatPanel:GetAllChildren()
    for i = 1, self.childPanels:Length() do
      if self.childPanels:Get(i).actionOnSendMsg then
        self.childPanels:Get(i).actionOnSendMsg:Add(self.SendMsg, self)
      end
    end
  end
  self:AddChat(ChatEnum.EChatChannel.team, ChatEnum.ChannelName.team)
  self:SelectTab(2)
  self:InitView()
  self.actionOnPageInitFinished()
end
function GameChatPageMobile:OnClose()
  if RedDotTree then
    RedDotTree:Unbind(RedDotModuleDef.ModuleName.GameChatPrivate)
  end
  if self.CheckBox_ShortcutText then
    self.CheckBox_ShortcutText.OnCheckStateChanged:Remove(self, self.OnSelectShortcut)
  end
  if self.CheckBox_GroupChat then
    self.CheckBox_GroupChat.OnCheckStateChanged:Remove(self, self.OnSelectGroupChat)
  end
  if self.CheckBox_PrivateChat then
    self.CheckBox_PrivateChat.OnCheckStateChanged:Remove(self, self.OnSelectPrivateChat)
  end
  if self.CheckBox_Voice then
    self.CheckBox_Voice.OnCheckStateChanged:Remove(self, self.OnSelectVoiceSetting)
  end
  if self.childPanels then
    for i = 1, self.childPanels:Length() do
      if self.childPanels:Get(i).actionOnSendMsg then
        self.childPanels:Get(i).actionOnSendMsg:Remove(self.SendMsg, self)
      end
    end
  end
  self:ClearScrollTask()
  self:ClearSendTask()
  self:ClearUpdateTask()
  self:ClearTeamTask()
  self:ClearRoomTask()
end
function GameChatPageMobile:InitView()
  if self.VerticalBox_Chat and self.SelectRole_Input then
    self.SelectRole_Input:AddChild(self.VerticalBox_Chat)
  end
  if self.ScrollBox_Content and self.SelectRole_OutContent then
    self.SelectRole_OutContent:AddChild(self.ScrollBox_Content)
  end
  if self.WidgetSwitcher_InGame then
    self.WidgetSwitcher_InGame:SetActiveWidgetIndex(1)
  end
  if self.childPanels then
    for i = 1, self.childPanels:Length() do
      self.childPanels:Get(i):InitPanel()
    end
  end
  self:SetChatState(ChatEnum.EChatState.deactive)
end
function GameChatPageMobile:SetInGameState(bInGame)
  LogDebug("GameChatPageMobile", "Set is in game: %s", bInGame)
  if self.isInBattle == bInGame then
    return
  end
  self:SetChatState(ChatEnum.EChatState.deactive)
  self.isInBattle = bInGame
  if self.isInBattle then
    if self.VerticalBox_Chat and self.Border_Input then
      self.Border_Input:AddChild(self.VerticalBox_Chat)
    end
    if self.ScrollBox_Content and self.Overlay_OutContent then
      self.Overlay_OutContent:AddChild(self.ScrollBox_Content)
      self.Overlay_OutContent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.WidgetSwitcher_InGame then
      self.WidgetSwitcher_InGame:SetActiveWidgetIndex(0)
    end
  else
    if self.VerticalBox_Chat and self.SelectRole_Input then
      self.SelectRole_Input:AddChild(self.VerticalBox_Chat)
    end
    if self.ScrollBox_Content and self.SelectRole_OutContent then
      self.SelectRole_OutContent:AddChild(self.ScrollBox_Content)
      self.SelectRole_OutContent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.WidgetSwitcher_InGame then
      self.WidgetSwitcher_InGame:SetActiveWidgetIndex(1)
    end
  end
  self.msgRecord = {}
  self.actionOnPageInitFinished()
  self:SetChatState(ChatEnum.EChatState.deactive)
  self:StartMsgDisappear()
  self:SelectTab(2)
end
function GameChatPageMobile:OnSelectShortcut()
  self:SelectTab(1)
end
function GameChatPageMobile:OnSelectGroupChat()
  self:SelectTab(2)
end
function GameChatPageMobile:OnSelectPrivateChat()
  self:SelectTab(3)
end
function GameChatPageMobile:OnSelectVoiceSetting()
  self:SelectTab(4)
end
function GameChatPageMobile:OnClickOpen()
  self:SetChatState(ChatEnum.EChatState.active)
end
function GameChatPageMobile:SelectTab(tabIndex)
  if self.CheckBox_ShortcutText then
    self.CheckBox_ShortcutText:SetIsChecked(1 == tabIndex)
  end
  if self.CheckBox_GroupChat then
    self.CheckBox_GroupChat:SetIsChecked(2 == tabIndex)
  end
  if self.CheckBox_PrivateChat then
    self.CheckBox_PrivateChat:SetIsChecked(3 == tabIndex)
  end
  if self.CheckBox_Voice then
    self.CheckBox_Voice:SetIsChecked(4 == tabIndex)
  end
  if self.WidgetSwitcher_ChatPanel then
    self.WidgetSwitcher_ChatPanel:SetActiveWidgetIndex(tabIndex - 1)
  end
  self:GetPanelFromChannelName(ChatEnum.ChannelName.private):SetIsShown(3 == tabIndex)
end
function GameChatPageMobile:AddChat(channelType, tabName, chatId)
  if channelType == ChatEnum.EChatChannel.room then
    self.roomId = chatId
  elseif channelType == ChatEnum.EChatChannel.team then
    self.teamId = chatId
  end
  if self:GetPanelFromChannelName() then
    self:GetPanelFromChannelName():AddChat(channelType)
  end
  if self:GetPanelFromChannelName(tabName) then
    self:GetPanelFromChannelName(tabName):AddChat(channelType)
  end
end
function GameChatPageMobile:DeleteSystemChat()
  if self:GetPanelFromChannelName() then
    self:GetPanelFromChannelName():DeleteSystemChat()
  end
  if self:GetPanelFromChannelName(ChatEnum.ChannelName.team) then
    self:GetPanelFromChannelName(ChatEnum.ChannelName.team):DeleteSystemChat()
  end
end
function GameChatPageMobile:SetActiveChannel(tabName)
end
function GameChatPageMobile:SwitchChatState()
  if self.chatState == ChatEnum.EChatState.active then
    self:SetChatState(ChatEnum.EChatState.deactive)
  elseif self.chatState == ChatEnum.EChatState.deactive then
    self:SetChatState(ChatEnum.EChatState.active)
  end
end
function GameChatPageMobile:SetChatState(newChatState)
  if self.chatState == newChatState then
    return
  end
  self.chatState = newChatState
  if self.chatState == ChatEnum.EChatState.active then
    if self.bUseNewSetting then
      GameFacade:SendNotification(NotificationDefines.Chat.UpdateChatPanelSetting)
    end
    self:StopMsgDisappear()
    if self.childPanels then
      for i = 1, self.childPanels:Length() do
        self.childPanels:Get(i):ResetChannel()
      end
    end
    if self.WidgetSwitcher_ChatPanel and 2 == self.WidgetSwitcher_ChatPanel:GetActiveWidgetIndex() then
      self:GetPanelFromChannelName(ChatEnum.ChannelName.private):SetIsShown(true)
    end
    if self.isInBattle then
      if self.Overlay_OutContent then
        self.Overlay_OutContent:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.Border_Input then
        self.Border_Input:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      if self.Button_OpenChat then
        self.Button_OpenChat:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.SelectRole_OutContent then
        self.SelectRole_OutContent:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.SelectRole_Input then
        self.SelectRole_Input:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    if self.Button_Focus then
      self.Button_Focus:SetUserFocus(UE4.UGameplayStatics.GetPlayerController(self, 0))
    end
  else
    self:GetPanelFromChannelName(ChatEnum.ChannelName.private):SetIsShown(false)
    if self.isInBattle then
      if self.Overlay_OutContent then
        self.Overlay_OutContent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.Border_Input then
        self.Border_Input:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      if self.Button_OpenChat then
        self.Button_OpenChat:SetVisibility(UE4.ESlateVisibility.Visible)
      end
      if self.SelectRole_OutContent then
        self.SelectRole_OutContent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.SelectRole_Input then
        self.SelectRole_Input:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self:StartMsgDisappear()
  end
  GameFacade:SendNotification(NotificationDefines.Chat.ChatPanelStatusChange, newChatState == ChatEnum.EChatState.active)
end
function GameChatPageMobile:SendMsgSucceed()
  if self.WidgetSwitcher_ChatPanel then
    self.WidgetSwitcher_ChatPanel:GetActiveWidget():SendMsgSucceed()
  end
  self:SetIsSendMsg(false)
end
function GameChatPageMobile:SendShortcutText(text)
  self:SetChatState(ChatEnum.EChatState.deactive)
  if 0 == self.roomId then
    self:AddSystemMsg(self.invalidTeamChannelText)
  else
    local msgInfo = {}
    msgInfo.channelType = ChatEnum.EChatChannel.team
    msgInfo.chatName = ChatEnum.ChannelName.team
    msgInfo.chatId = self.roomId
    msgInfo.msgSend = text
    self:SendMsg(msgInfo)
  end
end
function GameChatPageMobile:SendMsg(msgInfo)
  if self.isSendingMsg then
    return
  end
  self:SetChatState(ChatEnum.EChatState.deactive)
  if msgInfo then
    local channelType = msgInfo.channelType
    if nil == channelType then
      self:AddSystemMsg(self.invalidTeamChannelText)
      return
    elseif channelType == ChatEnum.EChatChannel.team then
      if 0 == self.teamId then
        self:AddSystemMsg(self.invalidTeamChannelText)
        return
      else
        msgInfo.chatName = ChatEnum.ChannelName.team
        msgInfo.chatId = self.teamId
      end
    elseif channelType == ChatEnum.EChatChannel.room then
      if 0 == self.roomId then
        self:AddSystemMsg(self.invalidTeamChannelText)
        return
      else
        msgInfo.chatName = ChatEnum.ChannelName.room
        msgInfo.chatId = self.roomId
      end
    end
    if not self:CheckCanChat(channelType) then
      return
    end
    local textString = UE4.UKismetTextLibrary.Conv_TextToString(msgInfo.msgSend)
    if self.MaxMsgCharacters and UE4.UKismetStringLibrary.Len(textString) > self.MaxMsgCharacters then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 20305)
      return
    end
    self:SetIsSendMsg(true)
    self.actionOnSendMsg(msgInfo)
  end
end
function GameChatPageMobile:CheckCanChat(channelType)
  if channelType == ChatEnum.EChatChannel.team then
    if self.teamCoolDown > 0 then
      self:AddSystemMsg(ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatCoolDownTip"))
      return false
    end
  elseif channelType == ChatEnum.EChatChannel.team and self.roomCoolDown > 0 then
    self:AddSystemMsg(ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatCoolDownTip"))
    return false
  end
  return true
end
function GameChatPageMobile:SetIsSendMsg(isSending)
  self.isSendingMsg = isSending
  if isSending then
    if self.isInBattle then
      if self.Border_Input then
        self.Border_Input:SetIsEnabled(false)
      end
    elseif self.SelectRole_Input then
      self.SelectRole_Input:SetIsEnabled(false)
    end
  elseif self.isInBattle then
    if self.Border_Input then
      self.Border_Input:SetIsEnabled(true)
    end
  elseif self.SelectRole_Input then
    self.SelectRole_Input:SetIsEnabled(true)
  end
  if isSending then
    self.sendMsgCancelTask = TimerMgr:AddTimeTask(5, 0, 1, function()
      self:SetIsSendMsg(false)
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1)
    end)
  else
    self:ClearSendTask()
  end
end
function GameChatPageMobile:AddSystemMsg(msgContent)
  local msgInfo = {
    chatId = 0,
    chatNick = "",
    chatMsg = msgContent,
    isOwnMsg = true
  }
  self:NotifyRecvMsg(ChatEnum.ChannelName.system, msgInfo)
end
function GameChatPageMobile:NotifyRecvMsg(channelName, msgInfo)
  local msgProp = {}
  msgProp.title = channelName
  msgProp.time = msgInfo.time or os.time()
  local shouldDisapper = true
  if self.chatState == ChatEnum.EChatState.active then
    shouldDisapper = false
  end
  local msg = {
    info = msgInfo,
    prop = msgProp,
    disapper = shouldDisapper
  }
  table.insert(self.msgRecord, msg)
  if #self.msgRecord > #self.msgPanels_Content then
    table.remove(self.msgRecord, 1)
  end
  if msgInfo.isOwnMsg and self.TimeCount and self.TimeCoolDown and self.MsgLimit then
    local curTime = os.time()
    if channelName == ChatEnum.ChannelName.team then
      if self.teamMsgQueue[1] then
        if curTime - self.teamMsgQueue[1] >= self.TimeCount then
          self.teamMsgQueue = {}
        elseif self.teamMsgQueue[self.MsgLimit - 1] then
          self.teamCoolDown = self.TimeCoolDown
          GameFacade:SendNotification(NotificationDefines.Chat.StartChatCD, self.teamCoolDown)
          self.teamCoolDownTask = TimerMgr:AddTimeTask(self.TimeCoolDown, 0, 1, function()
            self.teamCoolDown = 0
            self:ClearTeamTask()
          end)
        end
      end
      table.insert(self.teamMsgQueue, curTime)
    elseif channelName == ChatEnum.ChannelName.room then
      if self.roomMsgQueue[1] then
        if curTime - self.roomMsgQueue[1] >= self.TimeCount then
          self.roomMsgQueue = {}
        elseif self.roomMsgQueue[self.MsgLimit - 1] then
          self.roomCoolDown = self.TimeCoolDown
          GameFacade:SendNotification(NotificationDefines.Chat.StartChatCD, self.roomCoolDown)
          self.roomCoolDownTask = TimerMgr:AddTimeTask(self.TimeCoolDown, 0, 1, function()
            self.roomCoolDown = 0
            self:ClearRoomTask()
          end)
        end
      end
      table.insert(self.roomMsgQueue, curTime)
    end
  end
  self:UpdateViewTask()
  if self:GetPanelFromChannelName(channelName) then
    self:GetPanelFromChannelName(channelName):NotifyRecvMsg(channelName, msgInfo)
  end
end
function GameChatPageMobile:UpdateOutMsgShown()
  if self.ScrollBox_Content and #self.msgPanels_Content > 0 then
    for i = 1, #self.msgPanels_Content do
      if self.msgRecord[i] then
        local msg = self.msgRecord[i]
        self.msgPanels_Content[i]:InitMsg(msg.info, msg.prop, msg.disapper)
        self.msgPanels_Content[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      else
        self.msgPanels_Content[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.ScrollBox_Content:SetVisibility(#self.msgRecord <= 0 and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.HitTestInvisible)
    self.scrollHandle = TimerMgr:RunNextFrame(function()
      self.ScrollBox_Content:ScrollToEnd()
      self:ClearScrollTask()
    end)
  end
end
function GameChatPageMobile:UpdateViewTask()
  if self.updateHandle == nil then
    self.updateHandle = TimerMgr:RunNextFrame(function()
      self:UpdateOutMsgShown()
      self:ClearUpdateTask()
    end)
  end
end
function GameChatPageMobile:ClearScrollTask()
  if self.scrollHandle then
    self.scrollHandle:EndTask()
    self.scrollHandle = nil
  end
end
function GameChatPageMobile:ClearUpdateTask()
  if self.updateHandle then
    self.updateHandle:EndTask()
    self.updateHandle = nil
  end
end
function GameChatPageMobile:ClearTeamTask()
  if self.teamCoolDownTask then
    self.teamCoolDownTask:EndTask()
    self.teamCoolDownTask = nil
  end
end
function GameChatPageMobile:ClearSendTask()
  if self.sendMsgCancelTask then
    self.sendMsgCancelTask:EndTask()
    self.sendMsgCancelTask = nil
  end
end
function GameChatPageMobile:ClearRoomTask()
  if self.roomCoolDownTask then
    self.roomCoolDownTask:EndTask()
    self.roomCoolDownTask = nil
  end
end
function GameChatPageMobile:StopMsgDisappear()
  if self.ScrollBox_Content then
    local msgPanels = self.ScrollBox_Content:GetAllChildren()
    for index = 1, msgPanels:Length() do
      msgPanels:Get(index):ClearTimer()
    end
  end
end
function GameChatPageMobile:StartMsgDisappear()
  if self.ScrollBox_Content then
    local msgPanels = self.ScrollBox_Content:GetAllChildren()
    for index = 1, msgPanels:Length() do
      msgPanels:Get(index):StartTimer()
    end
  end
end
function GameChatPageMobile:DeleteMsg(msgTimestamp)
  for key, value in pairs(self.msgRecord) do
    if msgTimestamp and value.prop.time == msgTimestamp then
      for i = 1, key do
        table.remove(self.msgRecord, 1)
      end
    end
  end
  self:UpdateViewTask()
end
function GameChatPageMobile:OnRemovedFromFocusPath(inFocusEvent)
  if self.VerticalBox_Chat then
    local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if self.VerticalBox_Chat:HasUserFocus(playerController) == false then
      self:SetChatState(ChatEnum.EChatState.deactive)
    end
  end
end
function GameChatPageMobile:GetPanelFromChannelName(channelName)
  local groupChatPanel
  if self.WidgetSwitcher_ChatPanel then
    if nil == channelName then
      groupChatPanel = self.WidgetSwitcher_ChatPanel:GetChildAt(0)
    elseif channelName == ChatEnum.ChannelName.room or channelName == ChatEnum.ChannelName.team or channelName == ChatEnum.ChannelName.system then
      groupChatPanel = self.WidgetSwitcher_ChatPanel:GetChildAt(1)
    else
      groupChatPanel = self.WidgetSwitcher_ChatPanel:GetChildAt(2)
    end
  end
  return groupChatPanel
end
function GameChatPageMobile:UpdateRedDotGameChatPrivate(cnt)
  if self.RedDot_Private then
    self.RedDot_Private:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function GameChatPageMobile:ApplyNewSettings()
  LogDebug("GameChatPageMobile", "Apply new settings")
  self.bUseNewSetting = true
end
function GameChatPageMobile:SetChatPanelLoc(panelLoc)
  if panelLoc then
    LogDebug("GameChatPageMobile", "Chat button loc: pos:%f %f, size:%f %f", panelLoc.position.X, panelLoc.position.Y, panelLoc.desiredSize.X, panelLoc.desiredSize.Y)
    local alignmentType = self:GetPanelAlignmentType(panelLoc)
    if nil == alignmentType or nil == self.Border_Input then
      return
    end
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Border_Input)
    if nil == canvasSlot then
      return
    end
    local originPos = panelLoc.position
    local size = panelLoc.desiredSize
    local scale = self.Border_Input.RenderTransform.Scale
    local panelSize = canvasSlot:GetSize()
    local offset = (scale - 1) * panelSize / 2
    if alignmentType == GlobalEnumDefine.ESecondPanelAlignment.BelowRight then
      canvasSlot:SetAlignment(UE4.FVector2D(0, 0))
      canvasSlot:SetPosition(UE4.FVector2D(originPos.X + offset.X, originPos.Y + size.Y + offset.Y))
    elseif alignmentType == GlobalEnumDefine.ESecondPanelAlignment.AboveRight then
      canvasSlot:SetAlignment(UE4.FVector2D(0, 1))
      canvasSlot:SetPosition(UE4.FVector2D(originPos.X + offset.X, originPos.Y - offset.Y))
    elseif alignmentType == GlobalEnumDefine.ESecondPanelAlignment.BelowLeft then
      canvasSlot:SetAlignment(UE4.FVector2D(1, 0))
      canvasSlot:SetPosition(UE4.FVector2D(originPos.X + size.X - offset.X, originPos.Y + size.Y + offset.Y))
    elseif alignmentType == GlobalEnumDefine.ESecondPanelAlignment.AboveLeft then
      canvasSlot:SetAlignment(UE4.FVector2D(1, 1))
      canvasSlot:SetPosition(UE4.FVector2D(originPos.X + size.X - offset.X, originPos.Y - offset.Y))
    end
  end
  self.bUseNewSetting = false
end
function GameChatPageMobile:GetPanelAlignmentType(anchorPanelLoc)
  if nil == anchorPanelLoc or nil == anchorPanelLoc.position or nil == anchorPanelLoc.desiredSize then
    return nil
  end
  local centerX = anchorPanelLoc.position.X + anchorPanelLoc.desiredSize.X / 2
  local centerY = anchorPanelLoc.position.Y + anchorPanelLoc.desiredSize.Y / 2
  if centerX and centerY then
    if centerX < 960.0 then
      return centerY < 540.0 and GlobalEnumDefine.ESecondPanelAlignment.BelowRight or GlobalEnumDefine.ESecondPanelAlignment.AboveRight
    else
      return centerY < 540.0 and GlobalEnumDefine.ESecondPanelAlignment.BelowLeft or GlobalEnumDefine.ESecondPanelAlignment.AboveLeft
    end
  end
end
return GameChatPageMobile
