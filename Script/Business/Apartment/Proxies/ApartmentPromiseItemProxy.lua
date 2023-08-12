local ApartmentPromiseItemProxy = class("ApartmentPromiseItemProxy", PureMVC.Proxy)
local RolePromiseItemCfg = {}
function ApartmentPromiseItemProxy:OnRegister()
  self.super.OnRegister(self)
  self:InitRolePromiseItemCfg()
end
function ApartmentPromiseItemProxy:InitRolePromiseItemCfg()
  local PromiseItemCfg = ConfigMgr:GetPledgeItemTableRow()
  if not PromiseItemCfg then
    return
  end
  PromiseItemCfg = PromiseItemCfg:ToLuaTable()
  for row, value in pairs(PromiseItemCfg) do
    local ownerRole = value.OwnerRoleId
    if not RolePromiseItemCfg[ownerRole] then
      RolePromiseItemCfg[ownerRole] = {}
    end
    RolePromiseItemCfg[ownerRole][value.Id] = value
  end
end
function ApartmentPromiseItemProxy:GetRoleAllPromiseItemsCfg(roleId)
  return RolePromiseItemCfg[roleId]
end
function ApartmentPromiseItemProxy:GetUnlockedPromiseItem(roleId)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  if not KaPhoneProxy or not RoleProxy then
    LogDebug("Lua", "ApartmentPromiseItemProxy:GetUnlockedPromiseItem, get Proxy failed.")
    return
  end
  local roleProperty = KaPhoneProxy:GetRoleProperties(roleId)
  local promiseItemInfo = RoleProxy:GetRolePromiseItemInfo(roleId, roleProperty.intimacy_lv)
  if roleProperty.pledges and #roleProperty.pledges > 0 then
    for idx, info in ipairs(promiseItemInfo) do
      for _, unlockedPledge in ipairs(roleProperty.pledges) do
        if unlockedPledge.id == info.id then
          info.unlocked = true
          if unlockedPledge.step < 1 then
            info.newUnlock = true
          end
          if unlockedPledge.step < 2 then
            info.unCheckedStory = true
          end
          break
        end
      end
    end
  end
  return promiseItemInfo
end
function ApartmentPromiseItemProxy:GetPromiseItemCfg(roleId, itemId)
  if roleId and itemId and RolePromiseItemCfg[roleId] then
    return RolePromiseItemCfg[roleId][itemId]
  end
end
return ApartmentPromiseItemProxy
