local GameTransitionPlayerController = Class()
function GameTransitionPlayerController:Initialize()
  LogDebug("GameTransitionPlayerController", "Initialize...")
end
function GameTransitionPlayerController:ReceiveBeginPlay()
  local gameInstance = UE4.UGameplayStatics.GetGameInstance(self)
  self.reason = gameInstance:RetrieveTransitionReason()
  self:HandleTransition()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager then
    GlobalDelegateManager.OnPreLoadMap:Add(self, self.OnHandlePreloadMap)
    GlobalDelegateManager.OnHandleNetworkFailure:Add(self, self.OnHandleNetworkFailure)
  end
end
function GameTransitionPlayerController:ReceiveEndPlay()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager then
    GlobalDelegateManager.OnPreLoadMap:Remove(self, self.OnHandlePreloadMap)
    GlobalDelegateManager.OnHandleNetworkFailure:Remove(self, self.OnHandleNetworkFailure)
  end
end
function GameTransitionPlayerController:OnHandlePreloadMap(_)
  ViewMgr:ClosePage(self, UIPageNameDefine.DSDisconnectPage)
end
function GameTransitionPlayerController:OnHandleNetworkFailure(transitionReason)
  LogDebug("GameTransitionPlayerController", "HandleNetworkFailure ")
  self.reason = transitionReason
  self:HandleTransition()
end
function GameTransitionPlayerController:HandleTransition()
  LogDebug("GameTransitionPlayerController", "reason:" .. tostring(self.reason) .. "  " .. type(self.reason))
  local stopLoading = not self.reason.TransitionReasonType == UE4.EPMGameTransitionReasonType.WorldTransition
  if stopLoading then
    local LS = UE4.UCyLoadingStream.Get(LuaGetWorld())
    if LS then
      LS:Stop()
    end
  end
  if self.reason.TransitionReasonType == UE4.EPMGameTransitionReasonType.DisconnectToDS then
    self:HandleDisconnectToDS()
  elseif self.reason.TransitionReasonType == UE4.EPMGameTransitionReasonType.LoginReconnectGame then
  elseif self.reason.TransitionReasonType == UE4.EPMGameTransitionReasonType.AccountKickOut then
    self:HandleAccountKickOut()
  elseif self.reason.TransitionReasonType == UE4.EPMGameTransitionReasonType.ACEUnsafe then
    self:HandleACEUnsafe()
  end
end
function GameTransitionPlayerController:HandleDisconnectToDS()
  LogDebug("GameTransitionPlayerController", "HandleDisconnectToDS reason:" .. tostring(self.reason))
  ViewMgr:OpenPage(self, UIPageNameDefine.DSDisconnectPage, false, self.reason)
end
function GameTransitionPlayerController:HandleAccountKickOut()
  local dataCenter = UE4.UPMLoginDataCenter.Get(self.Object)
  if dataCenter then
    dataCenter:ShowKickOutLobbyDialog(self:GetWorld())
  end
end
function GameTransitionPlayerController:HandleACEUnsafe()
  LogDebug("GameTransitionPlayerController", "HandleACEUnsafe reason:" .. tostring(self.reason))
  local dataCenter = UE4.UPMLoginDataCenter.Get(self.Object)
  if dataCenter then
    dataCenter:ShowACEUnsafeDialog(self:GetWorld())
  end
end
return GameTransitionPlayerController
