local GameModeSelectMediator = class("GameModeSelectMediator", PureMVC.Mediator)
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local gameModeSelectProxy, roomDataProxy
function GameModeSelectMediator:ListNotificationInterests()
  return {
    NotificationDefines.Common,
    NotificationDefines.GameServerReconnect,
    NotificationDefines.GameServerDisconnect,
    NotificationDefines.GameModeSelect.EnterOrQuitPlay,
    NotificationDefines.GameModeSelect,
    NotificationDefines.GameModeSelect.SwitchGameMode,
    NotificationDefines.TeamRoom.OnNtfTeamExit,
    NotificationDefines.GameModeSelect.TeamModeModify,
    NotificationDefines.TeamRoom.OnRoomCreateRes,
    NotificationDefines.TeamRoom.OnRoomReconnectRes,
    NotificationDefines.GameModeSelect.ClickGameModeSelectNavBtn,
    NotificationDefines.GameModeSelect.ClearAllGameModeSelectNavBtn,
    NotificationDefines.GameModeSelect.RestoreGameMode,
    NotificationDefines.Login.ReceiveLoginRes,
    NotificationDefines.GameModeSelect.ShowGameModeSelectUI,
    NotificationDefines.GameModeSelect.GameModeDatasUpdate
  }
end
function GameModeSelectMediator:HandleNotification(notify)
  local body = notify:GetBody()
  local notifyName = notify:GetName()
  local notifyType = notify:GetType()
  local viewComponent = self:GetViewComponent()
  if notifyName == NotificationDefines.GameServerDisconnect or notifyName == NotificationDefines.Login.ReceiveLoginRes then
    self.bSwitchGameModeEnable = true
    self.currentGameMode = GameModeSelectNum.GameModeType.None
    self.ReqGameMode = GameModeSelectNum.GameModeType.None
    if gameModeSelectProxy then
      gameModeSelectProxy:ClearData()
    end
    if roomDataProxy then
      roomDataProxy:ClearData()
    end
  elseif notifyName == NotificationDefines.Common then
    if notifyType == NotificationDefines.Common.ClickPcKey then
      local global_delegate_manager = GetGlobalDelegateManager()
      global_delegate_manager.EnterNavigationDefaultPage:Broadcast()
      self:Quit(false)
    elseif notifyType == NotificationDefines.Common.UpdateTeamInfo then
    end
  elseif notifyName == NotificationDefines.GameModeSelect then
    if notifyType == NotificationDefines.GameModeSelect.QuitRoomByEsc then
      if body then
        self:Quit(true)
      else
        self:Quit(false)
        self:BackToHomePage()
      end
    end
  elseif notifyName == NotificationDefines.GameModeSelect.SwitchGameMode then
    self:SwitchGameMode(body)
  elseif notifyName == NotificationDefines.TeamRoom.OnNtfTeamExit then
    self:OnResTeamExit()
  elseif notifyName == NotificationDefines.GameModeSelect.TeamModeModify then
    self:OnTeamModeModify(body)
  elseif notifyName == NotificationDefines.TeamRoom.OnRoomCreateRes then
    self:OnResTeamCreate(body)
  elseif notifyName == NotificationDefines.TeamRoom.OnRoomReconnectRes then
    self:OnRoomReconnectRes()
  elseif notifyName == NotificationDefines.GameModeSelect.ClickGameModeSelectNavBtn then
    self:OnClickNavBtn(body)
  elseif notifyName == NotificationDefines.GameModeSelect.ClearAllGameModeSelectNavBtn then
    self:OnClearGameModeCheckState()
  elseif notifyName == NotificationDefines.GameModeSelect.RestoreGameMode then
    self:RestoreGameMode()
  elseif notifyName == NotificationDefines.GameModeSelect.ShowGameModeSelectUI then
    self:OnShowGameModeSelectUI(body)
  elseif notifyName == NotificationDefines.GameModeSelect.GameModeDatasUpdate then
    viewComponent:SetModeBtnVisibility()
  end
