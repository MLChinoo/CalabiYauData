local EquipRoomUpdateRoleListCmd = class("EquipRoomUpdateRoleListCmd", PureMVC.Command)
function EquipRoomUpdateRoleListCmd:Execute(notification)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleTeamProxy = GameFacade:RetrieveProxy(ProxyNames.RoleTeamProxy)
  local roleTableDatas = roleProxy:GetAllRoleCfgs()
  local roleData = {}
  for k, v in pairs(roleTableDatas) do
    if v then
      local itemData = {}
      itemData.InItemID = v.RoleId
      itemData.SortId = v.SortId
      itemData.bUnlock = roleProxy:IsUnlockRole(v.RoleId)
      self:UpdateCafePrivilegeData(itemData)
      local roleSkin = roleProxy:GetRoleSkin(roleProxy:GetRoleCurrentWearAdvancedSkinID(v.RoleId))
      if roleSkin then
        itemData.softTexture = roleSkin.IconRoleSelect
      end
      local roleProfileTableData = roleProxy:GetRoleProfile(v.RoleId)
      if roleProfileTableData then
        itemData.itemName = roleProfileTableData.NameEn
        local roleProfessionData = roleProxy:GetRoleProfession(roleProfileTableData.Profession)
        if roleProfessionData then
          itemData.professSoftTexture = roleProfessionData.IconProfession
          itemData.professColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(roleProfessionData.Color2))
          local roleTeamData = roleTeamProxy:GetTeamTableRow(roleProfileTableData.Team)
          if roleTeamData then
            itemData.teamColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(roleTeamData.Color))
          end
        end
      end
      if self:IsShow(v, itemData.bUnlock) then
        table.insert(roleData, itemData)
      end
    end
  end
  self:SortRoleList(roleData)
  local body = {}
  body.ItemData = roleData
  body.defaultSelectIndex = notification.body
  LogDebug("EquipRoomUpdateRoleListCmd", "EquipRoomUpdateRoleListCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleList, body)
end
function EquipRoomUpdateRoleListCmd:SortRoleList(roleData)
  if roleData then
    table.sort(roleData, function(a, b)
      return a.SortId < b.SortId
    end)
  end
end
function EquipRoomUpdateRoleListCmd:UpdateCafePrivilegeData(itemData)
  GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):UpdateCafePrivilegeData(itemData)
end
function EquipRoomUpdateRoleListCmd:IsShow(row, bUnlock)
  return GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):IsShow(row, bUnlock)
end
return EquipRoomUpdateRoleListCmd
