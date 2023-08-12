local DecalProxy = class("DecalProxy", PureMVC.Proxy)
function DecalProxy:InitDecalTableData()
  self.ownedDecalDatas = {}
end
function DecalProxy:OnRegister()
  self.super:OnRegister()
  self:InitDecalTableData()
end
function DecalProxy:GetDecalTableDatas()
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  return ItemsProxy:GetDecalCfg()
end
function DecalProxy:GetDecalTableDataByItemID(itemID)
  if self:GetDecalTableDatas() == nil then
    LogError("DecalProxy", "decalCfg is nil")
    return nil
  end
  return self:GetDecalTableDatas()[tostring(itemID)]
end
function DecalProxy:UpdateOwnedDecalByServer(serverData)
  local decalID = serverData.item_id
  self.ownedDecalDatas[decalID] = serverData
  LogDebug("DecalProxy", "decalID: %s ,ServerData update", decalID)
end
function DecalProxy:IsOwnDecalByDecalID(decalID)
  if self.ownedDecalDatas[tonumber(decalID)] then
    return true
  end
  return false
end
function DecalProxy:GetDecalUIDByDecalID(decalID)
  local serverData = self.ownedDecalDatas[decalID]
  if serverData then
    return serverData.item_uuid
  end
  LogError("DecalProxy", "decalID: %s ,ServerData is nil", decalID)
  return nil
end
function DecalProxy:GetDecalIDByDecalUID(decalUID)
  local itemID
  for key, value in pairs(self.ownedDecalDatas) do
    if value.item_uuid == decalUID then
      itemID = key
      break
    end
  end
  return itemID
end
return DecalProxy
