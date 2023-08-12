local GrowthPageMediator = class("GrowthPageMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthPageMediator:ListNotificationInterests()
  return {}
end
function GrowthPageMediator:HandleNotification(notification)
end
function GrowthPageMediator:OnRegister()
  GrowthPageMediator.super.OnRegister(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  self.OnRoundStageUpdateHandle = DelegateMgr:AddDelegate(GameState.OnNotifyRoundStateChange, self, "OnRoundStageUpdate")
  local GrowthComponent = MyPlayerState:GetGrowthComponent()
  if MyPlayerState.OnCurrentGrowthPointChangedEvent and GrowthComponent and GrowthComponent.OnLevelMaskChanged and GrowthComponent.OnLevelTempMaskChanged then
    self.OnCurrentGrowthPointChangedHandle = DelegateMgr:AddDelegate(MyPlayerState.OnCurrentGrowthPointChangedEvent, self, "OnCurrentGrowthPointChanged")
    self.OnGrowthLevelsChangedHandle = DelegateMgr:AddDelegate(GrowthComponent.OnLevelMaskChanged, self, "OnGrowthLevelsChanged")
    self.OnTempGrowthLevelsChangedHandle = DelegateMgr:AddDelegate(GrowthComponent.OnLevelTempMaskChanged, self, "OnTempGrowthLevelsChanged")
  end
  self:UpdateBaseInfo()
  self:UpdateGrowthPoint()
  self:UpdateWeaponProperty()
end
function GrowthPageMediator:OnRemove()
  GrowthPageMediator.super.OnRemove(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self.OnRoundStageUpdateHandle then
    DelegateMgr:RemoveDelegate(GameState.OnNotifyRoundStateChange, self.OnRoundStageUpdateHandle)
    self.OnRoundStageUpdateHandle = nil
  end
  if self.OnCurrentGrowthPointChangedHandle then
    DelegateMgr:RemoveDelegate(MyPlayerState.OnCurrentGrowthPointChangedEvent, self.OnCurrentGrowthPointChangedHandle)
    self.OnCurrentGrowthPointChangedHandle = nil
  end
  local GrowthComponent = MyPlayerState:GetGrowthComponent()
  if GrowthComponent then
    if self.OnGrowthLevelsChangedHandle then
      DelegateMgr:RemoveDelegate(GrowthComponent.OnLevelMaskChanged, self.OnGrowthLevelsChangedHandle)
      self.OnGrowthLevelsChangedHandle = nil
    end
    if self.OnTempGrowthLevelsChangedHandle then
      DelegateMgr:RemoveDelegate(GrowthComponent.OnLevelTempMaskChanged, self.OnTempGrowthLevelsChangedHandle)
      self.OnTempGrowthLevelsChangedHandle = nil
    end
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  if not GrowthProxy then
    return
  end
  GrowthProxy:SetSelectSlot(UE4.EGrowthSlotType.Max)
end
function GrowthPageMediator:OnRoundStageUpdate()
  local GameState = UE4.UGameplayStatics.GetGameState(self.viewComponent)
  if not GameState then
    return
  end
  if GameState:GetRoundState() > UE4.ERoundStage.Freeze then
    ViewMgr:HidePage(self:GetViewComponent(), UIPageNameDefine.GrowthPage)
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.GrowthDowngradeDialog)
  end
end
function GrowthPageMediator:OnCurrentGrowthPointChanged()
  self:UpdateGrowthPoint()
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthLevelUpdateCmd)
end
function GrowthPageMediator:OnGrowthLevelsChanged()
  self:UpdateGrowthPoint()
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthLevelUpdateCmd)
  LogDebug("GetWeaponAttributes", "OnGrowthLevelsChanged")
  self:UpdateWeaponProperty()
  if self.viewComponent.OnLevelChanged then
    self.viewComponent:OnLevelChanged()
  end
end
function GrowthPageMediator:OnTempGrowthLevelsChanged()
  self:UpdateGrowthPoint()
  LogDebug("GetWeaponAttributes", "OnTempGrowthLevelsChanged")
  GameFacade:SendNotification(NotificationDefines.Growth.GrowthLevelUpdateCmd)
  self:UpdateWeaponProperty()
end
function GrowthPageMediator:UpdateBaseInfo()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthBaseInfo = {}
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleProfile = roleProxy:GetRoleProfile(MyPlayerState.SelectRoleId)
  if not RoleProfile then
    LogError("Get RoleProfile Table Error", "RoleId=%s", MyPlayerState.SelectRoleId)
    return
  end
  GrowthBaseInfo.RoleNameCn = RoleProfile.NameCn
  local growthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local WeaponTableRow = growthProxy:GetWeaponTableRowByRoleId(MyPlayerState.SelectRoleId)
  if not WeaponTableRow then
    LogError("Get Weapon Table Error", "RoleId=%s", MyPlayerState.SelectRoleId)
    return
  end
  GrowthBaseInfo.WeaponName = WeaponTableRow.Name
  GrowthBaseInfo.WeaponIcon = WeaponTableRow.IconGrowth
  self.viewComponent:UpdateBaseInfo(GrowthBaseInfo)
end
function GrowthPageMediator:UpdateGrowthPoint()
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self.viewComponent)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local GrowthPoint = MyPlayerState.CurrentGrowthPoint
  self.viewComponent:UpdateGrowthPoint(GrowthPoint)
end
function GrowthPageMediator:UpdateWeaponProperty()
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self.viewComponent, 0)
  local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
  if not MyPlayerState then
    return
  end
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local PartsLvNew = {}
  for Slot = UE4.EGrowthSlotType.WeaponPart_Muzzle, UE4.EGrowthSlotType.WeaponPart_ButtStock do
    PartsLvNew[Slot] = GrowthProxy:GetGrowthLv(MyPlayerState, Slot)
  end
  local notify = false
  if self.PartsLvCache then
    for Slot, value in pairs(PartsLvNew) do
      if self.PartsLvCache[Slot] ~= value then
        GrowthProxy:SetSelectSlot(Slot)
        notify = true
        break
      end
    end
  end
  self.PartsLvCache = PartsLvNew
  if notify then
    GameFacade:SendNotification(NotificationDefines.Growth.GrowthWeaponDetailUpdateCmd)
  end
end
return GrowthPageMediator
