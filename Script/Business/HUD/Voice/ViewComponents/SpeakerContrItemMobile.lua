local SpeakerContrItemMobile = class("SpeakerContrItemMobile", PureMVC.ViewComponentPanel)
function SpeakerContrItemMobile:ListNeededMediators()
  return {}
end
function SpeakerContrItemMobile:InitializeLuaEvent()
end
function SpeakerContrItemMobile:Construct()
  SpeakerContrItemMobile.super.Construct(self)
  self.voiceManager = UE4.UPMVoiceManager.Get(LuaGetWorld())
  LogDebug("SpeakerContrItemMobile", "Construct")
  self.CheckBox_OpenVoice.OnCheckStateChanged:Add(self, self.OnChangeForbidVoiceState)
end
function SpeakerContrItemMobile:InitView(playID)
  LogDebug("SpeakerContrItemMobile", "InitView  playID == " .. tostring(playID))
  self.playID = playID
  local ForbidVoiceState = self.voiceManager:GetPlayreForbidVoiceState(self.playID)
  self.CheckBox_OpenVoice:SetIsChecked(not ForbidVoiceState)
  self.PlayerName:SetText(self.voiceManager:GetPlayerNameByOpenID(self.playID))
end
function SpeakerContrItemMobile:OnChangeForbidVoiceState(bIsChecked)
  if not bIsChecked then
    local msg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Chat, "ForbidPlayerMsg")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
  end
  self.voiceManager:SetPlayreForbidVoiceState(self.playID, not bIsChecked)
  LogDebug("SpeakerContrItemMobile", "playID = " .. tostring(self.playID) .. "  bIsChecked = " .. tostring(bIsChecked))
end
function SpeakerContrItemMobile:Destruct()
  SpeakerContrItemMobile.super.Destruct(self)
  LogDebug("SpeakerContrItemMobile", "Destruct")
end
return SpeakerContrItemMobile
