local FlapFaceProxy = class("FlapFaceProxy", PureMVC.Proxy)
local FlapFaceEnum = require("Business/Activities/FlapFace/Proxies/FlapFaceEnum")
local LimitLevel = 6
local OpenEnum = {
  Open = 2,
  Limit = 1,
  Close = 0
}
function FlapFaceProxy:OnRegister()
  FlapFaceProxy.super.OnRegister(self)
  self.open_type = OpenEnum.Close
  self.currentLevel = nil
  self.bDayLogin = {}
  self.bEnterLogin = {}
  self.open_type = {}
  self.start_time = {}
  self.end_time = {}
  self.first_login = {}
  self.type_order = {}
  self.monthlyCardJumped = false
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SHOP_MONTH_CARD_CRYSTAL_RES, FuncSlot(self.OnMonthCardCrystalRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REPORT_LOGIN_PICTURE_NTF, FuncSlot(self.OnLoginPictureNtf, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_REPORT_LOGIN_PICTURE_RES, FuncSlot(self.OnLoginPictureRes, self))
end
function FlapFaceProxy:OnRemove()
  FlapFaceProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SHOP_MONTH_CARD_CRYSTAL_RES, FuncSlot(self.OnMonthCardCrystalRes, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REPORT_LOGIN_PICTURE_NTF, FuncSlot(self.OnLoginPictureNtf, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_REPORT_LOGIN_PICTURE_RES, FuncSlot(self.OnLoginPictureRes, self))
  self.currentLevel = nil
end
function FlapFaceProxy:SetConfig(data, indexName)
  self.bDayLogin[indexName] = data.param == "0"
  self.bEnterLogin[indexName] = data.param == "1"
  self.open_type[indexName] = data.open_type
  self.start_time[indexName] = data.start_time
  local index
  for i, v in ipairs(self.type_order) do
    if v.index == indexName then
      index = i
      break
    end
  end
  if index then
    self.type_order[index].type_order = data.type_order
  else
    self.type_order[#self.type_order + 1] = {
      indexName = indexName,
      type_order = data.type_order
    }
  end
  table.sort(self.type_order, function(a, b)
    return a.type_order < b.type_order
  end)
  self.end_time[indexName] = data.end_time
  if self.currentLevel == nil then
    local PlayerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
    local level = PlayerAttrProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
    self.currentLevel = level
  end
end
function FlapFaceProxy:GetKey(indexName)
  if nil == indexName then
    LogError("FlapFaceProxy", "indexName is nil")
  end
  local PlayerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local playerid = PlayerAttrProxy:GetPlayerId()
  local key = "flapface_" .. tostring(playerid) .. tostring(indexName)
  return key
end
function FlapFaceProxy:WritePopTimeStamp(timestamp, indexName)
  local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
  local key = self:GetKey(indexName)
  local resTbl = {}
  resTbl[key] = tostring(timestamp)
  SettingSaveGameProxy:WriteExtraData(resTbl)
end
function FlapFaceProxy:GetLastPopTimeStamp(indexName)
  local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
  local key = self:GetKey(indexName)
  local lastPopTime = SettingSaveGameProxy:GetExtraDataByKey(key)
  return lastPopTime
end
function FlapFaceProxy:CheckPopNormalPage(indexName)
  if self.open_type[indexName] == nil then
    return false
  end
  LogInfo("FlapFaceProxy", "check pop page:" .. tostring(indexName))
  local PlayerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local playerid = PlayerAttrProxy:GetPlayerId()
  if indexName == FlapFaceEnum.FlapFace then
    if self.currentLevel and self.currentLevel < LimitLevel then
      LogInfo("FlapFaceProxy", "not reach to limitLevel!")
      return false
    end
  elseif indexName == FlapFaceEnum.MonthlyCard then
  end
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if not NewPlayerGuideProxy:IsAllGuideComplete() then
    LogInfo("FlapFaceProxy", "guide not complete!")
    return false
  end
  if self.open_type[indexName] == OpenEnum.Close then
    LogInfo("FlapFaceProxy", "opentype is close")
    return false
  end
  local currentTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if self.open_type[indexName] == OpenEnum.Limit and (currentTime > self.end_time[indexName] or currentTime < self.start_time[indexName]) then
    LogInfo("FlapFaceProxy", "opentype is limit time is not activity time")
    return false
  end
  if self.bDayLogin[indexName] then
    local lastTime = self:GetLastPopTimeStamp(indexName)
    if currentTime and lastTime then
      local currentDay = os.date("!%j", tonumber(currentTime))
      local lastDay = os.date("!%j", tonumber(lastTime))
      if lastDay == currentDay then
        LogInfo("FlapFaceProxy", "same day")
        return false
      else
        LogInfo("FlapFaceProxy", "not same day")
        self:WritePopTimeStamp(currentTime, indexName)
        return true
      end
    else
      LogInfo("FlapFaceProxy", "last time is nil")
      self:WritePopTimeStamp(currentTime, indexName)
      return true
    end
  elseif self.bEnterLogin[indexName] then
    if self.bFirstLogin and self.first_login[indexName] ~= false then
      self.first_login[indexName] = false
      LogInfo("FlapFaceProxy", "first login is true")
      self:WritePopTimeStamp(currentTime, indexName)
      return true
    else
      LogInfo("FlapFaceProxy", "first login is false")
    end
  end
  LogInfo("FlapFaceProxy", "nothing is here")
  return false
end
function FlapFaceProxy:CheckPopPage(indexName)
  if indexName == FlapFaceEnum.FlapFace then
    return self:CheckPopNormalPage(indexName)
  elseif indexName == FlapFaceEnum.MonthlyCard then
    return self:CheckPopMonthlyCardPage()
  end
end
function FlapFaceProxy:CheckPopMonthlyCardPage()
  print("CheckPopMonthlyCardPage", self.monthlyCardJumped)
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local data = HermesProxy:GetMonthCardData()
  if nil == data then
    LogInfo("FlapFaceProxy", "the user is not monthly card user")
    return false
  end
  local currentTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if currentTime > data.end_time then
    LogInfo("FlapFaceProxy", "the monthly card is out of time")
    return false
  end
  if self.monthlyCardJumped == true then
    LogInfo("FlapFaceProxy", "now day is poped")
    return false
  end
  return true
end
function FlapFaceProxy:SetMonthlyCardJumped(bJumped)
  self.monthlyCardJumped = bJumped
end
function FlapFaceProxy:SetLoginFlag(bFirstLogin)
  self.bFirstLogin = bFirstLogin
end
function FlapFaceProxy:SetCurrrentPopPage(indexName)
  self.indexName = indexName
end
function FlapFaceProxy:GetCurrrentPopPage()
  return self.indexName
end
function FlapFaceProxy:GetTypeOrder()
  return self.type_order
end
function FlapFaceProxy:OnMonthCardCrystalRes(InServerData)
  local data = DeCode(Pb_ncmd_cs_lobby.shop_month_card_crystal_res, InServerData)
  if 0 ~= data.code then
    print("data.code", data.code)
  end
  if type(self.monthCardCallback) == "function" then
    self.monthCardCallback(0 == data.code)
    self.monthCardCallback = nil
  end
end
function FlapFaceProxy:MonthCardCrystalReq(callback)
  self.monthCardCallback = callback
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SHOP_MONTH_CARD_CRYSTAL_REQ, pb.encode(Pb_ncmd_cs_lobby.shop_month_card_crystal_req, {}))
end
function FlapFaceProxy:SendLoginPictureReq(data)
  local pictures = {}
  for i, v in ipairs(data) do
    pictures[#pictures + 1] = v
  end
  SendRequest(Pb_ncmd_cs.NCmdId.NID_REPORT_LOGIN_PICTURE_REQ, pb.encode(Pb_ncmd_cs_lobby.report_login_picture_req, {pictures = pictures}))
end
function FlapFaceProxy:OnLoginPictureNtf(data)
  local serverData = DeCode(Pb_ncmd_cs_lobby.report_login_picture_ntf, data)
  table.print(serverData)
  print("OnLoginPictureNtf")
  self.monthlyCardJumped = false
  if serverData.pictures then
    for i, v in ipairs(serverData.pictures) do
      if v == FlapFaceEnum.MonthlyCard then
        self.monthlyCardJumped = true
      end
    end
  end
end
function FlapFaceProxy:OnLoginPictureRes(data)
  local serverData = DeCode(Pb_ncmd_cs_lobby.report_login_picture_res, data)
  if 0 ~= serverData.code then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, serverData.code)
  end
end
return FlapFaceProxy
