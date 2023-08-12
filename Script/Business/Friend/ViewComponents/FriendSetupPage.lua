local FriendSetupPage = class("FriendSetupPage", PureMVC.ViewComponentPage)
local FriendSetupPageMediator = require("Business/Friend/Mediators/FriendSetupPageMediator")
function FriendSetupPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendSetupPage:ListNeededMediators()
  return {FriendSetupPageMediator}
end
function FriendSetupPage:InitializeLuaEvent()
  self.actionOnClickOnlineState = LuaEvent.new()
  self.actionOnClickTeamSecret = LuaEvent.new()
  self.actionOnCheckOnline = LuaEvent.new()
  self.actionOnCheckLeave = LuaEvent.new()
  self.actionOnCheckPublic = LuaEvent.new()
  self.actionOnCheckFriendOnly = LuaEvent.new()
  self.actionOnCheckPrivate = LuaEvent.new()
end
function FriendSetupPage:Construct()
  FriendSetupPage.super.Construct(self)
  self.Button_OnlineState.OnClicked:Add(self, self.OnClickOnlineState)
  self.Button_TeamSecret.OnClicked:Add(self, self.OnClickTeamSecret)
  self.CheckBox_Online.OnCheckStateChanged:Add(self, self.OnCheckOnline)
  self.CheckBox_Leave.OnCheckStateChanged:Add(self, self.OnCheckLeave)
  self.CheckBox_Public.OnCheckStateChanged:Add(self, self.OnCheckPublic)
  self.CheckBox_FriendOnly.OnCheckStateChanged:Add(self, self.OnCheckFriendOnly)
  self.CheckBox_Private.OnCheckStateChanged:Add(self, self.OnCheckPrivate)
end
function FriendSetupPage:Destruct()
  FriendSetupPage.super.Destruct(self)
  self.Button_OnlineState.OnClicked:Remove(self, self.OnClickOnlineState)
  self.Button_TeamSecret.OnClicked:Remove(self, self.OnClickTeamSecret)
  self.CheckBox_Online.OnCheckStateChanged:Remove(self, self.OnCheckOnline)
  self.CheckBox_Leave.OnCheckStateChanged:Remove(self, self.OnCheckLeave)
  self.CheckBox_Public.OnCheckStateChanged:Remove(self, self.OnCheckPublic)
  self.CheckBox_FriendOnly.OnCheckStateChanged:Remove(self, self.OnCheckFriendOnly)
  self.CheckBox_Private.OnCheckStateChanged:Remove(self, self.OnCheckPrivate)
end
function FriendSetupPage:OnClickOnlineState()
  self.actionOnClickOnlineState()
end
function FriendSetupPage:OnClickTeamSecret()
  self.actionOnClickTeamSecret()
end
function FriendSetupPage:OnCheckOnline()
  self.actionOnCheckOnline()
end
function FriendSetupPage:OnCheckLeave()
  self.actionOnCheckLeave()
end
function FriendSetupPage:OnCheckPublic()
  self.actionOnCheckPublic()
end
function FriendSetupPage:OnCheckFriendOnly()
  self.actionOnCheckFriendOnly()
end
function FriendSetupPage:OnCheckPrivate()
  self.actionOnCheckPrivate()
end
return FriendSetupPage
