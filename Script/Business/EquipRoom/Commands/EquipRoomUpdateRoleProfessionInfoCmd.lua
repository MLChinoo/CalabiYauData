local EquipRoomUpdateRoleProfessionInfoCmd = class("EquipRoomUpdateRoleProfessionInfoCmd", PureMVC.Command)
function EquipRoomUpdateRoleProfessionInfoCmd:Execute(notification)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local itemData = {}
  local roleProfileTableData = roleProxy:GetRoleProfile(notification.body)
  if roleProfileTableData then
    itemData.itemName = roleProfileTableData.NameCn
    itemData.roleDesc = roleProfileTableData.Desc
    itemData.roleTitle = roleProfileTableData.Title
    local roleProfessionData = roleProxy:GetRoleProfession(roleProfileTableData.Profession)
    if roleProfessionData then
      itemData.professSoftTexture = roleProfessionData.IconProfession
      itemData.professColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(roleProfessionData.Color1))
      itemData.professNameCn = roleProfessionData.NameCn
      itemData.professDesc = roleProfessionData.IntroduceCn
    end
  end
  LogDebug("EquipRoomUpdateRoleProfessionInfoCmd", "EquipRoomUpdateRoleProfessionInfoCmd Execute")
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleProfessionInfo, itemData)
end
return EquipRoomUpdateRoleProfessionInfoCmd
