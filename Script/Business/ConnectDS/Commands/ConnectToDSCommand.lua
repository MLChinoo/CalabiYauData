local ConnectToDSCommand = class("ConnectToDSCommand", PureMVC.Command)
function ConnectToDSCommand:Execute(notification)
  LogDebug("ConnectToDSCommand", "Handle Notification name:%s type:%s", notification:GetName(), notification:GetType())
  if notification:GetName() == NotificationDefines.ReConnectToDS then
    local notificationType = notification:GetType()
    if notificationType == NotificationDefines.ReConnectToDSType.UserTrigger then
      local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
      LogDebug("ConnectToDSCommand", "will request query roominfo. roomDataProxya:%s", roomDataProxy)
      roomDataProxy:QueryRoomStatusForReconnect()
    elseif notificationType == NotificationDefines.ReConnectToDSType.QueryRoomStatus then
      local data = notification:GetBody()
      if data.exist and 3 == data.status then
        self:ConnectTo()
      else
        local pageData = {
          contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "ReconnectFailed_BattleEnd"),
          source = nil,
          cb = function(_)
            local gameInstance = UE4.UGameplayStatics.GetGameInstance(LuaGetWorld())
            gameInstance:GotoLobbyScene()
          end,
          bIsOneBtn = true
        }
        ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
      end
    end
  end
end
function ConnectToDSCommand:TryConnectTo()
end
function ConnectToDSCommand:ConnectTo()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local url = roomDataProxy:GetDSUrl()
  LogInfo("ConnectToDSCommand", " ds url %s", url)
  local matchResult = roomDataProxy:GetMatchResult()
  if not matchResult then
    return
  end
  local mapId = matchResult.map_id
  local SM = UE4.UPMGlobalStateMachine.Get(LuaGetWorld())
  if SM then
    SM:TransferGlobalPlayingState_Pvp(mapId, url)
  end
  LogInfo("ConnectToDSCommand", "matchResult cached match result%s", matchResult)
end
return ConnectToDSCommand
