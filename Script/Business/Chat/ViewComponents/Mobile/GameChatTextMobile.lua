local GameChatTextMobile = class("GameChatTextMobile", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local chatTitleText, timeFormatText, chatNickText
function GameChatTextMobile:ListNeededMediators()
  return {}
end
function GameChatTextMobile:InitializeLuaEvent()
  self.actionOnDeleteMsg = LuaEvent.new(msgTimestamp)
end
function GameChatTextMobile:Construct()
  GameChatTextMobile.super.Construct(self)
  if not chatTitleText then
    chatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTitle")
  end
  if not timeFormatText then
    timeFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Time")
  end
  if not chatNickText then
    chatNickText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatNick")
  end
end
function GameChatTextMobile:Destruct()
  self:ClearTimer()
  GameChatTextMobile.super.Destruct(self)
end
function GameChatTextMobile:OnListItemObjectSet(itemObj)
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
function GameChatTextMobile:InitMsg(msgData, msgProp, needDisappear)
  if msgProp.showTime then
    self.HorizontalBox_Time:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    local tab = os.date("*t", msgProp.time)
    if self.TimeText_Time then
      local formatText = timeFormatText
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
  if self.Text_Title then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.private)
    if not msgData.isPrivateChat then
      text = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, msgProp.title)
    end
    local formatText = chatTitleText
    local stringMap = {
      [0] = text
    }
    local textShow = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    self.Text_Title:SetText(textShow)
  end
  if msgProp.title == ChatEnum.ChannelName.system then
    local textTitleStyle = ConfigMgr:GetRichTextStyle("Chat-System-MB")
    if self.Text_Title then
      self.Text_Title:SetDefaultTextStyle(textTitleStyle)
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTitle")
      local stringMap = {
        [0] = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.system)
      }
      local textShow = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Title:SetText(textShow)
    end
  end
  local nameTextStyle = "GameChat-Self-MB"
  local nameText = ""
  if msgProp.title ~= ChatEnum.ChannelName.system then
    if not msgData.isOwnMsg then
      nameTextStyle = "GameChat-Other-MB"
    end
    local formatText = chatNickText
    local stringMap = {
      [0] = msgData.chatNick
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    nameText = "<" .. nameTextStyle .. ">" .. text .. "</>"
  end
  if self.Text_Content then
    local textStyle = ConfigMgr:GetRichTextStyle("Chat-System-MB")
    if msgProp.title ~= ChatEnum.ChannelName.system then
      textStyle = ConfigMgr:GetRichTextStyle("Chat-Other-MB")
    end
    self.Text_Content:SetDefaultTextStyle(textStyle)
    self.Text_Content:SetText(nameText .. msgData.chatMsg)
  end
  if needDisappear then
    if self.msgTimestamp and self.msgTimestamp == msgProp.time then
      return
    end
    self:StartTimer()
  end
  self.msgTimestamp = msgProp.time
end
function GameChatTextMobile:StartTimer()
  self:ClearTimer()
  self:StopAllAnimations()
  self:SetRenderOpacity(1)
  self.taskDisappear = TimerMgr:AddTimeTask(self.MsgDisappearTime, 10, 1, function()
    self:MsgDisappear()
  end)
end
function GameChatTextMobile:ClearTimer()
  if self.taskDisappear then
    self.taskDisappear:EndTask()
    self.taskDisappear = nil
  end
end
function GameChatTextMobile:MsgDisappear()
  self:PlayWidgetAnimationWithCallBack("FadeOut", {
    self,
    self.DeleteSelf
  })
end
function GameChatTextMobile:DeleteSelf()
  self:ClearTimer()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.actionOnDeleteMsg(self.msgTimestamp)
  self.msgTimestamp = nil
end
return GameChatTextMobile
