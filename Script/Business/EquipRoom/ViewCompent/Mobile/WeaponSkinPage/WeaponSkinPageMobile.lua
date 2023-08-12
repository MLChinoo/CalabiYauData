local WeaponSkinPageMeditor = require("Business/EquipRoom/Mediators/WeaponSkin/WeaponSkinPageMeditor")
local SecondaryBasePage = require("Business/EquipRoom/ViewCompent/Mobile/SecondaryBasePage/SecondaryBasePageMobile")
local WeaponSkinPageMobile = class("WeaponSkinPageMobile", SecondaryBasePage)
function WeaponSkinPageMobile:ListNeededMediators()
  return {WeaponSkinPageMeditor}
end
function WeaponSkinPageMobile:InitializeLuaEvent()
  WeaponSkinPageMobile.super.InitializeLuaEvent(self)
end
function WeaponSkinPageMobile:OnOpen(luaOpenData, nativeOpenData)
end
function WeaponSkinPageMobile:OnClose()
  WeaponSkinPageMobile.super.OnClose(self)
end
function WeaponSkinPageMobile:HideBodyLable()
  if self.Canvas_Body then
    self:HideUWidget(self.Canvas_Body)
  end
end
function WeaponSkinPageMobile:ShowBodyLable()
  if self.Canvas_Body then
    self:ShowUWidget(self.Canvas_Body)
  end
end
function WeaponSkinPageMobile:SkinPanelPlayShowAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayOpenAnimation()
  end
end
function WeaponSkinPageMobile:SkinPanelCloseAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayColseAnimation()
  end
end
function WeaponSkinPageMobile:ReturnPage()
  ViewMgr:PopPage(self, UIPageNameDefine.EquipRoomWeaponSkinPage)
end
function WeaponSkinPageMobile:SelectPrimaryWeaponTab()
  self:SelectBarByCustomType(UE4.ECYFunctionMobileTypes.EquipRoomPrimaryWeaponSkin)
end
function WeaponSkinPageMobile:SelectSecondaryWeaponTab()
  self:SelectBarByCustomType(UE4.ECYFunctionMobileTypes.EquipRoomSecondaryWeaponSkin)
end
function WeaponSkinPageMobile:UpdateBar()
  local barDataMap = {}
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.EquipRoomPrimaryWeaponSkin, barDataMap)
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.EquipRoomSecondaryWeaponSkin, barDataMap)
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.GrenadeSkin_1, barDataMap)
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.GrenadeSkin_2, barDataMap)
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar:UpdateBar(barDataMap)
  end
end
function WeaponSkinPageMobile:AddTabPanel(tabPanelMap)
  tabPanelMap[UE4.ECYFunctionMobileTypes.EquipRoomPrimaryWeaponSkin] = self.PrimaryWeaponSkinPanel
  tabPanelMap[UE4.ECYFunctionMobileTypes.EquipRoomSecondaryWeaponSkin] = self.SecondaryWeaponSkinPanel
  tabPanelMap[UE4.ECYFunctionMobileTypes.GrenadeSkin_1] = self.GrenadeSkinPanel_1
  tabPanelMap[UE4.ECYFunctionMobileTypes.GrenadeSkin_2] = self.GrenadeSkinPanel_2
end
function WeaponSkinPageMobile:InitRedDot()
end
function WeaponSkinPageMobile:UpdateRedDot()
end
function WeaponSkinPageMobile:SelectyWeaponSkinTab(slotType)
  local functionType = UE4.ECYFunctionMobileTypes.EquipRoomPrimaryWeaponSkin
  if slotType == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
    functionType = UE4.ECYFunctionMobileTypes.EquipRoomPrimaryWeaponSkin
  elseif slotType == UE4.EWeaponSlotTypes.WeaponSlot_Secondary then
    functionType = UE4.ECYFunctionMobileTypes.EquipRoomSecondaryWeaponSkin
  elseif slotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 then
    functionType = UE4.ECYFunctionMobileTypes.GrenadeSkin_1
  elseif slotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
    functionType = UE4.ECYFunctionMobileTypes.GrenadeSkin_2
  end
  self:SelectBarByCustomType(functionType)
end
return WeaponSkinPageMobile
