local ItemsProxy = class("ItemsProxy", PureMVC.Proxy)
local itemCfg = {}
local itemIdIntervalCfg = {}
local currencyCfg = {}
local decalCfg = {}
local idCardCfg = {}
local itemQualityCfg = {}
function ItemsProxy:InitTableCfg()
  self:InitItemIdIntervalTableCfg()
  self:InitCurrencyTableCfg()
  self:InitDecalTableCfg()
  self:InitIdCardTableCfg()
  self:InitItemTableCfg()
  self:InitItemQualityTableCfg()
end
function ItemsProxy:InitItemIdIntervalTableCfg()
  local arrRows = ConfigMgr:GetItemIdIntervalTableRows()
  if arrRows then
    itemIdIntervalCfg = arrRows:ToLuaTable()
  end
end
function ItemsProxy:InitCurrencyTableCfg()
  local arrRows = ConfigMgr:GetCurrencyTableRows()
  if arrRows then
    currencyCfg = arrRows:ToLuaTable()
  end
end
function ItemsProxy:InitDecalTableCfg()
  local arrRows = ConfigMgr:GetDecalTableRows()
  if arrRows then
    decalCfg = arrRows:ToLuaTable()
  end
end
function ItemsProxy:InitIdCardTableCfg()
  local arrRows = ConfigMgr:GetIdCardTableRows()
  if arrRows then
    idCardCfg = arrRows:ToLuaTable()
  end
end
function ItemsProxy:InitItemTableCfg()
  local arrRows = ConfigMgr:GetItemTableRows()
  if arrRows then
    itemCfg = arrRows:ToLuaTable()
  end
end
function ItemsProxy:InitItemQualityTableCfg()
  local arrRows = ConfigMgr:GetItemQualityTableRows()
  if arrRows then
    itemQualityCfg = arrRows:ToLuaTable()
  end
end
function ItemsProxy:ctor(proxyName, data)
  ItemsProxy.super.ctor(self, proxyName, data)
end
function ItemsProxy:OnRegister()
  ItemsProxy.super.OnRegister(self)
  self:InitTableCfg()
end
function ItemsProxy:GetItemIdIntervalType(itemId)
  if itemId then
    local InId = tonumber(itemId)
    for type, value in pairs(itemIdIntervalCfg) do
      if InId >= value.IdLower and InId <= value.IdUpper then
        return value.ItemType
      end
    end
  end
  return UE4.EItemIdIntervalType.None
end
function ItemsProxy:GetItemIdInterval(itemId)
  local InId = tonumber(itemId)
  for type, value in pairs(itemIdIntervalCfg) do
    if InId >= value.IdLower and InId <= value.IdUpper then
      return value
    end
  end
  return nil
end
function ItemsProxy:GetCurrencyConfig(CurrencyId)
  local InId = tostring(CurrencyId)
  return currencyCfg[InId]
end
function ItemsProxy:GetItemQualityConfig(QualityId)
  for key, value in pairs(itemQualityCfg) do
    if value and value.QualityId == QualityId then
      return value
    end
  end
  return nil
end
function ItemsProxy:GetItemTableConfig(itemId)
  local InId = tostring(itemId)
  return itemCfg[InId]
end
function ItemsProxy:GetAnyItemImg(itemId)
  local InId = tostring(itemId)
  local itemImg
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemImg = currencyCfg[InId].IconItem
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleInfo = roleProxy:GetRole(InId)
      if roleInfo then
        itemImg = roleInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      if weaponInfo then
        itemImg = weaponInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      if roleSkinInfo then
        itemImg = roleSkinInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemImg = roleActionInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemImg = roleVoiceInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemImg = decalCfg[InId].IconItem
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemImg = idCardCfg[InId].IconItem
    end
  elseif itemIdIntervalType == EItemIdType.FlyEffect then
    local flyEffectProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
    if flyEffectProxy then
      local flyEffectData = flyEffectProxy:GetFlyEffectRowTableCfg(tonumber(InId))
      if flyEffectData then
        itemImg = flyEffectData.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      local roleRmote = roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
      if roleRmote then
        itemImg = roleRmote.IconItem
      end
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemImg = itemCfg[InId].IconItem
  end
  return itemImg
