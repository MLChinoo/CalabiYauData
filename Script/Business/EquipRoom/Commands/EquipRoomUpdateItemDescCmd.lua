local EquipRoomUpdateItemDescCmd = class("EquipRoomUpdateItemDescCmd", PureMVC.Command)
function EquipRoomUpdateItemDescCmd:Execute(notification)
  local notifyBody = notification:GetBody()
  if nil == notifyBody then
    return
  end
  local itemType = notifyBody.itemType
  local data = {}
  if itemType == UE4.EItemIdIntervalType.RoleSkin then
    self:GetRoleSkinDesc(notifyBody.itemID, data)
  elseif itemType == UE4.EItemIdIntervalType.RoleVoice then
    self:GetRoleVoiceDesc(notifyBody.itemID, data)
  elseif itemType == UE4.EItemIdIntervalType.RoleAction then
    self:GetRoleActionDesc(notifyBody.itemID, data)
  elseif itemType == UE4.EItemIdIntervalType.Weapon then
    self:GetWeaponDesc(notifyBody, data)
  elseif itemType == UE4.EItemIdIntervalType.FlyEffect then
    self:GetFlyEffectDesc(notifyBody, data)
  elseif itemType == UE4.EItemIdIntervalType.Decal then
    self:GetDecalDesc(notifyBody, data)
  elseif itemType == UE4.EItemIdIntervalType.RoleEmote then
    self:GetRoleEmoteDesc(notifyBody, data)
  end
  LogDebug("EquipRoomUpdateItemDescCmd", "EquipRoomUpdateItemDescCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateItemDesc, data)
end
function EquipRoomUpdateItemDescCmd:GetRoleSkinDesc(roleSkinID, data)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleSkinRow = roleProxy:GetRoleSkin(roleSkinID)
  if roleSkinRow then
    data.itemName = roleSkinRow.NameCn
    data.itemDesc = roleSkinRow.Description
    self:GetQuality(roleSkinRow.Quality, data)
    self:GetHideStory(roleSkinRow, data)
  end
end
function EquipRoomUpdateItemDescCmd:GetRoleVoiceDesc(roleVoiceID, data)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleVoiceRow = roleProxy:GetRoleVoice(roleVoiceID)
  if roleVoiceRow then
    data.itemName = roleVoiceRow.VoiceName
    data.itemDesc = roleVoiceRow.Content
    if roleVoiceRow.VoiceType == UE4.ETableVoiceType.Trigger then
      data.qualityID = roleVoiceRow.Quality
    end
  end
end
function EquipRoomUpdateItemDescCmd:GetRoleActionDesc(roleActionID, data)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleActionRow = roleProxy:GetRoleAction(roleActionID)
  if roleActionRow then
    data.itemName = roleActionRow.ActionName
    data.itemDesc = roleActionRow.Content
  end
end
function EquipRoomUpdateItemDescCmd:GetWeaponDesc(body, data)
  local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  local weaponRow = weaponProxy:GetWeapon(body.itemID)
  if weaponRow then
    data.itemName = weaponRow.Name
    data.itemDesc = weaponRow.Tips
    data.softTexture = self:GetWeaponRoleHeadIcon(body.roleID)
    local defaultWeapon = weaponProxy:GetDefaultWeaponSkinBySubType(weaponRow.SubType)
    if defaultWeapon then
      data.ownerName = defaultWeapon.Name
    end
  end
end
function EquipRoomUpdateItemDescCmd:GetWeaponRoleHeadIcon(roleID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local skinID = roleProxy:GetRoleCurrentWearSkinID(roleID)
  local roleSkinRow = roleProxy:GetRoleSkin(skinID)
  if roleSkinRow then
    return roleSkinRow.IconRoleSelectedPrebattle
  end
  return nil
end
function EquipRoomUpdateItemDescCmd:GetFlyEffectDesc(body, data)
  local roleFlyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
  local flyEffectRow = roleFlyEffectProxy:GetFlyEffectRowTableCfg(body.itemID)
  if flyEffectRow then
    data.itemName = flyEffectRow.Name
    data.itemDesc = flyEffectRow.Desc
    self:GetQuality(flyEffectRow.Quality, data)
  end
end
function EquipRoomUpdateItemDescCmd:GetDecalDesc(body, data)
  local equipRoomPaintProxy = GameFacade:RetrieveProxy(ProxyNames.DecalProxy)
  local decalRowData = equipRoomPaintProxy:GetDecalTableDataByItemID(body.itemID)
  if decalRowData then
    data.itemName = decalRowData.Name
    data.itemDesc = decalRowData.Desc
    self:GetQuality(decalRowData.Quality, data)
  end
end
function EquipRoomUpdateItemDescCmd:GetRoleEmoteDesc(body, data)
  local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  local rowData = roleEmoteProxy:GetRoleEmoteTableRow(body.itemID)
  if rowData then
    data.itemName = rowData.Name
    data.itemDesc = rowData.Desc
    self:GetQuality(rowData.Quality, data)
  end
end
function EquipRoomUpdateItemDescCmd:GetHideStory(roleSkinRow, data)
  if roleSkinRow.Quality < UE4.ESkinQualityType.Orange then
    return
  end
  data.bHaveHideStory = true
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local bUnlock = roleProxy:IsUnlockRoleSkin(roleSkinRow.RoleSkinId)
  if bUnlock then
    data.storyTitle = roleSkinRow.TskinTitle
    data.storyDesc = roleSkinRow.TskinDescription
  end
end
function EquipRoomUpdateItemDescCmd:GetQuality(quality, data)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local qulityRow = itemProxy:GetItemQualityConfig(quality)
  if qulityRow then
    data.qualityName = qulityRow.Desc
    data.qualityColor = qulityRow.Color
  end
end
return EquipRoomUpdateItemDescCmd
