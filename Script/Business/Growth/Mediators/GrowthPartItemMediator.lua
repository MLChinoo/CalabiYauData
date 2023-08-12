local GrowthUpgradeMediator = require("Business/Growth/Mediators/GrowthUpgradeMediator")
local GrowthPartItemMediator = class("GrowthPartMediator", GrowthUpgradeMediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthPartItemMediator:OnRegister()
  GrowthPartItemMediator.super.OnRegister(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  if GrowthProxy:IsGrowthPartUpgradeManual(self.viewComponent) then
    self:GetViewComponent().OnPartItemClicked:Add(self.UpgradeGrowthPartItem, self)
    self:GetViewComponent().OnRevertBtnClicked:Add(self.DowngradeGrowthPartItem, self)
  end
end
function GrowthPartItemMediator:OnRemove()
  GrowthPartItemMediator.super.OnRemove(self)
  self:GetViewComponent().OnPartItemClicked:Remove(self.UpgradeGrowthPartItem, self)
  self:GetViewComponent().OnRevertBtnClicked:Remove(self.DowngradeGrowthPartItem, self)
end
return GrowthPartItemMediator
