local playerAttrProxy = class("playerAttrProxy", PureMVC.Proxy)
local playerId = 0
local playerAttr = {}
local playerInfo = {}
local preAttrStartIdx = 10000
local attrInited = false
local playerLevelCfg = {}
function playerAttrProxy:ctor(proxyName, data)
  playerAttrProxy.super.ctor(self, proxyName, data)
  self.playerLevelTotalExp = {}
  self.currentExperience = 0
  self.maxPlayerLevel = 1
end
function playerAttrProxy:InitTableCfg()
  self:InitPlayerLevelCfg()
end
function playerAttrProxy:InitPlayerLevelCfg()
  local arrRows = ConfigMgr:GetPlayerLevelTableRows()
  if arrRows then
    playerLevelCfg = arrRows:ToLuaTable()
    for rowName, rowData in pairs(playerLevelCfg) do
      if self.maxPlayerLevel < rowData.Lv then
        self.maxPlayerLevel = rowData.Lv
      end
    end
    local totalExp = 0
    for i = 1, self.maxPlayerLevel do
      totalExp = totalExp + tonumber(playerLevelCfg[tostring(i)].Exp)
      self.playerLevelTotalExp[tostring(i)] = totalExp
    end
  end
end
function playerAttrProxy:GetLevelByTotleExp(TotalExp)
  for i = 1, self.maxPlayerLevel do
    if TotalExp < self.playerLevelTotalExp[tostring(i)] then
      return i
    end
  end
  return self.maxPlayerLevel
end
function playerAttrProxy:GetPlayerMaxLv()
  return self.maxPlayerLevel
end
function playerAttrProxy:GetPlayerLevelTableRow(Level)
  return playerLevelCfg[tostring(Level)]
end
function playerAttrProxy:OnRegister()
  playerAttrProxy.super.OnRegister(self)
  self:InitTableCfg()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_ATTRIBUTE_SYNC_NTF, FuncSlot(self.OnResAttrSyncNtf, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnResLogin, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_PLAYER_CREATE_RES, FuncSlot(self.OnResPlayerCreate, self))
  end
end
function playerAttrProxy:OnRemove()
  playerId = 0
  playerAttr = {}
  playerLevelCfg = {}
  playerInfo = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_ATTRIBUTE_SYNC_NTF, FuncSlot(self.OnResAttrSyncNtf, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_LOGIN_RES, FuncSlot(self.OnResLogin, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_PLAYER_CREATE_RES, FuncSlot(self.OnResPlayerCreate, self))
  end
  local global_delegate_manager = GetGlobalDelegateManager()
  DelegateMgr:RemoveDelegate(global_delegate_manager.OnInitPlayerName, self.OnInitPlayerName)
  playerAttrProxy.super.OnRemove(self)
end
function playerAttrProxy:OnInitPlayerName(PlayerState)
  if PlayerState then
    PlayerState:SetLocalPlayerName(playerInfo.nick)
  end
end
function playerAttrProxy:OnResAttrSyncNtf(data)
  LogDebug("playerAttrProxy", "On receive attribute sync ntf")
  local roleAttrInfo = DeCode(Pb_ncmd_cs_lobby.attribute_sync_ntf, data)
  for key, value in pairs(roleAttrInfo.items) do
    if attrInited then
      playerAttr[preAttrStartIdx + value.id] = self:GetPlayerAttr(value.id)
    end
    if value.value_type == "string" then
      playerAttr[value.id] = tostring(value.value)
    else
      playerAttr[value.id] = tonumber(value.value)
    end
    if not attrInited then
      playerAttr[preAttrStartIdx + value.id] = self:GetPlayerAttr(value.id)
    end
  end
  attrInited = true
  self:CalculateCurrentExperience()
  local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  local avatarId = tonumber(playerAttr[GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID]) or cardDataProxy:GetAvatarId()
  local cardFrameId = tonumber(playerAttr[GlobalEnumDefine.PlayerAttributeType.emVCardFrameId]) or cardDataProxy:GetFrameId()
  local borderId = tonumber(playerAttr[GlobalEnumDefine.PlayerAttributeType.emVCardBorderID]) or cardDataProxy:GetBorderId()
  local achievementId = tonumber(playerAttr[GlobalEnumDefine.PlayerAttributeType.emVCardAchieId]) or cardDataProxy:GetAchievementId()
  cardDataProxy:UpdateCardInfo(avatarId, cardFrameId, borderId, achievementId)
  GameFacade:SendNotification(NotificationDefines.OnResPlayerAttrSync, playerAttr)
  local attrIdsChanged = {}
  for key, value in pairs(roleAttrInfo.items) do
    if playerAttr[value.id] and playerAttr[preAttrStartIdx + value.id] and playerAttr[value.id] ~= playerAttr[preAttrStartIdx + value.id] then
      table.insert(attrIdsChanged, value.id)
    end
  end
  if #attrIdsChanged > 0 then
    GameFacade:SendNotification(NotificationDefines.PlayerAttrChanged, attrIdsChanged)
  end
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.BusinessCardChanged)
end
function playerAttrProxy:OnResLogin(data)
  local login_res = pb.decode(Pb_ncmd_cs_lobby.login_res, data)
  if 0 == login_res.code then
    if login_res.player then
      playerId = login_res.player.player_id
      playerInfo = login_res.player
      UE4.UPMVoiceManager.Get(LuaGetWorld()):CallInitVoiceEngine(tostring(playerId))
      UE4.UPMVoiceManager.Get(LuaGetWorld()):QuitAllVoiceRoom()
      local global_delegate_manager = GetGlobalDelegateManager()
      if global_delegate_manager.OnInitPlayerName then
        self.ReqTeamLeavePracticeHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnInitPlayerName, self, "OnInitPlayerName")
      end
    else
      LogInfo("playerAttrProxy", "New player")
    end
  end
