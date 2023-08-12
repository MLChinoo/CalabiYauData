local EquipRoomMainPageMediator = require("Business/EquipRoom/Mediators/EquipRoomMainPageMeditor")
local EquipRoomMainPageMobile = class("EquipRoomMainPageMobile", PureMVC.ViewComponentPage)
function EquipRoomMainPageMobile:ListNeededMediators()
  return {EquipRoomMainPageMediator}
end
function EquipRoomMainPageMobile:InitializeLuaEvent()
  self.WeaponListBG.OnClickedEvent:Add(self, self.OnClickWeaponListBG)
  self.OnCloseAnimationFinishEvent = LuaEvent.new()
  self.OnClickWeaponListBGEvent = LuaEvent.new()
  self.OnOpenRolePresetPageEvent = LuaEvent.new()
  self.OnOpenDecalPageEvent = LuaEvent.new()
  self.OnOpenWeaponSkinPageEvent = LuaEvent.new()
  self.OnSelectRoleEvent = LuaEvent.new()
  self.OnClickWeaponSoltItemEvent = LuaEvent.new()
  self.OnClickWeaponListItemEvent = LuaEvent.new()
  self.OnRoleUnlockEvent = LuaEvent.new()
  self.Btn_OpenRolePresetPage.OnClickEvent:Add(self, self.OnOpenRolePresetPage)
  self.Btn_OpenWeaponSkinPage.OnClickEvent:Add(self, self.OnOpenWeaponSkinPage)
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel.clickItemEvent:Add(self.OnSelectRole, self)
  end
  if self.EquipWeaponPanel then
    self.EquipWeaponPanel.OnClickSoltItemEvent:Add(self.OnClickSoltItem, self)
    self.EquipWeaponPanel.OnClickListItemEvent:Add(self.OnClickWeaponListItem, self)
  end
  if self.Btn_RoleUnlock then
    self.Btn_RoleUnlock.OnClicked:Add(self, self.OnUnlockRoleClick)
  end
  if self.TabPanel then
    self.TabPanel.onItemClickEvent:Add(self.OnChangTab, self)
    self.TabPanel:SetBarSelectState(0)
  end
  if self.ReturnButton then
    self.ReturnButton.OnClickEvent:Add(self, self.OnReturnClick)
  end
end
function EquipRoomMainPageMobile:Construct()
  EquipRoomMainPageMobile.super.Construct(self)
  if self.ReturnButton then
    local basicFunctionProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
    local configRow = basicFunctionProxy:GetFunctionMobileById(UE4.ECYFunctionMobileTypes.EquipmentRoom)
    if configRow then
      self.ReturnButton:SetButtonName(configRow.Name)
    end
  end
end
function EquipRoomMainPageMobile:OnClose()
  self.WeaponListBG.OnClickedEvent:Remove(self, self.OnClickWeaponListBG)
  self.Btn_OpenRolePresetPage.OnClickEvent:Remove(self, self.OnOpenRolePresetPage)
  self.Btn_OpenWeaponSkinPage.OnClickEvent:Remove(self, self.OnOpenWeaponSkinPage)
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel.clickItemEvent:Remove(self.OnSelectRole, self)
  end
  if self.EquipWeaponPanel then
    self.EquipWeaponPanel.OnClickSoltItemEvent:Remove(self.OnClickSoltItem, self)
    self.EquipWeaponPanel.OnClickListItemEvent:Remove(self.OnClickWeaponListItem, self)
  end
  if self.Btn_RoleUnlock then
    self.Btn_RoleUnlock.OnClicked:Remove(self, self.OnUnlockRoleClick)
  end
  if self.TabPanel then
    self.TabPanel.onItemClickEvent:Remove(self.OnChangTab, self)
  end
  if self.ReturnButton then
    self.ReturnButton.OnClickEvent:Remove(self, self.OnReturnClick)
  end
end
function EquipRoomMainPageMobile:OnReturnClick()
  ViewMgr:PopPage(self, UIPageNameDefine.EquipRoomMainPage)
end
function EquipRoomMainPageMobile:OnChangTab(customType)
  if self.WidgetSwitcher_Tab and customType then
    self.WidgetSwitcher_Tab:SetActiveWidgetIndex(customType)
  end
end
function EquipRoomMainPageMobile:OnUnlockRoleClick()
  self.OnRoleUnlockEvent()
end
function EquipRoomMainPageMobile:OnClickWeaponListItem(data)
  self.OnClickWeaponListItemEvent(data)
end
function EquipRoomMainPageMobile:OnClickSoltItem(soltItem)
  self.OnClickWeaponSoltItemEvent(soltItem)
end
function EquipRoomMainPageMobile:OnSelectRole(roleID)
  self.OnSelectRoleEvent(roleID)
end
function EquipRoomMainPageMobile:OnOpenRolePresetPage()
  self.OnOpenRolePresetPageEvent()
end
function EquipRoomMainPageMobile:OnOpenDecalPage()
  self.OnOpenDecalPageEvent()
end
function EquipRoomMainPageMobile:OnOpenWeaponSkinPage()
  self.OnOpenWeaponSkinPageEvent()
end
function EquipRoomMainPageMobile:OnOpen(luaOpenData, nativeOpenData)
  self.ViewSwtichAnimation:PlayOpenAnimation({
    self,
    self.OnOpenAnimationFinish
  })
end
function EquipRoomMainPageMobile:OnOpenAnimationFinish()
end
function EquipRoomMainPageMobile:OnClickWeaponListBG()
  self.OnClickWeaponListBGEvent()
end
function EquipRoomMainPageMobile:HideWeaponListPanel()
  self:HideUWidget(self.WeaponListBG)
  self.EquipWeaponPanel:HideWeaponListPanel()
end
function EquipRoomMainPageMobile:ShowWeaponListPanel()
  self.EquipWeaponPanel:ShowWeaponListPanel()
  self.WeaponListBG:SetVisibility(UE4.ESlateVisibility.Visible)
end
function EquipRoomMainPageMobile:OnCloseAnimationFinish()
  self.OnCloseAnimationFinishEvent()
end
function EquipRoomMainPageMobile:UpdateRoleGridPanel(PanelDatas)
  self.SelectRoleGridPanel:UpdatePanel(PanelDatas)
  self.SelectRoleGridPanel:UpdateItemNumStr(PanelDatas)
end
function EquipRoomMainPageMobile:SetDefaultSelectItem(roleID)
  if nil ~= roleID and 0 ~= roleID then
    self.SelectRoleGridPanel:SetDefaultSelectItemByItemID(roleID)
  else
    self.SelectRoleGridPanel:SetDefaultSelectItem(1)
  end
end
function EquipRoomMainPageMobile:OpenNextPage(nextPage)
  ViewMgr:PushPage(self, nextPage)
end
function EquipRoomMainPageMobile:SetRoleUnlockVisible(bShow)
  if self.Overlay_RoleUnlock then
    self.Overlay_RoleUnlock:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function EquipRoomMainPageMobile:UpdateRedDotByRole()
end
function EquipRoomMainPageMobile:UpdateRoleListRedDot()
end
return EquipRoomMainPageMobile
