local GrowthWakeItem = class("GrowthWakeItem", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local MaxWeaponNum = 4
local MaxSkillNum = 2
local MaxShieldNum = 2
function GrowthWakeItem:Construct()
  GrowthWakeItem.super.Construct(self)
  self.Btn_SwitchActive.OnClicked:Add(self, self.OnButtonSwitchActive)
  self.Btn_SwitchActive.OnHovered:Add(self, self.OnButtonSwitchHovered)
  self.Btn_SwitchActive.OnUnhovered:Add(self, self.OnButtonSwitchUnHovered)
end
function GrowthWakeItem:Destruct()
  GrowthWakeItem.super.Destruct(self)
  self.Btn_SwitchActive.OnClicked:Remove(self, self.OnButtonSwitchActive)
  self.Btn_SwitchActive.OnHovered:Remove(self, self.OnButtonSwitchHovered)
  self.Btn_SwitchActive.OnUnhovered:Remove(self, self.OnButtonSwitchUnHovered)
  self.ParticleSystemWidget_Active_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ParticleSystemWidget_Active_2:SetVisibility(UE4.ESlateVisibility.Hidden)
end
function GrowthWakeItem:OnButtonSwitchHovered()
  self.Text_SwitchActive:SetColorAndOpacity(self.SwitchActiveColor_Hover)
end
function GrowthWakeItem:OnButtonSwitchUnHovered()
  self.Text_SwitchActive:SetColorAndOpacity(self.SwitchActiveColor_Normal)
end
function GrowthWakeItem:OnButtonSwitchActive()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not GameState or not GameState.GetModeType then
    return
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb and GameState:GetRoundState() >= UE4.ERoundStage.Start then
    return
  end
  MyPlayerState:GetGrowthComponent():ServerSwitchArousal(self.WakeIdx)
end
function GrowthWakeItem:Update()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleRow = roleProxy:GetRole(MyPlayerState.SelectRoleId)
  local WakeSkillId = RoleRow.SkillWake:Get(self.WakeIdx)
  local SkillRow = roleProxy:GetRoleSkill(WakeSkillId)
  if not SkillRow then
    LogError("Get Skill Table Error", "WakeSkillId=%s", WakeSkillId)
    return
  end
  local WakeData = {}
  WakeData.Name = SkillRow.Name
  WakeData.Intro = SkillRow.Intro
  WakeData.WeaponNum = SkillRow.ActiveCond:Get(1)
  WakeData.SkillNum = SkillRow.ActiveCond:Get(2)
  WakeData.ShieldNum = SkillRow.ActiveCond:Get(3)
  WakeData.ActiveWeaponNum = GrowthProxy:GetWeaponPartMaxLvNum(MyPlayerState)
  WakeData.ActiveSkillNum = GrowthProxy:GetSkillMaxLvNum(MyPlayerState)
  WakeData.ActiveShieldNum = GrowthProxy:GetShieldMaxLvNum(MyPlayerState)
  WakeData.Actived = MyPlayerState.GrowthComponent:IsArousalActivating(self.WakeIdx)
  if WakeData.Actived and self.LastActiveState ~= nil and not self.LastActiveState then
    WakeData.ChangeToActive = true
  else
    WakeData.ChangeToActive = false
  end
  self.LastActiveState = WakeData.Actived
  self.TextBlock_Name:SetText(WakeData.Name)
  self.TextBlock_Desc:SetText(WakeData.Intro)
  for i = 1, MaxWeaponNum do
    self["SizeBox_Icon_" .. i - 1]:SetVisibility(i <= WakeData.WeaponNum and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self["WidgetSwitcher_Icon_" .. i - 1]:SetActiveWidgetIndex(i - 1 < WakeData.ActiveWeaponNum and 0 or 1)
  end
  for i = 1, MaxSkillNum do
    local idx = i + MaxWeaponNum
    self["SizeBox_Icon_" .. idx - 1]:SetVisibility(i <= WakeData.SkillNum and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self["WidgetSwitcher_Icon_" .. idx - 1]:SetActiveWidgetIndex(i - 1 < WakeData.ActiveSkillNum and 0 or 1)
  end
  for i = 1, MaxShieldNum do
    local idx = i + MaxWeaponNum + MaxSkillNum
    self["SizeBox_Icon_" .. idx - 1]:SetVisibility(i <= WakeData.ShieldNum and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self["WidgetSwitcher_Icon_" .. idx - 1]:SetActiveWidgetIndex(i - 1 < WakeData.ActiveShieldNum and 0 or 1)
  end
  local bActive = WakeData.Actived
  self.TextBlock_WakeTitle:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Wake")
  self.TextBlock_WakeTitle:SetText(string.format("%s%s：", str, self.WakeIdx))
  self.TextBlock_Name:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.TextBlock_Desc:SetColorAndOpacity(bActive and self.LinearColor_Awake or self.LinearColor_UnAwake)
  self.Switch_Active:SetActiveWidgetIndex(bActive and 1 or 0)
  self.switch_wake_decorate_icon:SetActiveWidgetIndex(bActive and 1 or 0)
  if bActive then
    if WakeData.ChangeToActive then
      self.ParticleSystemWidget_Active_1:SetReactivate(true)
      self.ParticleSystemWidget_Active_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:K2_PostAkEvent(self.AKActive)
    end
    self.ParticleSystemWidget_Active_2:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.ParticleSystemWidget_Active_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.ParticleSystemWidget_Active_2:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  local CanActive = WakeData.ActiveWeaponNum >= WakeData.WeaponNum and WakeData.ActiveSkillNum >= WakeData.SkillNum and WakeData.ActiveShieldNum >= WakeData.ShieldNum
  if not bActive and CanActive then
    self.Btn_SwitchActive:SetVisibility(UE4.ESlateVisibility.Visible)
    local GameState = UE4.UGameplayStatics.GetGameState(self)
    if not GameState or not GameState.GetModeType then
      return
    end
    if GameState:GetModeType() == UE4.EPMGameModeType.Bomb and GameState:GetRoundState() >= UE4.ERoundStage.Start then
      self.Btn_SwitchActive:SetIsEnabled(false)
      self.Text_SwitchActive:SetColorAndOpacity(self.SwitchActiveColor_Disable)
    else
      self.Btn_SwitchActive:SetIsEnabled(true)
      self.Text_SwitchActive:SetColorAndOpacity(self.SwitchActiveColor_Normal)
    end
  else
    self.Btn_SwitchActive:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
return GrowthWakeItem
