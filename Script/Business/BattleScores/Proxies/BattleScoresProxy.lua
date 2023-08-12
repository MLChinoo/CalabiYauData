local BattleScoresProxy = class("BattleScoresProxy", PureMVC.Proxy)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local mapTableRows
local FriendApplys = {}
local ForbidedPlayer = {}
function BattleScoresProxy:OnRegister()
  LogDebug("BattleScoresProxy", "OnRegister")
  BattleScoresProxy.super.OnRegister(self)
  mapTableRows = ConfigMgr:GetMapCfgTableRows():ToLuaTable()
  FriendApplys = {}
  ForbidedPlayer = {}
end
function BattleScoresProxy:OnRemove()
  LogDebug("BattleScoresProxy", "OnRemove")
  BattleScoresProxy.super.OnRemove(self)
end
function BattleScoresProxy:AddFriendApply(UID)
  table.insert(FriendApplys, UID)
end
function BattleScoresProxy:IsFriendApply(UID)
  return table.index(FriendApplys, UID)
end
function BattleScoresProxy:AddForbidedPlayer(UID)
  table.insert(ForbidedPlayer, UID)
end
function BattleScoresProxy:IsForbidedPlayer(UID)
  return table.index(ForbidedPlayer, UID)
end
function BattleScoresProxy:GetMapName(inMapID)
  for key, value in pairs(mapTableRows) do
    if value.Id == inMapID then
      return value.Name
    end
  end
  return ""
end
function BattleScoresProxy:GetMapTypeName(inMapID)
  for key, value in pairs(mapTableRows) do
    if value and value.Id == inMapID then
      local rowType = value.Type
      if rowType == RoomEnum.MapType.TeamSports then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TeamMode")
      elseif rowType == RoomEnum.MapType.BlastInvasion then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "BombMode")
      elseif rowType == RoomEnum.MapType.CrystalWar then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CrystaScrambleMode")
      elseif rowType == RoomEnum.MapType.Team5V5V5 then
        return ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Team5V5V5")
      end
    end
  end
  return ""
end
function BattleScoresProxy:GetMapType(inMapID)
  for key, value in pairs(mapTableRows) do
    if value and value.Id == inMapID then
      return value.Type
    end
  end
  return nil
end
return BattleScoresProxy
