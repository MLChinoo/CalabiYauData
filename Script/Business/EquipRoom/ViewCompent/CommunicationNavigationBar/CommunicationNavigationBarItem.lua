local CommunicationNavigationBarItem = class("CommunicationNavigationBarItem", PureMVC.ViewComponentPanel)
function CommunicationNavigationBarItem:OnInitialized()
  CommunicationNavigationBarItem.super.OnInitialized(self)
  self.onClickEvent = LuaEvent.new()
end
function CommunicationNavigationBarItem:OnLuaItemClick()
  self.onClickEvent(self)
end
function CommunicationNavigationBarItem:OnLuaItemHovered()
  if self.Img_Hovered then
    self:ShowUWidget(self.Img_Hovered)
  end
end
function CommunicationNavigationBarItem:OnLuaItemUnhovered()
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
end
function CommunicationNavigationBarItem:SetCustomType(customType)
  self.customType = customType
end
function CommunicationNavigationBarItem:GetCustomType()
  return self.customType
end
function CommunicationNavigationBarItem:SetSelectState(bSelect)
  if bSelect then
    if self.Overlay_Select then
      self:ShowUWidget(self.Overlay_Select)
    end
  elseif self.Overlay_Select then
    self:HideUWidget(self.Overlay_Select)
  end
end
function CommunicationNavigationBarItem:SetSlefBeSelect()
  self.onClickEvent(self)
end
function CommunicationNavigationBarItem:SetRedDotVisible(bShow)
  if self.Overlay_RedDot then
    if bShow then
      self.Overlay_RedDot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Overlay_RedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
return CommunicationNavigationBarItem
