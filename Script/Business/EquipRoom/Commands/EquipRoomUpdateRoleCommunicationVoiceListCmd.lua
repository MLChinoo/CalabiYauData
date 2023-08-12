local this = class("EquipRoomUpdateRoleCommunicationVoiceListCmd", PureMVC.Command)
function this:Execute(notification)
  local roleID = notification:GetBody()
  local voiceDataMap = {}
  if nil == roleID then
    LogDebug("EquipRoomUpdateRoleCommunicationVoiceListCmd.Execute", "roleID is nil")
    return
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleVoiceIDList = roleProxy:GetRoleCommunicationVoiceIDList(roleID)
  if nil == roleVoiceIDList then
    LogDebug("EquipRoomUpdateRoleCommunicationVoiceListCmd.Execute", "roleVoiceIDList is nil,roleID:%s", roleID)
    return
  end
  if roleVoiceIDList then
    for key, value in pairs(roleVoiceIDList) do
      local voiceRow = roleProxy:GetRoleVoice(value)
      if voiceRow then
        local skinData = {}
        skinData.bCanDrag = true
        skinData.itemName = voiceRow.VoiceName
        skinData.InItemID = value
        skinData.bUnlock = roleProxy:IsUnlockRoleVoice(value)
        self:UpdateCafePrivilegeData(skinData)
        skinData.bEquip = roleProxy:IsEquipRoleCommunicationItem(roleID, value)
        if self:IsShow(voiceRow, skinData.bUnlock) then
          table.insert(voiceDataMap, skinData)
        end
      end
    end
    table.sort(voiceDataMap, function(a, b)
      if a.bUnlock == b.bUnlock then
        return a.InItemID < b.InItemID
      elseif a.bUnlock then
        return true
      else
        return false
      end
    end)
    local redDotList = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):GetLocalCommunicationRedDotMap()
    if redDotList then
      for key, value in pairs(redDotList) do
        for k, v in pairs(voiceDataMap) do
          if v.InItemID == value.reddot_rid then
            v.redDotID = key
          end
        end
      end
    end
  end
  LogDebug("EquipRoomUpdateRoleCommunicationVoiceListCmd", "EquipRoomUpdateRoleCommunicationVoiceListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleCommunicationVoiceList, voiceDataMap)
end
function this:UpdateCafePrivilegeData(itemData)
  GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):UpdateCafePrivilegeData(itemData)
end
function this:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return this
