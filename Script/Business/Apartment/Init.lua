local M = class("Init", PureMVC.ModuleInit)
M.Proxys = {
  {
    Name = ProxyNames.ApartmentGiftProxy,
    Path = "Business/Apartment/Proxies/ApartmentGiftProxy"
  },
  {
    Name = ProxyNames.ApartmentContractProxy,
    Path = "Business/Apartment/Proxies/ApartmentContractProxy"
  },
  {
    Name = ProxyNames.ApartmentStateMachineProxy,
    Path = "Business/Apartment/Proxies/ApartmentStateMachineProxy"
  },
  {
    Name = ProxyNames.ApartmentConditionProxy,
    Path = "Business/Apartment/Proxies/ApartmentConditionProxy"
  },
  {
    Name = ProxyNames.ApartmentStateMachineConfigProxy,
    Path = "Business/Apartment/Proxies/ApartmentStateMachineConfigProxy"
  },
  {
    Name = ProxyNames.ApartmentRoomProxy,
    Path = "Business/Apartment/Proxies/ApartmentRoomProxy"
  },
  {
    Name = ProxyNames.ApartmentRoomTouchProxy,
    Path = "Business/Apartment/Proxies/ApartmentRoomTouchProxy"
  },
  {
    Name = ProxyNames.ApartmentRoomWindingCorridorProxy,
    Path = "Business/Apartment/Proxies/ApartmentRoomWindingCorridorProxy"
  },
  {
    Name = ProxyNames.ApartmentTLogProxy,
    Path = "Business/Apartment/Proxies/ApartmentTLogProxy"
  },
  {
    Name = ProxyNames.ApartmentPromiseItemProxy,
    Path = "Business/Apartment/Proxies/ApartmentPromiseItemProxy"
  }
}
M.Commands = {
  {
    Name = NotificationDefines.PMApartmentMainCmd,
    Path = "Business/Apartment/Commands/PMApartmentMainCmd"
  },
  {
    Name = NotificationDefines.ReqApartmentPromisePageData,
    Path = "Business/Apartment/Commands/ApartmentPromisePageDataCmd"
  },
  {
    Name = NotificationDefines.ReqApartmentGiftPageData,
    Path = "Business/Apartment/Commands/ApartmentGiftPageDataCmd"
  },
  {
    Name = NotificationDefines.ReqApartmentInformationPageData,
    Path = "Business/Apartment/Commands/ApartmentInformationPageDataCmd"
  },
  {
    Name = NotificationDefines.ReqApartmentMemoryPageData,
    Path = "Business/Apartment/Commands/ApartmentMemoryPageDataCmd"
  },
  {
    Name = NotificationDefines.ApartmentRoleInfoChangedCmd,
    Path = "Business/Apartment/Commands/ApartmentRoleInfoChangedCmd"
  }
}
return M