end
function ItemsProxy:GetAnyItemDisplayImg(itemId)
  local InId = tostring(itemId)
  local itemImg
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemImg = currencyCfg[InId].IconDisplayItem
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleInfo = roleProxy:GetRole(InId)
      if roleInfo then
        itemImg = roleInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      if weaponInfo then
        itemImg = weaponInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      if roleSkinInfo then
        itemImg = roleSkinInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemImg = roleActionInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemImg = roleVoiceInfo.BigiconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemImg = decalCfg[InId].IconItem
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg then
    if idCardCfg[InId] then
      itemImg = idCardCfg[InId].IconDisplayItem
    end
  elseif itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemImg = idCardCfg[InId].IconItem
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemImg = itemCfg[InId].IconDisplayItem
  end
  return itemImg
end
function ItemsProxy:GetAnyItemName(itemId)
  local InId = tostring(itemId)
  local itemName
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemName = currencyCfg[InId].Name
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleInfo = roleProxy:GetRoleProfile(InId)
      if roleInfo then
        itemName = roleInfo.NameCn
      end
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      if weaponInfo then
        itemName = weaponInfo.Name
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      if roleSkinInfo then
        itemName = roleSkinInfo.NameCn
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemName = roleActionInfo.ActionName
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemName = roleVoiceInfo.VoiceName
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemName = decalCfg[InId].Name
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      local roleRmote = roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
      if roleRmote then
        itemName = roleRmote.Name
      end
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemName = idCardCfg[InId].Name
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemName = itemCfg[InId].Name
  end
  return itemName
end
function ItemsProxy:GetAnyItemShotName(itemId)
  local InId = tostring(itemId)
  local itemName
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemName = currencyCfg[InId].Name
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleInfo = roleProxy:GetRoleProfile(InId)
      if roleInfo then
        itemName = roleInfo.NameCn
      end
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      if weaponInfo then
        itemName = weaponInfo.Name
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      if roleSkinInfo then
        itemName = roleSkinInfo.NameShort
        if "" == itemName then
          itemName = roleSkinInfo.NameCn
          LogError("GetAnyItemShotName", "ShotName is Empty,RoleSkinID Is .. " .. tostring(InId))
        end
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemName = roleActionInfo.ActionName
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemName = roleVoiceInfo.VoiceNameShort
        if "" == itemName then
          itemName = roleVoiceInfo.VoiceName
          LogError("GetAnyItemShotName", "ShotName is Empty,VoiceID Is .. " .. tostring(InId))
        end
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemName = decalCfg[InId].Name
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      local roleRmote = roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
      if roleRmote then
        itemName = roleRmote.Name
      end
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemName = idCardCfg[InId].Name
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemName = itemCfg[InId].Name
  end
  return itemName
end
function ItemsProxy:GetAnyItemQuality(itemId)
  local InId = tostring(itemId)
  local itemQuality
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemQuality = currencyCfg[InId].Quality
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    itemQuality = 1
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      if weaponInfo then
        itemQuality = weaponInfo.Quality
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      if roleSkinInfo then
        itemQuality = roleSkinInfo.Quality
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemQuality = roleActionInfo.Quality
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemQuality = roleVoiceInfo.Quality
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemQuality = decalCfg[InId].Quality
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemQuality = idCardCfg[InId].Quality
    end
  elseif itemIdIntervalType == EItemIdType.FlyEffect then
    local roleProfileProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
    if roleProfileProxy then
      local flyEffectInfo = roleProfileProxy:GetFlyEffectRowTableCfg(tonumber(InId))
      if flyEffectInfo then
        itemQuality = flyEffectInfo.Quality
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      local roleRmote = roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
      if roleRmote then
        itemQuality = roleRmote.Quality
      end
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemQuality = itemCfg[InId].Quality
  end
  return itemQuality
