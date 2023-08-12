local this = class("EquipRoomUpdateRoleCommunicationActionListCmd", PureMVC.Command)
function this:Execute(notification)
  local roleID = notification:GetBody()
  local actionDataMap = {}
  if nil == roleID then
    LogDebug("EquipRoomUpdateRoleCommunicationActionListCmd.Execute", "roleID is nil")
    return
  end
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleActionIDList = roleProxy:GetRoleCommunicationActionIDList(roleID)
  if nil == roleActionIDList then
    LogDebug("EquipRoomUpdateRoleCommunicationActionListCmd.Execute", "roleActionIDList is nil,roleID:%s", roleID)
    return
  end
  if roleActionIDList then
    for key, value in pairs(roleActionIDList) do
      local actionRow = roleProxy:GetRoleAction(value)
      if actionRow then
        local actionData = {}
        actionData.InItemID = value
        actionData.bCanDrag = true
        actionData.softTexture = actionRow.IconItem
        actionData.bUnlock = roleProxy:IsUnlockRoleAction(value)
        if actionData.bUnlock then
          actionData.bEquip = roleProxy:IsEquipRoleCommunicationItem(roleID, value)
        end
        actionData.SortID = actionRow.SortID
        actionData.quality = actionRow.Quality
        if self:IsShow(actionRow, actionData.bUnlock) then
          table.insert(actionDataMap, actionData)
        end
      end
    end
    table.sort(actionDataMap, function(a, b)
      if a.bUnlock == b.bUnlock then
        return a.SortID > b.SortID
      elseif a.bUnlock then
        return true
      else
        return false
      end
    end)
    local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_ACTION)
    if redDotList then
      for key, value in pairs(redDotList) do
        for k, v in pairs(actionDataMap) do
          if v.InItemID == value.reddot_rid and value.mark then
            v.redDotID = key
          end
        end
      end
    end
  end
  LogDebug("EquipRoomUpdateRoleCommunicationActionListCmd", "EquipRoomUpdateRoleCommunicationActionListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleCommunicationActionList, actionDataMap)
end
function this:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return this
