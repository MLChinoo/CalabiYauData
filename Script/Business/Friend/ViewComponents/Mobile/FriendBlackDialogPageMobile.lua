local FriendBlackDialogPageMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendBlackDialogPageMediatorMobile")
local FriendBlackDialogPage = class("FriendBlackDialogPage", PureMVC.ViewComponentPage)
function FriendBlackDialogPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendBlackDialogPage:ListNeededMediators()
  return {FriendBlackDialogPageMediatorMobile}
end
function FriendBlackDialogPage:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClose = LuaEvent.new()
  self.actionOnClickConfirm = LuaEvent.new()
  self.actionOnClickESC = LuaEvent.new()
end
function FriendBlackDialogPage:Construct()
  FriendBlackDialogPage.super.Construct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Add(self, self.OnClickConfirm)
  end
  if self.Btn_Return then
    self.Btn_Return.OnClicked:Add(self, self.OnClickESC)
  end
end
function FriendBlackDialogPage:Destruct()
  FriendBlackDialogPage.super.Destruct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  end
  if self.Btn_Return then
    self.Btn_Return.OnClicked:Remove(self, self.OnClickESC)
  end
end
function FriendBlackDialogPage:OnShow()
  self.actionOnShow()
end
function FriendBlackDialogPage:OnClose()
  self.actionOnClose()
end
function FriendBlackDialogPage:OnClickConfirm()
  self.actionOnClickConfirm()
end
function FriendBlackDialogPage:OnClickESC()
  self.actionOnClickESC()
end
return FriendBlackDialogPage
