local BusinessCardDataProxy = class("BusinessCardDataProxy", PureMVC.Proxy)
local businessCardEnum = require("Business/PlayerProfile/Proxies/BusinessCard/businessCardEnumDefine")
local businessCardMap = {}
function BusinessCardDataProxy:GetCardMap()
  return businessCardMap
end
function BusinessCardDataProxy:GetCardType(cardId)
  for key, value in pairs(businessCardMap) do
    if value.cardList and value.cardList[cardId] then
      return key
    end
  end
  return 0
end
function BusinessCardDataProxy:GetCardIdConfig(cardId)
  for key, value in pairs(businessCardMap) do
    if value.cardList and value.cardList[cardId] then
      return value.cardList[cardId].config
    end
  end
  return nil
end
function BusinessCardDataProxy:IsOwnCard(cardId)
  for i, v in pairs(businessCardMap) do
    if v.cardList and v.cardList[tonumber(cardId)] then
      return v.cardList[tonumber(cardId)].hasGained
    end
  end
  return nil
end
function BusinessCardDataProxy:GetIconTexture(cardId)
  local cardCfg = self:GetCardConfig(businessCardEnum.cardType.avatar, cardId)
  return cardCfg and cardCfg.IconItem or nil
end
function BusinessCardDataProxy:GetFrameIconTexture(cardId)
  local cardCfg = self:GetCardConfig(businessCardEnum.cardType.frame, cardId)
  return cardCfg and cardCfg.IconIdcardFrameHeadphoto or nil
end
function BusinessCardDataProxy:SetHeadIcon(page, avatarImg, avatarId, borderImg, borderId)
  if nil == page then
    return
  end
  if avatarImg and avatarId then
    local avatarIcon = self:GetIconTexture(avatarId)
    if avatarIcon then
      page:SetImageByTexture2D(avatarImg, avatarIcon)
    else
      LogError("BusinessCardDataProxy", "Page:%s Player icon or config error", UE4.UKismetSystemLibrary.GetDisplayName(page))
    end
  end
  if borderImg and borderId then
    local frameIcon = self:GetFrameIconTexture(borderId)
    if frameIcon and not frameIcon:IsNull() then
      page:SetImageByTexture2D(borderImg, frameIcon)
      borderImg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      borderImg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function BusinessCardDataProxy:GetCardConfig(cardType, cardId)
  if 0 == cardId and cardType == businessCardEnum.cardType.achieve then
    return 0
  end
  if 0 == cardId or businessCardMap[cardType].cardList[cardId] == nil then
    local defaultId = businessCardMap[cardType].defaultCardId
    if defaultId then
      return businessCardMap[cardType].cardList[defaultId].config
    else
      return nil
    end
  end
  return businessCardMap[cardType].cardList[cardId].config
end
function BusinessCardDataProxy:InitBusinessCardMap()
  for key, value in pairs(businessCardEnum.cardType) do
    businessCardMap[value] = {}
    businessCardMap[value].cardList = {}
    businessCardMap[value].defaultCardId = 0
    businessCardMap[value].cardNum = 0
    businessCardMap[value].ownedNum = 0
  end
  local arrRows = ConfigMgr:GetIdCardTableRows()
  if arrRows then
    for RowName, UserData in pairs(arrRows:ToLuaTable()) do
      if businessCardMap[UserData.Type] and UserData.AvailableState ~= UE4.ECyAvailableType.Hide then
        local achieveGroupId = -1
        local bHasLevel = false
        local achieveLevel = 0
        if UserData.Type == businessCardEnum.cardType.achieve and UserData.AchievementType then
          local achieveCfg = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchievementTableRow(UserData.Id)
          if achieveCfg then
            achieveGroupId = achieveCfg.Group
            bHasLevel = true
            achieveLevel = achieveCfg.Level
          else
            LogError("BusinessCardDataProxy", "成就表没有对应：%d的配置  @艾甫", UserData.Id)
          end
        end
        businessCardMap[UserData.Type].cardList[UserData.Id] = {
          config = UserData,
          hasGained = false,
          hasLevel = bHasLevel,
          groupId = achieveGroupId,
          level = achieveLevel,
          obtainTime = 0,
          expireTime = 0
        }
        if UserData.Default then
          businessCardMap[UserData.Type].defaultCardId = UserData.Id
        end
        if bHasLevel and 1 == achieveLevel or false == bHasLevel then
          businessCardMap[UserData.Type].cardNum = businessCardMap[UserData.Type].cardNum + 1
        end
      end
    end
  else
    LogError("BusinessCardDataProxy", "Initialize businesscard failed")
  end
