local PrivateChatName = class("PrivateChatName", PureMVC.ViewComponentPanel)
function PrivateChatName:ListNeededMediators()
  return {}
end
function PrivateChatName:InitializeLuaEvent()
  self.actionOnChooseChat = LuaEvent.new(chatName)
end
function PrivateChatName:Construct()
  PrivateChatName.super.Construct(self)
  if self.Button_Select then
    self.Button_Select.OnClicked:Add(self, self.OnSelect)
  end
end
function PrivateChatName:Destruct()
  if self.Button_Select then
    self.Button_Select.OnClicked:Remove(self, self.OnSelect)
  end
  PrivateChatName.super.Destruct(self)
end
function PrivateChatName:UpdateView(chatName)
  LogWarn("PrivateChatName", chatName)
  if self.Text_ChatName then
    self.Text_ChatName:SetText(chatName)
  end
  self.chatName = chatName
end
function PrivateChatName:OnSelect()
  self.actionOnChooseChat(self.chatName)
end
return PrivateChatName
