local GameSkillPage = class("GameSkillPage", PureMVC.ViewComponentPage)
function GameSkillPage:OnShow(luaOpenData, nativeOpenData)
  self.Button_Close.OnClicked:Add(self, self.OnExitButtonClicked)
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  local MyPlayerState = self.ViewCharacter and self.ViewCharacter.PlayerState
  if not MyPlayerState then
    return
  end
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleProp = RoleProxy:GetRoleProfile(MyPlayerState.SelectRoleId)
  if not roleProp then
    LogError("GetRoleProfile Error", "RoleId=%s", MyPlayerState.SelectRoleId)
    return
  end
  self.Txt_CharacterName:SetText(string.format("%s", roleProp.NameCn))
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
  self.Txt_ActiveSkillName:SetText(string.format("%s: %s", str, SkillRow.Name))
  self.Txt_ActiveSkillDesc:SetText(SkillRow.Intro)
  self.Img_ActiveSkillIcon:SetBrushFromSoftTexture(SkillRow.IconSkill)
  local PassiveSkillID = RoleRow.SkillPassive:Get(1)
  local SkillRow = RoleProxy:GetRoleSkill(PassiveSkillID)
  if not SkillRow then
    LogError("GetRoleSkill Error", "PassiveSkillID=%s", PassiveSkillID)
    return
  end
  local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "PassiveSkill")
  self.Txt_PassiveSkillName:SetText(string.format("%s: %s", str, SkillRow.Name))
  self.Txt_PassiveSkillDesc:SetText(SkillRow.Intro)
  self.Img_PassiveSkillIcon:SetBrushFromSoftTexture(SkillRow.IconSkill)
  local UniqueSkillID = RoleRow.SkillUltimate:Get(1)
  local SkillRow = RoleProxy:GetRoleSkill(UniqueSkillID)
  if not SkillRow then
    LogError("GetRoleSkill Error", "UniqueSkillID=%s", UniqueSkillID)
    return
  end
  local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "UniqueSkill")
  self.Txt_UniqueSkillName:SetText(string.format("%s: %s", str, SkillRow.Name))
  self.Txt_UniqueSkillDesc:SetText(SkillRow.Intro)
  self.Img_UniqueSkillIcon:SetBrushFromSoftTexture(SkillRow.IconSkill)
  local bActive = MyPlayerState.GrowthComponent:IsArousalActivating(UE4.EArousalPosition.One)
  local WakeSkillId = RoleRow.SkillWake:Get(UE4.EArousalPosition.One)
  local SkillRow = RoleProxy:GetRoleSkill(WakeSkillId)
  self.Txt_WakeName_1:SetText(SkillRow.Name)
  self.Txt_WakeDesc_1:SetText(SkillRow.Intro)
  self.Switch_Active_1:SetActiveWidgetIndex(bActive and 1 or 0)
  self.Txt_WakeTitle_1:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Txt_WakeName_1:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Txt_WakeDesc_1:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Image_FenGe_1:SetColorAndOpacity(bActive and self.ImageColor_Awake or self.ImageColor_UnAwake)
  local bActive = MyPlayerState.GrowthComponent:IsArousalActivating(UE4.EArousalPosition.Two)
  local WakeSkillId = RoleRow.SkillWake:Get(UE4.EArousalPosition.Two)
  local SkillRow = RoleProxy:GetRoleSkill(WakeSkillId)
  self.Txt_WakeName_2:SetText(SkillRow.Name)
  self.Txt_WakeDesc_2:SetText(SkillRow.Intro)
  self.Switch_Active_2:SetActiveWidgetIndex(bActive and 1 or 0)
  self.Txt_WakeTitle_2:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Txt_WakeName_2:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Txt_WakeDesc_2:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Image_FenGe_2.Brush.FSlateColor = bActive and self.ImageColor_Awake or self.ImageColor_UnAwake
  local bActive = MyPlayerState.GrowthComponent:IsArousalActivating(UE4.EArousalPosition.Three)
  local WakeSkillId = RoleRow.SkillWake:Get(UE4.EArousalPosition.Three)
  local SkillRow = RoleProxy:GetRoleSkill(WakeSkillId)
  self.Txt_WakeName_3:SetText(SkillRow.Name)
  self.Txt_WakeDesc_3:SetText(SkillRow.Intro)
  self.Switch_Active_3:SetActiveWidgetIndex(bActive and 1 or 0)
  self.Txt_WakeTitle_3:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Txt_WakeName_3:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Txt_WakeDesc_3:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Image_FenGe_3:SetColorAndOpacity(bActive and self.ImageColor_Awake or self.ImageColor_UnAwake)
end
function GameSkillPage:GetInputDisplayName(InputName)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName(InputName, arr)
  local ele = arr:Get(1)
  if ele then
    return UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key)
  end
end
function GameSkillPage:OnExitButtonClicked()
  ViewMgr:HidePage(self, UIPageNameDefine.GameSkillPage)
end
return GameSkillPage
