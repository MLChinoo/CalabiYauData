local ApartmentMemoryPageDataCmd = class("ApartmentMemoryPageDataCmd", PureMVC.Command)
function ApartmentMemoryPageDataCmd:Execute(notification)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local ApartmentRoomWindingCorridorProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentRoomWindingCorridorProxy)
  local Body = {}
  local PromiseItemProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentPromiseItemProxy)
  Body.PledgeItemsInfo = PromiseItemProxy:GetUnlockedPromiseItem(CurrentRoleId)
  for idx, info in pairs(Body.PledgeItemsInfo) do
    info.itemCfg = PromiseItemProxy:GetPromiseItemCfg(CurrentRoleId, info.id)
  end
  local cfg = ApartmentRoomWindingCorridorProxy:GetWindingCorridorListByRoleID(CurrentRoleId)
  Body.MemoryInfo = {}
  local InData = {}
  for index, value in pairs(cfg or {}) do
    local cgId = value.SequenceId > 0 and value.SequenceId or value.AvgId
    InData = {
      SequenceId = value.SequenceId,
      AvgId = value.AvgId,
      Title = value.Title,
      Desc = value.Desc,
      UnlockTitle = value.Unlocktitle,
      UnlockTips = value.UnlockTips,
      MemoryPicture = value.MemoryPicture,
      bIsUnLock = ApartmentRoomWindingCorridorProxy:IsUnlockWindingCorridor(CurrentRoleId, cgId),
      ReadState = ApartmentRoomWindingCorridorProxy:GetMemoryReadState(CurrentRoleId, cgId)
    }
    Body.MemoryInfo[index] = InData
  end
  GameFacade:SendNotification(NotificationDefines.SetApartmentMemoryPageData, Body)
end
return ApartmentMemoryPageDataCmd
