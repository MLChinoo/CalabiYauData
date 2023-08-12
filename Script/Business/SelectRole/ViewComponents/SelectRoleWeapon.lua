local SelectRoleWeaponMediator = require("Business/SelectRole/Mediators/SelectRoleWeaponMediator")
local SelectRoleWeapon = class("SelectRoleWeapon", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function SelectRoleWeapon:ListNeededMediators()
  return {SelectRoleWeaponMediator}
end
function SelectRoleWeapon:InitializeLuaEvent()
  self.OnClickWeaponSoltItemEvent = LuaEvent.new()
  self.OnClickWeaponListItemEvent = LuaEvent.new()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Team then
    self.EquipWeaponPanel.VerticalBox_Grenade:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.EquipWeaponPanel.VerticalBox_Grenade:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SelectRoleWeapon:OnClickWeaponListItem(data)
  self.OnClickWeaponListItemEvent(data)
end
function SelectRoleWeapon:OnClickSoltItem(soltItem)
  self.OnClickWeaponSoltItemEvent(soltItem)
end
function SelectRoleWeapon:Construct()
  if self.EquipWeaponPanel then
    self.EquipWeaponPanel.OnClickSoltItemEvent:Add(self.OnClickSoltItem, self)
    self.EquipWeaponPanel.OnClickListItemEvent:Add(self.OnClickWeaponListItem, self)
  end
  SelectRoleWeapon.super.Construct(self)
end
function SelectRoleWeapon:Destruct()
  if self.EquipWeaponPanel then
    self.EquipWeaponPanel.OnClickSoltItemEvent:Remove(self.OnClickSoltItem, self)
    self.EquipWeaponPanel.OnClickListItemEvent:Remove(self.OnClickWeaponListItem, self)
  end
  SelectRoleWeapon.super.Destruct(self)
end
function SelectRoleWeapon:HideWeaponListPanel()
  self.EquipWeaponPanel:HideWeaponListPanel()
end
function SelectRoleWeapon:ShowWeaponListPanel()
  self.EquipWeaponPanel:ShowWeaponListPanel()
end
function SelectRoleWeapon:GetWeaponListPanelVisibility()
  return self.EquipWeaponPanel.WeaponListPanel:GetVisibility()
end
function SelectRoleWeapon:UpdateView(NewRoleId)
  LogDebug("SelectRoleWeapon", "UpdateView NewRoleId=%s", NewRoleId)
  self.RoleId = NewRoleId
  self:HideWeaponListPanel()
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponEquipSoltCmd, self.RoleId)
  self.EquipWeaponPanel:DefalutSelectSoltItem(UE4.EWeaponSlotTypes.WeaponSlot_Primary)
end
return SelectRoleWeapon
