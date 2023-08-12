local SettingNetProxy = class("SettingNetProxy", PureMVC.Proxy)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
function SettingNetProxy:OnRegister()
  self.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SETTING_SYNC_NTF, FuncSlot(self.OnRcvSyncSetting, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SETTING_UPDATE_RES, FuncSlot(self.OnRcvUpdateSetting, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_GET_PLAYER_SETTING_RES, FuncSlot(self.OnGetPlayerSettingRes, self))
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SET_PLAYER_SETTING_RES, FuncSlot(self.OnSetPlayerSettingRes, self))
end
function SettingNetProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SETTING_SYNC_NTF, FuncSlot(self.OnRcvSyncSetting, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SETTING_UPDATE_RES, FuncSlot(self.OnRcvUpdateSetting, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_GET_PLAYER_SETTING_RES, FuncSlot(self.OnGetPlayerSettingRes, self))
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SET_PLAYER_SETTING_RES, FuncSlot(self.OnSetPlayerSettingRes, self))
end
function SettingNetProxy:ReqSyncSetting()
  local data = {key = 0}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SETTING_SYNC_REQ, pb.encode(Pb_ncmd_cs_lobby.setting_sync_req, data))
end
function SettingNetProxy:ReqUpdateSetting(setting_list)
  setting_list = SettingHelper.FilterVisualAttribute(setting_list)
  setting_list = SettingHelper.FilterLocalAttribute(setting_list)
  LogInfo("SettingNetProxy", "ReqUpdateSetting")
  local setting_list2 = table.copy(setting_list)
  setting_list2[#setting_list2 + 1] = {
    key = SettingStoreMap.indexKeyToSaveKey.InitFlag,
    value = 1
  }
  SettingHelper.PrintSettingList(setting_list2)
  table.print(setting_list2)
  local data = {setting_list = setting_list2, is_sync = 1}
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SETTING_UPDATE_REQ, pb.encode(Pb_ncmd_cs_lobby.setting_update_req, data))
end
function SettingNetProxy:OnRcvSyncSetting(InServerData)
  local settingData = DeCode(Pb_ncmd_cs_lobby.setting_sync_ntf, InServerData)
  if settingData.code == nil or 0 == settingData.code then
    local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
    LogInfo("SettingNetProxy", "OnRcvSyncSetting")
    local setting_list = settingData.setting_list
    local bInit = false
    for k, v in pairs(setting_list) do
      if v.key == SettingStoreMap.indexKeyToSaveKey.InitFlag and 1 == v.value then
        bInit = true
      end
    end
    setting_list = SettingHelper.FilterVisualAttribute(setting_list)
    setting_list = SettingHelper.FilterLocalAttribute(setting_list)
    setting_list = SettingHelper.FilterServerNotSaveAttribute(setting_list)
    SettingHelper.PrintSettingList(setting_list)
    LogInfo("SettingNetProxy bInit", tostring(bInit))
    if bInit then
      setting_list = SettingHelper.FixVoluemAttribute(setting_list)
      SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToApplyChange)
    else
      setting_list = SettingHelper.FixVoluemAttribute({})
      SettingSaveDataProxy:UpdateCurrentData(setting_list, SettingEnum.SaveStatus.SaveToApplyChange)
    end
  end
end
function SettingNetProxy:OnRcvUpdateSetting(InServerData)
  local settingData = DeCode(Pb_ncmd_cs_lobby.setting_update_res, InServerData)
  if settingData.code == nil or 0 ~= settingData.code then
    ViewMgr:OpenPage(self, UIPageNameDefine.PopUpPromptPage, false, settingData.code)
  end
end
function SettingNetProxy:ReqSetPlayerSetting(keyArr, valueArr)
  local data = {keys = keyArr, values = valueArr}
  LogInfo("SettingNetProxy", " ReqSetPlayerSetting")
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SET_PLAYER_SETTING_REQ, pb.encode(Pb_ncmd_cs_lobby.set_player_setting_req, data))
end
function SettingNetProxy:OnSetPlayerSettingRes(InServerData)
  local settingData = DeCode(Pb_ncmd_cs_lobby.set_player_setting_res, InServerData)
  if settingData.code == nil or 0 ~= settingData.code then
    ViewMgr:OpenPage(self, UIPageNameDefine.PopUpPromptPage, false, settingData.code)
  end
end
function SettingNetProxy:ReqGetPlayerSetting(playerid)
  local data = {player_id = playerid}
  LogInfo("SettingNetProxy", " ReqGetPlayerSetting playerid:" .. tostring(playerid))
  SendRequest(Pb_ncmd_cs.NCmdId.NID_GET_PLAYER_SETTING_REQ, pb.encode(Pb_ncmd_cs_lobby.get_player_setting_req, data))
end
function SettingNetProxy:OnGetPlayerSettingRes(InServerData)
  local settingData = DeCode(Pb_ncmd_cs_lobby.get_player_setting_res, InServerData)
  if settingData.code == nil or 0 ~= settingData.code then
    ViewMgr:OpenPage(self, UIPageNameDefine.PopUpPromptPage, false, settingData.code)
    SettingCacheProxy:DoCacheCallFunc(settingData.player_id)
  else
    local SettingCacheProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCacheProxy)
    SettingCacheProxy:AddCache(settingData.player_id, settingData.settings)
    SettingCacheProxy:DoCacheCallFunc(settingData.player_id)
  end
end
return SettingNetProxy
