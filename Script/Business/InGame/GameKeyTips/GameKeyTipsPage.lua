local GameKeyTipsPage = class("GameKeyTipsPage", PureMVC.ViewComponentPage)
function GameKeyTipsPage:OnShow(luaOpenData, nativeOpenData)
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  local MyPlayerState
  if not self:IsViewCharacterInCtrlSummon() then
    MyPlayerState = self.ViewCharacter and self.ViewCharacter.PlayerState
  else
    MyPlayerState = self:TryGetPlayerStateInControlSummon()
  end
  if LocalPlayerController:IsOnlyASpectator() then
    self.ModeSwitcher:SetActiveWidgetIndex(1)
    MyPlayerState = LocalPlayerController.CurrentSpectatorPlayerState
  end
  if not MyPlayerState then
    self.Canvas_Panel_RoleSkill:SetVisibility(UE.ESlateVisibility.Hidden)
    return
  end
  self.Canvas_Panel_RoleSkill:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleProp = RoleProxy:GetRoleProfile(MyPlayerState.SelectRoleId)
  if not roleProp then
    LogError("GetRoleProfile Error", "RoleId=%s", MyPlayerState.SelectRoleId)
    return
  end
  self.Txt_RoleName:SetText(string.format("%s >>", roleProp.NameCn))
  local RoleRow = RoleProxy:GetRole(MyPlayerState.SelectRoleId)
  if not RoleRow then
    LogError("GetRole Error", "RoleId=%s", MyPlayerState.SelectRoleId)
    return
  end
  local ActiveSkillID = RoleRow.SkillActive:Get(1)
  local SkillRow = RoleProxy:GetRoleSkill(ActiveSkillID)
  if not SkillRow then
    LogError("GetRoleSkill Error", "ActiveSkillID=%s", ActiveSkillID)
    return
  end
  local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "ActiveSkill")
  self.Txt_ActiveSkillName:SetText(string.format("%s/%s", str, SkillRow.Name))
  self.Txt_ActiveSkillDesc:SetText(SkillRow.Intro)
  self.Img_ActiveSkillIcon:SetBrushFromSoftTexture(SkillRow.IconSkill)
  local PassiveSkillID = RoleRow.SkillPassive:Get(1)
  local SkillRow = RoleProxy:GetRoleSkill(PassiveSkillID)
  if not SkillRow then
    LogError("GetRoleSkill Error", "PassiveSkillID=%s", PassiveSkillID)
    return
  end
  local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "PassiveSkill")
  self.Txt_PassiveSkillName:SetText(string.format("%s/%s", str, SkillRow.Name))
  self.Txt_PassiveSkillDesc:SetText(SkillRow.Intro)
  self.Img_PassiveSkillIcon:SetBrushFromSoftTexture(SkillRow.IconSkill)
  local UniqueSkillID = RoleRow.SkillUltimate:Get(1)
  local SkillRow = RoleProxy:GetRoleSkill(UniqueSkillID)
  if not SkillRow then
    LogError("GetRoleSkill Error", "UniqueSkillID=%s", UniqueSkillID)
    return
  end
  local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "UniqueSkill")
  self.Txt_UniqueSkillName:SetText(string.format("%s/%s", str, SkillRow.Name))
  self.Txt_UniqueSkillDesc:SetText(SkillRow.Intro)
  self.Img_UniqueSkillIcon:SetBrushFromSoftTexture(SkillRow.IconSkill)
  local InputDisplayName = self:GetInputDisplayName("SkillQ")
  if InputDisplayName then
    self.Txt_SkillKey:SetText(InputDisplayName)
  end
  local inputName = "SkillX"
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName("SkillX", arr)
  local arrNum = arr:Num()
  local ele = arrNum > 0 and arr:Get(arrNum) or nil
  if ele then
    local KeyBursh = UE4.UPMLuaBridgeBlueprintLibrary.GetPMGlobals().UIConfig.KeyBindingBurshDisplayMap:Find(ele.Key)
    if KeyBursh then
      self.Switch_UltimateKey:SetActiveWidgetIndex(1)
      self.Img_UltimateKey:SetBrush(KeyBursh)
    else
      self.Switch_UltimateKey:SetActiveWidgetIndex(0)
      local Name = UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key)
      self.Txt_UltimateKey:SetText(Name)
    end
  end
  inputName = "SkillQ"
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName("SkillQ", arr)
  local arrNum = arr:Num()
  local ele = arrNum > 0 and arr:Get(arrNum) or nil
  if ele then
    local KeyBursh = UE4.UPMLuaBridgeBlueprintLibrary.GetPMGlobals().UIConfig.KeyBindingBurshDisplayMap:Find(ele.Key)
    if KeyBursh then
      self.Switch_SkillKey:SetActiveWidgetIndex(1)
      self.Img_SkillKey:SetBrush(KeyBursh)
    else
      self.Switch_SkillKey:SetActiveWidgetIndex(0)
      local Name = UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key)
      self.Txt_SkillKey:SetText(Name)
    end
  end
  self:UpdateKeyTipItems()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if GameState then
    if GameState:GetModeType() == UE4.EPMGameModeType.Team or GameState:GetModeType() == UE4.EPMGameModeType.TeamGuide then
      self.CanvasPanel_UniqueSkill:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.CanvasPanel_UniqueSkill:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.OnRoundStageUpdateHandle = DelegateMgr:AddDelegate(GameState.OnNotifyRoundStateChange, self, "OnRoundStageUpdate")
  end
end
function GameKeyTipsPage:OnHide()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if GameState and self.OnRoundStageUpdateHandle then
    DelegateMgr:RemoveDelegate(GameState.OnNotifyRoundStateChange, self.OnRoundStageUpdateHandle)
    self.OnRoundStageUpdateHandle = nil
  end
end
function GameKeyTipsPage:OnRoundStageUpdate()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if GameState and GameState:GetRoundState() == UE4.ERoundStage.End then
    ViewMgr:HidePage(self, UIPageNameDefine.GameKeyTipsPage)
  end
end
function GameKeyTipsPage:GetInputDisplayName(InputName)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName(InputName, arr)
  local arrNum = arr:Num()
  local ele = arrNum > 0 and arr:Get(arrNum) or nil
  if ele then
    return UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key)
  end
end
function GameKeyTipsPage:UpdateKeyTipItems()
  local InputNames = {
    "SettingSideAndFly",
    "EnableTeamVoice",
    "MarkWheel",
    "Wall2D",
    "EnableRoomVoice"
  }
  for index, value in ipairs(InputNames) do
    self["WBP_GameKeyTipItem_" .. index]:SetItem(value)
  end
end
return GameKeyTipsPage
