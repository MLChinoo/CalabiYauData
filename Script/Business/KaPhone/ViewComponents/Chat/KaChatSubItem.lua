local KaChatSubItem = class("KaChatSubItem", PureMVC.ViewComponentPanel)
local Valid
function KaChatSubItem:Init(SubItemTitleData)
  self.SecondListMap = SubItemTitleData.SecondListMap
  self.bIsFinish = SubItemTitleData.bIsFinish
  self.bIsReaded = SubItemTitleData.bIsReaded
  if self.bIsFinish then
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.WidgetSwitcher_ButtonState and self.WidgetSwitcher_ButtonState:SetActiveWidgetIndex(1)
  elseif self.bIsReaded then
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetActiveWidgetIndex(1)
  else
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetActiveWidgetIndex(0)
  end
  local Content = SubItemTitleData.Content
  local ContentLength = FunctionUtil:getByteCount(Content)
  local IsNeedShowContentTail = false
  if ContentLength > self.TextLength then
    IsNeedShowContentTail = true
    ContentLength = self.TextLength
  end
  self.Text_Content:SetText(FunctionUtil:getSubStringByCount(Content, 1, ContentLength))
  self.LatestContent_1:SetVisibility(IsNeedShowContentTail and Visible or Collapsed)
end
function KaChatSubItem:UpdateState()
  local EndUniqueMark = self.SecondListMap and self.SecondListMap.End and self.SecondListMap.End.UniqueMark
  local StartUniqueMark = self.SecondListMap and self.SecondListMap.Start and self.SecondListMap.Start.UniqueMark
  local KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
  if KaChatProxy:GetPlayerChose(EndUniqueMark) then
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.WidgetSwitcher_ButtonState and self.WidgetSwitcher_ButtonState:SetActiveWidgetIndex(1)
    self.bIsFinish = true
  elseif KaChatProxy:GetPlayerChose(StartUniqueMark) then
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetActiveWidgetIndex(1)
    self.bIsReaded = true
  else
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetActiveWidgetIndex(0)
  end
end
function KaChatSubItem:Construct()
  KaChatSubItem.super.Construct(self)
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  Valid = self.Button and self.Button.OnClicked:Add(self, self.OnClickedButton)
  Valid = self.Button and self.Button.OnHovered:Add(self, self.OnHoveredButton)
  Valid = self.Button and self.Button.OnUnhovered:Add(self, self.OnUnhoveredButton)
  self.bIsFinish = nil
  self.bIsReaded = nil
end
function KaChatSubItem:Destruct()
  KaChatSubItem.super.Destruct(self)
  self.bIsFinish = nil
  self.bIsReaded = nil
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.OnClickedButton)
  Valid = self.Button and self.Button.OnHovered:Remove(self, self.OnHoveredButton)
  Valid = self.Button and self.Button.OnUnhovered:Remove(self, self.OnUnhoveredButton)
end
function KaChatSubItem:OnClickedButton()
  Valid = self.Button and self.Button:SetIsEnabled(false)
  self.bIsReaded = true
  Valid = self.WidgetSwitcher_RedDot and self.WidgetSwitcher_RedDot:SetActiveWidgetIndex(1)
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  GameFacade:RetrieveProxy(ProxyNames.KaChatProxy):ReqReadMsg(self.SecondListMap and self.SecondListMap.Start)
  GameFacade:SendNotification(NotificationDefines.UpdateKaChatDetail, self.SecondListMap)
  GameFacade:SendNotification(NotificationDefines.NtfKaChatSubItem, self)
end
function KaChatSubItem:OnHoveredButton()
  if self.Button and self.Button:GetIsEnabled() then
    Valid = self.Img_Selected and self.Img_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function KaChatSubItem:OnUnhoveredButton()
  if self.Button and self.Button:GetIsEnabled() then
    Valid = self.Img_Selected and self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function KaChatSubItem:ReSetState()
  Valid = self.Button and self.Button:SetIsEnabled(true)
  Valid = self.Img_Selected and self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return KaChatSubItem
