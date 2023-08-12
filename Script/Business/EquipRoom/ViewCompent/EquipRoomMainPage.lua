local EquipRoomMainPageMediator = require("Business/EquipRoom/Mediators/EquipRoomMainPageMeditor")
local EquioRoomMainPage = class("EquioRoomMainPage", PureMVC.ViewComponentPage)
function EquioRoomMainPage:ListNeededMediators()
  return {EquipRoomMainPageMediator}
end
function EquioRoomMainPage:InitializeLuaEvent()
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
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys.actionOnReturn:Add(self.OnReturn, self)
  end
end
function EquioRoomMainPage:OnReturn()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function EquioRoomMainPage:OnUnlockRoleClick()
  self.OnRoleUnlockEvent()
end
function EquioRoomMainPage:OnClickWeaponListItem(data)
  self.OnClickWeaponListItemEvent(data)
end
function EquioRoomMainPage:OnClickSoltItem(soltItem)
  self.OnClickWeaponSoltItemEvent(soltItem)
end
function EquioRoomMainPage:OnSelectRole(roleID)
  self.OnSelectRoleEvent(roleID)
end
function EquioRoomMainPage:OnOpenRolePresetPage()
  self.OnOpenRolePresetPageEvent()
end
function EquioRoomMainPage:OnOpenDecalPage()
  self.OnOpenDecalPageEvent()
end
function EquioRoomMainPage:OnOpenWeaponSkinPage()
  self.OnOpenWeaponSkinPageEvent()
end
function EquioRoomMainPage:OnOpen(luaOpenData, nativeOpenData)
  self.ViewSwtichAnimation:PlayOpenAnimation({
    self,
    self.OnOpenAnimationFinish
  })
  self:InitRedDot()
end
function EquioRoomMainPage:OnClose()
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
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys.actionOnReturn:Remove(self.OnReturn, self)
  end
  self:UnbindRedDot()
end
function EquioRoomMainPage:OnOpenAnimationFinish()
end
function EquioRoomMainPage:OnClickWeaponListBG()
  self.OnClickWeaponListBGEvent()
end
function EquioRoomMainPage:HideWeaponListPanel()
  self:HideUWidget(self.WeaponListBG)
  self.EquipWeaponPanel:HideWeaponListPanel()
end
function EquioRoomMainPage:ShowWeaponListPanel()
  self.EquipWeaponPanel:ShowWeaponListPanel()
  self.WeaponListBG:SetVisibility(UE4.ESlateVisibility.Visible)
end
function EquioRoomMainPage:OnCloseAnimationFinish()
  self.OnCloseAnimationFinishEvent()
end
function EquioRoomMainPage:UpdateRoleGridPanel(PanelDatas)
  self.SelectRoleGridPanel:UpdatePanel(PanelDatas)
  self.SelectRoleGridPanel:UpdateItemNumStr(PanelDatas)
end
function EquioRoomMainPage:SetDefaultSelectItem(roleID)
  if nil ~= roleID and 0 ~= roleID then
    self.SelectRoleGridPanel:SetDefaultSelectItemByItemID(roleID)
  else
    self.SelectRoleGridPanel:SetDefaultSelectItem(1)
  end
end
function EquioRoomMainPage:LuaHandleKeyEvent(key, inputEvent)
  if self.WBP_ItemDisplayKeys then
    return self.WBP_ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function EquioRoomMainPage:OpenNextPage(nextPage)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  ViewMgr:OpenPage(self, nextPage)
end
function EquioRoomMainPage:SetRoleUnlockVisible(bShow)
  if self.Overlay_RoleUnlock then
    self.Overlay_RoleUnlock:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function EquioRoomMainPage:InitRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.RoleDefault, function(cnt)
    self:UpdateRedDotRoleDefault()
    self:UpdateRoleListRedDot()
  end)
  self:UpdateRedDotRoleDefault()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomWeaponSkin, function(cnt)
    self:UpdateRedDotWeaponSkin()
    self:UpdateRoleListRedDot()
  end)
  self:UpdateRedDotWeaponSkin()
end
function EquioRoomMainPage:UnbindRedDot()
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomWeaponSkin)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.RoleDefault)
end
function EquioRoomMainPage:UpdateRoleListRedDot()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
  local roleIDList = equiproomProxy:GetRedDotInfluenceRoleIDList()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:UpdateRedDotByRoleIDList(roleIDList)
  end
end
function EquioRoomMainPage:UpdateRedDotRoleDefault()
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleIDList = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):GetRedDotInfluenceRoleByDefault()
  local bShow = false
  for key, value in pairs(roleIDList) do
    if value == equiproomProxy:GetSelectRoleID() then
      bShow = true
      break
    end
  end
  if RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Decal) > 0 then
    bShow = true
  end
  if RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote) > 0 then
    bShow = true
  end
  if self.Btn_OpenRolePresetPage then
    self.Btn_OpenRolePresetPage:SetRedDotVisible(bShow)
  end
end
function EquioRoomMainPage:UpdateRedDotWeaponSkin()
  if self.Btn_OpenWeaponSkinPage then
    local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
    local roleIDList = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):GetRedDotInfluenceRoleByWeaponSkin()
    local bShow = false
    for key, value in pairs(roleIDList) do
      if value == equiproomProxy:GetSelectRoleID() then
        bShow = true
        break
      end
    end
    self.Btn_OpenWeaponSkinPage:SetRedDotVisible(bShow)
  end
end
function EquioRoomMainPage:UpdateRedDotByRole()
  self:UpdateRedDotRoleDefault()
  self:UpdateRedDotWeaponSkin()
end
return EquioRoomMainPage
