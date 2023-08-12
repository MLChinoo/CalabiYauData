local FriendSetupPageMobile = class("FriendSetupPageMobile", PureMVC.ViewComponentPage)
local FriendSetupPageMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendSetupPageMediatorMobile")
function FriendSetupPageMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendSetupPageMobile:ListNeededMediators()
  return {FriendSetupPageMediatorMobile}
end
function FriendSetupPageMobile:InitializeLuaEvent()
  self.actionOnCheckOnlineCheck = LuaEvent.new()
  self.actionOnCheckOffLineCheck = LuaEvent.new()
  self.actionOnCheckPublicCheck = LuaEvent.new()
  self.actionOnCheckOnlyFriendCheck = LuaEvent.new()
  self.actionOnCheckPrivateCheck = LuaEvent.new()
end
function FriendSetupPageMobile:Construct()
  FriendSetupPageMobile.super.Construct(self)
  self.OnlineCheck.OnCheckStateChanged:Add(self, self.OnCheckOnlineCheck)
  self.OffLineCheck.OnCheckStateChanged:Add(self, self.OnCheckOffLineCheck)
  self.PublicCheck.OnCheckStateChanged:Add(self, self.OnCheckPublicCheck)
  self.OnlyFriendCheck.OnCheckStateChanged:Add(self, self.OnCheckOnlyFriendCheck)
  self.PrivateCheck.OnCheckStateChanged:Add(self, self.OnCheckPrivateCheck)
end
function FriendSetupPageMobile:Destruct()
  FriendSetupPageMobile.super.Destruct(self)
  self.OnlineCheck.OnCheckStateChanged:Remove(self, self.OnCheckOnlineCheck)
  self.OffLineCheck.OnCheckStateChanged:Remove(self, self.OnCheckOffLineCheck)
  self.PublicCheck.OnCheckStateChanged:Remove(self, self.OnCheckPublicCheck)
  self.OnlyFriendCheck.OnCheckStateChanged:Remove(self, self.OnCheckOnlyFriendCheck)
  self.PrivateCheck.OnCheckStateChanged:Remove(self, self.OnCheckPrivateCheck)
end
function FriendSetupPageMobile:OnCheckOnlineCheck(bIsChecked)
  self.actionOnCheckOnlineCheck(bIsChecked)
end
function FriendSetupPageMobile:OnCheckOffLineCheck(bIsChecked)
  self.actionOnCheckOffLineCheck(bIsChecked)
end
function FriendSetupPageMobile:OnCheckPublicCheck(bIsChecked)
  self.actionOnCheckPublicCheck(bIsChecked)
end
function FriendSetupPageMobile:OnCheckOnlyFriendCheck(bIsChecked)
  self.actionOnCheckOnlyFriendCheck(bIsChecked)
end
function FriendSetupPageMobile:OnCheckPrivateCheck(bIsChecked)
  self.actionOnCheckPrivateCheck(bIsChecked)
end
return FriendSetupPageMobile
