local MicContrlPanelPanelMediatorMobile = require("Business/HUD/Voice/Mediators/MicContrlPanelPanelMediatorMobile")
local MicContrlPanelMobile = class("MicContrlPanelMobile", PureMVC.ViewComponentPanel)
function MicContrlPanelMobile:ListNeededMediators()
  return {MicContrlPanelPanelMediatorMobile}
end
function MicContrlPanelMobile:InitializeLuaEvent()
  self.actionOnClickMicRootBtn = LuaEvent.new()
  self.actionOnClickMicAlwaysTeamBtn = LuaEvent.new()
  self.actionOnClickMicAlwaysRoomBtn = LuaEvent.new()
  self.actionOnClickMicAlwaysCloseBtn = LuaEvent.new()
  self.actionOnClickMicPressTeamBtn = LuaEvent.new()
  self.actionOnClickMicPressRoomBtn = LuaEvent.new()
  self.actionOnClickCloseBtn = LuaEvent.new()
end
function MicContrlPanelMobile:Construct()
  MicContrlPanelMobile.super.Construct(self)
  if self.Btn_Mic then
    self.Btn_Mic.OnClicked:Add(self, self.OnClickMicRootBtn)
  end
  if self.Mic_Always_Team then
    self.Mic_Always_Team.OnClicked:Add(self, self.OnClickMicAlwaysTeamBtn)
  end
  if self.Mic_Always_Room then
    self.Mic_Always_Room.OnClicked:Add(self, self.OnClickMicAlwaysRoomBtn)
  end
  if self.Mic_Always_Close then
    self.Mic_Always_Close.OnClicked:Add(self, self.OnClickMicAlwaysCloseBtn)
  end
  if self.Mic_Press_Team then
    self.Mic_Press_Team.OnClicked:Add(self, self.OnClickMicPressTeamBtn)
  end
  if self.Mic_Press_Room then
    self.Mic_Press_Room.OnClicked:Add(self, self.OnClickMicPressRoomBtn)
  end
  if self.CloseBtn then
    self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  end
end
function MicContrlPanelMobile:Destruct()
  MicContrlPanelMobile.super.Destruct(self)
  if self.Btn_Mic then
    self.Btn_Mic.OnClicked:Remove(self, self.OnClickMicRootBtn)
  end
  if self.Mic_Always_Team then
    self.Mic_Always_Team.OnClicked:Remove(self, self.OnClickMicAlwaysTeamBtn)
  end
  if self.Mic_Always_Room then
    self.Mic_Always_Room.OnClicked:Remove(self, self.OnClickMicAlwaysRoomBtn)
  end
  if self.Mic_Always_Close then
    self.Mic_Always_Close.OnClicked:Remove(self, self.OnClickMicAlwaysCloseBtn)
  end
  if self.Mic_Press_Team then
    self.Mic_Press_Team.OnClicked:Remove(self, self.OnClickMicPressTeamBtn)
  end
  if self.Mic_Press_Room then
    self.Mic_Press_Room.OnClicked:Remove(self, self.OnClickMicPressRoomBtn)
  end
  if self.CloseBtn then
    self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  end
end
function MicContrlPanelMobile:OnClickMicRootBtn()
  self.actionOnClickMicRootBtn()
end
function MicContrlPanelMobile:OnClickMicAlwaysTeamBtn()
  self:actionOnClickMicAlwaysTeamBtn()
end
function MicContrlPanelMobile:OnClickMicAlwaysRoomBtn()
  self:actionOnClickMicAlwaysRoomBtn()
end
function MicContrlPanelMobile:OnClickMicAlwaysCloseBtn()
  self:actionOnClickMicAlwaysCloseBtn()
end
function MicContrlPanelMobile:OnClickMicPressTeamBtn()
  self:actionOnClickMicPressTeamBtn()
end
function MicContrlPanelMobile:OnClickMicPressRoomBtn()
  self:actionOnClickMicPressRoomBtn()
end
function MicContrlPanelMobile:OnClickCloseBtn()
  self:actionOnClickCloseBtn()
end
return MicContrlPanelMobile
