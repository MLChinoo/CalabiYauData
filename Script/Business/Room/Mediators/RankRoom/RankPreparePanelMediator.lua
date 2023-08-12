local RankPreparePanelMediator = class("RankPreparePanelMediator", PureMVC.Mediator)
local roomDataProxy
function RankPreparePanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.TeamRoom.OnReadyConfirmRes,
    NotificationDefines.TeamRoom.OnReadyConfirmNtf,
    NotificationDefines.TeamRoom.OnPenaltyTimeNtf,
    NotificationDefines.TeamRoom.OnMatchResultNtf,
    NotificationDefines.TeamRoom.OnQuitBattle
  }
end
function RankPreparePanelMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.TeamRoom.OnReadyConfirmRes then
    self:OnReadyConfirmRes(notification:GetBody().bResult, notification:GetBody().resCode)
  elseif notification:GetName() == NotificationDefines.TeamRoom.OnReadyConfirmNtf then
    self:OnReadyConfirmNtf(notification:GetBody())
  elseif notification:GetName() == NotificationDefines.TeamRoom.OnPenaltyTimeNtf then
    self:OnPenaltyTimeNtf(notification:GetBody())
  elseif notification:GetName() == NotificationDefines.TeamRoom.OnMatchResultNtf then
    if notification:GetBody() then
      self:UpdatePlayerConfirmStatus()
    end
  elseif notification:GetName() == NotificationDefines.TeamRoom.OnQuitBattle then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
  end
end
function RankPreparePanelMediator:OnRegister()
  local viewComponent = self:GetViewComponent()
  viewComponent.actionOnClickPrepare:Add(self.OnClickPrepare, self)
  self:OnInit()
end
function RankPreparePanelMediator:OnRemove()
  local viewComponent = self:GetViewComponent()
  viewComponent.actionOnClickPrepare:Remove(self.OnClickPrepare, self)
  self:ClearCountdownTimeHandler()
  self:ClearPlayerCardStartAnimationTimeHandle()
  viewComponent:K2_StopAllAkEvents()
  viewComponent:StopAllAnimations()
end
function RankPreparePanelMediator:OnInit()
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self:InitPlayerCardData()
  self:PrepareCountDown()
  self:PlayerCardStartAnimation()
end
function RankPreparePanelMediator:InitPlayerCardData()
  local matchResult = roomDataProxy:GetMatchResult()
  if matchResult and matchResult.roomId and 0 ~= matchResult.roomId and matchResult.playerInfos then
    self.playerCardsNum = #matchResult.playerInfos
    for key, value in pairs(matchResult.playerInfos) do
      local cardName = "Card_" .. tostring(value.uIPos)
      local cardIns = self:GetViewComponent()[cardName]
      if cardIns then
        cardIns:SetPlayerData(value)
      end
    end
  end
end
function RankPreparePanelMediator:PlayerCardStartAnimation()
  self.randList = self:GetRandList(self.playerCardsNum)
  if self.randList and #self.randList > 0 then
    for index, value in ipairs(self.randList) do
      self.cardIndex = 1
      self:ClearPlayerCardStartAnimationTimeHandle()
      self.playerCardStartAnimationTimeHandle = TimerMgr:AddTimeTask(0, 0.05, 0, function()
        if self.cardIndex and self.randList[self.cardIndex] then
          local cardName = "Card_" .. tostring(self.randList[self.cardIndex])
          local cardIns = self:GetViewComponent()[cardName]
          if cardIns then
            cardIns:PlayStartAnimation(value)
          end
          if self.cardIndex == self.playerCardsNum then
            self:ClearPlayerCardStartAnimationTimeHandle()
          end
          self.cardIndex = self.cardIndex + 1
        end
      end)
    end
  else
    LogInfo("RankPreparePanelMediator spawn randlist nil.")
  end
end
function RankPreparePanelMediator:GetRandList(n)
  if not n or n <= 0 then
    return nil
  end
  local map = {}
  local list = {}
  for index = 1, n do
    local r = math.random(index, n)
    local a = r
    if map[r] then
      a = map[r]
    end
    table.insert(list, a)
    map[r] = map[index] or index
  end
  return list
