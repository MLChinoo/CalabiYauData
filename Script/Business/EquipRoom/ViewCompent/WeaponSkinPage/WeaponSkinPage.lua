local WeaponSkinPageMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/WeaponSkinPageMeditor")
local SecondaryBasePage = require("Business/EquipRoom/ViewCompent/SecondaryBasePage/SecondaryBasePage")
local WeaponSkinPage = class("WeaponSkinPage", SecondaryBasePage)
function WeaponSkinPage:ListNeededMediators()
  return {WeaponSkinPageMeditor}
end
function WeaponSkinPage:InitializeLuaEvent()
  WeaponSkinPage.super.InitializeLuaEvent(self)
  self.onCtrImgPressedEvent = LuaEvent.new()
  self.onCtrImgReleasedEvent = LuaEvent.new()
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys.actionOnStartDrag:Add(self.OnCtrImgPressed, self)
    self.WBP_ItemDisplayKeys.actionOnStopDrag:Add(self.OnCtrImgReleased, self)
  end
end
function WeaponSkinPage:OnOpen(luaOpenData, nativeOpenData)
end
function WeaponSkinPage:OnClose()
  WeaponSkinPage.super.OnClose(self)
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys.actionOnStartDrag:Remove(self.OnCtrImgPressed, self)
    self.WBP_ItemDisplayKeys.actionOnStopDrag:Remove(self.OnCtrImgReleased, self)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomPrimaryWeaponSkin)
end
function WeaponSkinPage:OnCtrImgPressed()
  self.onCtrImgPressedEvent()
end
function WeaponSkinPage:OnCtrImgReleased()
  self.onCtrImgReleasedEvent()
end
function WeaponSkinPage:HideBodyLable()
  if self.Canvas_Body then
    self:HideUWidget(self.Canvas_Body)
  end
end
function WeaponSkinPage:ShowBodyLable()
  if self.Canvas_Body then
    self:ShowUWidget(self.Canvas_Body)
  end
end
function WeaponSkinPage:SkinPanelPlayShowAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayOpenAnimation()
  end
end
function WeaponSkinPage:SkinPanelCloseAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayColseAnimation()
  end
end
function WeaponSkinPage:SelectPrimaryWeaponTab()
  self:SelectBarByCustomType(UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin)
end
function WeaponSkinPage:SelectSecondaryWeaponTab()
  self:SelectBarByCustomType(UE4.EPMFunctionTypes.EquipRoomSecondaryWeaponSkin)
end
function WeaponSkinPage:SelectyWeaponSkinTab(slotType)
  local functionType = UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin
  if slotType == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
    functionType = UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin
  elseif slotType == UE4.EWeaponSlotTypes.WeaponSlot_Secondary then
    functionType = UE4.EPMFunctionTypes.EquipRoomSecondaryWeaponSkin
  elseif slotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
    functionType = UE4.EPMFunctionTypes.GrenadeSkin_1
  elseif slotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
    functionType = UE4.EPMFunctionTypes.GrenadeSkin_2
  end
  self:SelectBarByCustomType(functionType)
end
function WeaponSkinPage:UpdateBar()
  local barDataMap = {}
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomSecondaryWeaponSkin, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.GrenadeSkin_1, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.GrenadeSkin_2, barDataMap)
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar:UpdateBar(barDataMap)
  end
end
function WeaponSkinPage:AddTabPanel(tabPanelMap)
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin] = self.PrimaryWeaponSkinPanel
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomSecondaryWeaponSkin] = self.SecondaryWeaponSkinPanel
  tabPanelMap[UE4.EPMFunctionTypes.GrenadeSkin_1] = self.GrenadeSkinPanel_1
  tabPanelMap[UE4.EPMFunctionTypes.GrenadeSkin_2] = self.GrenadeSkinPanel_2
  self.tabPanelMap = tabPanelMap
end
function WeaponSkinPage:InitRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomPrimaryWeaponSkin, function(cnt)
    self:UpdateRedDotByCustomType(cnt, UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPrimaryWeaponSkin), UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin)
end
function WeaponSkinPage:UpdateRedDot()
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPrimaryWeaponSkin), UE4.EPMFunctionTypes.EquipRoomPrimaryWeaponSkin)
end
function WeaponSkinPage:UpdateRedDotByCustomType(cnt, customType)
  if self.SecondaryNavigationBar then
    local barItem = self.SecondaryNavigationBar:GetBarByCustomType(customType)
    if barItem then
      barItem:SetRedDotVisible(self:IsCurrentRoleInfluenece(customType))
    end
  end
  local tabPanel = self.tabPanelMap[customType]
  if tabPanel then
    tabPanel:SetSwitchRoleBtnRedDotVisible(cnt > 0)
  end
  self:UpdateRoleListRedDot(customType)
end
function WeaponSkinPage:UpdateRoleListRedDot(customType)
  if self.SelectRoleGridPanel then
    local roleIDList = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):GetRedDotInfluenceRoleByWeaponSkin()
    self.SelectRoleGridPanel:UpdateRedDotByRoleIDList(roleIDList)
  end
end
return WeaponSkinPage
