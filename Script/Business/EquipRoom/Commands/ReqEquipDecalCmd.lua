local this = class("ReqEquipDecalCmd", PureMVC.Command)
function this:Execute(notification)
  if notification:GetBody() then
    local equipRoomPrepareProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy)
    equipRoomPrepareProxy:ReqEquipDecal(notification:GetBody().decalID, notification:GetBody().useState, notification:GetBody().roleID)
  else
    LogError("ReqEquipDecalCmd", "notification.body is nil")
  end
end
return this
