local ShortcutTextPanelMobile = class("ShortcutTextPanelMobile", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function ShortcutTextPanelMobile:ListNeededMediators()
  return {}
end
function ShortcutTextPanelMobile:InitializeLuaEvent()
  self.actionOnSendMsg = LuaEvent.new(text)
end
function ShortcutTextPanelMobile:Construct()
  ShortcutTextPanelMobile.super.Construct(self)
  if self.ListView_TextContent then
    self.ListView_TextContent.BP_OnItemClicked:Add(self, self.ChooseText)
  end
  if self.SendContent then
    self.SendContent.OnTextCommitted:Add(self, self.SendMsg)
  end
  if self.Button_ChangeChannel then
    self.Button_ChangeChannel.OnClicked:Add(self, self.ChangeChannel)
  end
end
function ShortcutTextPanelMobile:Destruct()
  if self.ListView_TextContent then
    self.ListView_TextContent.BP_OnItemClicked:Remove(self, self.ChooseText)
  end
  if self.SendContent then
    self.SendContent.OnTextCommitted:Remove(self, self.SendMsg)
  end
  if self.Button_ChangeChannel then
    self.Button_ChangeChannel.OnClicked:Remove(self, self.ChangeChannel)
  end
  ShortcutTextPanelMobile.super.Destruct(self)
end
function ShortcutTextPanelMobile:InitPanel()
  self.hasRoom = false
  self.activeChannelIndex = 0
  if self.ListView_TextContent then
    self.ListView_TextContent:ClearListItems()
    local shortcutTextTable = ConfigMgr:GetShortcutTextTableRows():ToLuaTable()
    for key, value in pairs(shortcutTextTable) do
      local itemObj = ObjectUtil:CreateLuaUObject(self)
      itemObj.text = value.ShortcutText
      self.ListView_TextContent:AddItem(itemObj)
    end
  end
end
function ShortcutTextPanelMobile:AddChat(channelType)
  self:SetActiveChannel(1)
  if channelType == ChatEnum.EChatChannel.room then
    self.hasRoom = true
  end
end
function ShortcutTextPanelMobile:DeleteSystemChat()
  self:SetActiveChannel(1)
  self.hasRoom = false
  self.activeChannelIndex = 0
end
function ShortcutTextPanelMobile:ResetChannel()
  if self.activeChannelIndex > 0 then
    self:SetActiveChannel(1)
  end
end
function ShortcutTextPanelMobile:ChangeChannel()
  if 0 == self.activeChannelIndex or not self.hasRoom then
    return
  end
  if 1 == self.activeChannelIndex then
    self:SetActiveChannel(2)
  elseif 2 == self.activeChannelIndex then
    self:SetActiveChannel(1)
  end
end
function ShortcutTextPanelMobile:SetActiveChannel(index)
  self.activeChannelIndex = index
  if self.Text_ChannelTitle then
    local tabName = 1 == self.activeChannelIndex and ChatEnum.ChannelName.team or ChatEnum.ChannelName.room
    local nameShow = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, tabName)
    self.Text_ChannelTitle:SetText(nameShow)
  end
end
function ShortcutTextPanelMobile:ChooseText(item)
  self:SendMsg(item.text)
end
function ShortcutTextPanelMobile:SendMsg(msgContent)
  local text = self.SendContent:GetText()
  if msgContent then
    text = msgContent
  end
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
function ShortcutTextPanelMobile:SendMsgSucceed()
  if self.SendContent then
    self.SendContent:SetText("")
  end
end
return ShortcutTextPanelMobile
