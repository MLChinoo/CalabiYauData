local GroupChatPanelMobile = class("GroupChatPanelMobile", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function GroupChatPanelMobile:ListNeededMediators()
  return {}
end
function GroupChatPanelMobile:InitializeLuaEvent()
  self.actionOnSendMsg = LuaEvent.new(msgInfo)
end
function GroupChatPanelMobile:Construct()
  GroupChatPanelMobile.super.Construct(self)
  if self.List_Content then
    self.List_Content:ClearListItems()
  end
  if self.SendContent then
    self.SendContent.OnTextCommitted:Add(self, self.SendMsg)
  end
  if self.Button_ChangeChannel then
    self.Button_ChangeChannel.OnClicked:Add(self, self.ChangeChannel)
  end
end
function GroupChatPanelMobile:Destruct()
  if self.SendContent then
    self.SendContent.OnTextCommitted:Remove(self, self.SendMsg)
  end
  if self.Button_ChangeChannel then
    self.Button_ChangeChannel.OnClicked:Remove(self, self.ChangeChannel)
  end
  GroupChatPanelMobile.super.Destruct(self)
end
function GroupChatPanelMobile:InitPanel()
  self.hasRoom = false
  self.activeChannelIndex = 0
  self.lastMsgTime = 0
end
function GroupChatPanelMobile:AddChat(channelType)
  self:SetActiveChannel(1)
  if channelType == ChatEnum.EChatChannel.room then
    self.hasRoom = true
  end
end
function GroupChatPanelMobile:DeleteSystemChat()
  self:SetActiveChannel(1)
  self.hasRoom = false
  self.activeChannelIndex = 0
  self.lastMsgTime = 0
end
function GroupChatPanelMobile:ResetChannel()
  if self.activeChannelIndex > 0 then
    self:SetActiveChannel(1)
  end
end
function GroupChatPanelMobile:ChangeChannel()
  if 0 == self.activeChannelIndex or not self.hasRoom then
    return
  end
  if 1 == self.activeChannelIndex then
    self:SetActiveChannel(2)
  elseif 2 == self.activeChannelIndex then
    self:SetActiveChannel(1)
  end
end
function GroupChatPanelMobile:SetActiveChannel(index)
  self.activeChannelIndex = index
  if self.Text_ChannelTitle then
    local tabName = 1 == self.activeChannelIndex and ChatEnum.ChannelName.team or ChatEnum.ChannelName.room
    local nameShow = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, tabName)
    self.Text_ChannelTitle:SetText(nameShow)
  end
end
function GroupChatPanelMobile:SendMsg()
  local text = self.SendContent:GetText()
  if not UE4.UKismetTextLibrary.TextIsEmpty(text) then
    local msgInfo = {}
    if 1 == self.activeChannelIndex then
      msgInfo.channelType = ChatEnum.EChatChannel.team
    elseif 2 == self.activeChannelIndex then
      msgInfo.channelType = ChatEnum.EChatChannel.room
    end
    msgInfo.msgSend = text
    self.actionOnSendMsg(msgInfo)
  end
end
function GroupChatPanelMobile:SendMsgSucceed()
  if self.SendContent then
    self.SendContent:SetText("")
    self.SendContent:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
  end
end
function GroupChatPanelMobile:NotifyRecvMsg(channelName, msgInfo)
  local showTime = true
  local curTime = msgInfo.time or os.time()
  if 0 ~= self.lastMsgTime then
    showTime = curTime - self.lastMsgTime > self.TimeInterval * 60
  end
  self.lastMsgTime = curTime
  if self.List_Content then
    local itemObj = ObjectUtil:CreateLuaUObject(self)
    itemObj.data = msgInfo
    itemObj.title = channelName
    itemObj.time = curTime
    itemObj.showTime = showTime
    local isAtBottom = self:CheckIsAtBottom(self.List_Content)
    self.List_Content:AddItem(itemObj)
    if isAtBottom or msgInfo.isOwnMsg or msgInfo.time and msgInfo.time < os.time() - 1 then
      self.List_Content:ScrollToBottom()
    end
  end
end
function GroupChatPanelMobile:CheckIsAtBottom(listView)
  if listView then
    local number = listView:GetNumItems()
    return listView:BP_IsItemVisible(listView:GetItemAt(number - 1))
  end
  return false
end
return GroupChatPanelMobile