end
function RankPreparePanelMediator:PrepareCountDown()
  local matchResult = roomDataProxy:GetMatchResult()
  if matchResult then
    self.countdownTime = matchResult.prepareLeftTime
  end
  self.playAudioCountdownTime = 5
  self.curPlayAudioCountdownTime = 0
  self:ClearCountdownTimeHandler()
  self.countdownTimeHandler = TimerMgr:AddTimeTask(0, 1, 0, function()
    self:IsAllReady()
    if self:GetViewComponent().Text_LeftTime and self.countdownTime >= 0 then
      self:GetViewComponent().Text_LeftTime:SetText(tostring(math.ceil(self.countdownTime)))
      self.countdownTime = self.countdownTime - 1
      if self.countdownTime < self.playAudioCountdownTime and self.countdownTime < self.curPlayAudioCountdownTime then
        self.curPlayAudioCountdownTime = self.curPlayAudioCountdownTime - 1
      end
      if self.countdownTime >= 0 and self.countdownTime < 10 then
        self:GetViewComponent():K2_PostAkEvent(self:GetViewComponent().CountdownTimeAudioEvent)
      end
    else
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
      self:ClearCountdownTimeHandler()
    end
  end)
end
function RankPreparePanelMediator:OnClickPrepare()
  roomDataProxy:ReqReadyConfirm()
end
function RankPreparePanelMediator:OnReadyConfirmRes(bResult, resCode)
  if bResult then
    self:UpdateReadyState(roomDataProxy:GetPlayerID())
    if self:GetViewComponent().Btn_Prepare then
      self:GetViewComponent().Btn_Prepare:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:GetViewComponent().Btn_Prepare:SetButtonIsEnabled(false)
    end
  end
end
function RankPreparePanelMediator:OnReadyConfirmNtf(preparePlayerID)
  self:UpdateReadyState(preparePlayerID)
end
function RankPreparePanelMediator:IsAllReady()
  local viewComponent = self:GetViewComponent()
  local readCount = 0
  if viewComponent.CanvasPanel_Card then
    for index = 0, self.playerCardsNum - 1 do
      local cardIns = viewComponent.CanvasPanel_Card:GetChildAt(index)
      if cardIns and cardIns:GetConfirmStatus() then
        readCount = readCount + 1
      end
    end
  end
  if readCount == self.playerCardsNum then
    viewComponent.WS_PrepareState:SetActiveWidgetIndex(1)
    for index = 0, self.playerCardsNum - 1 do
      local cardIns = viewComponent.CanvasPanel_Card:GetChildAt(index)
      if cardIns then
        cardIns:PlayCardRevealAnimation()
      end
    end
    viewComponent:K2_StopAkEvent(viewComponent.bp_loopMatchAudio)
    self:ClearCountdownTimeHandler()
    self:GetViewComponent():PlayAnimation(self:GetViewComponent().Sink, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    return true
  end
  return false
end
function RankPreparePanelMediator:UpdatePlayerConfirmStatus()
  local matchResult = roomDataProxy:GetMatchResult()
  if matchResult and matchResult.playerInfos then
    for key, value in pairs(matchResult.playerInfos) do
      if value and value.readyConfirm then
        self:UpdateReadyState(value.playerId)
      end
    end
  end
end
function RankPreparePanelMediator:UpdateReadyState(playerId)
  local viewComponent = self:GetViewComponent()
  if viewComponent and viewComponent.WS_TimeTips and playerId == roomDataProxy:GetPlayerID() then
    viewComponent.WS_TimeTips:SetActiveWidgetIndex(1)
  end
  if viewComponent and viewComponent.CanvasPanel_Card then
    for index = 0, self.playerCardsNum - 1 do
      local cardIns = viewComponent.CanvasPanel_Card:GetChildAt(index)
      if cardIns and cardIns:GetPlayerID() == playerId then
        cardIns:UpdatePrepareState(true)
        break
      end
    end
  end
end
function RankPreparePanelMediator:OnPenaltyTimeNtf(penaltyPlayerIDs)
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.RankPreparePage)
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.MatchTimeCounterPage)
end
function RankPreparePanelMediator:ClearCountdownTimeHandler()
  if self.countdownTimeHandler then
    self.countdownTimeHandler:EndTask()
    self.countdownTimeHandler = nil
  end
end
function RankPreparePanelMediator:ClearPlayerCardStartAnimationTimeHandle()
  if self.playerCardStartAnimationTimeHandle then
    self.playerCardStartAnimationTimeHandle:EndTask()
    self.playerCardStartAnimationTimeHandle = nil
  end
end
return RankPreparePanelMediator
