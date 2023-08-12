local GameReconnectMediator = class("GameReconnectMediator", PureMVC.Mediator)
function GameReconnectMediator:OnRegister()
  self.ViewPage = self:GetViewComponent()
  self.LoginDataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  if not self.LoginDataCenter then
    LogInfo("GameReconnectMediator", "GameReconnectMediator:InitModule, DolphinSubSystem is nil")
  end
  self.ReconnectStateHandler = DelegateMgr:BindDelegate(self.LoginDataCenter.ReconnectStateDelegate, self, GameReconnectMediator.OnReconnectStateUpdate)
end
function GameReconnectMediator:OnRemove()
  if self.ReconnectStateHandler then
    DelegateMgr:UnbindDelegate(self.LoginDataCenter.ReconnectStateDelegate, self.ReconnectStateHandler)
    self.ReconnectStateHandler = nil
  end
end
function GameReconnectMediator:OnReconnectStateUpdate(reconnectTimes, maxReconnectTimes)
  self.ViewPage:UpdateReconnectState(reconnectTimes, maxReconnectTimes)
end
return GameReconnectMediator
