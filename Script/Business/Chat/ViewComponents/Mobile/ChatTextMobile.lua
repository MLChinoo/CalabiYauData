local ChatTextMobile = class("ChatTextMobile", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
local ConfigMgr = require("base/config/ConfigMgr")
local StringTablePath = require("base/global/StringTablePath")
local ChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatTitle")
local SystemChatTitleText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, ChatEnum.ChannelName.system)
local TimeFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Time")
function ChatTextMobile:ListNeededMediators()
  return {}
end
function ChatTextMobile:InitializeLuaEvent()
  self.actionOnDeleteMsg = LuaEvent.new(msgTimestamp)
end
function ChatTextMobile:Construct()
  ChatTextMobile.super.Construct(self)
end
function ChatTextMobile:OnListItemObjectSet(itemObj)
  self.msgIndex = itemObj.msgIndex
  local msgData = itemObj.data
  local msgProp = {}
  msgProp.time = itemObj.time
  msgProp.showTime = itemObj.showTime
  if itemObj.useHyperlink then
    msgProp.useHyperlink = true
    if self.Button_ClickName then
      self.Button_ClickName:SetVisibility(itemObj.data.isOwnMsg and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
    end
  elseif self.Button_ClickName then
    self.Button_ClickName:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if itemObj.title then
    msgProp.title = itemObj.title
  end
  self:InitMsg(msgData, msgProp, false)
end
function ChatTextMobile:InitMsg(msgData, msgProp, needDisappear)
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
  if msgProp.title == ChatEnum.ChannelName.system then
    local textTitleStyle = ConfigMgr:GetRichTextStyle("ChatMsg-System-MB")
    if self.Text_Title then
      self.Text_Title:SetDefaultTextStyle(textTitleStyle)
      local formatText = ChatTitleText
      local stringMap = {
        [0] = SystemChatTitleText
      }
      local textShow = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Title:SetText(textShow)
    end
    if self.Text_ContentSystem then
      self.Text_ContentSystem:SetDefaultTextStyle(textTitleStyle)
      self.Text_ContentSystem:SetText(msgData.chatMsg)
    end
    if self.WidgetSwitcher_MsgOwner then
      self.WidgetSwitcher_MsgOwner:SetActiveWidgetIndex(2)
    end
    return
  end
  if msgData.isOwnMsg and self.WidgetSwitcher_MsgOwner then
    if self.Text_NameSelf then
      self.Text_NameSelf:SetText(msgData.chatNick)
    end
    if self.Text_ContentSelf then
      self.Text_ContentSelf:SetDefaultTextStyle(ConfigMgr:GetRichTextStyle("ChatMsg-Self-MB"))
      local contentShown = string.replace(msgData.chatMsg, "<a id=\"Team\" style=\"Team\"", "<a id=\"Team\" style=\"Team_MB\"")
      contentShown = string.replace(contentShown, "<a id=\"Player\" style=\"Player\"", "<a id=\"Player\" style=\"Player_MB\"")
      self.Text_ContentSelf:SetText(contentShown)
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
    GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Img_PlayerIconSelf, msgData.chatIcon, self.Image_BorderIconSelf, msgData.chatIcon_Border)
    self.WidgetSwitcher_MsgOwner:SetActiveWidgetIndex(1)
  else
    if self.Text_Name then
      self.Text_Name:SetText(msgData.chatNick)
    end
    if self.Text_Content then
      self.Text_Content:SetDefaultTextStyle(ConfigMgr:GetRichTextStyle("ChatMsg-Other-MB"))
      local contentShown = string.replace(msgData.chatMsg, "<a id=\"Team\" style=\"Team\"", "<a id=\"Team\" style=\"Team_MB\"")
      contentShown = string.replace(contentShown, "<a id=\"Player\" style=\"Player\"", "<a id=\"Player\" style=\"Player_MB\"")
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
    GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Img_PlayerIcon, msgData.chatIcon, self.Image_BorderIcon, msgData.chatIcon_Border)
    self.WidgetSwitcher_MsgOwner:SetActiveWidgetIndex(0)
  end
  if needDisappear then
    if self.msgTimestamp and self.msgTimestamp == msgProp.time then
      return
    end
    self:StartTimer()
  end
  self.msgTimestamp = msgProp.time
end
function ChatTextMobile:StartTimer()
  self:ClearTimer()
  self:StopAllAnimations()
  self:SetRenderOpacity(1)
  self.taskDisappear = TimerMgr:AddTimeTask(self.MsgDisappearTime, 10, 1, function()
    self:MsgDisappear()
  end)
end
function ChatTextMobile:ClearTimer()
  if self.taskDisappear then
    self.taskDisappear:EndTask()
    self.taskDisappear = nil
  end
end
function ChatTextMobile:MsgDisappear()
  self:PlayWidgetAnimationWithCallBack("FadeOut", {
    self,
    self.DeleteSelf
  })
end
function ChatTextMobile:DeleteSelf()
  self:ClearTimer()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.actionOnDeleteMsg(self.msgTimestamp)
  self.msgTimestamp = nil
end
function ChatTextMobile:Destruct()
  self:ClearTimer()
  ChatTextMobile.super.Destruct(self)
end
return ChatTextMobile
