local EquipRoomUpdateRoleInfoPanelCmd = class("EquipRoomUpdateRoleInfoPanelCmd", PureMVC.Command)
function EquipRoomUpdateRoleInfoPanelCmd:Execute(notification)
  if notification.body then
    local notificationBody = {}
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local roleProfileRowData = roleProxy:GetRoleProfile(notification.body)
    if roleProfileRowData then
      notificationBody.roleName = roleProfileRowData.NameCn
      notificationBody.roleTitle = roleProfileRowData.Title
      local roleProfessRowData = roleProxy:GetRoleProfession(roleProfileRowData.Profession)
      if roleProfessRowData then
        notificationBody.professSoftTexture = roleProfessRowData.IconProfession
        notificationBody.professColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(roleProfileRowData.Color2))
      end
    end
    LogDebug("EquipRoomUpdateRoleInfoPanelCmd", "EquipRoomUpdateRoleInfoPanelCmd Execute")
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleInfoPanel, notificationBody)
  else
    LogDebug("EquipRoomUpdateRoleInfoPanelCmd", "notification.body is nil")
  end
end
return EquipRoomUpdateRoleInfoPanelCmd