end
function GameModeSelectMediator:OnShowGameModeSelectUI(body)
  local viewComponent = self:GetViewComponent()
  if body then
    if body.bShow then
      if body.bDelay and body.delayTime > 0 then
        if self.delayShowGameModeSelectUITimer then
          self.delayShowGameModeSelectUITimer:EndTask()
        end
        self.delayShowGameModeSelectUITimer = TimerMgr:AddTimeTask(body.delayTime, 0, 1, function()
          viewComponent.GameModeBtnList:SetVisibility(UE4.ESlateVisibility.Visible)
        end)
      else
        viewComponent.GameModeBtnList:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    else
      viewComponent.GameModeBtnList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    viewComponent.GameModeBtnList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function GameModeSelectMediator:OnTeamModeModify(newMode)
  if newMode then
    if newMode == GameModeSelectNum.GameModeType.Room then
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPCPage)
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RoomPagePC)
    else
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RoomPagePC)
      ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.RankPCPage)
    end
    self:OnSetNewSelectedGameModeCheckState(newMode)
    self.currentGameMode = newMode
    roomDataProxy:SetRecentlySelectedMode(self.currentGameMode)
    self:AdjustNavBtn(newMode)
  end
end
function GameModeSelectMediator:RestoreGameMode()
  self:OnSetNewSelectedGameModeCheckState(self.currentGameMode)
end
function GameModeSelectMediator:OnRegister()
  GameModeSelectMediator.super.OnRegister(self)
  self:GetViewComponent().actionLuaHandleKeyEvent:Add(self.LuaHandleKeyEvent, self)
  self:GetViewComponent().actionOnShow:Add(self.OnShow, self)
  gameModeSelectProxy = GameFacade:RetrieveProxy(ProxyNames.GameModeSelectProxy)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  roomDataProxy:SetIsInRankOrRoomUI(true)
  self.currentGameMode = roomDataProxy:GetRecentlySelectedMode()
  self.bSwitchGameModeEnable = true
  self.ReqGameMode = GameModeSelectNum.GameModeType.None
  self.bFirstEnterLobby = true
  local global_delegate_manager = GetGlobalDelegateManager()
  self.EnterLobbyPageHandler = DelegateMgr:AddDelegate(global_delegate_manager.EnterLobbyPage, self, "OnEnterLobby")
  self.ClickQuitRoomHandler = DelegateMgr:AddDelegate(global_delegate_manager.ClickQuitRoom, self, "OnClickQuitRoom")
  self.OperationInterval = self:GetViewComponent().OperationInterval
  self.bShowFrequentOperationTip = self:GetViewComponent().bShowFrequentOperationTip
  self.FrequentOperationStr = self:GetViewComponent().FrequentOperationStr
  roomDataProxy:SetStartGameStatus(false)
  gameModeSelectProxy:SetBackToHomePage(false)
  self.platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
end
function GameModeSelectMediator:OnRemove()
  GameModeSelectMediator.super.OnRemove(self)
  self:GetViewComponent().actionLuaHandleKeyEvent:Remove(self.LuaHandleKeyEvent, self)
  self:GetViewComponent().actionOnShow:Remove(self.OnShow, self)
  roomDataProxy:SetIsInRankOrRoomUI(false)
  local global_delegate_manager = GetGlobalDelegateManager()
  DelegateMgr:RemoveDelegate(global_delegate_manager.EnterLobbyPage, self.EnterLobbyPageHandler)
  DelegateMgr:RemoveDelegate(global_delegate_manager.ClickQuitRoom, self.ClickQuitRoomHandler)
  if roomDataProxy:GetTeamMemberCount() > 1 or roomDataProxy.bIsReqJoinMatch or roomDataProxy:GetEnterPracticeStatus() or roomDataProxy:GetStartGameStatus() then
    self:Quit(false)
  else
    self:Quit(true)
  end
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RoomPagePC)
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPCPage)
  if self.delayShowGameModeSelectUITimer then
    self.delayShowGameModeSelectUITimer:EndTask()
  end
end
function GameModeSelectMediator:LuaHandleKeyEvent(key, inputEvent)
  return false
end
function GameModeSelectMediator:OnResTeamMode(resCode)
  if 0 == resCode then
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.ChangeTeamMode, self.currentGameMode)
  end
end
function GameModeSelectMediator:OnClickQuitRoom(bQuitRoom)
  self:Quit(bQuitRoom)
end
function GameModeSelectMediator:OnEnterLobby(bReconnect)
  self:Enter()
end
function GameModeSelectMediator:OnShow()
  self:Enter()
