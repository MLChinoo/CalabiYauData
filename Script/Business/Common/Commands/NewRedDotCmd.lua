local NewRedDotCmd = class("NewRedDotCmd", PureMVC.Command)
function NewRedDotCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.RedDot.NewRedDotCmd then
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_VCARD then
      GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):AddRedDot(notification:GetBody())
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_REACH_ACHIEVEMENT then
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_ITEM then
      GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):InitRedDot()
      local redDotInfo = notification:GetBody()
      if redDotInfo then
        GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):AddWeaponSkinRedDot(redDotInfo)
        GameFacade:SendNotification(NotificationDefines.ReqApartmentGiftPageData)
      end
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_DECAL then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):AddDecalRedDot(notification:GetBody())
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_EMOTION then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):AddEmoteRedDot(notification:GetBody())
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_ROLE_SKIN then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):AddRoleSkinRedDot(notification:GetBody())
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_VOICE then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):AddRoleVoiceRedDot(notification:GetBody())
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_FLUTTERING then
    end
    if notification:GetType() == Pb_ncmd_cs.EReddotType.ReddotType_NEW_ACTION then
      GameFacade:RetrieveProxy(ProxyNames.EquipRoomRedDotProxy):AddRoleActionRedDot(notification:GetBody())
    end
  end
end
return NewRedDotCmd
