local BattleScorePlayer = class("BattleScorePlayer", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local BattleScoreDefine = require("Business/BattleScores/Proxies/BattleScoresDefine")
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local DeadIconOpacity = 0.3
local MemberBGDefault = 0
local MemberBGBlue = 1
local MemberBGRed = 2
local MemberBGDead = 3
local MemberBGSelf = 4
local RandPingMin = 30
local RandPingMax = 75
local RandPingTimerMin = 2
local RandPingTimerMax = 6
function BattleScorePlayer:Construct()
  BattleScorePlayer.super.Construct(self)
  self.AIPingUpdateInterval = self.AIPingUpdateInterval or 0
  self.AIPingUpdateTime = self.AIPingUpdateTime or 0
  self.OpIdx = BattleScoreDefine.OpIdxJuBao
  if self.btn_jubao then
    self.btn_jubao.OnClicked:Add(self, self.OnClickOpJuBao)
  end
  if self.btn_voice_able then
    self.btn_voice_able.OnClicked:Add(self, self.OnClickOpVoice)
  end
  if self.btn_voice_disable then
    self.btn_voice_disable.OnClicked:Add(self, self.OnClickOpVoice)
  end
  if self.btn_friend then
    self.btn_friend.OnClicked:Add(self, self.OnClickOpFriend)
  end
end
function BattleScorePlayer:Destruct()
  BattleScorePlayer.super.Destruct(self)
  if self.btn_jubao then
    self.btn_jubao.OnClicked:Remove(self, self.OnClickOpJuBao)
  end
  if self.btn_voice_able then
    self.btn_voice_able.OnClicked:Remove(self, self.OnClickOpVoice)
  end
  if self.btn_voice_disable then
    self.btn_voice_disable.OnClicked:Remove(self, self.OnClickOpVoice)
  end
  if self.btn_friend then
    self.btn_friend.OnClicked:Remove(self, self.OnClickOpFriend)
  end
end
function BattleScorePlayer:OnClickOpJuBao()
  if self.PlayerState and self.PlayerState.UID then
    local TipoffPageParam = {
      TargetUID = self.PlayerState.UID,
      EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME,
      SceneType = UE4.ECyTipoffSceneType.IN_GAME
    }
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.OpenTipOffPlayerCmd, TipoffPageParam)
  end
end
function BattleScorePlayer:OnClickOpVoice()
  if self.PlayerState and self.PlayerState.UID then
    local ForbidVoiceState = UE4.UPMVoiceManager.Get(self):GetPlayreForbidVoiceState(self.PlayerState.UID)
    UE4.UPMVoiceManager.Get(self):SetPlayreForbidVoiceState(self.PlayerState.UID, not ForbidVoiceState)
    ForbidVoiceState = UE4.UPMVoiceManager.Get(self):GetPlayreForbidVoiceState(self.PlayerState.UID)
    if ForbidVoiceState then
      local msg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Chat, "ForbidPlayerMsg")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
    end
  end
end
function BattleScorePlayer:OnClickOpFriend()
  if not self.PlayerState then
    return
  end
  if not self.PlayerState.PlayerNamePrivate then
    return
  end
  if not self.PlayerState.UID then
    return
  end
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy then
    if not self.PlayerState.bIsABot then
      friendDataProxy:ReqFriendAdd(self.PlayerState.PlayerNamePrivate, self.PlayerState.UID, FriendEnum.FriendType.Friend)
    end
    local text = ObjectUtil:GetTextFromFormat(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "15"), {
      self.PlayerState.PlayerNamePrivate
    })
    GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, text)
    local BattleScoresProxy = GameFacade:RetrieveProxy(ProxyNames.BattleScoresProxy)
    BattleScoresProxy:AddFriendApply(self.PlayerState.UID)
  end
end
function BattleScorePlayer:Tick(MyGeometry, InDeltaTime)
  self.AIPingUpdateTime = self.AIPingUpdateTime + InDeltaTime
end
function BattleScorePlayer:SetOpIdx(OpIdx)
  self.OpIdx = OpIdx
