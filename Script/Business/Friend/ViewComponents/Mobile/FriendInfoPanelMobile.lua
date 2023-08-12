local FriendInfoPanelMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendInfoPanelMediatorMobile")
local FriendInfoPanelMobile = class("FriendInfoPanelMobile", PureMVC.ViewComponentPanel)
function FriendInfoPanelMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendInfoPanelMobile:ListNeededMediators()
  return {FriendInfoPanelMediatorMobile}
end
function FriendInfoPanelMobile:InitializeLuaEvent()
  self.actionOnClickPlayerInfo = LuaEvent.new()
  self.actionOnClickBlack = LuaEvent.new()
  self.actionOnClickDelete = LuaEvent.new()
  self.actionOnClickComment = LuaEvent.new()
  self.actionOnSetInfoPanelData = LuaEvent.new()
end
function FriendInfoPanelMobile:Construct()
  FriendInfoPanelMobile.super.Construct(self)
  self.PlayerInfoBtn_1.OnClicked:Add(self, self.OnClickPlayerInfo)
  self.RemarksBtn_1.OnClicked:Add(self, self.OnClickComment)
  self.DeletePlayerBtn_1.OnClicked:Add(self, self.OnClickDelete)
  self.ShieldPlayerBtn_1.OnClicked:Add(self, self.OnClickBlack)
end
function FriendInfoPanelMobile:Destruct()
  FriendInfoPanelMobile.super.Destruct(self)
  self.PlayerInfoBtn_1.OnClicked:Remove(self, self.OnClickPlayerInfo)
  self.RemarksBtn_1.OnClicked:Remove(self, self.OnClickComment)
  self.DeletePlayerBtn_1.OnClicked:Remove(self, self.OnClickDelete)
  self.ShieldPlayerBtn_1.OnClicked:Remove(self, self.OnClickBlack)
end
function FriendInfoPanelMobile:OnSetInfoPanelData(PanelData)
  self.FriendPanelData = PanelData
end
function FriendInfoPanelMobile:OnClickPlayerInfo()
  self.actionOnClickPlayerInfo()
end
function FriendInfoPanelMobile:OnClickBlack()
  self.actionOnClickBlack()
end
function FriendInfoPanelMobile:OnClickDelete()
  self.actionOnClickDelete()
end
function FriendInfoPanelMobile:OnClickComment()
  self.actionOnClickComment()
end
return FriendInfoPanelMobile
