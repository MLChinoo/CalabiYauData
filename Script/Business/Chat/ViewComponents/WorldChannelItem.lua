local WorldChannelItem = class("WorldChannelItem", PureMVC.ViewComponentPanel)
local buttonState = {
  normal = 0,
  hover = 1,
  choose = 2
}
function WorldChannelItem:InitializeLuaEvent()
  self.actionOnDeleteMsg = LuaEvent.new(msgTimestamp)
end
function WorldChannelItem:OnListItemObjectSet(itemObj)
  local isSelected = UE4.UUserListEntryLibrary.IsListItemSelected(self)
  self:BP_OnItemSelectionChanged(isSelected)
  local channelItem = itemObj.data
  if channelItem then
    if self.Text_Channel then
      self.Text_Channel:SetText(channelItem.channel)
    end
    if self.BusyCount and self.NormalCount and self.WidgetSwitcher_Status then
      if channelItem.count > self.BusyCount then
        self.WidgetSwitcher_Status:SetActiveWidgetIndex(0)
      elseif channelItem.count > self.NormalCount then
        self.WidgetSwitcher_Status:SetActiveWidgetIndex(1)
      else
        self.WidgetSwitcher_Status:SetActiveWidgetIndex(2)
      end
    elseif self.WidgetSwitcher_Status then
      self.WidgetSwitcher_Status:SetActiveWidgetIndex(2)
    end
  end
end
function WorldChannelItem:BP_OnItemSelectionChanged(bIsSelected)
  self:SetItemState(bIsSelected and buttonState.choose or buttonState.normal)
  if self.Img_Selected then
    self.Img_Selected:SetVisibility(bIsSelected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function WorldChannelItem:SetItemState(newState)
  if self.WidgetSwitcher_ItemState then
    self.WidgetSwitcher_ItemState:SetActiveWidgetIndex(newState)
  end
end
function WorldChannelItem:OnLuaItemHovered()
  if not UE4.UUserListEntryLibrary.IsListItemSelected(self) then
    self:SetItemState(buttonState.hover)
  end
end
function WorldChannelItem:OnLuaItemUnhovered()
  if not UE4.UUserListEntryLibrary.IsListItemSelected(self) then
    self:SetItemState(buttonState.normal)
  end
end
return WorldChannelItem
