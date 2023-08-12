local SecondaryBasePageMeditor = require("Business/EquipRoom/Mediators/SecondaryBasePageMeditor/SecondaryBasePageMeditor")
local WeaponSkinPageMeditor = class("WeaponSkinPageMeditor", SecondaryBasePageMeditor)
local EquipRoomProxy
function WeaponSkinPageMeditor:ListNotificationInterests()
  local list = WeaponSkinPageMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateWeaponSkinModel)
  return list
end
function WeaponSkinPageMeditor:OnRegister()
  WeaponSkinPageMeditor.super.OnRegister(self)
  if self:GetViewComponent().onCtrImgPressedEvent then
    self:GetViewComponent().onCtrImgPressedEvent:Add(self.OnCtrImgPressed, self)
  end
  if self:GetViewComponent().onCtrImgReleasedEvent then
    self:GetViewComponent().onCtrImgReleasedEvent:Add(self.OnCtrImgReleased, self)
  end
  EquipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
end
function WeaponSkinPageMeditor:OnRemove()
  WeaponSkinPageMeditor.super.OnRemove(self)
  if self:GetViewComponent().onCtrImgPressedEvent then
    self:GetViewComponent().onCtrImgPressedEvent:Remove(self.OnCtrImgPressed, self)
  end
  if self:GetViewComponent().onCtrImgReleasedEvent then
    self:GetViewComponent().onCtrImgReleasedEvent:Remove(self.OnCtrImgReleased, self)
  end
end
function WeaponSkinPageMeditor:HandleNotification(notify)
  WeaponSkinPageMeditor.super.HandleNotification(self, notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateWeaponSkinModel then
    self:ChangeWeaponSkin(notifyBody)
  end
end
function WeaponSkinPageMeditor:OnViewComponentPagePreOpen(luaData, originOpenData)
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Normal
  local soltData = EquipRoomProxy:GetSelectWeaponSlotData()
  if soltData then
    self:GetViewComponent():SelectyWeaponSkinTab(soltData.slotType)
  else
    self:SelectPrimaryWeaponTab()
  end
  self:GetRoleList()
  self:GetViewComponent():InitRedDot()
end
function WeaponSkinPageMeditor:SelectPrimaryWeaponTab()
  self:GetViewComponent():SelectPrimaryWeaponTab()
end
function WeaponSkinPageMeditor:SelectSecondaryWeaponTab()
  self:GetViewComponent():SelectSecondaryWeaponTab()
end
function WeaponSkinPageMeditor:OnCtrImgPressed()
  if self.bCtrimg == nil or self.bCtrimg == false then
    self.bCtrimg = true
    if self.pageViewMode == GlobalEnumDefine.EPageModelPreviewType.Normal then
      if self.currentTabPanel then
        self.currentTabPanel:PlayColseAnimation()
      end
      self:HideRoleListPanel()
    end
  end
end
function WeaponSkinPageMeditor:OnCtrImgReleased()
  if self.bCtrimg == true then
    self.bCtrimg = false
    if self.pageViewMode == GlobalEnumDefine.EPageModelPreviewType.Normal and self.currentTabPanel then
      self.currentTabPanel:PlayOpenAnimation()
    end
  end
end
function WeaponSkinPageMeditor:OnSelectRole(roleID)
  WeaponSkinPageMeditor.super.OnSelectRole(self, roleID)
  if EquipRoomProxy:GetSelectRoleID() == roleID then
    LogDebug("WeaponSkinPageMeditor:OnSelectRole", "Role already seleced,ID:%s", roleID)
    return
  end
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Normal
  EquipRoomProxy:SetSelectRoleID(roleID)
  self:UpdateCurrentTabPanelByRoleID(roleID)
  self:GetViewComponent():UpdateRedDot()
end
function WeaponSkinPageMeditor:OnChangeTab(tabType)
  if self:GetCurrentTabType() == tabType then
    LogWarn("WeaponSkinPageMeditor:OnChangeTab", "TabPanel already open,TabPanelType:%s", tabType)
    return
  end
  WeaponSkinPageMeditor.super.OnChangeTab(self, tabType)
end
function WeaponSkinPageMeditor:EnterPreviewMode()
  if self.pageViewMode == GlobalEnumDefine.EPageModelPreviewType.Preview then
    return
  end
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Preview
  if self.currentTabPanel then
    self.currentTabPanel:PlayColseAnimation()
  end
  self:HideRoleListPanel()
end
function WeaponSkinPageMeditor:QuitPreviewMode()
  if self.pageViewMode == GlobalEnumDefine.EPageModelPreviewType.Normal then
    return
  end
  self.pageViewMode = GlobalEnumDefine.EPageModelPreviewType.Normal
  if self.currentTabPanel then
    self.currentTabPanel:PlayOpenAnimation()
  end
end
function WeaponSkinPageMeditor:ChangeWeaponSkin(weaponID)
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys:SetItemDisplayed({itemId = weaponID})
  end
end
function WeaponSkinPageMeditor:PlayChangeWeaponEffect()
  if self:GetViewComponent().ChangeWeaponEffectObjectRef then
    local effectScale = self:GetViewComponent().ChangeWeaponEffectScale
    local weaponPos = UE4.UPMLuaBridgeBlueprintLibrary.GetEquipRoomWeaponPosition(self:GetViewComponent())
    UE4.UGameplayStatics.SpawnEmitterAtLocation(self:GetViewComponent(), self:GetViewComponent().ChangeWeaponEffectObjectRef, weaponPos, UE4.FRotator(), UE4.FVector(effectScale, effectScale, effectScale), true, UE4.EPSCPoolMethod.None, true)
  end
end
function WeaponSkinPageMeditor:UpdateModuleTitle()
  local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "WeaponSkin")
  self:SetModuleTitle(name)
end
return WeaponSkinPageMeditor
