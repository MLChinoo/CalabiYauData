local RoomSettingPageMediator = require("Business/Room/Mediators/SettingRoom/RoomSettingPageMediator")
local RoomSettingPage = class("RoomSettingPage", PureMVC.ViewComponentPanel)
function RoomSettingPage:ListNeededMediators()
  return {RoomSettingPageMediator}
end
function RoomSettingPage:InitializeLuaEvent()
  self.actionOnClickEsc = LuaEvent.new()
  self.actionOnClickSave = LuaEvent.new()
  self.actionOnRoomNameTextChanged = LuaEvent.new()
  self.actionOnRoomPwdTextChanged = LuaEvent.new()
end
function RoomSettingPage:Construct()
  RoomSettingPage.super.Construct(self)
  self.Button_Esc.OnClicked:Add(self, self.OnBtnEsc)
  self.Button_Save.OnClicked:Add(self, self.OnBtnSave)
  self.EditableTB_RoomName.OnTextChanged:Add(self, self.OnRoomNameTextChanged)
  self.EditableTB_Password.OnTextChanged:Add(self, self.OnPasswordTextChanged)
  self.Btn_HidePassword.OnClicked:Add(self, self.OnBtnHidePassword)
  self.Btn_ShowPassword.OnClicked:Add(self, self.OnBtnShowPassword)
  self:OnBtnHidePassword()
end
function RoomSettingPage:Destruct()
  RoomSettingPage.super.Destruct(self)
  self.Button_Esc.OnClicked:Remove(self, self.OnBtnEsc)
  self.Button_Save.OnClicked:Remove(self, self.OnBtnSave)
  self.EditableTB_RoomName.OnTextChanged:Remove(self, self.OnPasswordTextChanged)
  self.Btn_HidePassword.OnClicked:Remove(self, self.OnBtnHidePassword)
  self.Btn_ShowPassword.OnClicked:Remove(self, self.OnBtnShowPassword)
end
function RoomSettingPage:OnBtnHidePassword()
  self.WS_passwordVisibility:SetActiveWidgetIndex(0)
  self.EditableTB_Password:SetIsPassword(true)
end
function RoomSettingPage:OnBtnShowPassword()
  self.WS_passwordVisibility:SetActiveWidgetIndex(1)
  self.EditableTB_Password:SetIsPassword(false)
end
function RoomSettingPage:OnRoomNameTextChanged(inText)
  self.actionOnRoomNameTextChanged(inText)
end
function RoomSettingPage:OnPasswordTextChanged(inText)
  self.actionOnRoomPwdTextChanged(inText)
end
function RoomSettingPage:OnBtnEsc()
  self.actionOnClickEsc()
end
function RoomSettingPage:OnBtnSave()
  self.actionOnClickSave()
end
function RoomSettingPage:OnShow(luaData, originOpenData)
end
function RoomSettingPage:LuaHandleKeyEvent(key, inputEvent)
  local keyDisplayName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyDisplayName and inputEvent == UE4.EInputEvent.IE_Released then
    ViewMgr:ClosePage(self, UIPageNameDefine.RoomSettingPC)
    return true
  elseif "Y" == keyDisplayName and inputEvent == UE4.EInputEvent.IE_Released then
    if self.EditableTB_RoomName:HasKeyboardFocus() or self.EditableTB_Password:HasKeyboardFocus() then
      return false
    end
    self.actionOnClickSave()
    return true
  end
  return false
end
return RoomSettingPage
