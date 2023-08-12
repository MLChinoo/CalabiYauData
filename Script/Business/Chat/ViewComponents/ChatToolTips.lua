local ChatToolTips = class("ChatToolTips", PureMVC.ViewComponentPanel)
function ChatToolTips:ListNeededMediators()
  return {}
end
function ChatToolTips:InitializeLuaEvent()
end
function ChatToolTips:SetToolTips(hyperlinkType, playerId)
  if playerId <= 0 then
    LogDebug("ChatToolTips", "Player id invalid...")
    return
  end
  local myPlayerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  if myPlayerId <= 0 then
    LogDebug("ChatToolTips", "My player id invalid...")
    return
  end
  if self.Text_ToolTip and hyperlinkType == UE4.EHyperlinkToolTipType.Team then
    LogDebug("ChatToolTips", "Show team hyper tool tips...")
    local toolTipString = "TeamHyperToolTipText_Self"
    if myPlayerId ~= playerId then
      toolTipString = "TeamHyperToolTipText_Other"
    end
    local toolTipText = ConfigMgr:FromStringTable(StringTablePath.ST_Chat, toolTipString)
    self.Text_ToolTip:SetText(toolTipText)
  end
end
return ChatToolTips
