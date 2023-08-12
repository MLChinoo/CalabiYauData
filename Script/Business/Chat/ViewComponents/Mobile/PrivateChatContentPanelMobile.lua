local PrivateChatContentPanelMobile = class("PrivateChatContentPanelMobile", PureMVC.ViewComponentPanel)
function PrivateChatContentPanelMobile:ListNeededMediators()
  return {}
end
function PrivateChatContentPanelMobile:Construct()
  PrivateChatContentPanelMobile.super.Construct(self)
  self:ClearContent()
  if self.ContentList then
    self.ContentList.BP_OnEntryGenerated:Add(self, self.OnEntryGenerated)
    self.ContentList.BP_OnEntryReleased:Add(self, self.OnEntryReleased)
  end
end
function PrivateChatContentPanelMobile:Destruct()
  if self.ContentList then
    self.ContentList.BP_OnEntryGenerated:Remove(self, self.OnEntryGenerated)
    self.ContentList.BP_OnEntryReleased:Remove(self, self.OnEntryReleased)
  end
  PrivateChatContentPanelMobile.super.Destruct(self)
end
function PrivateChatContentPanelMobile:ClearContent()
  if self.ContentList then
    self.ContentList:ClearListItems()
  end
  if self.Button_ToBottom then
    self.Button_ToBottom:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.isAtBottom = true
  self.lastMsgTime = 0
  self.msgNumInList = 0
end
function PrivateChatContentPanelMobile:AddMsg(msgInfo)
  if self.ContentList then
    local itemObj = ObjectUtil:CreateLuaUObject(self)
    itemObj.data = msgInfo
    itemObj.msgIndex = self.msgNumInList + 1
    local showTime = true
    local currentTime = msgInfo.msgTime or os.time()
    if 0 ~= self.lastMsgTime then
      showTime = currentTime - self.lastMsgTime > self.TimeInterval * 60
    end
    self.lastMsgTime = currentTime
    if showTime then
      itemObj.time = currentTime
    end
    self.ContentList:AddItem(itemObj)
    self.msgNumInList = self.msgNumInList + 1
    if msgInfo.isOwnMsg or self.isAtBottom then
      self:ScrollToBottom()
    else
    end
  end
end
function PrivateChatContentPanelMobile:ScrollToBottom()
  if self.ContentList then
    self.ContentList:ScrollToBottom()
  end
end
function PrivateChatContentPanelMobile:OnEntryGenerated(widget)
  if widget.msgIndex == self.msgNumInList then
    self:SetIsAtBottom(true)
  end
end
function PrivateChatContentPanelMobile:OnEntryReleased(widget)
  if widget.msgIndex == self.msgNumInList then
    self:SetIsAtBottom(false)
  end
end
function PrivateChatContentPanelMobile:SetIsAtBottom(isBottom)
  self.isAtBottom = isBottom
end
return PrivateChatContentPanelMobile