end
function BusinessCardDataProxy:UpdateBusinessCardMap(cardResourceInfoSync)
  if cardResourceInfoSync.resources then
    for key, value in pairs(cardResourceInfoSync.resources) do
      local obtainTime = value.obtain_time
      if obtainTime and obtainTime > 0 then
        for i, v in pairs(businessCardMap) do
          if v.cardList[value.resource_id] then
            v.cardList[value.resource_id].hasGained = true
            v.cardList[value.resource_id].obtainTime = obtainTime
            if value.expire_time then
              v.cardList[value.resource_id].expireTime = value.expire_time
            end
          end
        end
      end
    end
  end
  for key, value in pairs(businessCardMap) do
    local ownedNum = 0
    for i, v in pairs(value.cardList) do
      if v.hasGained then
        ownedNum = ownedNum + 1
      end
    end
    value.ownedNum = ownedNum
  end
end
function BusinessCardDataProxy:OnRegister()
  LogDebug("BusinessCardDataProxy", "Register BusinessCardData Proxy")
  BusinessCardDataProxy.super.OnRegister(self)
  self:InitBusinessCardMap()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SELF_VCARD_UPDATE_RES, FuncSlot(self.OnResCardUpdate, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_VCARD_RESOURCE_SYNC_NTF, FuncSlot(self.OnResCardResourceSyncNtf, self))
  end
end
function BusinessCardDataProxy:OnRemove()
  businessCardMap = {}
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SELF_VCARD_UPDATE_RES, FuncSlot(self.OnResCardUpdate, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_VCARD_RESOURCE_SYNC_NTF, FuncSlot(self.OnResCardResourceSyncNtf, self))
  end
  BusinessCardDataProxy.super.OnRemove(self)
end
function BusinessCardDataProxy:ReqUpdateCard(cardIdSelected)
  LogDebug("BusinessCardDataProxy", "Request update card settings")
  local resources = {}
  for key, value in pairs(cardIdSelected) do
    local cardId = value
    if key == businessCardEnum.cardType.achieve then
      local achieveBaseId, _ = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetAchieveLevel(value)
      if achieveBaseId then
        cardId = achieveBaseId
      end
    elseif 0 == cardId then
      cardId = businessCardMap[key].defaultCardId
    end
    table.insert(resources, cardId)
  end
  local data = {resource_ids = resources}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SELF_VCARD_UPDATE_REQ, pb.encode(Pb_ncmd_cs_lobby.self_vcard_update_req, data))
end
function BusinessCardDataProxy:OnResCardUpdate(data)
  LogDebug("BusinessCardDataProxy", "On receive card update")
  local rebackMsg = pb.decode(Pb_ncmd_cs_lobby.self_vcard_update_res, data)
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.BusinessCard.ChangeBCStyle, rebackMsg)
end
function BusinessCardDataProxy:OnResCardResourceSyncNtf(data)
  LogDebug("BusinessCardDataProxy", "On receive card resource sync ntf")
  local cardResourceInfo = pb.decode(Pb_ncmd_cs_lobby.vcard_resource_sync_ntf, data)
  self:UpdateBusinessCardMap(cardResourceInfo)
end
function BusinessCardDataProxy:InitRedDot()
  LogDebug("BusinessCardDataProxy", "Init red dot...")
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_NEW_VCARD)
  if redDotList then
    for key, value in pairs(redDotList) do
      if value.mark then
        self:AddRedDot(value)
      end
    end
  end
end
function BusinessCardDataProxy:AddRedDot(redDotInfo)
  if redDotInfo and redDotInfo.needPassUp then
    local cardId = 0 ~= redDotInfo.event_id and redDotInfo.event_id or redDotInfo.reddot_rid
    if self:GetCardType(cardId) == businessCardEnum.cardType.avatar then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.BCAvatar, 1)
    end
    if self:GetCardType(cardId) == businessCardEnum.cardType.frame then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.BCFrame, 1)
    end
    if self:GetCardType(cardId) == businessCardEnum.cardType.achieve then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.BCAchieve, 1)
    end
  end
end
return BusinessCardDataProxy
