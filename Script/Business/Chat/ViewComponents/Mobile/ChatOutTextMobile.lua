local ChatOutTextMobile = class("ChatOutTextMobile", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local ConfigMgr = require("base/config/ConfigMgr")
local StringTablePath = require("base/global/StringTablePath")
local ChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTitle")
local WorldChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.world)
local TeamChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.team)
local RoomChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.room)
local SystemChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.system)
local PrivateChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.private)
local TimeFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Time")
local ChatTargetText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTargetFormat")
local ChatNickText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatNick")
function ChatOutTextMobile:ListNeededMediators()
  return {}
end
function ChatOutTextMobile:InitializeLuaEvent()
  self.actionOnDeleteMsg = LuaEvent.new(ChatOutTextMobilePanel)
end
function ChatOutTextMobile:OnListItemObjectSet(itemObj)
  self.msgIndex = itemObj.msgIndex
  local msgData = itemObj.data
  local msgProp = {}
  msgProp.time = itemObj.time
  msgProp.showTime = itemObj.showTime
  if itemObj.title then
    msgProp.title = itemObj.title
  end
  self:InitMsg(msgData, msgProp, false)
end
function ChatOutTextMobile:InitMsg(msgData, msgProp, needDisappear)
  if msgProp.showTime then
    self.HorizontalBox_Time:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    local tab = os.date("*t", msgProp.time)
    if self.TimeText_Time then
      local formatText = TimeFormatText
      local stringMap = {
        Min = tab.hour < 10 and "0" .. tab.hour or tab.hour,
        Sec = tab.min < 10 and "0" .. tab.min or tab.min
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.TimeText_Time:SetText(text)
    end
  else
    self.HorizontalBox_Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local isPrivateChat = false
  if self.Text_Title then
    if msgProp.title then
      local text = ""
      local textTitleStyle = ""
      if msgProp.title == ChatEnum.ChannelName.world then
        text = WorldChatTitleText
        textTitleStyle = "Chat-World-MB"
      elseif msgProp.title == ChatEnum.ChannelName.team then
        text = TeamChatTitleText
        textTitleStyle = "Chat-Team-MB"
      elseif msgProp.title == ChatEnum.ChannelName.room then
        text = RoomChatTitleText
        textTitleStyle = "Chat-Room-MB"
      elseif msgProp.title == ChatEnum.ChannelName.system then
        text = SystemChatTitleText
        textTitleStyle = "Chat-System-MB"
      else
        isPrivateChat = true
        textTitleStyle = "Chat-Private-MB"
        text = PrivateChatTitleText
      end
      self.Text_Title:SetDefaultTextStyle(ConfigMgr:GetRichTextStyle(textTitleStyle))
      local formatText = ChatTitleText
      local stringMap = {
        [0] = text
      }
      local textShow = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Title:SetText(textShow)
      self.Text_Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Text_Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local textStyle = ConfigMgr:GetRichTextStyle("Chat-Self-MB")
  if msgData.isOwnMsg == false then
    textStyle = ConfigMgr:GetRichTextStyle("Chat-Other-MB")
  end
  local playerNickText = ""
  if self.Text_Name then
    self.Text_Name:SetDefaultTextStyle(textStyle)
    if msgProp.title == ChatEnum.ChannelName.system then
      self.Text_Name:SetText("")
    elseif msgProp.title and msgData.isOwnMsg and isPrivateChat then
      local formatText = ChatTargetText
      local stringMap = {
        [0] = msgProp.title
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Name:SetText(text)
      playerNickText = text
    else
      local formatText = ChatNickText
      local stringMap = {
        [0] = msgData.chatNick
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Name:SetText(text)
      playerNickText = text
    end
  end
  if self.Text_Content then
    self.Text_Content:SetDefaultTextStyle(textStyle)
    local contentShown = playerNickText .. msgData.chatMsg
    contentShown = string.replace(contentShown, "<a id=\"Team\" style=\"Team\"", "<a id=\"Team\" style=\"Team_MB_Little\"")
    contentShown = string.replace(contentShown, "<a id=\"Player\" style=\"Player\"", "<a id=\"Player\" style=\"Player_MB_Little\"")
    self.Text_Content:SetText(contentShown)
    if self.EmoteFormat and string.startswith(msgData.chatMsg, UE4.UKismetStringLibrary.Left(self.EmoteFormat, 15)) then
      local emotionId = string.match(msgData.chatMsg, "[%d]+")
      local emotionCfg = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetChatEmotionCfg(emotionId)
      if emotionCfg then
        contentShown = "[" .. emotionCfg.Name .. "]"
      else
        contentShown = ""
      end
      self.Text_ContentSelf:SetText(contentShown)
    end
  end
  if needDisappear then
    if self.msgTimestamp and self.msgTimestamp == msgProp.time then
      return
    end
    self:StartTimer()
  end
  self.msgTimestamp = msgProp.time
end
function ChatOutTextMobile:StartTimer()
  self:ClearTimer()
  self:StopAllAnimations()
  self:SetRenderOpacity(1)
  self.taskDisappear = TimerMgr:AddTimeTask(self.MsgDisappearTime, 10, 1, function()
    self:MsgDisappear()
  end)
end
function ChatOutTextMobile:ClearTimer()
  if self.taskDisappear then
    self.taskDisappear:EndTask()
    self.taskDisappear = nil
  end
end
function ChatOutTextMobile:MsgDisappear()
  self:PlayWidgetAnimationWithCallBack("FadeOut", {
    self,
    self.DeleteSelf
  })
end
function ChatOutTextMobile:DeleteSelf()
  self:ClearTimer()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.actionOnDeleteMsg(self.msgTimestamp)
  self.msgTimestamp = nil
end
function ChatOutTextMobile:Destruct()
  self:ClearTimer()
  ChatOutTextMobile.super.Destruct(self)
end
return ChatOutTextMobile
