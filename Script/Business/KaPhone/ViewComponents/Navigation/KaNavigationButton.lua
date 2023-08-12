local KaNavigationButton = class("KaNavigationButton", PureMVC.ViewComponentPanel)
local Valid
local ButtonState = {
  Normal = 0,
  Current = 1,
  Selected = 2,
  Hovered = 3
}
function KaNavigationButton:InitItem(Data, bIsCurRole)
  if not Data then
    return nil
  end
  self.bIsCurRole = bIsCurRole
  self.Data = Data
  Valid = Data.Avatar and self.Avatar and self:SetImageByTexture2D(self.Avatar, Data.Avatar)
  Valid = self.Overlay_Current and self.Overlay_Current:SetVisibility(bIsCurRole and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.LoveLevel and self.LoveLevel:SetText(Data.LoveLevel)
  if GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetIsFirstEnterRoom(Data.RoleId) then
    Valid = self.PS_LoopGolw and self.PS_LoopGolw:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.Overlay_LoveLevel and self.Overlay_LoveLevel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    Valid = self.PS_LoopGolw and self.PS_LoopGolw:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.Overlay_LoveLevel and self.Overlay_LoveLevel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  Valid = self.PS_OnceGolw and self.PS_OnceGolw:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:ResetButtonState()
end
function KaNavigationButton:PlayUnlockPS()
  Valid = self.PS_OnceGolw and self.PS_OnceGolw:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  Valid = self.PS_OnceGolw and self.PS_OnceGolw:SetReactivate(true)
end
function KaNavigationButton:Construct()
  KaNavigationButton.super.Construct(self)
  self.actionOnClick = LuaEvent.new()
  Valid = self.Button and self.Button.OnClicked:Add(self, self.OnClick)
  Valid = self.Button and self.Button.OnHovered:Add(self, self.OnHovered)
  Valid = self.Button and self.Button.OnUnhovered:Add(self, self.OnUnhovered)
  Valid = self.SizeBox_Hovered and self.SizeBox_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function KaNavigationButton:Destruct()
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.OnClick)
  Valid = self.Button and self.Button.OnHovered:Remove(self, self.OnHovered)
  Valid = self.Button and self.Button.OnUnhovered:Remove(self, self.OnUnhovered)
  KaNavigationButton.super.Destruct(self)
end
function KaNavigationButton:ResetButtonState()
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(self.bIsCurRole and ButtonState.Current or ButtonState.Normal)
end
function KaNavigationButton:OnClick()
  self.actionOnClick(self)
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(ButtonState.Selected)
end
function KaNavigationButton:OnHovered()
  Valid = self.SizeBox_Hovered and self.SizeBox_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function KaNavigationButton:OnUnhovered()
  Valid = self.SizeBox_Hovered and self.SizeBox_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return KaNavigationButton
