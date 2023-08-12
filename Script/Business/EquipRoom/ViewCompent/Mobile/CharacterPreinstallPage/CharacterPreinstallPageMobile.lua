local CharacterPreinstallPageMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPageMeditor")
local SecondaryBasePage = require("Business/EquipRoom/ViewCompent/Mobile/SecondaryBasePage/SecondaryBasePageMobile")
local CharacterPreinstallPageMobile = class("CharacterPreinstallPageMobile", SecondaryBasePage)
function CharacterPreinstallPageMobile:ListNeededMediators()
  return {CharacterPreinstallPageMeditor}
end
function CharacterPreinstallPageMobile:InitializeLuaEvent()
  CharacterPreinstallPageMobile.super.InitializeLuaEvent(self)
end
function CharacterPreinstallPageMobile:OnOpen(luaOpenData, nativeOpenData)
end
function CharacterPreinstallPageMobile:OnClose()
  CharacterPreinstallPageMobile.super.OnClose(self)
end
function CharacterPreinstallPageMobile:HideRoleListCollectPanel()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:HideCollectPanel()
  end
end
function CharacterPreinstallPageMobile:SkinPanelPlayShowAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayOpenAnimation()
  end
end
function CharacterPreinstallPageMobile:SkinPanelCloseAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayColseAnimation()
  end
end
function CharacterPreinstallPageMobile:ReturnPage()
  ViewMgr:PopPage(self, UIPageNameDefine.CharacterPreinstallPage)
end
function CharacterPreinstallPageMobile:SetDefaultTab()
  self:SelectBarByCustomType(UE4.ECYFunctionMobileTypes.EquipRoomRoleSkin)
end
function CharacterPreinstallPageMobile:UpdateBar()
  local barDataMap = {}
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.EquipRoomRoleSkin, barDataMap)
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.EquipRoomRoleVoice, barDataMap)
  self:SetTabInfo(UE4.ECYFunctionMobileTypes.EquipRoomDecal, barDataMap)
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar:UpdateBar(barDataMap)
  end
end
function CharacterPreinstallPageMobile:AddTabPanel(tabPanelMap)
  tabPanelMap[UE4.ECYFunctionMobileTypes.EquipRoomRoleSkin] = self.SkinPanel
  tabPanelMap[UE4.ECYFunctionMobileTypes.EquipRoomRoleVoice] = self.RoleVoicePanel
  tabPanelMap[UE4.ECYFunctionMobileTypes.EquipRoomDecal] = self.DecalPanel
end
function CharacterPreinstallPageMobile:ShowViewTips()
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys:ShowRoll(true)
    self.WBP_ItemDisplayKeys:ShowFOV(true)
  end
end
function CharacterPreinstallPageMobile:HideViewTips()
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys:ShowRoll(false)
    self.WBP_ItemDisplayKeys:ShowFOV(false)
  end
end
function CharacterPreinstallPageMobile:SetTipsByTabType(tabType)
  if tabType ~= UE4.ECYFunctionMobileTypes.EquipRoomRoleSkin then
    self:HideViewTips()
  end
end
function CharacterPreinstallPageMobile:InitRedDot()
end
function CharacterPreinstallPageMobile:UpdateRedDot()
end
return CharacterPreinstallPageMobile
