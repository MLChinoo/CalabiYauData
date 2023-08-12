local NewPlayerTeamFightGuideEnum = {}
local index = 1
local GetCount = function()
  local retIndex = index
  index = index + 1
  return retIndex
end
NewPlayerTeamFightGuideEnum.GuideStep = {
  GotoFight = GetCount(),
  SelectTeamFight = GetCount(),
  BeginFight = GetCount()
}
NewPlayerTeamFightGuideEnum.GuideStepMax = index - 1
return NewPlayerTeamFightGuideEnum
