local this = class("EquipRoomUpdatePersonalityRouletteCmd", PureMVC.Command)
local RoleProxy, RolePersonalityProxy
function this:Execute(notification)
  local roleID = notification:GetBody()
  if nil == roleID then
    LogWarn("EquipRoomUpdatePersonalityRouletteCmd.Execute", "roleID is nil")
    return
  end
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  RolePersonalityProxy = GameFacade:RetrieveProxy(ProxyNames.RolePersonalityCommunicationProxy)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local bUnlockRole = RoleProxy:IsOwnRole(roleID)
  local equipData = {}
  if bUnlockRole then
    local equipRouletteSeverDataArray = RolePersonalityProxy:GetRoleRouletteSeverData(roleID)
    if nil == equipRouletteSeverDataArray then
      LogWarn("EquipRoomUpdatePersonalityRouletteCmd.Execute", "equipRouletteSeverDataArray is nil")
    end
    if equipRouletteSeverDataArray then
      for key, value in pairs(equipRouletteSeverDataArray) do
        if value then
          local singleData = {}
          singleData.itemID = value.id
          singleData.itemType = itemProxy:GetItemIdIntervalType(singleData.itemID)
          if singleData.itemType == UE4.EItemIdIntervalType.RoleAction then
            self:GetActionIcon(singleData)
          elseif singleData.itemType == UE4.EItemIdIntervalType.RoleEmote then
            self:GetEmoteIcon(singleData)
          end
          equipData[key] = singleData
        end
      end
    end
  else
    LogDebug("EquipRoomUpdatePersonalityRouletteCmd.Execute", "roleID: %s ,is not unlock", tostring(roleID))
  end
  LogDebug("EquipRoomUpdatePersonalityRouletteCmd", "EquipRoomUpdatePersonalityRouletteCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdatePersonalityRoulette, equipData)
end
function this:GetActionIcon(singleData)
  local roleActionRow = RoleProxy:GetRoleAction(singleData.itemID)
  singleData.ItemIdIntervalType = UE4.EItemIdIntervalType.RoleAction
  if roleActionRow then
    singleData.sortTexture = roleActionRow.IconItem
  end
end
function this:GetEmoteIcon(singleData)
  local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  local Row = roleEmoteProxy:GetRoleEmoteTableRow(singleData.itemID)
  singleData.ItemIdIntervalType = UE4.EItemIdIntervalType.RoleEmote
  if Row then
    singleData.sortTexture = Row.IconItem
  end
end
return this