end
function BattleScorePlayer:UpdateOpUI()
  if self.Switch_OpIcon then
    self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switch_OpIcon:SetActiveWidgetIndex(self.OpIdx)
    local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
    if not (GameState and MyPlayerController) or not MyPlayerState then
      return
    end
    if not self.PlayerState.UID then
      return
    end
    if self.OpIdx == BattleScoreDefine.OpIdxJuBao then
      local tipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.InGameTipoffPlayerDataProxy)
      if not tipoffPlayerDataProxy then
        self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
        return
      end
      local bHide = tipoffPlayerDataProxy:CheckPlayerTipoffMax(self.PlayerState.UID, UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME)
      local bIsABot = self.PlayerState.bIsABot
      if not bIsABot then
        if self.PlayerState == MyPlayerState then
          self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
        else
          self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          if bHide then
            self.btn_jubao:SetIsEnabled(false)
          else
            self.btn_jubao:SetIsEnabled(true)
          end
        end
      else
        self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
    if self.OpIdx == BattleScoreDefine.OpIdxFriend then
      if self.PlayerState == MyPlayerState then
        self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
        local BattleScoresProxy = GameFacade:RetrieveProxy(ProxyNames.BattleScoresProxy)
        if not self.PlayerState.PlayerNamePrivate then
          return
        end
        local IsFriend = SettingCombatProxy:IsFriend(self.PlayerState.PlayerNamePrivate)
        local IsFriendApply = BattleScoresProxy:IsFriendApply(self.PlayerState.UID)
        if IsFriend or IsFriendApply then
          self.btn_friend:SetIsEnabled(false)
        else
          self.btn_friend:SetIsEnabled(true)
        end
      end
    end
    if self.OpIdx == BattleScoreDefine.OpIdxVoice then
      if self.PlayerState == MyPlayerState then
        self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local ForbidVoiceState = UE4.UPMVoiceManager.Get(self):GetPlayreForbidVoiceState(self.PlayerState.UID)
        if ForbidVoiceState then
          self.Switch_Voice:SetActiveWidgetIndex(1)
        else
          self.Switch_Voice:SetActiveWidgetIndex(0)
        end
      end
    end
  end
end
function BattleScorePlayer:Reset()
  self.PlayerState = nil
  local EmptyText = ""
  self.PlayerNameText:SetText(EmptyText)
  self.DamageText:SetText(EmptyText)
  self.PingText:SetText(EmptyText)
  self.KdaText:SetText(EmptyText)
  self.ChargeText:SetText(EmptyText)
  self.WidgetSwitcher_Bg:SetActiveWidgetIndex(MemberBGDefault)
  self.IconBorder:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ImageRole:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ImageDeath:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasPanel_Growth:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.Switch_OpIcon then
    self.Switch_OpIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
function BattleScorePlayer:Update(PlayerState)
  self:SetPlayerState(PlayerState)
  self.PlayerState = PlayerState
  if not self.PlayerState then
    self:Reset()
  else
    self:UpdatePlayer()
  end
end
function BattleScorePlayer:UpdatePlayer()
  self:UpdatePing()
  self:UpdatePlayerIcon()
  self:UpdateSlotStyle()
  self:UpdateKda()
  self:UpdateDamage()
  self:UpdateOpUI()
end
function BattleScorePlayer:UpdatePlayerIcon()
  local func = function()
    if not self.PlayerState then
      return
    end
    if self.PlayerState.GetPlayerName then
      self.PlayerNameText:SetText(self.PlayerState:GetPlayerName())
    end
    local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    self.IconBorder:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ImageRole:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.PlayerState.RoleSkinId then
      local SkinRow = RoleProxy:GetRoleSkin(self.PlayerState.RoleSkinId)
      if SkinRow then
        self.ImageRole:SetBrushFromSoftTexture(SkinRow.IconRoleScoreboard)
      end
    end
  end
  pcall(func)
