local SmallSpeakerContrlPanelMediator = require("Business/Room/Mediators/Card/SmallSpeakerContrlPanelMediator")
local SmallSpeakerContrlPanel = class("SmallSpeakerContrlPanel", PureMVC.ViewComponentPanel)
function SmallSpeakerContrlPanel:ListNeededMediators()
  return {SmallSpeakerContrlPanelMediator}
end
local roomDataProxy
function SmallSpeakerContrlPanel:InitializeLuaEvent()
  self.playerID = nil
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.actionOnClickedNormalVoiceState = LuaEvent.new()
  self.actionOnClickedSpeakVoiceState = LuaEvent.new()
  self.actionOnClickedShieldVoiceState = LuaEvent.new()
end
function SmallSpeakerContrlPanel:Construct()
  SmallSpeakerContrlPanel.super.Construct(self)
  self.Btn_VoiceState_Normal.OnClicked:Add(self, self.OnClickedNormalVoiceState)
  self.Btn_VoiceState_Speak.OnClicked:Add(self, self.OnClickedSpeakVoiceState)
  self.Btn_VoiceState_Shield.OnClicked:Add(self, self.OnClickedShieldVoiceState)
end
function SmallSpeakerContrlPanel:Destruct()
  SmallSpeakerContrlPanel.super.Destruct(self)
  self.Btn_VoiceState_Normal.OnClicked:Remove(self, self.OnClickedNormalVoiceState)
  self.Btn_VoiceState_Speak.OnClicked:Remove(self, self.OnClickedSpeakVoiceState)
  self.Btn_VoiceState_Shield.OnClicked:Remove(self, self.OnClickedShieldVoiceState)
end
function SmallSpeakerContrlPanel:OnClickedNormalVoiceState()
  if self.playerID == roomDataProxy:GetPlayerID() then
    return
  end
  self.actionOnClickedNormalVoiceState()
end
function SmallSpeakerContrlPanel:OnClickedSpeakVoiceState()
  if self.playerID == roomDataProxy:GetPlayerID() then
    return
  end
  self.actionOnClickedSpeakVoiceState()
end
function SmallSpeakerContrlPanel:OnClickedShieldVoiceState()
  if self.playerID == roomDataProxy:GetPlayerID() then
    return
  end
  self.actionOnClickedShieldVoiceState()
end
return SmallSpeakerContrlPanel
