local this = class("EquipRoomUpdateRoleFlyEffectListCmd", PureMVC.Command)
function this:Execute(notification)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local roleFlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
  local allFlyEffectRowTableCfg = roleFlyEffectProxy:GetAllFlyEffectRowTableCfg()
  if nil == allFlyEffectRowTableCfg then
    LogError("EquipRoomUpdateRoleFlyEffectListCmd.Execute", "allFlyEffectRowTableCfg is nil")
    return
  end
  local flyEffectData = {}
  for key, value in pairs(allFlyEffectRowTableCfg) do
    local fxFlyingTableRow = value
    if fxFlyingTableRow then
      local singleData = {}
      singleData.itemName = fxFlyingTableRow.Name
      singleData.InItemID = fxFlyingTableRow.Id
      singleData.bUnlock = roleFlyEffectProxy:IsUnlockFlyEffect(fxFlyingTableRow.Id)
      singleData.bEquip = roleFlyEffectProxy:IsEquipFlyEffect(fxFlyingTableRow.Id)
      singleData.quality = fxFlyingTableRow.SortId
      local qulityRow = itemProxy:GetItemQualityConfig(fxFlyingTableRow.Quality)
      if qulityRow then
        singleData.qulityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(qulityRow.Color))
        singleData.qulityName = qulityRow.Desc
      end
      table.insert(flyEffectData, singleData)
    end
  end
  table.sort(flyEffectData, function(a, b)
    if a.bEquip == b.bEquip then
      if a.bUnlock == b.bUnlock then
        return a.quality > b.quality
      elseif a.bUnlock then
        return true
      else
        return false
      end
    else
      if a.bEquip == true then
        return true
      end
      return false
    end
  end)
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_FLUTTERING)
  if redDotList then
    for key, value in pairs(redDotList) do
      for k, v in pairs(flyEffectData) do
        if v.InItemID == value.reddot_rid and value.mark then
          v.redDotID = key
        end
      end
    end
  end
  LogDebug("EquipRoomUpdateRoleFlyEffectListCmd", "EquipRoomUpdateRoleFlyEffectListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleFlyEffectList, flyEffectData)
end
return this
