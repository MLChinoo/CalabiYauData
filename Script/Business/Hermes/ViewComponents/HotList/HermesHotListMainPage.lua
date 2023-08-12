local HermesHotListPage = class("HermesHotListPage", PureMVC.ViewComponentPage)
local HermesHotListMediator = require("Business/Hermes/Mediators/HotList/HotListMediator")
local Valid
function HermesHotListPage:Update(AllData)
  self.ListPanelMap = {}
  self.BarItemMap = {}
  local Index = 0
  if self.HotlistPanelClass then
    local TempPanelClass = ObjectUtil:LoadClass(self.HotlistPanelClass)
    Valid = self.ScrollBox_Panel and self.ScrollBox_Panel:ClearChildren()
    for i, Data in pairs(AllData) do
      local TempPanel = UE4.UWidgetBlueprintLibrary.Create(self, TempPanelClass)
      if not TempPanel then
        break
      end
      Valid = self.ScrollBox_Panel and self.ScrollBox_Panel:AddChild(TempPanel)
      self.ListPanelMap[i] = TempPanel
      TempPanel:Update(Data)
      Index = Index + 1
    end
  end
  if self.ScrollBarItemClass then
    local BarItemClass = ObjectUtil:LoadClass(self.ScrollBarItemClass)
    if self.HorizontalBox_Scroll then
      self.HorizontalBox_Scroll:ClearChildren()
      local BarItemPanel
      for index = 1, Index do
        BarItemPanel = nil
        BarItemPanel = UE4.UWidgetBlueprintLibrary.Create(self, BarItemClass)
        if not BarItemPanel then
          break
        end
        BarItemPanel:Init(index)
        BarItemPanel:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Default)
        self.HorizontalBox_Scroll:AddChildToHorizontalBox(BarItemPanel)
        BarItemPanel.clickItemEvent:Add(self.ClickScrollItem, self)
        BarItemPanel.TimeUpEvent:Add(self.ChangeToNextPanel, self)
        self.BarItemMap[index] = BarItemPanel
      end
    end
  end
  self.LastItemIndex = 1
  Valid = self.BarItemMap[1] and self.BarItemMap[1]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Working)
  if 0 == Index then
    Valid = self.HorizontalBox_Bottom and self.HorizontalBox_Bottom:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  Valid = self.ScrollBox_Panel and self.ScrollBox_Panel:ScrollToStart()
end
function HermesHotListPage:ListNeededMediators()
  return {HermesHotListMediator}
end
function HermesHotListPage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.CloseAnim and self:PlayAnimation(self.CloseAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  Valid = self.HotKeyButton_Esc and self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
end
function HermesHotListPage:OnClose()
  Valid = self.HotKeyButton_Esc and self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
end
function HermesHotListPage:OnMouseWheel(MyGeometry, MouseEvent)
  local delta = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent)
  if delta > 0 then
    self:ChangeToUpPanel(self.LastItemIndex)
  else
    self:ChangeToNextPanel(self.LastItemIndex, true)
  end
  return true
end
function HermesHotListPage:OnEscHotKeyClick()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function HermesHotListPage:ClickScrollItem(Index)
  Valid = self.BarItemMap[self.LastItemIndex] and self.BarItemMap[self.LastItemIndex]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Default)
  self.LastItemIndex = Index
  Valid = self.BarItemMap[self.LastItemIndex] and self.BarItemMap[self.LastItemIndex]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Working)
  Valid = self.ScrollBox_Panel and self.ListPanelMap[Index] and self.ScrollBox_Panel:ScrollWidgetIntoView(self.ListPanelMap[Index], true)
end
function HermesHotListPage:ChangeToNextPanel(CurIndex, bIsWheel)
  local Index = CurIndex
  if self.ListPanelMap and #self.ListPanelMap > 0 then
    if Index >= #self.ListPanelMap then
      if bIsWheel then
        return nil
      end
      Index = 1
    else
      Index = Index + 1
    end
  end
  Valid = self.BarItemMap[self.LastItemIndex] and self.BarItemMap[self.LastItemIndex]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Default)
  self.LastItemIndex = Index
  Valid = self.ScrollBox_Panel and self.ListPanelMap[Index] and self.ScrollBox_Panel:ScrollWidgetIntoView(self.ListPanelMap[Index], true)
  Valid = self.BarItemMap[Index] and self.BarItemMap[Index]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Working)
end
function HermesHotListPage:ChangeToUpPanel(CurIndex)
  local Index = CurIndex
  if self.ListPanelMap and #self.ListPanelMap > 0 then
    if Index <= 1 then
      return nil
    else
      Index = Index - 1
    end
  end
  Valid = self.BarItemMap[self.LastItemIndex] and self.BarItemMap[self.LastItemIndex]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Default)
  self.LastItemIndex = Index
  Valid = self.ScrollBox_Panel and self.ListPanelMap[Index] and self.ScrollBox_Panel:ScrollWidgetIntoView(self.ListPanelMap[Index], true)
  Valid = self.BarItemMap[Index] and self.BarItemMap[Index]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Working)
end
function HermesHotListPage:SetScrollBarPause(bPause)
  if bPause then
    Valid = self.BarItemMap[self.LastItemIndex] and self.BarItemMap[self.LastItemIndex]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.Pause)
  else
    Valid = self.BarItemMap[self.LastItemIndex] and self.BarItemMap[self.LastItemIndex]:SetState(GlobalEnumDefine.EHermesScrollBarStateType.UnPause)
  end
end
return HermesHotListPage
