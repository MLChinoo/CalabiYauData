local CustomVoiceContrlPanelMediatorMobile = require("Business/Voice/Mediators/CustomVoiceContrlPanelMediatorMobile")
local CustomVoiceContrlPanelMobile = class("CustomVoiceContrlPanelMobile", PureMVC.ViewComponentPanel)
function CustomVoiceContrlPanelMobile:ListNeededMediators()
  return {CustomVoiceContrlPanelMediatorMobile}
end
function CustomVoiceContrlPanelMobile:InitializeLuaEvent()
  self.actionOnClickMicRootBtn = LuaEvent.new()
  self.actionOnClickSpeakerRootBtn = LuaEvent.new()
  self.actionOnClickMicAlwaysTeamBtn = LuaEvent.new()
  self.actionOnClickMicAlwaysRoomBtn = LuaEvent.new()
  self.actionOnClickMicAlwaysCloseBtn = LuaEvent.new()
  self.actionOnClickMicPressTeamBtn = LuaEvent.new()
  self.actionOnClickMicPressRoomBtn = LuaEvent.new()
  self.actionOnClickSpeakerTeamBtn = LuaEvent.new()
  self.actionOnClickSpeakerRoomBtn = LuaEvent.new()
  self.actionOnClickSpeakerCloseBtn = LuaEvent.new()
end
function CustomVoiceContrlPanelMobile:Construct()
  CustomVoiceContrlPanelMobile.super.Construct(self)
  if self.Btn_Mic then
    self.Btn_Mic.OnClicked:Add(self, self.OnClickMicRootBtn)
  end
  if self.Btn_Speaker then
    self.Btn_Speaker.OnClicked:Add(self, self.OnClickSpeakerRootBtn)
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
  if self.Speaker_Team then
    self.Speaker_Team.OnClicked:Add(self, self.OnClickSpeakerTeamBtn)
  end
  if self.Speaker_Room then
    self.Speaker_Room.OnClicked:Add(self, self.OnClickSpeakerRoomBtn)
  end
  if self.Speaker_Close then
    self.Speaker_Close.OnClicked:Add(self, self.OnClickSpeakerCloseBtn)
  end
end
function CustomVoiceContrlPanelMobile:Destruct()
  CustomVoiceContrlPanelMobile.super.Destruct(self)
  if self.Btn_Mic then
    self.Btn_Mic.OnClicked:Remove(self, self.OnClickMicRootBtn)
  end
  if self.Btn_Speaker then
    self.Btn_Speaker.OnClicked:Remove(self, self.OnClickSpeakerRootBtn)
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
  if self.Speaker_Team then
    self.Speaker_Team.OnClicked:Remove(self, self.OnClickSpeakerTeamBtn)
  end
  if self.Speaker_Room then
    self.Speaker_Room.OnClicked:Remove(self, self.OnClickSpeakerRoomBtn)
  end
  if self.Speaker_Close then
    self.Speaker_Close.OnClicked:Remove(self, self.OnClickSpeakerCloseBtn)
  end
end
function CustomVoiceContrlPanelMobile:OnClickMicRootBtn()
  self.actionOnClickMicRootBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerRootBtn()
  self:actionOnClickSpeakerRootBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicAlwaysTeamBtn()
  self:actionOnClickMicAlwaysTeamBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicAlwaysRoomBtn()
  self:actionOnClickMicAlwaysRoomBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicAlwaysCloseBtn()
  self:actionOnClickMicAlwaysCloseBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicPressTeamBtn()
  self:actionOnClickMicPressTeamBtn()
end
function CustomVoiceContrlPanelMobile:OnClickMicPressRoomBtn()
  self:actionOnClickMicPressRoomBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerRoomBtn()
  self:actionOnClickSpeakerRoomBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerTeamBtn()
  self:actionOnClickSpeakerTeamBtn()
end
function CustomVoiceContrlPanelMobile:OnClickSpeakerCloseBtn()
  self:actionOnClickSpeakerCloseBtn()
end
return CustomVoiceContrlPanelMobile
