local CreditProxy = class("CreditProxy", PureMVC.Proxy)
function CreditProxy:OnRegister()
  CreditProxy.super.OnRegister(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_POLARIS_ERROR_NTF, FuncSlot(self.OnNtfErrorNTF, self))
  end
end
function CreditProxy:OnRemove()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_POLARIS_ERROR_NTF, FuncSlot(self.OnNtfErrorNTF, self))
  end
  CreditProxy.super.OnRemove(self)
end
function CreditProxy:OnNtfErrorNTF(ServerData)
  local Data = DeCode(Pb_ncmd_cs_lobby.polaris_error_ntf, ServerData)
  GameFacade:SendNotification(NotificationDefines.ShowCreditScoreTipCmd, Data)
end
function CreditProxy:OpenCreditPage(bUseBrowser)
  LogInfo("CreditProxy", "Open own credit page of tencent")
  local webUrl
  if UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) == GlobalEnumDefine.EPlatformType.Mobile then
    local nameEncode = UE4.UPMLuaBridgeBlueprintLibrary.LuaEncodeUrl(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerNick())
    webUrl = "https://gamecredit.qq.com/static/games/index.htm?rolename=" .. nameEncode
  else
    webUrl = "https://gamecredit.qq.com/static/index.htm#/"
  end
  if webUrl then
    if bUseBrowser then
      UE4.UKismetSystemLibrary.LaunchURL(webUrl)
    else
      UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld()):OpenWebView(webUrl, 0, 1)
    end
  else
    LogError("CreditProxy", "Can not get url")
  end
end
function CreditProxy:OpenReportPage(OpenData)
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.OpenTipOffPlayerCmd, OpenData)
  LogInfo("CreditProxy", "Open report page, target player id: %s", playerId)
end
return CreditProxy
