local TemplateDataProxy = class("TemplateDataProxy", PureMVC.Proxy)
function TemplateDataProxy:InitAchievementData()
  self.achievementTable = {}
  local arrRows = ConfigMgr:GetAchievementTableRows()
  for i = 1, arrRows:Length() do
    local row = arrRows:Get(i)
    self.achievementTable[row.Id] = row
  end
end
function TemplateDataProxy:OnRegister()
  self.Super.OnRegister(self)
  self:InitAchievementData()
end
function TemplateDataProxy:GetXXX()
end
function TemplateDataProxy:GetYYY()
end
return TemplateDataProxy