end
function playerAttrProxy:OnResPlayerCreate(data)
  local playerCreate = pb.decode(Pb_ncmd_cs_lobby.player_create_res, data)
  if 0 == playerCreate.code then
    playerId = playerCreate.player.player_id
    playerInfo = playerCreate.player
    if playerId then
      UE4.UPMVoiceManager.Get(LuaGetWorld()):CallInitVoiceEngine(tostring(playerId))
    end
    local global_delegate_manager = GetGlobalDelegateManager()
    if global_delegate_manager.OnInitPlayerName then
      self.ReqTeamLeavePracticeHandler = DelegateMgr:AddDelegate(global_delegate_manager.OnInitPlayerName, self, "OnInitPlayerName")
    end
  end
end
function playerAttrProxy:CalculateCurrentExperience()
  local exp = playerAttr[GlobalEnumDefine.PlayerAttributeType.emEXP]
  local levelTotalExp = self:GetLevelTotalExperience(playerAttr[GlobalEnumDefine.PlayerAttributeType.emLevel - 1])
  self.currentExperience = exp - levelTotalExp
end
function playerAttrProxy:GetPlayerInfo()
  return playerInfo
end
function playerAttrProxy:GetPlayerAttr(attrId)
  return playerAttr[attrId] or 0
end
function playerAttrProxy:GetPlayerPreAttr(attrId)
  return playerAttr[preAttrStartIdx + attrId] or 0
end
function playerAttrProxy:GetPlayerId()
  return playerId
end
function playerAttrProxy:GetPlayerNick()
  return playerAttr[GlobalEnumDefine.PlayerAttributeType.emNick]
end
function playerAttrProxy:GetPlayerExperience()
  return self.currentExperience
end
function playerAttrProxy:GetCurLevelUpExperience()
  local level = tostring(playerAttr[GlobalEnumDefine.PlayerAttributeType.emLevel])
  return self:GetLevelUpExperience(level)
end
function playerAttrProxy:GetLevelUpExperience(level)
  local exp = 0
  level = tostring(level)
  if playerLevelCfg[level] then
    exp = playerLevelCfg[level].Exp
  end
  return exp
end
function playerAttrProxy:GetPlayerPreExperience()
  local preLevel = self:GetPlayerPreAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
  return self:GetPlayerPreAttr(GlobalEnumDefine.PlayerAttributeType.emEXP) - self:GetLevelTotalExperience(preLevel - 1)
end
function playerAttrProxy:GetPlayerCurExperience()
  local level = self:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
  return self:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emEXP) - self:GetLevelTotalExperience(level - 1)
end
function playerAttrProxy:GetLevelTotalExperience(level)
  level = tostring(level)
  local exp = self.playerLevelTotalExp[level] or 0
  return exp
end
function playerAttrProxy:GetCurCurrencyNum(currencyId)
  local CurrencyTable = {
    [UE4.EFunctionCoinType.Crystal] = playerAttr[GlobalEnumDefine.PlayerAttributeType.emCrystal],
    [UE4.EFunctionCoinType.Hermes] = playerAttr[GlobalEnumDefine.PlayerAttributeType.emIdeal],
    [UE4.EFunctionCoinType.WeaponParticles] = playerAttr[GlobalEnumDefine.PlayerAttributeType.emWeaponScrap],
    [UE4.EFunctionCoinType.RoleChip] = playerAttr[GlobalEnumDefine.PlayerAttributeType.emRoleScrap]
  }
  if currencyId then
    return CurrencyTable[currencyId]
  else
    return CurrencyTable
  end
end
return playerAttrProxy