end
function GameModeSelectMediator:Enter()
  local teamInfo = roomDataProxy:GetTeamInfo()
  if teamInfo and teamInfo.mode and teamInfo.mode ~= GameModeSelectNum.GameModeType.None then
    self:EnterCacheRoomMode()
  elseif self.currentGameMode ~= GameModeSelectNum.GameModeType.None then
    self:SwitchGameMode(self.currentGameMode)
  else
    local defaultGameMode = GameModeSelectNum.GameModeType.None
    for index = 0, GameModeSelectNum.NavBtnType.Team3V3V3 do
      local gameModeBtnItem = self:GetViewComponent()["WBP_GameModeSelectPage_Btn_" .. tostring(index)]
      if gameModeBtnItem and gameModeBtnItem:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        defaultGameMode = gameModeSelectProxy:GetGameModeTypeByNavBtnType(index)
        if defaultGameMode ~= GameModeSelectNum.GameModeType.None and defaultGameMode ~= GameModeSelectNum.GameModeType.Room then
          break
        end
      end
    end
    if defaultGameMode ~= GameModeSelectNum.GameModeType.None then
      self:SwitchGameMode(defaultGameMode)
    else
      self:SwitchGameMode(GameModeSelectNum.GameModeType.None)
      LogInfo("TeamRoomLog:", "defaultGameMode is None")
    end
  end
  if self.platform == GlobalEnumDefine.EPlatformType.Mobile then
    GameFacade:SendNotification(NotificationDefines.TeamRoom.SetMatchTimeWidgetVisibilty, false)
  end
end
function GameModeSelectMediator:Quit(bQuitRoom)
  self.bQuitRoom = bQuitRoom
  if bQuitRoom then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.None)
  else
    local teamInfo = roomDataProxy:GetTeamInfo()
    if teamInfo and teamInfo.members and 1 == #teamInfo.members and teamInfo.teamId and not roomDataProxy:GetStartGameStatus() then
      self:SwitchGameMode(GameModeSelectNum.GameModeType.None)
    elseif self.currentGameMode == GameModeSelectNum.GameModeType.None then
      roomDataProxy:ClearData()
    end
  end
end
function GameModeSelectMediator:SwitchGameMode(newGameMode)
  if not self.bSwitchGameModeEnable then
    self.bSwitchGameModeEnable = true
    return
  end
  if newGameMode == GameModeSelectNum.GameModeType.RankBomb or newGameMode == GameModeSelectNum.GameModeType.RankTeam then
    local levelLimit = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy):GetParameterIntValue("5908")
    local playerLevel = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
    if levelLimit > playerLevel then
      self:OnSetNewSelectedGameModeCheckState(self.currentGameMode)
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "SelfRankLevelLimit")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
  end
  local teamInfo = roomDataProxy:GetTeamInfo()
  if teamInfo then
    if teamInfo.mode and teamInfo.mode == newGameMode and self.currentGameMode == newGameMode then
      return
    elseif teamInfo.teamId and #tostring(teamInfo.teamId) > 1 and (newGameMode == GameModeSelectNum.GameModeType.RankBomb or newGameMode == GameModeSelectNum.GameModeType.RankTeam) then
      local levelLimit = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy):GetParameterIntValue("5908")
      for _, value in pairs(teamInfo.members) do
        if levelLimit > value.level and not value.bIsRobot then
          self:OnSetNewSelectedGameModeCheckState(self.currentGameMode)
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, 1078)
          return
        end
      end
    end
  end
  self:JoinGameMode(newGameMode)
end
function GameModeSelectMediator:QuitGameMode(gameMode)
  local teamInfo = roomDataProxy:GetTeamInfo()
  if teamInfo then
    if roomDataProxy:GetTeamMemberCount() > 1 then
      local pageData = {}
      pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RoomQuitTipText")
      pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsConfirmText")
      pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsCancelText")
      pageData.source = self
      pageData.cb = GameModeSelectMediator.OnTeamReturn
      ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage, false, pageData)
    elseif gameModeSelectProxy then
      if teamInfo.teamId then
        gameModeSelectProxy:RequestTeamExit(teamInfo.teamId)
      end
      self.bSwitchGameModeEnable = false
    end
  else
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      self:OnResTeamExit()
    end
  end
end
function GameModeSelectMediator:JoinGameMode(gameMode)
  if gameMode == GameModeSelectNum.GameModeType.None then
    if not self.bQuitRoom then
      return
    else
      self:QuitGameMode(self.currentGameMode)
    end
    return
  end
  local teamInfo = roomDataProxy:GetTeamInfo()
  if teamInfo and teamInfo.teamId and 0 ~= teamInfo.teamId then
    roomDataProxy:ReqTeamMode(teamInfo.teamId, gameMode, roomDataProxy:GetDefaultMapId(RoomEnum.MapType.BlastInvasion))
    self.ReqGameMode = GameModeSelectNum.GameModeType.None
    return
  end
  if gameModeSelectProxy then
    self.ReqGameMode = gameMode
    roomDataProxy:ReqTeamCreate(gameMode, roomDataProxy:GetDefaultMapId(RoomEnum.MapType.BlastInvasion), 0)
  end
