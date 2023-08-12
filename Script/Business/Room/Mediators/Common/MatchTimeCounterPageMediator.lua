local MatchTimeCounterPageMediator = class("MatchTimeCounterPageMediator", PureMVC.Mediator)
local roomProxy
local AudioPlayer = UE4.UPMLuaAudioBlueprintLibrary
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function MatchTimeCounterPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.MatchResultNtf,
    NotificationDefines.TeamRoom.SetMatchTimeWidgetVisibilty,
    NotificationDefines.TeamRoom.OnQuitBattle,
    NotificationDefines.Login.ReceiveLoginRes
  }
end
function MatchTimeCounterPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.TeamRoom.MatchResultNtf then
    self:ShowMatchResult(notify:GetBody())
  elseif notify:GetName() == NotificationDefines.TeamRoom.SetMatchTimeWidgetVisibilty then
    self:SetMatchTimeWidgetVisibilty(notify:GetBody())
  elseif notify:GetName() == NotificationDefines.TeamRoom.OnQuitBattle then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
  elseif notify:GetName() == NotificationDefines.Login.ReceiveLoginRes then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
  end
end
function MatchTimeCounterPageMediator:OnRegister()
  self:GetViewComponent().actionOnQuitMatchBtnDown:Add(self.OnQuitMatchBtnDown, self)
  self:GetViewComponent().actionOnBackRoomBtnBtnDown:Add(self.OnBackRoomBtnBtnDown, self)
  self:OnInit()
end
function MatchTimeCounterPageMediator:OnRemove()
  self:GetViewComponent().actionOnQuitMatchBtnDown:Remove(self.OnQuitMatchBtnDown, self)
  self:GetViewComponent().actionOnBackRoomBtnBtnDown:Remove(self.OnBackRoomBtnBtnDown, self)
  if self.matchTimeCounterHandle then
    self.matchTimeCounterHandle:EndTask()
    self.matchTimeCounterHandle = nil
  end
end
function MatchTimeCounterPageMediator:OnQuitMatchBtnDown()
  if roomProxy then
    roomProxy:ReqQuitMatch()
  end
end
function MatchTimeCounterPageMediator:OnBackRoomBtnBtnDown()
  if not roomProxy:GetIsInRankOrRoomUI() then
    if UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) == GlobalEnumDefine.EPlatformType.PC then
      GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
        target = UIPageNameDefine.GameModeSelectPage
      })
    elseif UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) == GlobalEnumDefine.EPlatformType.Mobile then
      ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.GameModeSelectPage)
    end
  end
end
function MatchTimeCounterPageMediator:SetMatchTimeWidgetVisibilty(bVisable)
  if bVisable then
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:GetViewComponent():SetVisibility(UE4.ESlateVisibility.Collapsed)
    GameFacade:SendNotification(NotificationDefines.TeamRoom.StartRoomMatchTimeCount, self.matchTime)
  end
end
function MatchTimeCounterPageMediator:OnInit()
  self.matchTime = -1
  self.matchTimeCounterHandle = nil
  roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local playerId = roomProxy:GetPlayerID()
  local teamInfo = roomProxy:GetTeamInfo()
  if teamInfo and teamInfo.leaderId and playerId and teamInfo.leaderId == playerId then
    self:GetViewComponent().QuitBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:GetViewComponent().QuitBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Open, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self:UpdateExpectMatchTime()
  GameFacade:SendNotification(NotificationDefines.TeamRoom.StartRoomMatchTimeCount, self.matchTime)
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    self:SetMatchTimeWidgetVisibilty(not roomProxy:GetIsInRankOrRoomUI())
  end
end
function MatchTimeCounterPageMediator:SwitchContentType(switchIndex)
  if self:GetViewComponent().WS_Type:GetActiveWidgetIndex() == switchIndex then
    return
  end
  if 1 == switchIndex then
    if roomProxy:GetGameModeType() ~= GameModeSelectNum.GameModeType.Room then
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
    else
      AudioPlayer.PostEvent(3787154861)
    end
  elseif 2 == switchIndex then
    self:GetViewComponent().WS_Type:SetActiveWidgetIndex(switchIndex)
    self:GetViewComponent().Text_Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().MatchTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().QuitBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().BackRoomBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function MatchTimeCounterPageMediator:ShowMatchResult(bResult)
  if bResult and roomProxy then
    local teamInfo = roomProxy:GetTeamInfo()
    if teamInfo and teamInfo.mode then
      if teamInfo.mode == GameModeSelectNum.GameModeType.Room then
        self:SwitchContentType(2)
      else
        self:SwitchContentType(1)
      end
    end
    self:GetViewComponent():PlayAnimation(self:GetViewComponent().Success, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function MatchTimeCounterPageMediator:OnQuitMatchNtfCallback()
  ViewMgr:ClosePage(self:GetViewComponent())
end
function MatchTimeCounterPageMediator:UpdateExpectMatchTime()
  if roomProxy then
    local expectMatchTime = roomProxy:GetExpectMatchTime()
    if expectMatchTime and expectMatchTime >= 0 then
      local minTime = roomProxy:GetExpectMatchTime() / 60
      local secTime = roomProxy:GetExpectMatchTime() % 60
      local expectTimeText = self:GetTimeText(math.floor(minTime), math.floor(secTime))
      self:GetViewComponent().Text_Expect:SetText(expectTimeText)
      self.matchTimeCounterHandle = TimerMgr:AddTimeTask(0, 1, 0, function()
        self.matchTime = self.matchTime + 1
        local minutes = math.floor(self.matchTime / 60)
        local seconds = self.matchTime % 60
        local timeText = self:GetTimeText(minutes, seconds)
        self:GetViewComponent().Text_Time:SetText(timeText)
      end)
    end
    self:GetViewComponent():PlayAnimation(self:GetViewComponent().Continue, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function MatchTimeCounterPageMediator:GetTimeText(minutes, seconds)
  local minutesText = tostring(minutes)
  local secondsText = tostring(seconds)
  if #minutesText < 2 then
    minutesText = "0" .. minutesText
  end
  if #secondsText < 2 then
    secondsText = "0" .. secondsText
  end
  local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
  local arg1 = UE4.FFormatArgumentData()
  arg1.ArgumentName = "Min"
  arg1.ArgumentValue = minutesText
  arg1.ArgumentValueType = 4
  local arg2 = UE4.FFormatArgumentData()
  arg2.ArgumentName = "Sec"
  arg2.ArgumentValue = secondsText
  arg2.ArgumentValueType = 4
  inArgsTarry:Add(arg1)
  inArgsTarry:Add(arg2)
  local timeText = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Time")
  return UE4.UKismetTextLibrary.Format(timeText, inArgsTarry)
end
return MatchTimeCounterPageMediator
