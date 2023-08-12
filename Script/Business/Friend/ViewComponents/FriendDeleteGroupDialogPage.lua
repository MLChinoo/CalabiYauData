local FriendDeleteGroupDialogPageMediator = require("Business/Friend/Mediators/FriendDeleteGroupDialogPageMediator")
local FriendDeleteGroupDialogPage = class("FriendDeleteGroupDialogPage", PureMVC.ViewComponentPage)
function FriendDeleteGroupDialogPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendDeleteGroupDialogPage:ListNeededMediators()
  return {FriendDeleteGroupDialogPageMediator}
end
function FriendDeleteGroupDialogPage:InitializeLuaEvent()
  self.actionOnClickConfirm = LuaEvent.new()
  self.actionOnClickEsc = LuaEvent.new()
end
function FriendDeleteGroupDialogPage:Construct()
  FriendDeleteGroupDialogPage.super.Construct(self)
  self.Btn_Confirm.OnClicked:Add(self, self.OnClickConfirm)
  self.Btn_Esc.OnClicked:Add(self, self.OnClickEsc)
end
function FriendDeleteGroupDialogPage:Destruct()
  FriendDeleteGroupDialogPage.super.Destruct(self)
  self.Btn_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  self.Btn_Esc.OnClicked:Remove(self, self.OnClickEsc)
end
function FriendDeleteGroupDialogPage:OnClickConfirm()
  self.actionOnClickConfirm()
end
function FriendDeleteGroupDialogPage:OnClickEsc()
  self.actionOnClickEsc()
end
function FriendDeleteGroupDialogPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Y" then
    self.actionOnClickConfirm()
  elseif UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "E" then
    self.actionOnClickEsc()
  end
  return false
end
return FriendDeleteGroupDialogPage
