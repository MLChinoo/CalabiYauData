local FriendDeleteDialogPageMediator = require("Business/Friend/Mediators/FriendDeleteDialogPageMediator")
local FriendDeletekDialogPage = class("FriendDeletekDialogPage", PureMVC.ViewComponentPage)
function FriendDeletekDialogPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendDeletekDialogPage:ListNeededMediators()
  return {FriendDeleteDialogPageMediator}
end
function FriendDeletekDialogPage:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClose = LuaEvent.new()
  self.actionOnClickConfirm = LuaEvent.new()
  self.actionOnClickESC = LuaEvent.new()
end
function FriendDeletekDialogPage:Construct()
  FriendDeletekDialogPage.super.Construct(self)
  if self.Button_Confirm then
    self.Button_Confirm.OnClickEvent:Add(self, self.OnClickConfirm)
    self.Button_Confirm:SetButtonIsEnabled(true)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickESC)
    self.Button_Return:SetButtonIsEnabled(true)
  end
end
function FriendDeletekDialogPage:Destruct()
  FriendDeletekDialogPage.super.Destruct(self)
end
function FriendDeletekDialogPage:OnShow()
  self.actionOnShow()
end
function FriendDeletekDialogPage:OnClose()
  self.actionOnClose()
end
function FriendDeletekDialogPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "E" == keyName then
    return self.Button_Return:MonitorKeyDown(key, inputEvent)
  elseif "Y" == keyName then
    return self.Button_Confirm:MonitorKeyDown(key, inputEvent)
  end
  return false
end
function FriendDeletekDialogPage:OnClickConfirm()
  self.actionOnClickConfirm()
end
function FriendDeletekDialogPage:OnClickESC()
  self.actionOnClickESC()
end
return FriendDeletekDialogPage