end
function GameModeSelectMediator:OnResTeamCreate(data)
  local teamCreateRes = data
  if 0 ~= teamCreateRes.code then
    if teamCreateRes.code == 1004 then
      local teamInfo = roomDataProxy:GetTeamInfo()
      if teamInfo and teamInfo.mode then
        self.currentGameMode = teamInfo.mode
        roomDataProxy:SetRecentlySelectedMode(self.currentGameMode)
      end
    end
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, teamCreateRes.code)
  else
    self.currentGameMode = self.ReqGameMode
    roomDataProxy:SetRecentlySelectedMode(self.currentGameMode)
    if teamCreateRes.mode == GameModeSelectNum.GameModeType.Room then
      ViewMgr:OpenPage(self:GetViewComponent(), "RoomPagePC")
    elseif 0 ~= teamCreateRes.mode then
      ViewMgr:OpenPage(self:GetViewComponent(), "RankPCPage")
    end
    self:OnSetNewSelectedGameModeCheckState(self.currentGameMode)
    self:GetViewComponent().Img_background:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bSwitchGameModeEnable = true
  self.ReqGameMode = GameModeSelectNum.GameModeType.None
end
function GameModeSelectMediator:OnResTeamExit()
  self:BackToHomePage()
  if gameModeSelectProxy then
    gameModeSelectProxy:ClearData()
  end
end
function GameModeSelectMediator:OnSetNewSelectedGameModeCheckState(CheckGameMode)
  if nil == CheckGameMode then
    return
  end
  self:OnClearGameModeCheckState()
  self:AdjustNavBtn(CheckGameMode)
  self:ShowModeOpenTips()
  self.currentGameMode = CheckGameMode
  roomDataProxy:SetRecentlySelectedMode(self.currentGameMode)
end
function GameModeSelectMediator:OnRoomReconnectRes()
  local teamInfo = roomDataProxy:GetTeamInfo()
  if teamInfo and teamInfo.teamId and 0 ~= teamInfo.teamId and teamInfo.mode and 0 ~= teamInfo.mode then
    self.currentGameMode = teamInfo.mode
  end
end
function GameModeSelectMediator:OnClearGameModeCheckState()
  self:GetNavBtnArray()
  if self.btnArray then
    for key, value in pairs(self.btnArray) do
      if value.bp_btnIndex ~= self.currentNavBtnIndex then
        value:OnClearBtnStyle()
      end
    end
  end
end
function GameModeSelectMediator:OnTeamReturn(bFirstBtn)
  local teamInfo
  if roomDataProxy then
    teamInfo = roomDataProxy:GetTeamInfo()
  end
  if bFirstBtn then
    if teamInfo and teamInfo.teamId then
      gameModeSelectProxy:RequestTeamExit(teamInfo.teamId)
    end
    self.bSwitchGameModeEnable = false
  end
end
function GameModeSelectMediator:EnterCacheRoomMode()
  if roomDataProxy then
    local teamInfo = roomDataProxy:GetTeamInfo()
    if teamInfo and teamInfo.mode then
      local curMode = teamInfo.mode
      if curMode == GameModeSelectNum.GameModeType.None then
        if not gameModeSelectProxy.currentGameMode or gameModeSelectProxy.currentGameMode == GameModeSelectNum.GameModeType.None then
          LogInfo("TeamRoomLog:", "GameModeSelectProxy save date is nil")
          return
        end
        curMode = gameModeSelectProxy.currentGameMode
      end
      self:OnSetNewSelectedGameModeCheckState(curMode)
      self:GetViewComponent().Img_background:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if curMode == GameModeSelectNum.GameModeType.Room then
        ViewMgr:OpenPage(self:GetViewComponent(), "RoomPagePC")
      else
        ViewMgr:OpenPage(self:GetViewComponent(), "RankPCPage")
        if curMode == GameModeSelectNum.GameModeType.RankBomb or curMode == GameModeSelectNum.GameModeType.RankTeam then
          GameFacade:SendNotification(NotificationDefines.GameModeSelect.ChangeTeamMode, curMode)
        end
      end
      return
    end
    LogInfo("TeamRoomLog:", "teamInfo.mode date is nil")
  end
