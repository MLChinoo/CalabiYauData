local ViewComponentPanel = Class()
ViewComponentPanel.disable_index_set = true
function ViewComponentPanel:ListNeededMediators()
  return {}
end
function ViewComponentPanel:InitializeLuaEvent()
end
function ViewComponentPanel:OnInitialized()
  LogDebug("ViewComponentPanel", "OnInitialized on %s -- %s", tostring(self), tostring(self.Object))
  self.luaData = nil
  self:InitializeLuaEvent()
  self.UUIDStr = UE4.LuaBridge.LuaGetUniqIdByPointer(self)
  if nil == self.UUIDStr then
    LogError("ViewComponentPanel", "Can not get panel UUID: %s", tostring(self))
  end
end
function ViewComponentPanel:RegisterMediator(mediatorClass)
  local ins = mediatorClass.new(mediatorClass.__cname .. self.UUIDStr, self)
  GameFacade:RegisterMediator(ins)
  table.insert(self.mediators, ins)
end
function ViewComponentPanel:UnregisterMediator()
  for _, v in ipairs(self.mediators or {}) do
    GameFacade:RemoveMediator(v:GetMediatorName())
  end
  self.mediators = nil
end
function ViewComponentPanel:Construct()
  LogDebug("ViewComponent", self.__cname .. " -- Construct " .. tostring(self))
  self.mediators = {}
  local mediatorClassArr = self:ListNeededMediators()
  for _, v in ipairs(mediatorClassArr) do
    self:RegisterMediator(v)
  end
end
function ViewComponentPanel:Destruct()
  LogDebug("ViewComponent", "Destruct " .. tostring(self))
  self:UnregisterMediator()
  self.luaData = nil
end
return ViewComponentPanel