end
function BattleScorePlayer:UpdateSlotStyle()
  if not self.PlayerState or not self.PlayerState:IsValid() then
    return
  end
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local bIsLocalControlly = false
  if self.PlayerState == MyPlayerState then
    bIsLocalControlly = true
  elseif self:IsPlayingLocalReplayFile() and self.PlayerState == MyPlayerController.CurrentSpectatorPlayerState then
    bIsLocalControlly = true
  elseif self.PlayerState.PawnPrivate and self.PlayerState.PawnPrivate:IsValid() and self.PlayerState.PawnPrivate.IsLocallyControlled then
    if GameState:GetModeType() == UE4.EPMGameModeType.TeamGuide then
      bIsLocalControlly = false
    else
      bIsLocalControlly = self.PlayerState.PawnPrivate:IsLocallyControlled()
    end
  end
  local MyTeamNum = MyPlayerState.AttributeTeamID
  local bIsFriendly = bIsLocalControlly or self.PlayerState.AttributeTeamID == MyTeamNum
  local bIsAlive = true
  if self.PlayerState.PawnPrivate and self.PlayerState.PawnPrivate.IsAlive then
    bIsAlive = self.PlayerState.PawnPrivate:IsAlive(false)
  else
    bIsAlive = false
  end
  local TextStyle = self.TextColorNormal
  if bIsLocalControlly then
    TextStyle = bIsAlive and self.TextColorSelf or self.TextColorDead
  else
    TextStyle = bIsAlive and self.TextColorNormal or self.TextColorDead
  end
  self.PlayerNameText:SetColorAndOpacity(TextStyle)
  self.ChargeText:SetColorAndOpacity(TextStyle)
  self.DamageText:SetColorAndOpacity(TextStyle)
  self.PingText:SetColorAndOpacity(TextStyle)
  self.KdaText:SetColorAndOpacity(TextStyle)
  self.ImageDeath:SetVisibility(bIsAlive and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ImageRole:SetOpacity(bIsAlive and 1.0 or DeadIconOpacity)
  local bBlueBrush = bIsFriendly
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    bBlueBrush = self.PlayerState.AttributeTeamID ~= GameState.BombOwnerTeam
  elseif 3 == GameState.DefaultNumTeams then
    bBlueBrush = self.PlayerState.AttributeTeamID == MyTeamNum
  else
    bBlueBrush = 1 == self.PlayerState.AttributeTeamID
  end
  if bIsLocalControlly then
    self.WidgetSwitcher_Bg:SetActiveWidgetIndex(MemberBGSelf)
    if self.GrowthBg then
      self.GrowthBg:SetColorAndOpacity(self.GrowthBgColorSelf)
    end
  else
    self.WidgetSwitcher_Bg:SetActiveWidgetIndex(bIsAlive and (bBlueBrush and MemberBGBlue or MemberBGRed) or MemberBGDead)
    if self.GrowthBg then
      self.GrowthBg:SetColorAndOpacity(bIsAlive and (bBlueBrush and self.GrowthBgColorBlue or self.GrowthBgColorRed) or self.GrowthBgColorDead)
    end
  end
end
function BattleScorePlayer:UpdateKda()
  if not self.PlayerState then
    return
  end
  if self.PlayerState.NumKills and self.PlayerState.NumDeaths and self.PlayerState.NumAssist then
    self.KdaText:SetText(string.format("%s / %s / %s", self.PlayerState.NumKills, self.PlayerState.NumDeaths, self.PlayerState.NumAssist))
  end
end
function BattleScorePlayer:UpdateDamage()
  if self.DamageText and self.PlayerState.TotalDamage then
    self.DamageText:SetText(math.floor(self.PlayerState.TotalDamage))
  end
end
function BattleScorePlayer:UpdatePing()
  if not self.PlayerState then
    return
  end
  if self.PlayerState.PlayerPing then
    if self.PlayerState.PlayerPing >= 100000 or self.PlayerState.PlayerPing < 0 then
      self.PingSwitcher:SetActiveWidgetIndex(1)
    else
      self.PingSwitcher:SetActiveWidgetIndex(0)
      if self.PlayerState.bIsABot then
        if self.AIPingUpdateTime >= self.AIPingUpdateInterval then
          self.PingText:SetText(self:GetRandomPing())
          self.AIPingUpdateTime = 0
          self.AIPingUpdateInterval = math.random(RandPingTimerMin, RandPingTimerMax)
        end
      else
        self.PingText:SetText(math.floor(self.PlayerState.PlayerPing + 0.5))
      end
    end
  end
end
local RandomInc = {
  1,
  2,
  -1,
  -2
}
local RandomIncSize = table.count(RandomInc)
function BattleScorePlayer:GetRandomPing()
  if not self.RandomPing then
    self.RandomPing = math.floor(math.random(RandPingMin, RandPingMax))
  elseif math.random(100) > 50 then
    self.RandomPing = math.clamp(self.RandomPing + RandomInc[math.random(RandomIncSize)], RandPingMin, RandPingMax)
  end
  return self.RandomPing
end
function BattleScorePlayer:UpdateConnectionState(ReadyState)
  self.PingSwitcher:SetActiveWidgetIndex(ReadyState and 1 or 0)
end
return BattleScorePlayer