end
function ItemsProxy:GetAnyItemDesc(itemId)
  local InId = tostring(itemId)
  local itemDesc
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemDesc = currencyCfg[InId].Desc
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleInfo = roleProxy:GetRoleProfile(InId)
      if roleInfo then
        itemDesc = roleInfo.Desc
      end
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      if weaponInfo then
        itemDesc = weaponInfo.Tips
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      if roleSkinInfo then
        itemDesc = roleSkinInfo.Description
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemDesc = roleActionInfo.Content
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemDesc = roleVoiceInfo.Content
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemDesc = decalCfg[InId].Desc
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      local roleRmote = roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
      if roleRmote then
        itemDesc = roleRmote.Desc
      end
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemDesc = idCardCfg[InId].Desc
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemDesc = itemCfg[InId].Desc
  end
  return itemDesc
end
function ItemsProxy:GetAnyItemInfoById(itemId)
  local itemInfo = {
    name = "",
    image = "",
    quality = 1,
    desc = "",
    roleName = nil
  }
  local InId = tostring(itemId)
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      itemInfo.name = currencyCfg[InId].Name
      itemInfo.image = currencyCfg[InId].IconItem
      itemInfo.quality = currencyCfg[InId].Quality
      itemInfo.desc = currencyCfg[InId].Desc
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local profileInfo = roleProxy:GetRoleProfile(InId)
      local roleInfo = roleProxy:GetRole(InId)
      if profileInfo then
        itemInfo.name = profileInfo.NameCn
        itemInfo.quality = 1
        itemInfo.desc = profileInfo.Desc
      end
      if roleInfo then
        itemInfo.image = roleInfo.IconItem
      end
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if weaponProxy and RoleProxy then
      local weaponInfo = weaponProxy:GetWeapon(InId)
      local RoleInfo = RoleProxy:GetRoleCfgByWeaponId(InId)
      if weaponInfo then
        itemInfo.name = weaponInfo.Name
        itemInfo.image = weaponInfo.IconItem
        itemInfo.quality = weaponInfo.Quality
        itemInfo.desc = weaponInfo.Tips
        if RoleInfo then
          itemInfo.roleName = RoleInfo.NameCn
        end
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleSkinInfo = roleProxy:GetRoleSkin(InId)
      local roleProfile = roleProxy:GetRoleProfile(roleSkinInfo.RoleId)
      if nil == roleProfile then
        LogError("ItemsProxy:GetAnyItemInfoById", "ItemId = %s,RoleSkinId = %s, RoleId = %s", InId, roleSkinInfo.RoleSkinId, roleSkinInfo.RoleId)
      end
      if roleSkinInfo then
        itemInfo.name = roleSkinInfo.NameCn
        itemInfo.image = roleSkinInfo.IconItem
        itemInfo.quality = roleSkinInfo.Quality
        itemInfo.desc = roleSkinInfo.Description
        itemInfo.roleName = roleProfile.NameCn
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleActionInfo = roleProxy:GetRoleAction(InId)
      if roleActionInfo then
        itemInfo.name = roleActionInfo.ActionName
        itemInfo.image = roleActionInfo.IconItem
        itemInfo.quality = roleActionInfo.Quality
        itemInfo.desc = roleActionInfo.Content
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
      if roleVoiceInfo then
        itemInfo.name = roleVoiceInfo.VoiceName
        itemInfo.image = roleVoiceInfo.IconItem
        itemInfo.quality = roleVoiceInfo.Quality
        itemInfo.desc = roleVoiceInfo.Content
        local roleId = roleVoiceInfo.RoleId
        if roleId then
          local roleCfg = roleProxy:GetRoleProfile(roleId)
          if roleCfg then
            itemInfo.roleName = roleCfg.NameCn
          end
        end
      end
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      itemInfo.name = decalCfg[InId].Name
      itemInfo.image = decalCfg[InId].IconItem
      itemInfo.quality = decalCfg[InId].Quality
      itemInfo.desc = decalCfg[InId].Desc
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      itemInfo.name = idCardCfg[InId].Name
      itemInfo.image = idCardCfg[InId].IconItem
      itemInfo.quality = idCardCfg[InId].Quality
      itemInfo.desc = idCardCfg[InId].Desc
    end
  elseif itemIdIntervalType == EItemIdType.FlyEffect then
    local roleProfileProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
    if roleProfileProxy then
      local flyEffectInfo = roleProfileProxy:GetFlyEffectRowTableCfg(tonumber(InId))
      if flyEffectInfo then
        itemInfo.name = flyEffectInfo.Name
        itemInfo.image = flyEffectInfo.IconItem
        itemInfo.quality = flyEffectInfo.Quality
        itemInfo.desc = flyEffectInfo.Desc
      end
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      local roleRmote = roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
      if roleRmote then
        itemInfo.name = roleRmote.Name
        itemInfo.image = roleRmote.IconItem
        itemInfo.quality = roleRmote.Quality
        itemInfo.desc = roleRmote.Desc
      end
    end
  elseif itemIdIntervalType == EItemIdType.WeaponUpgradeFx then
    local weaponSkinUpgradeProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponSkinUpgradeProxy)
    if weaponSkinUpgradeProxy then
      local weaponFxRow = weaponSkinUpgradeProxy:GetFxWeaponRow(tonumber(InId))
      if weaponFxRow then
        itemInfo.name = weaponFxRow.Name
        itemInfo.image = weaponFxRow.IconItem
        itemInfo.quality = weaponFxRow.Quality
      end
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    itemInfo.name = itemCfg[InId].Name
    itemInfo.image = itemCfg[InId].IconItem
    itemInfo.quality = itemCfg[InId].Quality
    itemInfo.desc = itemCfg[InId].Desc
  end
  return itemInfo
