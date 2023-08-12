local GrowthUpgradeMediator = class("GrowthUpgradeMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthUpgradeMediator:UpgradeGrowthPartItem(SlotType, Lv)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    if GameState:GetRoundState() >= UE4.ERoundStage.Start then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Growth_NotUpgrade_InGame")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    if GameState:GetRoundState() ~= UE4.ERoundStage.Freeze then
      LogDebug("UpgradeGrowthPartItem", "Stage=%s not Freeze", GameState:GetRoundState())
      return
    end
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local LvMax = GrowthProxy:GetGrowthSlotLvMax(MyPlayerState.SelectRoleId, SlotType)
  if Lv > LvMax then
    LogDebug("UpgradeGrowthPartItem", "CurLv:%s > LvMax:%s", Lv, LvMax)
    return
  end
  local Cost = GrowthProxy:GetGrowthSlotCost(MyPlayerState.SelectRoleId, SlotType, Lv)
  if Cost > MyPlayerState.CurrentGrowthPoint then
    LogDebug("UpgradeGrowthPartItem", "CurrentGrowthPoint:%s < Cost:%s", MyPlayerState.CurrentGrowthPoint, Cost)
    return
  end
  LogDebug("GrowthPartItemMediator", "UpgradeGrowthPartItem SlotType=%s", SlotType)
  MyPlayerState:ServerUpgradeGrowthSlotLevel(SlotType, Lv)
end
function GrowthUpgradeMediator:DowngradeGrowthPartItem(SlotType, ShowDialog)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if GameState:GetModeType() == UE4.EPMGameModeType.Bomb then
    if GameState:GetRoundState() >= UE4.ERoundStage.Start then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Growth_NotDowngrade_InGame")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      return
    end
    if GameState:GetRoundState() ~= UE4.ERoundStage.Freeze then
      LogDebug("DowngradeGrowthPartItem", "Stage=%s not Freeze", GameState:GetRoundState())
      return
    end
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local CurLv = GrowthProxy:GetGrowthLv(MyPlayerState, SlotType)
  if CurLv <= 0 then
    LogDebug("DowngradeGrowthPartItem", "CurLv:%s<=0", CurLv)
    return
  end
  if ShowDialog then
    local TempCurLv = GrowthProxy:GetGrowthTempLv(MyPlayerState, SlotType)
    if TempCurLv <= 0 then
      ViewMgr:OpenPage(self.viewComponent, UIPageNameDefine.GrowthDowngradeDialog, false, SlotType)
      return
    end
  end
  GrowthProxy:SetSelectSlot(SlotType)
  LogDebug("GrowthUpgradeMediator", "DowngradeGrowthPartItem SlotType=%s", SlotType)
  MyPlayerState:ServerDowngradeGrowthSlotLevel(SlotType)
end
return GrowthUpgradeMediator
