local PrivateChatTabMobile = class("PrivateChatTabMobile", PureMVC.ViewComponentPanel)
function PrivateChatTabMobile:ListNeededMediators()
  return {}
end
function PrivateChatTabMobile:InitializeLuaEvent()
end
function PrivateChatTabMobile:OnListItemObjectSet(itemObj)
  self.itemInfo = itemObj
  if itemObj.parent then
    itemObj.parent.actionOnUpdatePlayer:Add(self.UpdateView, self)
  end
  self:UpdateView()
end
function PrivateChatTabMobile:BP_OnItemSelectionChanged(isSelected)
  self.itemInfo.isActive = isSelected
  if self.Image_Select then
    self.Image_Select:SetVisibility(self.itemInfo.isActive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  self:UpdateView()
end
function PrivateChatTabMobile:UpdateView()
  if self.itemInfo then
    local player = self.itemInfo.data
    if self.Image_Icon then
      local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(player.icon)
      if avatarIcon then
        self:SetImageByTexture2D(self.Image_Icon, avatarIcon)
      else
        LogError("PrivateChatTabMobile", "Player icon or config error")
      end
    end
    if self.Text_Name then
      local text = player.nick
      if UE4.UKismetStringLibrary.Len(text) > 4 then
        text = UE4.UKismetStringLibrary.Left(text, 4) .. "..."
      end
      self.Text_Name:SetText(text)
    end
    if self.Image_Select then
      self.Image_Select:SetVisibility(self.itemInfo.isActive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    if self.itemInfo.newMsgCnt > 0 and self.itemInfo.isActive then
      self.itemInfo.newMsgCnt = 0
      self.itemInfo.parent:ChangeNewMsgPlayerCnt(-1)
    end
    self:UpdateRedDotNewMsg()
  end
end
function PrivateChatTabMobile:UpdateRedDotNewMsg()
  if self.RedDot_NewMsg then
    self.RedDot_NewMsg:SetVisibility(self.itemInfo.newMsgCnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return PrivateChatTabMobile
