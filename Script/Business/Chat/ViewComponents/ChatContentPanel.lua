local ChatContentPanel = class("ChatContentPanel", PureMVC.ViewComponentPanel)
local ChatContentPanelMediator = require("Business/Chat/Mediators/ChatContentPanelMediator")
function ChatContentPanel:ListNeededMediators()
  return {ChatContentPanelMediator}
end
function ChatContentPanel:Destruct()
  if self.toBottomTask then
    self.toBottomTask:EndTask()
    self.toBottomTask = nil
  end
end
function ChatContentPanel:InitView(chatSettings, groupMembers, playerId)
  self.timeInterval = chatSettings.timeInterval
  self.maxMsgReserved = chatSettings.msgReserved
  if self.Button_ToBottom then
    self.Button_ToBottom:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Button_ToBottom.OnClicked:Add(self, function()
      self:ScrollToBottom()
    end)
  end
  self:ClearContent()
  self.isAtBottom = true
  self.isScrollForbidden = false
  if self.ContentList then
    self.ContentList.BP_OnEntryGenerated:Add(self, self.OnEntryGenerated)
    self.ContentList.BP_OnEntryReleased:Add(self, self.OnEntryReleased)
  end
  self:ShowUnreadNum()
end
function ChatContentPanel:ChangeSize()
  if self.isAtBottom then
    self:ScrollToBottom()
  end
end
function ChatContentPanel:ClearContent()
  if self.ContentList then
    self.ContentList:ClearListItems()
  end
  if self.Button_ToBottom then
    self.Button_ToBottom:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.lastMsgTime = 0
  self.earlistMsgIndex = 0
  self.msgReadIndex = 0
  self.msgNumInList = 0
end
function ChatContentPanel:DeleteMsgOfPlayer(playerId)
  if nil == playerId or playerId <= 0 then
    return
  end
  if self.ContentList then
    local items = self.ContentList:GetListItems()
    for i = items:Length(), 1, -1 do
      local itemObj = items:Get(i)
      if itemObj.data and itemObj.data.playerId and itemObj.data.playerId == playerId then
        self.ContentList:RemoveItem(itemObj)
      end
    end
  end
end
function ChatContentPanel:AddMsg(msgInfo, channelTitle, useHyperlink)
  if self.ContentList then
    local itemObj = ObjectUtil:CreateLuaUObject(self)
    itemObj.data = msgInfo
    itemObj.title = channelTitle
    itemObj.useHyperlink = useHyperlink
    itemObj.msgIndex = self.msgNumInList + 1
    local showTime = true
    local currentTime = msgInfo.msgTime or os.time()
    if 0 ~= self.lastMsgTime then
      showTime = currentTime - self.lastMsgTime > self.timeInterval * 60
    end
    self.lastMsgTime = currentTime
    itemObj.time = currentTime
    itemObj.showTime = showTime
    self.ContentList:AddItem(itemObj)
    self.msgNumInList = self.msgNumInList + 1
    if msgInfo.isOwnMsg or self.isAtBottom and self.isScrollForbidden == false then
      self:ScrollToBottom()
    else
      self:ShowUnreadNum()
    end
  end
end
function ChatContentPanel:ScrollToBottom()
  if self.toBottomTask == nil then
    self.toBottomTask = TimerMgr:RunNextFrame(function()
      self:ExecuteScrollBottom()
    end)
  end
end
function ChatContentPanel:ExecuteScrollBottom()
  if self.ContentList then
    self.ContentList:ScrollToBottom()
  end
  if self.toBottomTask then
    self.toBottomTask = nil
  end
end
function ChatContentPanel:ShowUnreadNum()
  local unreadNum = self.msgNumInList - self.msgReadIndex
  if self.TextBlock_Unread then
    local text = ""
    if unreadNum <= 0 then
      text = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "GoToChatBottom")
    else
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "NewChatMsgNum")
      local stringMap = {
        [0] = unreadNum
      }
      text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      if self.Button_ToBottom then
        self.Button_ToBottom:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
    self.TextBlock_Unread:SetText(text)
  end
end
function ChatContentPanel:OnItemIntoView(itemIndex)
  if itemIndex > self.msgReadIndex then
    self.msgReadIndex = itemIndex
    while self.earlistMsgIndex < self.msgReadIndex - self.maxMsgReserved do
      local item = self.ContentList:GetItemAt(0)
      self.ContentList:RemoveItem(item)
      self.earlistMsgIndex = self.earlistMsgIndex + 1
    end
    self:ShowUnreadNum()
  end
end
function ChatContentPanel:OnEntryGenerated(widget)
  if widget.actionOnFriendMenuOpen then
    widget.actionOnFriendMenuOpen:Add(self.AllowScroll, self)
  end
  self:OnItemIntoView(widget.msgIndex)
  if widget.msgIndex == self.msgNumInList then
    self:SetIsAtBottom(true)
  end
end
function ChatContentPanel:OnEntryReleased(widget)
  if widget.actionOnFriendMenuOpen then
    widget.actionOnFriendMenuOpen:Remove(self.AllowScroll, self)
  end
  if widget.msgIndex == self.msgNumInList then
    self:SetIsAtBottom(false)
  end
end
function ChatContentPanel:SetIsAtBottom(isBottom)
  if self.Button_ToBottom then
    if isBottom then
      self.Button_ToBottom:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Button_ToBottom:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
  self.isAtBottom = isBottom
end
function ChatContentPanel:AllowScroll(isMenuOpen)
  if self.ContentList then
    self.ContentList:SetVisibility(isMenuOpen and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Visible)
  end
  self.isScrollForbidden = isMenuOpen
end
function ChatContentPanel:AddMember(chatPlayer)
end
function ChatContentPanel:DeleteMember(exitPlayerId)
end
return ChatContentPanel
