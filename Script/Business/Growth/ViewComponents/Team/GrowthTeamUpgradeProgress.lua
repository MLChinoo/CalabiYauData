local GrowthTeamUpgradeProgress = class("GrowthTeamUpgradeProgress", PureMVC.ViewComponentPanel)
local MAXLV = 13
local GrowthTeamUpgradeProgressMediator = require("Business/Growth/Mediators/GrowthTeamUpgradeProgressMediator")
function GrowthTeamUpgradeProgress:ListNeededMediators()
  return {GrowthTeamUpgradeProgressMediator}
end
function GrowthTeamUpgradeProgress:Update()
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  local MyPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  if not MyPlayerController then
    LogError("Get PlayerContrller Error")
    return
  end
  local MyPlayerState = MyPlayerController.PlayerState
  if not MyPlayerState then
    LogError("Get PlayerState Error")
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local WeaponPartLv = GrowthProxy:GetWeaponPartLv(MyPlayerState)
  local SkillLv = GrowthProxy:GetSkillLv(MyPlayerState)
  local ShieldLv = GrowthProxy:GetShieldLv(MyPlayerState)
  local IsMaxLv = WeaponPartLv + SkillLv + ShieldLv >= MAXLV
  if IsMaxLv then
    self.WidgetSwitcher_Text:SetActiveWidgetIndex(1)
    for i = 1, MAXLV do
      self["img_progress_" .. i]:SetBrushTintColor(self.Color_Max)
    end
  else
    self.WidgetSwitcher_Text:SetActiveWidgetIndex(0)
    self.Text_CurrentProgress:SetText(WeaponPartLv + SkillLv + ShieldLv)
    local Idx = 1
    for i = Idx, WeaponPartLv do
      self["img_progress_" .. Idx]:SetBrushTintColor(self.Color_Blue)
      Idx = Idx + 1
    end
    for i = Idx, WeaponPartLv + SkillLv do
      self["img_progress_" .. Idx]:SetBrushTintColor(self.Color_Yellow)
      Idx = Idx + 1
    end
    for i = Idx, WeaponPartLv + SkillLv + ShieldLv do
      self["img_progress_" .. Idx]:SetBrushTintColor(self.Color_Green)
      Idx = Idx + 1
    end
    for i = Idx, MAXLV do
      self["img_progress_" .. Idx]:SetBrushTintColor(self.Color_Default)
      Idx = Idx + 1
    end
  end
end
return GrowthTeamUpgradeProgress
