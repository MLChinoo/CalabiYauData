local this = class("EquipRoomUpdateRoleEmoteListCmd", PureMVC.Command)
function this:Execute(notification)
  local roleID = notification:GetBody()
  local emoteDataMap = {}
  if nil == roleID then
    LogDebug("EquipRoomUpdateRoleEmoteListCmd.Execute", "roleID is nil")
    return
  end
  local rolePersonalityCommunicationProxy = GameFacade:RetrieveProxy(ProxyNames.RolePersonalityCommunicationProxy)
  local emoteRroxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  local allEmoteRows = emoteRroxy:GetAllRoleEmoteTableRows()
  if nil == allEmoteRows then
    LogDebug("EquipRoomUpdateRoleEmoteListCmd.Execute", "allEmoteRows is nil,roleID:%s", roleID)
    return
  end
  if allEmoteRows then
    for key, value in pairs(allEmoteRows) do
      if value then
        local emoteData = {}
        emoteData.InItemID = value.Id
        emoteData.bCanDrag = true
        emoteData.softTexture = value.IconItem
        emoteData.quality = value.Quality
        emoteData.bUnlock = emoteRroxy:IsUnlockEmote(value.Id)
        if emoteData.bUnlock then
          emoteData.bEquip = rolePersonalityCommunicationProxy:IsEquipPersonality(roleID, value.Id)
        end
        emoteData.SortID = value.SortID
        if self:IsShow(value, emoteData.bUnlock) then
          table.insert(emoteDataMap, emoteData)
        end
      end
    end
    table.sort(emoteDataMap, function(a, b)
      if a.bUnlock == b.bUnlock then
        return a.SortID > b.SortID
      elseif a.bUnlock then
        return true
      else
        return false
      end
    end)
    local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_EMOTION)
    if redDotList then
      for key, value in pairs(redDotList) do
        for k, v in pairs(emoteDataMap) do
          if v.InItemID == value.reddot_rid and value.mark then
            v.redDotID = key
          end
        end
      end
    end
  end
  LogDebug("EquipRoomUpdateRoleEmoteListCmd ", "EquipRoomUpdateRoleEmoteListCmd  Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleEmoteList, emoteDataMap)
end
function this:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return this
