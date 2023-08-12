local GlobalDelegateProxy = class("GlobalDelegateProxy", PureMVC.Proxy)
local NotificationDefines = NotificationDefines
function GlobalDelegateProxy:OnRegister()
  GlobalDelegateProxy.super.OnRegister(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnBeginGameDelegateSubsystemHandle = DelegateMgr:AddDelegate(GlobalDelegateManager.OnBeginGameDelegateSubsystem, self, "OnBeginGameDelegateSubsystem")
    self.OnEndGameDelegateSubsystemHandle = DelegateMgr:AddDelegate(GlobalDelegateManager.OnEndGameDelegateSubsystem, self, "OnEndGameDelegateSubsystem")
  end
end
function GlobalDelegateProxy:OnRemove()
  GlobalDelegateProxy.super.OnRemove(self)
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnBeginGameDelegateSubsystem, self.OnBeginGameDelegateSubsystemHandle)
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnEndGameDelegateSubsystem, self.OnEndGameDelegateSubsystemHandle)
  end
end
function GlobalDelegateProxy:OnBeginGameDelegateSubsystem()
  LogInfo("GlobalDelegateProxy", "OnBeginGameDelegateSubsystem...")
  if GameFacade then
    GameFacade:SendNotification(NotificationDefines.GameDelegateSubsystemCmd, nil, NotificationDefines.GameDelegateSubsystemCmdType.Begin)
  end
end
function GlobalDelegateProxy:OnEndGameDelegateSubsystem()
  LogInfo("GlobalDelegateProxy", "OnEndGameDelegateSubsystem...")
  if GameFacade then
    GameFacade:SendNotification(NotificationDefines.GameDelegateSubsystemCmd, nil, NotificationDefines.GameDelegateSubsystemCmdType.End)
  end
end
return GlobalDelegateProxy
