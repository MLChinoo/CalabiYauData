local EquipRoomProxy = class("EquipRoomProxy", PureMVC.Proxy)
function EquipRoomProxy:OnRegister()
  EquipRoomProxy.super.OnRegister(self)
  self.currentSelectRoleID = nil
  self.currentWeaponSlotData = {}
end
function EquipRoomProxy:OnRemove()
  LogDebug("EquipRoomProxy", "OnRemove")
  EquipRoomProxy.super.OnRemove(self)
end
function EquipRoomProxy:SetSelectRoleID(roleID)
  self.currentSelectRoleID = roleID
end
function EquipRoomProxy:GetSelectRoleID()
  return self.currentSelectRoleID
end
function EquipRoomProxy:SetSelectWeaponSlotData(slotType, weaponID)
  self.currentWeaponSlotData.slotType = slotType
  self.currentWeaponSlotData.weaponID = weaponID
end
function EquipRoomProxy:GetSelectWeaponSlotData()
  return self.currentWeaponSlotData
end
return EquipRoomProxy
