local ResultScoreListItem_PC = class("ResultScoreListItem_PC", PureMVC.ViewComponentPanel)
local BattleResultStandingsPlayerItemMediator = require("Business/BattleResult/Mediators/BattleResultStandingsPlayerItemMediator")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultScoreListItem_PC:ListNeededMediators()
  return {BattleResultStandingsPlayerItemMediator}
end
function ResultScoreListItem_PC:Construct()
  LogDebug("ResultScoreListItem_PC", "Construct ")
  ResultScoreListItem_PC.super.Construct(self)
  self.MenuAnchor_FriendContext.OnGetMenuContentEvent:Bind(self, self.CreateContextMenu)
  self.Button_Praise.OnClicked:Add(self, self.OnButtonPraise)
  if self.Paticle_Praise then
    self.Paticle_Praise:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if self.Button_Tipoff then
    self.Button_Tipoff.OnClicked:Add(self, self.OnHandleClickedTipoff)
  end
  self.platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
end
function ResultScoreListItem_PC:Destruct()
  LogDebug("ResultScoreListItem_PC", "Destruct")
  ResultScoreListItem_PC.super.Destruct(self)
  self.Button_Praise.OnClicked:Remove(self, self.OnButtonPraise)
  if self.Button_Tipoff then
    self.Button_Tipoff.OnClicked:Remove(self, self.OnHandleClickedTipoff)
  end
end
function ResultScoreListItem_PC:OnStandingsLikeNtf(standings_like_ntf)
  if not self.PlayerState then
    return
  end
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  if standings_like_ntf.target_id == MyPlayerInfo.player_id and standings_like_ntf.src_id == self.PlayerState.player_id then
    self:PlayAnimation(self.PlayPraiseAni, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, string.format("ResultLike%s", standings_like_ntf.like_id))
    self.Text_Like:SetText(text)
  end
end
function ResultScoreListItem_PC:OnButtonPraise()
  if not self.PlayerState then
    return
  end
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local sum = tonumber(UE4.UKismetStringTableLibrary.GetTableEntrySourceString(StringTablePath.ST_InGame, "ResultLikeSum"))
  local standings_like_req = {}
  standings_like_req.target_id = self.PlayerState.player_id
  standings_like_req.like_id = math.random(sum)
  standings_like_req.broadcast_ids = battleResultProxy:GetPlayerIds()
  battleResultProxy:StandingsLike(standings_like_req)
  self.WidgetSwitcher_Priaise:SetActiveWidgetIndex(1)
  if self.Paticle_Praise then
    self.Paticle_Praise:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ResultScoreListItem_PC:OnRefreshTipoff()
  if not self.Switcher_Tipoff then
    LogDebug("ResultScoreListItem_PC", "Miss Tipoff UI .")
    return
  end
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    self.Switcher_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local MyPlayerInfo = battleResultProxy:GetMyPlayerInfo()
  if not self.PlayerState or not MyPlayerInfo then
    self.Switcher_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local tipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.InGameTipoffPlayerDataProxy)
  if not tipoffPlayerDataProxy then
    self.Switcher_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local bHide = tipoffPlayerDataProxy:CheckPlayerTipoffMax(self.PlayerState.player_id, UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME)
  local bIsABot = false
  local CachePlayerInfo = battleResultProxy:GetCachedPlayerInfo(self.PlayerState.player_id)
  if CachePlayerInfo then
    bIsABot = CachePlayerInfo.bIsABot
  end
  local GameState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if GameState and GameState.GetModeType and GameState:GetModeType() == UE4.EPMGameModeType.TeamGuide then
    bIsABot = true
  end
  if not bIsABot then
    if self.PlayerState.player_id == MyPlayerInfo.player_id then
      self.Switcher_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Switcher_Tipoff:SetVisibility(UE4.ESlateVisibility.Visible)
      if bHide then
        self.Switcher_Tipoff:SetActiveWidgetIndex(1)
      else
        self.Switcher_Tipoff:SetActiveWidgetIndex(0)
      end
    end
  else
    self.Switcher_Tipoff:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ResultScoreListItem_PC:OnMouseButtonDown(InGeometry, InMouseEvent)
  local actionName = self.platform == GlobalEnumDefine.EPlatformType.Mobile and "RightMouseButton" or UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(InMouseEvent).KeyName
  if "RightMouseButton" == actionName then
    if not self.PlayerState then
      return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
    if not BattleResultProxy then
      return
    end
    local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
    if self.PlayerState.player_id == MyPlayerInfo.player_id then
      return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    self:K2_PostAkEvent(self.AK_Map:Find("Next"), true)
    local ScreenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    local LocalPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenPos)
    self.MenuAnchor_FriendContext.Slot:SetPosition(UE4.FVector2D(LocalPos.X + 122 + 20, 0))
    self.MenuAnchor_FriendContext:Open(true)
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  return UE4.UWidgetBlueprintLibrary.UnHandled()
end
function ResultScoreListItem_PC:CreateContextMenu()
  if not self.PlayerState then
    return
  end
  local showMenu = true
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  if BattleResultProxy.settle_battle_game_ntf.room_mode == Pb_ncmd_cs.ERoomMode.RoomMode_ROOM then
    local CachePlayerInfo = BattleResultProxy:GetCachedPlayerInfo(self.PlayerState.player_id)
    if CachePlayerInfo and CachePlayerInfo.bIsABot then
      showMenu = false
    end
  end
  if not showMenu then
    return
  end
  local PanelClass = ObjectUtil:LoadClass(self.bp_friendShortcutMenuClass)
  if PanelClass then
    local FriendShortcutIns = UE4.UWidgetBlueprintLibrary.Create(self, PanelClass)
    if FriendShortcutIns then
      local shortcutMenuData = {}
      shortcutMenuData.bPlayerInfo = true
      shortcutMenuData.bFriend = true
      shortcutMenuData.bMsg = true
      shortcutMenuData.bInviteTeam = true
      shortcutMenuData.bShield = true
      shortcutMenuData.bReport = true
      shortcutMenuData.playerId = self.PlayerState.player_id
      LogDebug("ResultScoreListItem_PC playerId", "%s", self.PlayerState.player_id)
      shortcutMenuData.playerNick = self.PlayerState.nick
      FriendShortcutIns.actionOnExecute:Add(function()
        self.MenuAnchor_FriendContext:Close()
      end, self)
      FriendShortcutIns:Init(shortcutMenuData)
      return FriendShortcutIns
    end
  end
  return nil
end
function ResultScoreListItem_PC:OnHandleClickedTipoff()
  if self.PlayerState then
    local TipoffPageParam = {
      TargetUID = self.PlayerState.player_id,
      EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME,
      SceneType = UE4.ECyTipoffSceneType.IN_GAME
    }
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.OpenTipOffPlayerCmd, TipoffPageParam)
  end
end
function ResultScoreListItem_PC:Update(PlayerState)
  LogDebug("ResultScoreListItem_PC", "Update")
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local standings_like_ntfs = battleResultProxy:GetStandingsLikeNtfs()
  for key, value in pairs(standings_like_ntfs) do
    if self.OnStandingsLikeNtf then
      self:OnStandingsLikeNtf(value)
    end
  end
  self:OnRefreshTipoff()
end
return ResultScoreListItem_PC
