local ChatText = class("ChatText", PureMVC.ViewComponentPanel)
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
local ChatNickHyperText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatNickHyper")
local ChatEmotionFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, "ChatEmotionFormat")
function ChatText:ListNeededMediators()
  return {}
end
function ChatText:InitializeLuaEvent()
  self.actionOnDeleteMsg = LuaEvent.new(msgTimestamp)
  self.actionOnFriendMenuOpen = LuaEvent.new(isOpen)
end
function ChatText:Construct()
  ChatText.super.Construct(self)
  if self.Button_ClickName then
    self.Button_ClickName.OnClicked:Add(self, self.OnClickName)
  end
  if self.MenuAnchor_Friend then
    self.MenuAnchor_Friend.OnGetMenuContentEvent:Bind(self, self.InitFriendMenu)
    self.MenuAnchor_Friend.OnMenuOpenChanged:Add(self, self.OnMenuOpenChanged)
  end
end
function ChatText:Destruct()
  if self.Button_ClickName then
    self.Button_ClickName.OnClicked:Remove(self, self.OnClickName)
  end
  if self.MenuAnchor_Friend then
    self.MenuAnchor_Friend.OnGetMenuContentEvent:Unbind()
    self.MenuAnchor_Friend.OnMenuOpenChanged:Remove(self, self.OnMenuOpenChanged)
  end
  self:ClearTimer()
  ChatText.super.Destruct(self)
end
function ChatText:OnListItemObjectSet(itemObj)
  self.msgIndex = itemObj.msgIndex
  if itemObj.data.isPrivateChat then
    self.playerId = itemObj.data.chatId
  else
    self.playerId = itemObj.data.playerId
  end
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
  self:InitMsg(msgData, msgProp, itemObj.shouldDisapper)
end
function ChatText:InitMsg(msgData, msgProp, needDisappear)
  self.nick = msgData.chatNick
  self.content = msgData.chatMsg
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
  local titleStyle = ""
  local nameStyle = ""
  local contentStyle = "ChatMsg"
  if msgProp.title then
    if msgProp.title == ChatEnum.ChannelName.world then
      titleStyle = "Chat-World"
    elseif msgProp.title == ChatEnum.ChannelName.team then
      titleStyle = "Chat-Team"
    elseif msgProp.title == ChatEnum.ChannelName.room then
      titleStyle = "Chat-Room"
    elseif msgProp.title == ChatEnum.ChannelName.system then
      titleStyle = "Chat-System"
    else
      isPrivateChat = true
      titleStyle = "Chat-Private"
    end
    if msgProp.title ~= ChatEnum.ChannelName.system and msgData.isOwnMsg then
      titleStyle = "Chat-Self"
    end
  end
  if msgData.isOwnMsg then
    nameStyle = "Chat-Self"
  else
    nameStyle = "Chat-Other"
  end
  if msgProp.title == ChatEnum.ChannelName.system then
    contentStyle = "ChatMsg-System"
  end
  if self:IsInBattle() and not isPrivateChat and msgProp.title ~= ChatEnum.ChannelName.system and not msgData.isOwnMsg then
    if msgData.isTeammate then
      titleStyle = "GameChat-Teammate"
      nameStyle = "GameChat-Teammate"
    else
      titleStyle = "GameChat-Enemy"
      nameStyle = "GameChat-Enemy"
    end
  end
  local isPrivateChat = false
  local titleStyle = ""
  local nameStyle = ""
  local contentStyle = "ChatMsg"
  if msgProp.title then
    if msgProp.title == ChatEnum.ChannelName.world then
      titleStyle = "Chat-World"
    elseif msgProp.title == ChatEnum.ChannelName.team then
      titleStyle = "Chat-Team"
    elseif msgProp.title == ChatEnum.ChannelName.room then
      titleStyle = "Chat-Room"
    elseif msgProp.title == ChatEnum.ChannelName.system then
      titleStyle = "Chat-System"
    else
      isPrivateChat = true
      titleStyle = "Chat-Private"
    end
    if msgProp.title ~= ChatEnum.ChannelName.system and msgData.isOwnMsg then
      titleStyle = "Chat-Self"
    end
  end
  if msgData.isOwnMsg then
    nameStyle = "Chat-Self"
  else
    nameStyle = "Chat-Other"
  end
  if msgProp.title == ChatEnum.ChannelName.system then
    contentStyle = "ChatMsg-System"
  end
  if self:IsInBattle() and not isPrivateChat and msgProp.title ~= ChatEnum.ChannelName.system and not msgData.isOwnMsg then
    if msgData.isTeammate then
      titleStyle = "GameChat-Teammate"
      nameStyle = "GameChat-Teammate"
    else
      titleStyle = "GameChat-Enemy"
      nameStyle = "GameChat-Enemy"
    end
  end
  if self.Text_Title then
    if msgProp.title then
      if "" ~= titleStyle then
        self.Text_Title:SetDefaultTextStyle(ConfigMgr:GetRichTextStyle(titleStyle))
      end
      local text = ""
      if msgProp.title == ChatEnum.ChannelName.world then
        text = WorldChatTitleText
      elseif msgProp.title == ChatEnum.ChannelName.team then
        text = TeamChatTitleText
      elseif msgProp.title == ChatEnum.ChannelName.room then
        text = RoomChatTitleText
      elseif msgProp.title == ChatEnum.ChannelName.system then
        text = SystemChatTitleText
      else
        text = PrivateChatTitleText
      end
      local formatText = ChatTitleText
      local stringMap = {
        [0] = text
      }
      local textShow = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Title:SetText(textShow)
      self.Text_Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self:IsInBattle() and msgProp.title == ChatEnum.ChannelName.team then
        self.Text_Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.Text_Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local playerNickText = ""
  if self.Text_Name then
    if msgProp.title == ChatEnum.ChannelName.system then
    elseif msgProp.title and msgData.isOwnMsg and isPrivateChat then
      local formatText = ChatTargetText
      local stringMap = {
        [0] = msgProp.title
      }
      playerNickText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    else
      local formatText = ""
      if msgProp.useHyperlink and msgData.isOwnMsg == false then
        formatText = ChatNickHyperText
      else
        formatText = ChatNickText
      end
      local stringMap = {
        [0] = msgData.chatNick
      }
      playerNickText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    end
    self.Text_Name:SetText(playerNickText)
    if self:IsInBattle() and msgProp.title ~= ChatEnum.ChannelName.system or msgData.isOwnMsg then
      playerNickText = string.format("<%s>%s</>", nameStyle, playerNickText)
    end
  end
  if self.EmoteFormat and string.startswith(msgData.chatMsg, UE4.UKismetStringLibrary.Left(self.EmoteFormat, 15)) then
    local emotionId = string.match(msgData.chatMsg, "[%d]+")
    local emotionCfg = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetChatEmotionCfg(emotionId)
    if emotionCfg and self.Img_Content then
      self:SetImageByTexture2D(self.Img_Content, emotionCfg.icon)
    end
    self:ShowEmote(true)
  else
    self:ShowNormalText(msgData.chatMsg, playerNickText, contentStyle)
    if self.Overlay_Name and msgProp.title == ChatEnum.ChannelName.system then
      self.Overlay_Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
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
function ChatText:ShowNormalText(textContent, nick, textStyle)
  if self.Text_Content then
    if "" ~= textStyle then
      self.Text_Content:SetDefaultTextStyle(ConfigMgr:GetRichTextStyle(textStyle))
    end
    self.Text_Content:SetText(nick .. textContent)
  end
  self:ShowEmote(false)
