local ApartmentGiftProxy = class("ApartmentGiftProxy", PureMVC.Proxy)
local RoleGiftsCfg = {}
local RoleGiftsHashCfg = {}
function ApartmentGiftProxy:OnRegister()
  self.super.OnRegister(self)
  self.GiveRoleId = nil
  self.GiveGiftId = nil
  self.NewGiftCache = {}
  self:InitCfgs()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_SEND_GIFT_RES, FuncSlot(self.ResGiveGiftResult, self))
  end
end
function ApartmentGiftProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_SEND_GIFT_RES, FuncSlot(self.ResGiveGiftResult, self))
end
function ApartmentGiftProxy:InitCfgs()
  RoleGiftsCfg = ConfigMgr:GetRoleFavorabilityGiftPresentTableRow()
  if RoleGiftsCfg then
    RoleGiftsCfg = RoleGiftsCfg:ToLuaTable()
    for key, value in pairs(RoleGiftsCfg) do
      if not RoleGiftsHashCfg[value.Gift] then
        RoleGiftsHashCfg[value.Gift] = {}
      end
      RoleGiftsHashCfg[value.Gift][value.RoleId] = value
    end
  end
end
function ApartmentGiftProxy:GetRoleGiftHashCfg()
  return RoleGiftsHashCfg
end
function ApartmentGiftProxy:ItemIsGift(itemId)
  return RoleGiftsHashCfg[itemId] and true or false
end
function ApartmentGiftProxy:GetGiftToRoleCfg(giftId, roleId)
  if not giftId or not roleId then
    LogError("ApartmentGiftProxy", "Gift Cfg invalaible! Role Id = nil or Gift Id = nil ")
    return nil
  end
  if RoleGiftsHashCfg[giftId] and RoleGiftsHashCfg[giftId][roleId] then
    return RoleGiftsHashCfg[giftId] and RoleGiftsHashCfg[giftId][roleId]
  else
    LogError("ApartmentGiftProxy", "Gift Cfg invalaible! Role Id : %s, Gift Id : %s", roleId, giftId)
  end
  return nil
end
function ApartmentGiftProxy:GetGiveRoleId()
  return self.GiveRoleId
end
function ApartmentGiftProxy:GetGiveGiftId()
  return self.GiveGiftId
end
function ApartmentGiftProxy:ClearGiftInfo()
  self.GiveGiftId = nil
  self.GiveRoleId = nil
end
function ApartmentGiftProxy:ReqGiveGiftToRole(params)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local MaxLv = RoleProxy:GetRoleFavorabilityMaxLv()
  local MaxLvCfg = RoleProxy:GetRoleFavoribility(MaxLv)
  local roleApartmentInfo = KaPhoneProxy:GetRoleProperties(params.roleId)
  if not roleApartmentInfo then
    return
  end
  if MaxLv <= roleApartmentInfo.intimacy_lv and roleApartmentInfo.intimacy >= MaxLvCfg.FExp then
    local tipsMsg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "AtMaxPromiseLv")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
    return
  end
  local reqData = {
    role_id = params.roleId,
    gift_id = params.giftId,
    gift_num = params.giveNum or 1
  }
  self.GiveRoleId = reqData.role_id
  self.GiveGiftId = reqData.gift_id
  if reqData.role_id and reqData.gift_id then
    SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SEND_GIFT_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_send_gift_req, reqData))
  end
end
function ApartmentGiftProxy:ResGiveGiftResult(result)
  local resultInfo = pb.decode(Pb_ncmd_cs_lobby.salon_send_gift_res, result)
  if 0 ~= resultInfo.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, resultInfo.code)
  else
    GameFacade:SendNotification(NotificationDefines.ReqApartmentGiftPageData)
    GameFacade:SendNotification(NotificationDefines.PlayApartmentGiftFeedbackAnimation)
  end
end
function ApartmentGiftProxy:AddNewGiftRedDot(redDotInfo)
  if not redDotInfo then
    return
  end
  if not self.NewGiftCache[redDotInfo.reddot_rid] or not self.NewGiftCache[redDotInfo.reddot_rid].mark then
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseGift, 1)
  end
  self.NewGiftCache[redDotInfo.reddot_rid] = redDotInfo
end
function ApartmentGiftProxy:GetGiftRedDotInfo(itemUUID)
  return self.NewGiftCache[itemUUID]
end
function ApartmentGiftProxy:SetGiftRedDotRead(redDotUUID)
  for key, value in pairs(self.NewGiftCache) do
    if value.reddot_id == redDotUUID then
      value.mark = false
      break
    end
  end
  self:UpdateGiftRedDot()
end
function ApartmentGiftProxy:UpdateGiftRedDot()
  local RedDotNum = 0
  for key, value in pairs(self.NewGiftCache) do
    if value.mark then
      RedDotNum = RedDotNum + 1
    end
  end
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.PromiseGift, RedDotNum)
end
return ApartmentGiftProxy
