local ChatEmotionPanel = class("ChatEmotionPanel", PureMVC.ViewComponentPanel)
local ChatEmotionPanelMediator = require("Business/Chat/Mediators/ChatEmotionPanelMediator")
function ChatEmotionPanel:ListNeededMediators()
  return {ChatEmotionPanelMediator}
end
function ChatEmotionPanel:InitializeLuaEvent()
  self.actionOnSendEmotion = LuaEvent.new(emoteId)
end
function ChatEmotionPanel:InitView(emotions)
  self:UpdateFavor()
  if self.EmoteEntry then
    for index, emoteCfg in pairs(emotions) do
      local emoteItem = self.EmoteEntry:BP_CreateEntry()
      emoteItem:InitView(emoteCfg)
      emoteItem.actionOnClickEmoteItem:Add(self.SendEmotion, self)
    end
  end
end
function ChatEmotionPanel:UpdateFavor()
  LogDebug("ChatEmotionPanel", "Update favor emotions")
  local favorEmotions = GameFacade:RetrieveProxy(ProxyNames.ChatDataProxy):GetFavorEmotion()
  for key, value in pairs(favorEmotions) do
    if self.favorEmotions[key] then
      self.favorEmotions[key]:InitView(value)
      self:ShowUWidget(self.favorEmotions[key])
    end
  end
  if self.VB_RecentUse and table.count(favorEmotions) > 0 then
    self.VB_RecentUse:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ChatEmotionPanel:Construct()
  LogDebug("ChatEmotionPanel", "Lua implement construct")
  ChatEmotionPanel.super.Construct(self)
  if self.FavorList then
    self.favorEmotions = {}
    local panels = self.FavorList:GetAllChildren()
    for i = 1, panels:Length() do
      local emotePanel = panels:Get(i)
      emotePanel.actionOnClickEmoteItem:Add(self.SendEmotion, self)
      emotePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      table.insert(self.favorEmotions, emotePanel)
    end
  end
  if self.VB_RecentUse then
    self.VB_RecentUse:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  GameFacade:SendNotification(NotificationDefines.Chat.GetChatEmotionListCmd)
end
function ChatEmotionPanel:SendEmotion(emoteId)
  LogDebug("ChatEmotionPanel", "Send emotion:%d", emoteId)
  GameFacade:SendNotification(NotificationDefines.Chat.AddFavorEmotionCmd, emoteId)
  self.actionOnSendEmotion(emoteId)
end
return ChatEmotionPanel
