local this = class("EquipRoomUpdateEquipCommunicationListCmd", PureMVC.Command)
local RoleProxy
function this:Execute(notification)
  local roleID = notification:GetBody()
  if nil == roleID then
    LogWarn("EquipRoomUpdateEquipCommunicationListCmd.Execute", "roleID is nil")
    return
  end
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local bUnlockRole = RoleProxy:IsOwnRole(roleID)
  local equipData = {}
  if bUnlockRole then
    local equipCommunicationList = RoleProxy:GetRoleEquipCommunication(roleID)
    if nil == equipCommunicationList then
      LogWarn("EquipRoomUpdateEquipCommunicationListCmd.Execute", "equipCommunicationList is nil")
    end
    if equipCommunicationList then
      for key, value in pairs(equipCommunicationList) do
        if value then
          local singleData = {}
          singleData.itemID = value.id
          singleData.itemType = value.communication_type
          self:GetVoiceName(singleData)
          equipData[key] = singleData
        end
      end
    end
  else
    LogDebug("EquipRoomUpdateEquipCommunicationListCmd.Execute", "roleID: %s ,is not unlock", tostring(roleID))
  end
  LogDebug("EquipRoomUpdateEquipCommunicationListCmd", "EquipRoomUpdateEquipCommunicationListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateEquipCommunicationList, equipData)
end
function this:GetActionIcon(singleData)
  local roleActionRow = RoleProxy:GetRoleAction(singleData.itemID)
  if roleActionRow then
    singleData.sortTexture = roleActionRow.IconItem
  end
end
function this:GetVoiceName(singleData)
  local roleVoiceRow = RoleProxy:GetRoleVoice(singleData.itemID)
  if roleVoiceRow then
    singleData.itemName = roleVoiceRow.VoiceName
  end
end
return this
