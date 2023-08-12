local VoiceEnum = {}
local EPanelType = {Speaker = 1, Mic = 2}
local ESpeakerChannelType = {
  Team = 1,
  Room = 2,
  Close = 3
}
local EMicChannelType = {
  TeamAuto = 1,
  RoomAuto = 2,
  Close = 3,
  TeamPress = 4,
  RoomPress = 5
}
local EPanelStatusType = {ON = 1, OFF = 2}
VoiceEnum.PanelType = EPanelType
VoiceEnum.MicChannelType = EMicChannelType
VoiceEnum.SpeakerChannelType = ESpeakerChannelType
VoiceEnum.PanelStatusType = EPanelStatusType
return VoiceEnum