end
function ItemsProxy:GetAnyItemOwned(itemId)
  local InId = itemId
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Role then
    return GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsUnlockRole(InId)
  elseif itemIdIntervalType == EItemIdType.Weapon then
    return GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetWeaponUnlockState(InId)
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    return GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsUnlockRoleSkin(InId)
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    return GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsUnlockRoleAction(InId)
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    return GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsUnlockRoleVoice(InId)
  elseif itemIdIntervalType == EItemIdType.Decal then
    return GameFacade:RetrieveProxy(ProxyNames.DecalProxy):IsOwnDecalByDecalID(InId)
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    return GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):IsOwnCard(InId)
  elseif itemIdIntervalType == EItemIdType.FlyEffect then
    return GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy):IsUnlockFlyEffect(InId)
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    return GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy):IsUnlockEmote(InId)
  end
  return false
end
function ItemsProxy:GetDecalCfg()
  return decalCfg
end
function ItemsProxy:GetItemCfg(itemId)
  local InId = tostring(itemId)
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  local EItemIdType = UE4.EItemIdIntervalType
  if itemIdIntervalType == EItemIdType.Currency then
    if currencyCfg[InId] then
      return currencyCfg[InId]
    end
  elseif itemIdIntervalType == EItemIdType.Role then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      return roleProxy:GetRole(InId)
    end
  elseif itemIdIntervalType == EItemIdType.Weapon then
    local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
    if weaponProxy then
      return weaponProxy:GetWeapon(InId)
    end
  elseif itemIdIntervalType == EItemIdType.RoleSkin then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      return roleProxy:GetRoleSkin(InId)
    end
  elseif itemIdIntervalType == EItemIdType.RoleAction then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      return roleProxy:GetRoleAction(InId)
    end
  elseif itemIdIntervalType == EItemIdType.RoleVoice then
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    if roleProxy then
      return roleProxy:GetRoleVoice(InId)
    end
  elseif itemIdIntervalType == EItemIdType.Decal then
    if decalCfg[InId] then
      return decalCfg[InId]
    end
  elseif itemIdIntervalType == EItemIdType.VCardAvatar or itemIdIntervalType == EItemIdType.VCardBg or itemIdIntervalType == EItemIdType.Achievement then
    if idCardCfg[InId] then
      return idCardCfg[InId]
    end
  elseif itemIdIntervalType == EItemIdType.FlyEffect then
    local roleProfileProxy = GameFacade:RetrieveProxy(ProxyNames.RoleFlyEffectProxy)
    if roleProfileProxy then
      return roleProfileProxy:GetFlyEffectRowTableCfg(tonumber(InId))
    end
  elseif itemIdIntervalType == EItemIdType.RoleEmote then
    local roleEmoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
    if roleEmoteProxy then
      return roleEmoteProxy:GetRoleEmoteTableRow(tonumber(InId))
    end
  elseif itemIdIntervalType > EItemIdType.BagItem_Min and itemIdIntervalType < EItemIdType.BagItem_Max and itemCfg[InId] then
    return itemCfg[InId]
  end
  return nil
