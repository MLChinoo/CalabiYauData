local MatchVoiceContrlPanelMediatorMobile = require("Business/Voice/Mediators/MatchVoiceContrlPanelMediatorMobile")
local MatchVoiceContrlPanelMobile = class("MatchVoiceContrlPanelMobile", PureMVC.ViewComponentPanel)
function MatchVoiceContrlPanelMobile:ListNeededMediators()
  return {MatchVoiceContrlPanelMediatorMobile}
end
function MatchVoiceContrlPanelMobile:InitializeLuaEvent()
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
function MatchVoiceContrlPanelMobile:Construct()
  MatchVoiceContrlPanelMobile.super.Construct(self)
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
function MatchVoiceContrlPanelMobile:Destruct()
  MatchVoiceContrlPanelMobile.super.Destruct(self)
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
function MatchVoiceContrlPanelMobile:OnClickMicRootBtn()
  self.actionOnClickMicRootBtn()
end
function MatchVoiceContrlPanelMobile:OnClickSpeakerRootBtn()
  self:actionOnClickSpeakerRootBtn()
end
function MatchVoiceContrlPanelMobile:OnClickMicAlwaysTeamBtn()
  self:actionOnClickMicAlwaysTeamBtn()
end
function MatchVoiceContrlPanelMobile:OnClickMicAlwaysRoomBtn()
  self:actionOnClickMicAlwaysRoomBtn()
end
function MatchVoiceContrlPanelMobile:OnClickMicAlwaysCloseBtn()
  self:actionOnClickMicAlwaysCloseBtn()
end
function MatchVoiceContrlPanelMobile:OnClickMicPressTeamBtn()
  self:actionOnClickMicPressTeamBtn()
end
function MatchVoiceContrlPanelMobile:OnClickMicPressRoomBtn()
  self:actionOnClickMicPressRoomBtn()
end
function MatchVoiceContrlPanelMobile:OnClickSpeakerRoomBtn()
  self:actionOnClickSpeakerRoomBtn()
end
function MatchVoiceContrlPanelMobile:OnClickSpeakerTeamBtn()
  self:actionOnClickSpeakerTeamBtn()
end
function MatchVoiceContrlPanelMobile:OnClickSpeakerCloseBtn()
  self:actionOnClickSpeakerCloseBtn()
end
return MatchVoiceContrlPanelMobile
