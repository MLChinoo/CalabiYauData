local ApartmentRoomWindingCorridorProxy = class("ApartmentRoomWindingCorridorProxy", PureMVC.Proxy)
function ApartmentRoomWindingCorridorProxy:OnRegister()
  self.roleWindingCorridorMap = {}
  self.roleUnlockWindingCorridorMap = {}
  self:InitRoleWindingCorridor()
end
function ApartmentRoomWindingCorridorProxy:OnRemove()
end
function ApartmentRoomWindingCorridorProxy:InitRoleWindingCorridor()
  local arrRow = ConfigMgr:GetWindingCorridorTableRow()
  self.windingCorridorTableRows = arrRow:ToLuaTable()
  if self.windingCorridorTableRows then
    for key, value in pairs(self.windingCorridorTableRows) do
      if value then
        local roleID = value.RoleId
        local windingCorridorArry = self.roleWindingCorridorMap[roleID]
        if nil == windingCorridorArry then
          windingCorridorArry = {}
        end
        table.insert(windingCorridorArry, value)
        self.roleWindingCorridorMap[roleID] = windingCorridorArry
      end
    end
  end
  for roleID, arr in pairs(self.roleWindingCorridorMap) do
    table.sort(arr, function(a, b)
      return a.SortId < b.SortId
    end)
  end
end
function ApartmentRoomWindingCorridorProxy:GetWindingCorridorListByRoleID(roleID)
  if self.roleWindingCorridorMap then
    return self.roleWindingCorridorMap[roleID]
  end
  return nil
end
function ApartmentRoomWindingCorridorProxy:UpdateUnlockWindingCorridorMap(roleID, windingCorridorList)
  if self.roleUnlockWindingCorridorMap == nil then
    self.roleUnlockWindingCorridorMap = {}
  end
  self.roleUnlockWindingCorridorMap[roleID] = windingCorridorList
  LogDebug("ApartmentRoomWindingCorridorProxy:UpdateUnlockWindingCorridorMap", "unlocks list")
end
function ApartmentRoomWindingCorridorProxy:IsUnlockWindingCorridor(roleID, sequenceID)
  if self.roleUnlockWindingCorridorMap == nil or self.roleUnlockWindingCorridorMap[roleID] == nil or table.count(self.roleUnlockWindingCorridorMap[roleID]) <= 0 then
    return false
  end
  for key, value in pairs(self.roleUnlockWindingCorridorMap[roleID]) do
    if value.id == sequenceID then
      return true
    end
  end
  return false
end
function ApartmentRoomWindingCorridorProxy:GetMemoryReadState(roleID, sequenceID)
  if self.roleUnlockWindingCorridorMap == nil or self.roleUnlockWindingCorridorMap[roleID] == nil or table.count(self.roleUnlockWindingCorridorMap[roleID]) <= 0 then
    return
  end
  for key, value in pairs(self.roleUnlockWindingCorridorMap[roleID]) do
    if value.id == sequenceID then
      return value
    end
  end
end
function ApartmentRoomWindingCorridorProxy:MemoryStoryHasPicture(roleId, storyId)
  local hasPicture = false
  local cfg = self.roleWindingCorridorMap[roleId]
  if cfg then
    for key, value in pairs(cfg) do
      local id = value.AvgId > 0 and value.AvgId or value.SequenceId
      if id == storyId and not value.MemoryPicture:IsNull() then
        hasPicture = true
        break
      end
    end
  end
  return hasPicture
end
return ApartmentRoomWindingCorridorProxy
