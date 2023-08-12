local AchievementLevelProgress = class("AchievementLevelProgress", PureMVC.ViewComponentPanel)
function AchievementLevelProgress:SetLevelProgress(requiredNumTable, level, totalNum)
  if self.HorizontalBox_Number then
    local numbers = self.HorizontalBox_Number:GetAllChildren()
    for index = 1, numbers:Length() do
      numbers:Get(index):SetText(requiredNumTable[index])
    end
  end
  local totalGot = totalNum or 0
  if self.ProgressBar_LevelProgress then
    local progressPercent
    if level == table.count(requiredNumTable) then
      progressPercent = 1
    else
      progressPercent = (level - 1) / (table.count(requiredNumTable) - 1)
      progressPercent = progressPercent + (totalGot - requiredNumTable[level]) / (requiredNumTable[level + 1] - requiredNumTable[level]) / (table.count(requiredNumTable) - 1)
    end
    LogDebug("AchievementLevelProgress", "Total number: " .. totalGot .. "; Progress percent: " .. progressPercent)
    self.ProgressBar_LevelProgress:SetPercent(progressPercent)
  end
end
return AchievementLevelProgress
