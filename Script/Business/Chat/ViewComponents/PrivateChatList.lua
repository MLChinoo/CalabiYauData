local PrivateChatList = class("PrivateChatList", PureMVC.ViewComponentPanel)
function PrivateChatList:ListNeededMediators()
  return {}
end
function PrivateChatList:InitializeLuaEvent()
  self.actionOnChoose = LuaEvent.new(chatName)
end
function PrivateChatList:InitChatList(chatNameList)
  if self.PrivateChatList then
    LogWarn("PrivateChatList", "Channels: %s", TableToString(chatNameList))
    if self.PrivateChatPanelClass then
      self.chatNameClass = ObjectUtil:LoadClass(self.PrivateChatPanelClass)
      if self.chatNameClass == nil then
        LogDebug("GameChatPage", "Chat name panel class load failed")
      end
    end
    if self.chatNameClass then
      self.PrivateChatList:ClearChildren()
      for index = table.count(chatNameList), 1, -1 do
        local panelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.chatNameClass)
        if panelIns then
          LogWarn("PrivateChatList", "Channel index: %d, channel name: %s", index, chatNameList[index])
          panelIns:UpdateView(chatNameList[index])
          self.PrivateChatList:AddChild(panelIns)
          panelIns.actionOnChooseChat:Add(self.ChooseItem, self)
        else
          LogError("PrivateChatList", "Create chat text panel failed")
        end
      end
    end
  end
end
function PrivateChatList:ChooseItem(itemName)
  self.actionOnChoose(itemName)
end
return PrivateChatList
