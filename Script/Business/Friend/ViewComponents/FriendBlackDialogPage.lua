local FriendBlackDialogPageMediator = require("Business/Friend/Mediators/FriendBlackDialogPageMediator")
local FriendBlackDialogPage = class("FriendBlackDialogPage", PureMVC.ViewComponentPage)
function FriendBlackDialogPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendBlackDialogPage:ListNeededMediators()
  return {FriendBlackDialogPageMediator}
end
function FriendBlackDialogPage:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClose = LuaEvent.new()
  self.actionOnClickConfirm = LuaEvent.new()
  self.actionOnClickESC = LuaEvent.new()
end
function FriendBlackDialogPage:Construct()
  FriendBlackDialogPage.super.Construct(self)
  if self.Button_Confirm then
    self.Button_Confirm.OnClickEvent:Add(self, self.OnClickConfirm)
    self.Button_Confirm:SetButtonIsEnabled(true)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickESC)
    self.Button_Return:SetButtonIsEnabled(true)
  end
end
function FriendBlackDialogPage:Destruct()
  FriendBlackDialogPage.super.Destruct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  end
  if self.Btn_MenuReturn then
    self.Btn_MenuReturn.OnClicked:Remove(self, self.OnClickESC)
  end
end
function FriendBlackDialogPage:OnShow()
  self.actionOnShow()
end
function FriendBlackDialogPage:OnClose()
  self.actionOnClose()
end
function FriendBlackDialogPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "E" == keyName then
    return self.Button_Return:MonitorKeyDown(key, inputEvent)
  elseif "Y" == keyName then
    return self.Button_Confirm:MonitorKeyDown(key, inputEvent)
  end
  return false
end
function FriendBlackDialogPage:OnClickConfirm()
  self.actionOnClickConfirm()
end
function FriendBlackDialogPage:OnClickESC()
  self.actionOnClickESC()
end
return FriendBlackDialogPage
