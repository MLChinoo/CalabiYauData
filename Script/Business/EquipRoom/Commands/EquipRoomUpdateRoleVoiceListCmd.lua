local this = class("EquipRoomUpdateRoleVoiceListCmd", PureMVC.Command)
function this:Execute(notification)
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  local roleID = equiproomProxy:GetSelectRoleID()
  local voiceDataMap = {}
  if nil == roleID then
    LogDebug("EquipRoomUpdateRoleVoiceListCmd.Execute", "roleID is nil")
    return
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local roleVoiceIDList = roleProxy:GetRoleVoiceIDList(roleID)
  if nil == roleVoiceIDList then
    LogDebug("EquipRoomUpdateRoleVoiceListCmd.Execute", "roleVoiceIDList is nil,roleID:%s", roleID)
    return
  end
  if roleVoiceIDList then
    for key, value in pairs(roleVoiceIDList) do
      local voiceRow = roleProxy:GetRoleVoice(value)
      if voiceRow then
        local skinData = {}
        skinData.itemName = voiceRow.VoiceName
        skinData.InItemID = value
        skinData.SortId = voiceRow.SortId
        skinData.bUnlock = roleProxy:IsUnlockRoleVoice(value)
        self:UpdateCafePrivilegeData(skinData)
        local qulityRow = itemProxy:GetItemQualityConfig(voiceRow.Quality)
        if qulityRow then
          skinData.qulityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(qulityRow.Color))
          skinData.qulityName = qulityRow.Desc
        end
        if self:IsShow(voiceRow, skinData.bUnlock) then
          table.insert(voiceDataMap, skinData)
        end
      end
    end
    table.sort(voiceDataMap, function(a, b)
      if a.bUnlock == b.bUnlock then
        return a.SortId > b.SortId
      elseif a.bUnlock then
        return true
      else
        return false
      end
    end)
    local redDotList = GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):GetAllLocalVoiceRedDotMap()
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
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleVoiceList, voiceDataMap)
end
function this:UpdateCafePrivilegeData(itemData)
  GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):UpdateCafePrivilegeData(itemData)
end
function this:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return this
