local KaChatItem = class("KaChatItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaChatItem:InitItem(ChatItemData)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  Valid = self.Avatar and self:SetImageByTexture2D(self.Avatar, ChatItemData.Avatar)
  self.RoleId = ChatItemData.RoleId
  self.Name:SetText(ChatItemData.Name)
  self.Favorability:SetVisibility(ChatItemData.LoveLevel >= 1 and Visible or Collapsed)
  self.LoveLevel:SetText(ChatItemData.LoveLevel)
  self.SubItemMap = {}
  local KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
  for SortId, SubItemTitleData in pairsByKeys(ChatItemData.SubChatItemData, function(a, b)
    return a < b
  end) do
    local SubItem = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
    if SubItem then
      SubItem:Init(SubItemTitleData)
      table.insert(self.SubItemMap, SubItem)
    end
  end
  self:UpdateRedDot()
  GameFacade:RetrieveProxy(ProxyNames.ApartmentTLogProxy):MessageFrequency()
end
function KaChatItem:UpdateRedDot()
  local bIsNeedShowTips = false
  for i, v in pairs(self.SubItemMap or nil) do
    if not v.bIsFinish and not v.bIsReaded then
      bIsNeedShowTips = true
    end
  end
  self.NewContentTip:SetVisibility(bIsNeedShowTips and SelfHitTestInvisible or Collapsed)
end
function KaChatItem:OnCloseSubList()
  Valid = self.AnimOpen and self:PlayAnimationReverse(self.AnimOpen)
  self.DynamicEntryBox:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function KaChatItem:Construct()
  KaChatItem.super.Construct(self)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:SetVisibility(UE.ESlateVisibility.Collapsed)
  Valid = self.Button and self.Button.OnClicked:Add(self, self.ItemClicked)
  Valid = self.Button and self.Button.OnHovered:Add(self, self.ItemHovered)
  Valid = self.Button and self.Button.OnUnhovered:Add(self, self.ItemUnhovered)
end
function KaChatItem:Destruct()
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.ItemClicked)
  Valid = self.Button and self.Button.OnHovered:Remove(self, self.ItemHovered)
  Valid = self.Button and self.Button.OnUnhovered:Remove(self, self.ItemUnhovered)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  KaChatItem.super.Destruct(self)
end
function KaChatItem:ItemClicked()
  if self.DynamicEntryBox then
    if self.DynamicEntryBox:GetVisibility() == UE.ESlateVisibility.Collapsed then
      Valid = self.AnimOpen and self:PlayAnimationForward(self.AnimOpen)
      GameFacade:SendNotification(NotificationDefines.NtfKaChatItem, self)
      self.DynamicEntryBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      Valid = self.AnimOpen and self:PlayAnimationReverse(self.AnimOpen)
      self.DynamicEntryBox:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end
function KaChatItem:ItemHovered()
  if self.DynamicEntryBox and self.DynamicEntryBox:GetVisibility() == UE.ESlateVisibility.Collapsed then
    Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(1)
  end
end
function KaChatItem:ItemUnhovered()
  if self.DynamicEntryBox and self.DynamicEntryBox:GetVisibility() == UE.ESlateVisibility.Collapsed then
    Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(0)
  end
end
return KaChatItem
