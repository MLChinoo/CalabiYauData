local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local RoleAchievementMediator = class("RoleAchievementMediator", PureMVC.Mediator)
function RoleAchievementMediator:OnRegister()
  RoleAchievementMediator.super.OnRegister(self)
  self.ViewPage = self:GetViewComponent()
  self.AchvProxy = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy)
end
function RoleAchievementMediator:OnRemove()
  RoleAchievementMediator.super.OnRemove(self)
end
function RoleAchievementMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.RoleAchievement.InitPage,
    NotificationDefines.Career.RoleAchievement.HeadItemSelected,
    NotificationDefines.Career.RoleAchievement.RoleAchvItemSelected
  }
end
function RoleAchievementMediator:HandleNotification(ntf)
  local ntfName = ntf:GetName()
  if ntfName == NotificationDefines.Career.RoleAchievement.InitPage then
    self:InitViewPage()
  elseif ntfName == NotificationDefines.Career.RoleAchievement.HeadItemSelected then
    self.ViewPage:OnRoleHeadItemClicked(ntf:GetBody())
  elseif ntfName == NotificationDefines.Career.RoleAchievement.RoleAchvItemSelected then
    self.ViewPage:OnRoleAchvItemClicked(ntf:GetBody())
  end
end
function RoleAchievementMediator:InitViewPage()
  local achievementMap = self.AchvProxy:GetAchievementMap()
  local roleAchvMap = achievementMap[CareerEnumDefine.achievementType.hero]
  local redDotList = GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDots(Pb_ncmd_cs.EReddotType.ReddotType_REACH_ACHIEVEMENT)
  if redDotList then
    for _, value in pairs(redDotList) do
      local achieveId = 0 ~= value.event_id and value.event_id or value.reddot_rid
      if roleAchvMap.achievementList and roleAchvMap.achievementList[achieveId] then
        roleAchvMap.achievementList[achieveId].redDotId = value.mark and value.reddot_id or nil
      end
    end
  end
  self.ViewPage:InitView(roleAchvMap)
end
return RoleAchievementMediator
