local SpeakerContrlPanelMediatorMobile = require("Business/HUD/Voice/Mediators/SpeakerContrlPanelMediatorMobile")
local SpeakerContrlPanelMobile = class("SpeakerContrlPanelMobile", PureMVC.ViewComponentPanel)
function SpeakerContrlPanelMobile:ListNeededMediators()
  return {SpeakerContrlPanelMediatorMobile}
end
function SpeakerContrlPanelMobile:InitializeLuaEvent()
  self.actionOnClickSpeakerTeamBtn = LuaEvent.new()
  self.actionOnClickSpeakerRoomBtn = LuaEvent.new()
  self.actionOnClickSpeakerCloseBtn = LuaEvent.new()
end
function SpeakerContrlPanelMobile:Construct()
  SpeakerContrlPanelMobile.super.Construct(self)
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
function SpeakerContrlPanelMobile:Destruct()
  SpeakerContrlPanelMobile.super.Destruct(self)
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
function SpeakerContrlPanelMobile:OnClickSpeakerRoomBtn()
  self:actionOnClickSpeakerRoomBtn()
end
function SpeakerContrlPanelMobile:OnClickSpeakerTeamBtn()
  self:actionOnClickSpeakerTeamBtn()
end
function SpeakerContrlPanelMobile:OnClickSpeakerCloseBtn()
  self:actionOnClickSpeakerCloseBtn()
end
function SpeakerContrlPanelMobile:InitPanel()
  LogDebug("SpeakerContrlPanelMobile", "InitPanel")
end
function SpeakerContrlPanelMobile:ResetChannel()
  LogDebug("SpeakerContrlPanelMobile", "ResetChannel")
end
return SpeakerContrlPanelMobile
