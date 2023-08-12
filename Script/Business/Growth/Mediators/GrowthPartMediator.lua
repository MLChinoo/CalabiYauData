local GrowthUpgradeMediator = require("Business/Growth/Mediators/GrowthUpgradeMediator")
local GrowthPartMediator = class("GrowthPartMediator", GrowthUpgradeMediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthPartMediator:ListNotificationInterests()
  return {
    NotificationDefines.Growth.GrowthLevelUpdateCmd,
    NotificationDefines.Growth.GrowthPointChangedCmd
  }
end
function GrowthPartMediator:HandleNotification(notification)
  local name = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if name == NotificationDefines.Growth.GrowthLevelUpdateCmd then
    if viewComponent and viewComponent.UpdatePart then
      viewComponent:UpdatePart()
    end
  elseif name == NotificationDefines.Growth.GrowthPointChangedCmd and viewComponent and viewComponent.UpdatePart then
    viewComponent:UpdatePart()
  end
end
function GrowthPartMediator:OnRegister()
  GrowthPartMediator.super.OnRegister(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  if GrowthProxy:IsGrowthPartUpgradeManual(self.viewComponent) then
    self:GetViewComponent().OnRevertBtnClicked:Add(self.DowngradeGrowthPartItem, self)
  end
end
function GrowthPartMediator:OnRemove()
  GrowthPartMediator.super.OnRemove(self)
  self:GetViewComponent().OnRevertBtnClicked:Remove(self.DowngradeGrowthPartItem, self)
end
return GrowthPartMediator
