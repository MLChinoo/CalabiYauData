local KaNavigationProxy = class("KaNavigationProxy", PureMVC.Proxy)
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function KaNavigationProxy:GetCurrentRoleId()
  return self.DefaultRoleId
end
function KaNavigationProxy:ReqUpdateRole(Data)
  self.Page = Data.Page
  self.NewRoleId = Data.RoleId
  ViewMgr:OpenPage(self.Page, UIPageNameDefine.PendingPage, nil, {Time = 5})
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SET_PLAYERINFO_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_set_playerinfo_req, {
    show_role_id = Data.RoleId
  }))
end
function KaNavigationProxy:GetIsFirstEnterRoom(RoleId)
  if RoleId <= 0 then
    return false
  end
  local Roleskin = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomProxy):GetRoleWearSkinID(RoleId)
  local value = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy):GetValueByRoleIDAndKey(RoleId, Roleskin)
  local role = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRole(RoleId)
  if role and (role.Navigation == GlobalEnumDefine.EApartmentNavigation.ShowNewGuideDefault or role.Navigation == GlobalEnumDefine.EApartmentNavigation.ShowAllDefault) then
    return false
  end
  if value == RoleAttrMap.FirstGoApartmentFlag then
    return false
  else
    return true
  end
end
function KaNavigationProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_PLAYERINFO_NTF, FuncSlot(self.OnRcvPlayerRoleInfo, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_SET_PLAYERINFO_RES, FuncSlot(self.OnRcvUpdateRole, self))
end
function KaNavigationProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_PLAYERINFO_NTF, FuncSlot(self.OnRcvPlayerRoleInfo, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_SET_PLAYERINFO_RES, FuncSlot(self.OnRcvUpdateRole, self))
end
function KaNavigationProxy:OnRcvUpdateRole(InServerData)
  local RecData = DeCode(Pb_ncmd_cs_lobby.salon_set_playerinfo_res, InServerData)
  local Valid = self.Page and ViewMgr:ClosePage(self.Page, UIPageNameDefine.PendingPage)
  if 0 ~= RecData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, RecData.code)
    return nil
  end
  local InTextContent = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "JumpPageTips")
  if GameFacade:RetrieveProxy(ProxyNames.RoomProxy):GetIsInMatch() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, InTextContent)
  end
  self.DefaultRoleId = self.NewRoleId
  if not GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):GetCurrentState() then
    local NavBarBodyTable = {
      pageType = UE4.EPMFunctionTypes.Apartment,
      exData = {bEnterNewRoleRoom = true}
    }
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
  else
    GameFacade:SendNotification(NotificationDefines.EnterCharacterApartmentRoom)
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentRoleInfoChangedCmd)
  GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):UpdateRedDotPromise()
end
function KaNavigationProxy:OnRcvPlayerRoleInfo(InServerData)
  local RecData = DeCode(Pb_ncmd_cs_lobby.salon_playerinfo_ntf, InServerData)
  if RecData.info.show_role_id == nil or 0 == RecData.info.show_role_id then
    LogError("KaNavigationProxy:OnRcvPlayerRoleInfo", "//服务器同步角色id为 0 或者空 找服务器同学, 有可能是因为旧账号")
    self.DefaultRoleId = 146
  else
    self.DefaultRoleId = RecData.info.show_role_id
  end
  GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):UpdateRedDotPromise()
end
return KaNavigationProxy
