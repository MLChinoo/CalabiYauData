local CharacterPreinstallPageMeditor = require("Business/EquipRoom/Mediators/CharacterPreinstallPageMeditor")
local SecondaryBasePage = require("Business/EquipRoom/ViewCompent/SecondaryBasePage/SecondaryBasePage")
local CharacterPreinstallPage = class("CharacterPreinstallPage", SecondaryBasePage)
function CharacterPreinstallPage:ListNeededMediators()
  return {CharacterPreinstallPageMeditor}
end
function CharacterPreinstallPage:InitializeLuaEvent()
  CharacterPreinstallPage.super.InitializeLuaEvent(self)
end
function CharacterPreinstallPage:OnOpen(luaOpenData, nativeOpenData)
end
function CharacterPreinstallPage:OnClose()
  CharacterPreinstallPage.super.OnClose(self)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomRoleSkin)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomRoleVoice)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomCommuication)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Decal)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoomPersonal)
end
function CharacterPreinstallPage:HideRoleListCollectPanel()
  if self.SelectRoleGridPanel then
    self.SelectRoleGridPanel:HideCollectPanel()
  end
end
function CharacterPreinstallPage:SkinPanelPlayShowAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayOpenAnimation()
  end
end
function CharacterPreinstallPage:SkinPanelCloseAnimation()
  if self.SkinPanel then
    self.SkinPanel:PlayColseAnimation()
  end
end
function CharacterPreinstallPage:SetDefaultTab()
  self:SelectBarByCustomType(UE4.EPMFunctionTypes.EquipRoomRoleSkin)
end
function CharacterPreinstallPage:UpdateBar()
  local barDataMap = {}
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomRoleSkin, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomRoleVoice, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomCommunication, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomPersonality, barDataMap)
  self:SetTabInfo(UE4.EPMFunctionTypes.EquipRoomDecal, barDataMap)
  if self.SecondaryNavigationBar then
    self.SecondaryNavigationBar:UpdateBar(barDataMap)
  end
end
function CharacterPreinstallPage:AddTabPanel(tabPanelMap)
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomRoleSkin] = self.SkinPanel
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomRoleVoice] = self.RoleVoicePanel
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomCommunication] = self.RoleCommunicationPanel
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomDecal] = self.DecalPanel
  tabPanelMap[UE4.EPMFunctionTypes.EquipRoomPersonality] = self.RolePersonalityPanel
  self.tabPanelMap = tabPanelMap
end
function CharacterPreinstallPage:ShowViewTips()
  if self.WBP_ItemDisplayKeys then
    self.WBP_ItemDisplayKeys:ShowRoll(true)
    self.WBP_ItemDisplayKeys:ShowPreview(true)
    self.WBP_ItemDisplayKeys:ShowFOV(true)
  end
end
function CharacterPreinstallPage:HideViewTips()
  if self.WBP_ItemDisplayKeys then
    if self.WBP_ItemDisplayKeys.isPreviewing then
      self.WBP_ItemDisplayKeys:StopPreview()
    end
    self.WBP_ItemDisplayKeys:ShowRoll(false)
    self.WBP_ItemDisplayKeys:ShowPreview(false)
    self.WBP_ItemDisplayKeys:ShowFOV(false)
  end
end
function CharacterPreinstallPage:SetTipsByTabType(tabType)
  if tabType ~= UE4.EPMFunctionTypes.EquipRoomRoleSkin then
    self:HideViewTips()
  end
end
function CharacterPreinstallPage:InitRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomRoleSkin, function(cnt)
    self:UpdateRedDotByCustomType(cnt, UE4.EPMFunctionTypes.EquipRoomRoleSkin)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleSkin), UE4.EPMFunctionTypes.EquipRoomRoleSkin)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomRoleVoice, function(cnt)
    self:UpdateRedDotByCustomType(cnt, UE4.EPMFunctionTypes.EquipRoomRoleVoice)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleVoice), UE4.EPMFunctionTypes.EquipRoomRoleVoice)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomCommuication, function(cnt)
    self:UpdateRedDotByCustomType(cnt, UE4.EPMFunctionTypes.EquipRoomCommunication)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomCommuication), UE4.EPMFunctionTypes.EquipRoomCommunication)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoomPersonal, function(cnt)
    self:UpdateRedDotByCustomType(cnt, UE4.EPMFunctionTypes.EquipRoomPersonality)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonal), UE4.EPMFunctionTypes.EquipRoomPersonality)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Decal, function(cnt)
    self:UpdateRedDotByCustomType(cnt, UE4.EPMFunctionTypes.EquipRoomDecal)
  end)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Decal), UE4.EPMFunctionTypes.EquipRoomDecal)
end
function CharacterPreinstallPage:UpdateRedDot()
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleSkin), UE4.EPMFunctionTypes.EquipRoomRoleSkin)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomRoleVoice), UE4.EPMFunctionTypes.EquipRoomRoleVoice)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomCommuication), UE4.EPMFunctionTypes.EquipRoomCommunication)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonal), UE4.EPMFunctionTypes.EquipRoomPersonality)
  self:UpdateRedDotByCustomType(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Decal), UE4.EPMFunctionTypes.EquipRoomDecal)
end
function CharacterPreinstallPage:UpdateRedDotByCustomType(cnt, customType)
  if self.SecondaryNavigationBar then
    local barItem = self.SecondaryNavigationBar:GetBarByCustomType(customType)
    if barItem then
      if customType == UE4.EPMFunctionTypes.EquipRoomDecal then
        barItem:SetRedDotVisible(cnt > 0)
      elseif customType == UE4.EPMFunctionTypes.EquipRoomPersonality then
        local emoteNum = RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoomPersonalEmote)
        local bShow = emoteNum > 0 or self:IsCurrentRoleInfluenece(customType)
        barItem:SetRedDotVisible(bShow)
      else
        barItem:SetRedDotVisible(self:IsCurrentRoleInfluenece(customType))
      end
    end
  end
  if customType ~= UE4.EPMFunctionTypes.EquipRoomDecal then
    local tabPanel = self.tabPanelMap[customType]
    if tabPanel then
      local equipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
      local roleIDList = equipRoomProxy:GetRedDotInfluenceRoleByDefault()
      tabPanel:SetSwitchRoleBtnRedDotVisible(table.count(roleIDList) > 0)
    end
    self:UpdateRoleListRedDot(customType)
  end
end
function CharacterPreinstallPage:UpdateRoleListRedDot(customType)
  if self.SelectRoleGridPanel then
    local equipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy)
    local roleIDList = equipRoomProxy:GetRedDotInfluenceRoleByDefault()
    self.SelectRoleGridPanel:UpdateRedDotByRoleIDList(roleIDList)
  end
end
return CharacterPreinstallPage
