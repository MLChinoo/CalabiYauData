local FriendDeleteDialogPageMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendDeleteDialogPageMediatorMobile")
local FriendDeletekDialogPageMobile = class("FriendDeletekDialogPageMobile", PureMVC.ViewComponentPage)
function FriendDeletekDialogPageMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendDeletekDialogPageMobile:ListNeededMediators()
  return {FriendDeleteDialogPageMediatorMobile}
end
function FriendDeletekDialogPageMobile:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClose = LuaEvent.new()
  self.actionOnClickConfirm = LuaEvent.new()
  self.actionOnClickESC = LuaEvent.new()
end
function FriendDeletekDialogPageMobile:Construct()
  FriendDeletekDialogPageMobile.super.Construct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Add(self, self.OnClickConfirm)
  end
  if self.Btn_Return then
    self.Btn_Return.OnClicked:Add(self, self.OnClickESC)
  end
end
function FriendDeletekDialogPageMobile:Destruct()
  FriendDeletekDialogPageMobile.super.Destruct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  end
  if self.Btn_Return then
    self.Btn_Return.OnClicked:Remove(self, self.OnClickESC)
  end
end
function FriendDeletekDialogPageMobile:OnShow()
  self.actionOnShow()
end
function FriendDeletekDialogPageMobile:OnClose()
  self.actionOnClose()
end
function FriendDeletekDialogPageMobile:OnClickConfirm()
  self.actionOnClickConfirm()
end
function FriendDeletekDialogPageMobile:OnClickESC()
  self.actionOnClickESC()
end
return FriendDeletekDialogPageMobile