end
function ItemsProxy:GetItemOwnerById(itemId, itemTypeList, ownerList)
  local InId = tostring(itemId)
  local itemIdIntervalType = self:GetItemIdIntervalType(InId)
  if table.containsValue(itemTypeList, itemIdIntervalType) then
    if itemIdIntervalType == UE4.EItemIdIntervalType.Weapon then
      local weaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
      if weaponProxy then
        local weaponInfo = weaponProxy:GetWeapon(InId)
        if weaponInfo and weaponInfo.Slot == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
          do
            local weaponType = weaponInfo.SubType
            local weaponCommonInfo = weaponProxy:GetWeapon(weaponType)
            if weaponCommonInfo then
              table.insert(ownerList, weaponCommonInfo.Name)
            else
              LogError("itemsProxy WeaponCfg", "//武器表找不到武器ID = %s 的武器信息,找策划！", weaponType)
            end
            local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
            if roleProxy then
              local roleCfgList = roleProxy:GetAllRoleCfgs()
              for key, value in pairs(roleCfgList) do
                if value.DefaultWeapon1 == weaponType then
                  local roleProfile = roleProxy:GetRoleProfile(value.RoleId)
                  if roleProfile then
                    table.insert(ownerList, roleProfile.NameCn)
                  end
                end
              end
            else
            end
          end
        end
      end
    elseif itemIdIntervalType == UE4.EItemIdIntervalType.RoleSkin then
      local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
      if roleProxy then
        local roleSkinInfo = roleProxy:GetRoleSkin(InId)
        if roleSkinInfo then
          local roleProfile = roleProxy:GetRoleProfile(roleSkinInfo.RoleId)
          if roleProfile then
            table.insert(ownerList, ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ItemTypeRoleSkin"))
            table.insert(ownerList, roleProfile.NameCn)
          else
            LogError("itemsProxy roleProfile", "//角色详情表找不到角色ID = %s 的角色信息,找策划！", roleSkinInfo.RoleId)
          end
        else
          LogError("itemsProxy roleSkinInfo", "//角色皮肤表找不到角色ID = %s 的角色皮肤信息,找策划！", InId)
        end
      end
    elseif itemIdIntervalType == UE4.EItemIdIntervalType.RoleVoice then
      local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
      if roleProxy then
        local roleVoiceInfo = roleProxy:GetRoleVoice(InId)
        if roleVoiceInfo then
          local roleProfile = roleProxy:GetRoleProfile(roleVoiceInfo.RoleId)
          if roleProfile then
            table.insert(ownerList, ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ItemTypeRoleVoice"))
            table.insert(ownerList, roleProfile.NameCn)
          else
            LogError("itemsProxy roleProfile", "//角色详情表找不到角色ID = %s 的角色信息,找策划！", roleSkinInfo.RoleId)
          end
        else
          LogError("itemsProxy roleVoiceInfo", "//角色语音表找不到角色ID = %s 的角色语音信息,找策划！", InId)
        end
      end
    end
  end
end
function ItemsProxy:IsShow(row, bUnlock)
  if row then
    if row.AvailableState == UE4.ECyAvailableType.Show then
      return true
    end
    if row.AvailableState == UE4.ECyAvailableType.OwnShow and bUnlock then
      return true
    end
  end
  return false
end
return ItemsProxy
