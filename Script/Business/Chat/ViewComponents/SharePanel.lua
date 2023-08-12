local SharePanel = class("SharePanel", PureMVC.ViewComponentPanel)
function SharePanel:ListNeededMediators()
  return {}
end
function SharePanel:InitializeLuaEvent()
  self.actionOnShareTeam = LuaEvent.new()
  self.actionOnSharePlayerInfo = LuaEvent.new()
end
function SharePanel:Construct()
  SharePanel.super.Construct(self)
  if self.Button_SharePlayerInfo then
    self.Button_SharePlayerInfo.OnClicked:Add(self, self.OnClickSharePlayerInfo)
  end
  if self.Button_ShareTeam then
    self.Button_ShareTeam.OnClicked:Add(self, self.OnClickShareTeam)
  end
end
function SharePanel:Destruct()
  if self.Button_SharePlayerInfo then
    self.Button_SharePlayerInfo.OnClicked:Remove(self, self.OnClickSharePlayerInfo)
  end
  if self.Button_ShareTeam then
    self.Button_ShareTeam.OnClicked:Remove(self, self.OnClickShareTeam)
  end
  SharePanel.super.Destruct(self)
end
function SharePanel:OnClickSharePlayerInfo()
  self.actionOnSharePlayerInfo()
end
function SharePanel:OnClickShareTeam()
  self.actionOnShareTeam()
end
return SharePanel
