local PrivateChatPanelMobile = class("PrivateChatPanelMobile", PureMVC.ViewComponentPanel)
local ChatEnum = require("Business/Chat/Proxies/ChatEnumDefine")
function PrivateChatPanelMobile:ListNeededMediators()
  return {}
end
function PrivateChatPanelMobile:InitializeLuaEvent()
  self.actionOnSendMsg = LuaEvent.new(msgInfo)
  self.actionOnUpdatePlayer = LuaEvent.new()
end
function PrivateChatPanelMobile:Construct()
  PrivateChatPanelMobile.super.Construct(self)
  if self.ListView_PlayerList then
    self.ListView_PlayerList.BP_OnItemClicked:Add(self, self.ChoosePlayer)
  end
  if self.SendContent then
    self.SendContent.OnTextCommitted:Add(self, self.SendMsg)
  end
  if self.WidgetSwitcher_HasPrivateChat then
    self.WidgetSwitcher_HasPrivateChat:SetActiveWidgetIndex(0)
  end
  if self.WidgetSwitcher_ChatContent then
    self.WidgetSwitcher_ChatContent:SetActiveWidgetIndex(0)
  end
end
function PrivateChatPanelMobile:Destruct()
  if self.ListView_PlayerList then
    self.ListView_PlayerList.BP_OnItemClicked:Remove(self, self.ChoosePlayer)
  end
  if self.SendContent then
    self.SendContent.OnTextCommitted:Remove(self, self.SendMsg)
  end
  PrivateChatPanelMobile.super.Destruct(self)
end
function PrivateChatPanelMobile:InitPanel()
  self.chatMap = {}
  self.chatId = 0
  self.privateChatCnt = 0
  self.isShown = false
  if self.ChatMsgPanelClass then
    self.msgPanelClass = ObjectUtil:LoadClass(self.ChatMsgPanelClass)
    if self.msgPanelClass == nil then
      LogDebug("GroupChatPanelMobile", "Chat msg panel class load failed")
    end
  end
  if self.ListView_PlayerList then
    self.ListView_PlayerList:ClearListItems()
  end
end
function PrivateChatPanelMobile:ResetChannel()
end
function PrivateChatPanelMobile:AddChat(chatId, chatNick, chatIcon)
  if self.chatMap[chatId] then
    self.chatMap[chatId].chatName = chatNick
  else
    self.chatMap[chatId] = {}
    self.chatMap[chatId].chatName = chatNick
    if self.msgPanelClass and self.WidgetSwitcher_ChatContent then
      local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.msgPanelClass)
      if panelIns then
        self.WidgetSwitcher_ChatContent:AddChild(panelIns)
        self.chatMap[chatId].msgPanel = panelIns
      else
        LogDebug("PrivateChatPanelMobile", "Msg panel create failed")
      end
    end
  end
  if self.ListView_PlayerList then
    local playerInfo = {
      playerId = chatId,
      nick = chatNick,
      icon = chatIcon
    }
    local itemObj = ObjectUtil:CreateLuaUObject(self)
    itemObj.data = playerInfo
    itemObj.newMsgCnt = 0
    itemObj.isActive = false
    itemObj.parent = self
    self.ListView_PlayerList:AddItem(itemObj)
    self.chatMap[chatId].playerInfoItem = itemObj
    self.privateChatCnt = self.privateChatCnt + 1
  end
  if self.WidgetSwitcher_HasPrivateChat then
    self.WidgetSwitcher_HasPrivateChat:SetActiveWidgetIndex(1)
  end
  if self.MaxPrivateChatNum and self.privateChatCnt > self.MaxPrivateChatNum then
    self:DeleteChat()
  end
  self.actionOnUpdatePlayer()
end
function PrivateChatPanelMobile:DeleteChat()
  local playerDelete = self.ListView_PlayerList:GetItemAt(self.MaxPrivateChatNum)
  if playerDelete.data.playerId == self.chatId then
    playerDelete = self.ListView_PlayerList:GetItemAt(self.MaxPrivateChatNum - 1)
  end
  self.ListView_PlayerList:RemoveItem(playerDelete)
end
function PrivateChatPanelMobile:ChoosePlayer(item)
  if item then
    LogDebug("PrivateChatPanelMobile", "Choose player: " .. item.data.nick)
    item.isActive = true
    if item.newMsgCnt > 0 then
      item.newMsgCnt = 0
      self:ChangeNewMsgPlayerCnt(-1)
    end
    self.chatId = item.data.playerId
    if self.WidgetSwitcher_ChatContent and self.chatMap[self.chatId] then
      self.WidgetSwitcher_ChatContent:SetActiveWidget(self.chatMap[self.chatId].msgPanel)
    end
  end
end
function PrivateChatPanelMobile:NotifyRecvMsg(channelName, msgInfo)
  if nil == msgInfo then
    return
  end
  local playerId = msgInfo.chatId
  if self.ListView_PlayerList then
    if nil == self.chatMap[playerId] then
      if msgInfo.isOwnMsg and not msgInfo.msgTime then
        for key, value in pairs(self.chatMap) do
          if value.chatName == channelName then
            playerId = key
            break
          end
        end
      else
        self:AddChat(msgInfo.chatId, msgInfo.chatNick, msgInfo.chatIcon)
      end
    end
    if nil == msgInfo.msgTime and not msgInfo.isOwnMsg then
      local playerState = self.chatMap[playerId].playerInfoItem
      if 0 == playerState.newMsgCnt then
        self:ChangeNewMsgPlayerCnt(1)
      end
      playerState.newMsgCnt = playerState.newMsgCnt + 1
    end
    self:UpdatePlayerLoc(playerId, 1)
    if self.isShown then
      self.actionOnUpdatePlayer()
    end
  end
  self.chatMap[playerId].msgPanel:AddMsg(msgInfo)
end
function PrivateChatPanelMobile:UpdatePlayerLoc(inPlayerId, locationAtList)
  if self.ListView_PlayerList then
    local players = self.ListView_PlayerList:GetListItems()
    for index = 1, players:Length() do
      if players:Get(index).data.playerId == inPlayerId then
        if index == locationAtList then
          return
        end
        local item = players:Get(index)
        players:RemoveItem(item)
        if 0 == locationAtList then
          players:Add(item)
        else
          players:Insert(item, locationAtList)
        end
        self.ListView_PlayerList:BP_SetListItems(players)
        break
      end
    end
    self.actionOnUpdatePlayer()
  end
end
function PrivateChatPanelMobile:SendMsg()
  local text = self.SendContent:GetText()
  if not UE4.UKismetTextLibrary.TextIsEmpty(text) then
    local msgInfo = {}
    msgInfo.channelType = ChatEnum.EChatChannel.private
    msgInfo.chatName = self.chatMap[self.chatId].chatName
    msgInfo.chatId = self.chatId
    msgInfo.msgSend = text
    self.actionOnSendMsg(msgInfo)
  end
end
function PrivateChatPanelMobile:SendMsgSucceed()
  if self.SendContent then
    self.SendContent:SetText("")
    self.SendContent:SetUserFocus(UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0))
  end
end
function PrivateChatPanelMobile:ChangeNewMsgPlayerCnt(cnt)
  if RedDotTree then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.GameChatPrivate, cnt)
  end
end
function PrivateChatPanelMobile:SetIsShown(isShown)
  self.isShown = isShown
  if self.isShown then
    self.actionOnUpdatePlayer()
  end
end
return PrivateChatPanelMobile
