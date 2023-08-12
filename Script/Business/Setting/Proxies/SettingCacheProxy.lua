local SettingCacheProxy = class("SettingCacheProxy", PureMVC.Proxy)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
function SettingCacheProxy:OnRegister()
  SettingCacheProxy.super.OnRegister(self)
  self.cache = {}
  self.callfunc = {}
end
function SettingCacheProxy:OnRemove()
  SettingCacheProxy.super.OnRemove(self)
  self:ClearCache()
end
function SettingCacheProxy:AddCache(playerid, cache)
  if 0 == playerid then
  else
    if cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_SECRET] == nil then
      local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
      cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_SECRET] = SettingSaveDataProxy:GetDefaultValueByKey("Switch_PrivacyProtect")
    end
    if nil == cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_REJECT_FRIEND_APPLY] then
      local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
      cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_REJECT_FRIEND_APPLY] = SettingSaveDataProxy:GetDefaultValueByKey("Switch_FriendApplyProtect")
    end
    if nil == cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_REJECT_HIDE_LOCA] then
      local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
      cache[Pb_ncmd_cs.EPlayerSettingKey.PlayerSettingKey_REJECT_HIDE_LOCA] = SettingSaveDataProxy:GetDefaultValueByKey("Switch_AreaPrivacy")
    end
    self.cache[playerid] = cache
  end
end
function SettingCacheProxy:GetCacheByPlayerId(playerid)
  return self.cache[playerid]
end
function SettingCacheProxy:GetValueByPlayerId(playerid, func)
  if nil == playerid then
    LogError("SettingCacheProxy:GetSpeCachePlayerId", "playerid is nil！")
    return
  end
  self.callfunc[playerid] = self.callfunc[playerid] or {}
  table.insert(self.callfunc[playerid], func)
  local SettingNetProxy = GameFacade:RetrieveProxy(ProxyNames.SettingNetProxy)
  SettingNetProxy:ReqGetPlayerSetting(playerid)
end
function SettingCacheProxy:DoCacheCallFunc(playerid)
  if self.callfunc[playerid] then
    for i, v in ipairs(self.callfunc[playerid]) do
      if v and type(v) == "function" then
        v()
      end
    end
    self.callfunc[playerid] = nil
  end
end
function SettingCacheProxy:ClearCache(playerid)
  if nil == playerid then
    self.cache = {}
  else
    self.cache[playerid] = {}
  end
  self.callfunc = {}
end
return SettingCacheProxy
