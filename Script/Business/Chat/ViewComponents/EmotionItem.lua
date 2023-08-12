local EmotionItem = class("EmotionItem", PureMVC.ViewComponentPanel)
function EmotionItem:ListNeededMediators()
  return {}
end
function EmotionItem:InitializeLuaEvent()
  self.actionOnClickEmoteItem = LuaEvent.new(emoteId)
end
function EmotionItem:InitView(emotionCfg)
  if emotionCfg then
    self.emoteId = emotionCfg.id
    if self.Img_Emote and emotionCfg.icon then
      self:SetImageByTexture2D_MatchSize(self.Img_Emote, emotionCfg.icon)
    end
  end
end
function EmotionItem:Construct()
  EmotionItem.super.Construct(self)
  if self.Img_Emote and self.Image then
    self.Img_Emote:SetBrush(self.Image)
  end
end
function EmotionItem:OnLuaItemHovered()
end
function EmotionItem:OnLuaItemUnhovered()
end
function EmotionItem:OnLuaItemClick()
  if self.emoteId then
    LogDebug("EmotionItem", "Click emote:%d", self.emoteId)
    self.actionOnClickEmoteItem(self.emoteId)
  end
end
return EmotionItem
