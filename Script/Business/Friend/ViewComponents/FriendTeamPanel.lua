local FriendTeamPanel = class("FriendTeamPanel", PureMVC.ViewComponentPanel)
function FriendTeamPanel:OnInitialized()
  FriendTeamPanel.super.OnInitialized(self)
end
function FriendTeamPanel:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendTeamPanel:ListNeededMediators()
  return {}
end
function FriendTeamPanel:InitializeLuaEvent()
  self.actionOnClickIcon = LuaEvent.new()
end
return FriendTeamPanel
