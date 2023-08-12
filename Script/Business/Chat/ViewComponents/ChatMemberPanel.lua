local ChatMemberPanel = class("ChatMemberPanel", PureMVC.ViewComponentPanel)
function ChatMemberPanel:ListNeededMediators()
  return {}
end
function ChatMemberPanel:InitView(chatPlayer)
  if self.TextBlock_Name then
    self.TextBlock_Name:SetText(chatPlayer.nick)
  end
  self.playerId = chatPlayer.player_id
end
return ChatMemberPanel
