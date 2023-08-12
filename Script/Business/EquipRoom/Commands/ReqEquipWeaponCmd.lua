local this = class("ReqEquipWeaponCmd", PureMVC.Command)
function this:Execute(notification)
  if notification:GetBody() then
    local equipData = notification:GetBody()
    local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
    equipRoomPrepareProxy:ReqEquipWeapon(equipData.roleID, equipData.itemID, equipData.weaponSoltType, equipData.advancedSkinID)
  else
    LogError("ReqEquipWeaponCmd", "notification.body is nil")
  end
end
return this