end
function ChatText:ShowEmote(bShow)
  if self.Text_Content then
    self.Text_Content:SetVisibility(bShow and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Text_Name then
    self.Text_Name:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
  end
  if self.Overlay_Name then
    self.Overlay_Name:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Img_Content then
    self.Img_Content:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ChatText:IsInBattle()
  local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
  if GameState then
    return GameState:GetModeType() ~= UE4.EPMGameModeType.FrontEnd
  end
  return false
end
function ChatText:StartTimer()
  self:ClearTimer()
  self:StopAllAnimations()
  self:SetRenderOpacity(1)
  self.taskDisappear = TimerMgr:AddTimeTask(self.MsgDisappearTime, 10, 1, function()
    self:MsgDisappear()
  end)
end
function ChatText:ClearTimer()
  if self.taskDisappear then
    self.taskDisappear:EndTask()
    self.taskDisappear = nil
  end
end
function ChatText:MsgDisappear()
  self:PlayWidgetAnimationWithCallBack("FadeOut", {
    self,
    self.DeleteSelf
  })
end
function ChatText:DeleteSelf()
  self:ClearTimer()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.actionOnDeleteMsg(self.msgTimestamp)
  self.msgTimestamp = nil
end
function ChatText:OnClickName()
  if self.MenuAnchor_Friend then
    self.MenuAnchor_Friend:Open(true)
  end
end
function ChatText:InitFriendMenu()
  local friendMenuIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Friend.MenuClass)
  if friendMenuIns then
    local shortcutMenuData = {}
    shortcutMenuData.bPlayerInfo = true
    shortcutMenuData.bFriend = true
    shortcutMenuData.bShield = true
    shortcutMenuData.bReport = true
    shortcutMenuData.playerId = self.playerId
    shortcutMenuData.playerNick = self.nick
    shortcutMenuData.reportContent = self.content
    friendMenuIns.actionOnExecute:Add(function()
      self.MenuAnchor_Friend:Close()
    end, self)
    friendMenuIns:Init(shortcutMenuData)
    return friendMenuIns
  end
  return nil
end
function ChatText:OnMenuOpenChanged(isOpen)
  self.actionOnFriendMenuOpen(isOpen)
end
return ChatText