end
function GameModeSelectMediator:UpdateGameModeCheckStateToRoom()
  if roomDataProxy then
    local roomInfo = roomDataProxy:GetTeamInfo()
    if roomInfo and roomInfo.teamId and tonumber(roomInfo.teamId) > 0 then
      self:OnSetNewSelectedGameModeCheckState(GameModeSelectNum.GameModeType.Room)
      ViewMgr:OpenPage(self:GetViewComponent(), "RoomPagePC")
      self:GetViewComponent().Img_background:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function GameModeSelectMediator:BackToHomePage()
  gameModeSelectProxy:SetBackToHomePage(true)
  if self.platform == GlobalEnumDefine.EPlatformType.PC then
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
  elseif self.platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:PopPage(self:GetViewComponent(), UIPageNameDefine.GameModeSelectPage)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.SetMatchTimeWidgetVisibilty, true)
  end
end
function GameModeSelectMediator:GetNavBtnArray()
  if not self.btnArray or 0 == table.count(self.btnArray) then
    local viewComponent = self:GetViewComponent()
    local maxBtnIndex = 0
    for key, value in pairs(viewComponent.GameModeBtnList:GetAllChildren()) do
      if value and value.bp_btnIndex and maxBtnIndex < value.bp_btnIndex then
        maxBtnIndex = value.bp_btnIndex
      end
    end
    self.btnArray = {}
    for index = 0, maxBtnIndex do
      local btnName = "WBP_GameModeSelectPage_Btn_" .. tostring(index)
      if viewComponent[btnName] then
        table.insert(self.btnArray, viewComponent[btnName])
      end
    end
  end
  return self.btnArray
end
function GameModeSelectMediator:OnClickNavBtn(btnIndex)
  self.currentNavBtnIndex = btnIndex
  self:GetNavBtnArray()
  if btnIndex == GameModeSelectNum.NavBtnType.Boomb then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.Boomb)
  elseif btnIndex == GameModeSelectNum.NavBtnType.Team then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.Team)
  elseif btnIndex == GameModeSelectNum.NavBtnType.RankBomb then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.RankBomb)
  elseif btnIndex == GameModeSelectNum.NavBtnType.CrystalScramble then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.CrystalScramble)
  elseif btnIndex == GameModeSelectNum.NavBtnType.Custom then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.Room)
  elseif btnIndex == GameModeSelectNum.NavBtnType.Team5V5V5 then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.Team5V5V5)
  elseif btnIndex == GameModeSelectNum.NavBtnType.Team3V3V3 then
    self:SwitchGameMode(GameModeSelectNum.GameModeType.Team3V3V3)
  end
end
function GameModeSelectMediator:OnShowNavBtnnStyle(btnIndex)
  self.currentNavBtnIndex = btnIndex
  self:OnClearGameModeCheckState()
  for key, value in pairs(self.btnArray) do
    if value.bp_btnIndex == btnIndex then
      value:SetBtnStyle(true)
    end
  end
end
function GameModeSelectMediator:AdjustNavBtn(gameMode)
  if gameMode == GameModeSelectNum.GameModeType.Boomb then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.Boomb)
  elseif gameMode == GameModeSelectNum.GameModeType.RankBomb then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.RankBomb)
  elseif gameMode == GameModeSelectNum.GameModeType.Team then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.Team)
  elseif gameMode == GameModeSelectNum.GameModeType.CrystalScramble then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.CrystalScramble)
  elseif gameMode == GameModeSelectNum.GameModeType.Room then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.Custom)
  elseif gameMode == GameModeSelectNum.GameModeType.Team5V5V5 then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.Team5V5V5)
  elseif gameMode == GameModeSelectNum.GameModeType.Team3V3V3 then
    self:OnShowNavBtnnStyle(GameModeSelectNum.NavBtnType.Team3V3V3)
  end
end
function GameModeSelectMediator:ShowModeOpenTips()
  if self.btnArray then
    for key, value in pairs(self.btnArray) do
      if value.bp_btnIndex == self.currentNavBtnIndex then
        local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
        if platform == GlobalEnumDefine.EPlatformType.PC then
          local message = value:GetLimitTimeStr()
          local viewComponent = self:GetViewComponent()
          if viewComponent then
            viewComponent:OnNavBarBtnClicked(message)
          end
        end
        break
      end
    end
  end
end
return GameModeSelectMediator
