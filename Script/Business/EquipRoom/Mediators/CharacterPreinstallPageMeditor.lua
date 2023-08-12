local SecondaryBasePageMeditor = require("Business/EquipRoom/Mediators/SecondaryBasePageMeditor/SecondaryBasePageMeditor")
local CharacterPreinstallPageMeditor = class("CharacterPreinstallPageMeditor", SecondaryBasePageMeditor)
local EquipRoomProxy
function CharacterPreinstallPageMeditor:ListNotificationInterests()
  local list = CharacterPreinstallPageMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomSwitchRoleSkinModel)
  table.insert(list, NotificationDefines.EquipRoomPlayVoiceRandomAction)
  table.insert(list, NotificationDefines.EquipRoomSwitchFlyEffect)
  table.insert(list, NotificationDefines.EquipRoomSwitchDecal)
  return list
end
function CharacterPreinstallPageMeditor:OnRegister()
  CharacterPreinstallPageMeditor.super.OnRegister(self)
  EquipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
end
function CharacterPreinstallPageMeditor:OnRemove()
  CharacterPreinstallPageMeditor.super.OnRemove(self)
end
function CharacterPreinstallPageMeditor:HandleNotification(notify)
  CharacterPreinstallPageMeditor.super.HandleNotification(self, notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomSwitchRoleSkinModel then
    self:ChangeRoleSkin(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomPlayVoiceRandomAction then
    self:PlayVoiceRandomAction(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomSwitchFlyEffect then
    self:PlayFlyEffect(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomSwitchDecal then
    self:SwitchDecal(notifyBody)
  end
end
function CharacterPreinstallPageMeditor:OnViewComponentPagePreOpen(luaData, originOpenData)
  self:GetViewComponent():SetDefaultTab()
  self:GetRoleList()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleInfoPanelCmd, EquipRoomProxy:GetSelectRoleID())
  self:GetViewComponent():InitRedDot()
end
function CharacterPreinstallPageMeditor:OnSelectRole(roleId)
  CharacterPreinstallPageMeditor.super.OnSelectRole(self, roleId)
  if EquipRoomProxy:GetSelectRoleID() == roleId then
    LogDebug("CharacterPreinstallPageMeditor:OnSelectRole", "Role already seleced,ID:%s", roleId)
    return
  end
  EquipRoomProxy:SetSelectRoleID(roleId)
  if self.currentTabPanelType ~= self:GetEnumRoleSkinType() then
    self:ChangeRole(roleId)
  end
  self:GetViewComponent():SetTipsByTabType(self.currentTabPanelType)
  self:GetViewComponent():UpdateRedDot()
  self:UpdateCurrentTabPanelByRoleID(roleId)
end
function CharacterPreinstallPageMeditor:OnTHotKeyClick()
  if self:GetCurrentTabType() ~= self:GetEnumRoleSkinType() then
    return
  end
  if self.pageViewMode == GlobalEnumDefine.EPageModelPreviewType.Normal then
    self:EnterPreviewMode()
  else
    self:QuitPreviewMode()
  end
end
function CharacterPreinstallPageMeditor:OnChangeTab(tabType)
  if self:GetCurrentTabType() == tabType then
    LogDebug("SecondaryBasePageMeditor:OnChangeTab", "TabPanel already open,TabPanelType:%s", tabType)
    return
  end
  self.currentRoleSkinID = nil
  CharacterPreinstallPageMeditor.super.OnChangeTab(self, tabType)
end
function CharacterPreinstallPageMeditor:SetCharacterHiddenInGame(bHide)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys:SetCharacterHiddenInGame(bHide)
  end
end
function CharacterPreinstallPageMeditor:HideMedia(bHide)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys:HideMedia(bHide)
  end
end
function CharacterPreinstallPageMeditor:HideDecal(bHide)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys:SetDecalActorHiddenInGame(bHide)
  end
end
function CharacterPreinstallPageMeditor:GetEnumRoleSkinType()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    return UE4.EPMFunctionTypes.EquipRoomRoleSkin
  elseif platform == GlobalEnumDefine.EPlatformType.PC then
    return UE4.ECYFunctionMobileTypes.EquipRoomRoleSkin
  end
  return UE4.EPMFunctionTypes.EquipRoomRoleSkin
end
function CharacterPreinstallPageMeditor:GetEnumFlyEffectType()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    return UE4.EPMFunctionTypes.EquipRoomFlyEffect
  elseif platform == GlobalEnumDefine.EPlatformType.PC then
    return UE4.ECYFunctionMobileTypes.EquipRoomFlyEffect
  end
  return UE4.EPMFunctionTypes.EquipRoomFlyEffect
end
function CharacterPreinstallPageMeditor:OnTabPanelCloseAnimationFinishExtend()
  if self.currentTabPanelType ~= self:GetEnumFlyEffectType() then
    self:SetCharacterHiddenInGame(false)
    self:HideMedia(true)
    self:HideDecal(false)
  else
    self:SetCharacterHiddenInGame(true)
    self:HideMedia(false)
    self:HideDecal(true)
  end
end
function CharacterPreinstallPageMeditor:EnterPreviewMode()
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Preview
  self:GetViewComponent():SkinPanelCloseAnimation()
  self:HideRoleListPanel()
end
function CharacterPreinstallPageMeditor:QuitPreviewMode()
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Normal
  self:GetViewComponent():SkinPanelPlayShowAnimation()
end
function CharacterPreinstallPageMeditor:ChangeRoleModel(roleID, roleSkinID, stateType)
  local itemDisplayKeys = self:GetViewComponent().WBP_ItemDisplayKeys
  if nil == itemDisplayKeys then
    LogError("CharacterPreinstallPageMeditor:ChangeRoleModel", "WBP_ItemDisplayKeys is nil")
    return
  end
  if itemDisplayKeys:GetDisplayItemID() == roleSkinID then
    LogWarn("CharacterPreinstallPageMeditor:ChangeRoleModel", "role model is already exist")
    if self.currentTabPanelType ~= self:GetEnumRoleSkinType() then
      itemDisplayKeys:SwitchAnimStateMachineType(UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeaponNoLeisure)
    else
      itemDisplayKeys:SwitchAnimStateMachineType(UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeapon)
    end
    return
  end
  self.currentRoleSkinID = roleSkinID
  if self.currentTabPanelType ~= self:GetEnumRoleSkinType() then
    stateType = UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeaponNoLeisure
  end
  itemDisplayKeys:SetItemDisplayed({itemId = roleSkinID, stateMachineType = stateType})
  local character = itemDisplayKeys:GetLobbyCharacter()
  if character and self.lastRoleID == EquipRoomProxy:GetSelectRoleID() then
    character:SetIsPlaySkinEnterAnim(false)
  end
  self.lastRoleID = EquipRoomProxy:GetSelectRoleID()
end
function CharacterPreinstallPageMeditor:ChangeRoleSkin(roleSkinID)
  if self.currentTabPanelType ~= self:GetEnumRoleSkinType() then
    local roleID = EquipRoomProxy:GetSelectRoleID()
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    self:ChangeRoleModel(roleID, roleProxy:GetRoleCurrentWearAdvancedSkinID(roleID))
  else
    self:ChangeRoleModel(EquipRoomProxy:GetSelectRoleID(), roleSkinID)
  end
end
function CharacterPreinstallPageMeditor:PlayFlyEffect(data)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self.currentRoleSkinID = 0
    local dataProp = {}
    dataProp.itemId = data.flyEffectID
    dataProp.flyEffectSkinId = data.baseSkinID
    self:GetViewComponent().WBP_ItemDisplayKeys:SetItemDisplayed(dataProp)
  end
end
function CharacterPreinstallPageMeditor:SwitchDecal(decalID)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    local dataProp = {}
    dataProp.itemId = decalID
    dataProp.show3DBackground = true
    self:GetViewComponent().WBP_ItemDisplayKeys:SetItemDisplayed(dataProp)
  end
end
function CharacterPreinstallPageMeditor:ChangeRole(roleID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  self:ChangeRoleModel(roleID, roleProxy:GetRoleCurrentWearAdvancedSkinID(roleID))
end
function CharacterPreinstallPageMeditor:PlayVoiceRandomAction(actionID)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys:SetItemDisplayed({itemId = actionID, bNotChangeRole = false})
  end
end
function CharacterPreinstallPageMeditor:UpdateModuleTitle()
  local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "RoleDefault")
  self:SetModuleTitle(name)
end
function CharacterPreinstallPageMeditor:IsShowCharacterByTabType(tabType)
  if tabType == UE4.EPMFunctionTypes.EquipRoomDecal or tabType == UE4.EPMFunctionTypes.EquipRoomPersonality then
    return false
  end
  return true
end
return CharacterPreinstallPageMeditor
