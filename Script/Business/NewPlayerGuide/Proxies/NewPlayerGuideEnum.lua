local NewPlayerGuideEnum = {}
local index = 1
local GetCount = function()
  local retIndex = index
  index = index + 1
  return retIndex
end
NewPlayerGuideEnum.GuideStep = {
  Gift = GetCount(),
  GiftFirstItem = GetCount(),
  Gift3DBox = GetCount(),
  GiftReceived = GetCount(),
  BackLobbyAndClose = GetCount()
}
NewPlayerGuideEnum.GuideStepMax = index - 1
return NewPlayerGuideEnum
