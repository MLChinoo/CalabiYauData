local GrowthWakePanelMobile = class("GrowthWakePanelMobile", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthWakePanelMobile:Construct()
  GrowthWakePanelMobile.super.Construct(self)
  self.Overridden.Construct(self)
  self.Button_SwitchActive.OnClicked:Add(self, self.OnButtonSwitchActive)
  self:UpdateWakeItem()
end
function GrowthWakePanelMobile:Destruct()
  if self.PS_Active_Bg then
    self.PS_Active_Bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  GrowthWakePanelMobile.super.Destruct(self)
  self.Button_SwitchActive.OnClicked:Remove(self, self.OnButtonSwitchActive)
end
function GrowthWakePanelMobile:SetWakeItemType()
  for i = 1, 3 do
    if self["WBP_GrowthWakeItem_" .. i] then
      self["WBP_GrowthWakeItem_" .. i].WakeIdx = i
    end
  end
end
function GrowthWakePanelMobile:UpdateWakeItem()
  self.activedWakeIndex = UE4.EArousalPosition.None
  self.canActivedWakeIndex = UE4.EArousalPosition.None
  for i = 1, 3 do
    if self["WBP_GrowthWakeItem_" .. i] then
      self["WBP_GrowthWakeItem_" .. i]:Update(self)
    end
  end
  if self.Button_SwitchActive then
    if self.activedWakeIndex ~= UE4.EArousalPosition.None and self.canActivedWakeIndex ~= UE4.EArousalPosition.None and self.activedWakeIndex ~= self.canActivedWakeIndex then
      self.Button_SwitchActive:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Button_SwitchActive:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function GrowthWakePanelMobile:UpdateSwitchWakeButton()
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
  local wakeTwoActived = MyPlayerState.GrowthComponent:IsArousalActivating(UE4.EArousalPosition.Two)
  local wakeThreeActived = MyPlayerState.GrowthComponent:IsArousalActivating(UE4.EArousalPosition.Three)
end
function GrowthWakePanelMobile:SetActivedWakeIndex(active, index)
  self.activedWakeIndex = index
end
function GrowthWakePanelMobile:SetCanActivedWakeIndex(index)
  self.canActivedWakeIndex = index
end
function GrowthWakePanelMobile:OnButtonSwitchActive()
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
  MyPlayerState:GetGrowthComponent():ServerSwitchArousal(self.canActivedWakeIndex)
end
return GrowthWakePanelMobile
