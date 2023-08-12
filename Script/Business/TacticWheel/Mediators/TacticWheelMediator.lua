local TacticWheelMediator = class("TacticWheelMediator", PureMVC.Mediator)
function TacticWheelMediator:ListNotificationInterests()
  return {}
end
function TacticWheelMediator:OnRegister()
  self.super:OnRegister()
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    self.OnPlayerCharacterDeathHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnPlayerCharacterDeath, self, "OnPlayerCharacterDeath")
  end
end
function TacticWheelMediator:OnRemove()
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnPlayerCharacterDeath, self.OnPlayerCharacterDeathHandle)
  end
  self.super:OnRemove()
end
function TacticWheelMediator:OnPlayerCharacterDeath(PlayerState)
  if PlayerState then
    local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(LuaGetWorld(), 0)
    local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
    if not MyPlayerState then
      return
    end
    if MyPlayerState == PlayerState then
      ViewMgr:ClosePage(self.viewComponent, UIPageNameDefine.TacticWheelPage)
    end
  end
end
return TacticWheelMediator
