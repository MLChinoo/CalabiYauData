local ActivityEntryPanelMediator = require("Business/ActivityEntryList/Mediators/ActivityEntryPanelMediator")
local ActivityEntryPanel = class("ActivityEntryPanel", PureMVC.ViewComponentPage)
function ActivityEntryPanel:ListNeededMediators()
  return {ActivityEntryPanelMediator}
end
function ActivityEntryPanel:InitializeLuaEvent()
  self.updateViewEvent = LuaEvent.new()
end
function ActivityEntryPanel:Construct()
  ActivityEntryPanel.super.Construct(self)
  self.updateViewEvent()
  if self.EntryBtn then
    self.EntryBtn.OnClicked:Add(self, ActivityEntryPanel.OnClickEntryBtn)
  end
end
function ActivityEntryPanel:Destruct()
  ActivityEntryPanel.super.Destruct(self)
  if self.EntryBtn then
    self.EntryBtn.OnClicked:Remove(self, ActivityEntryPanel.OnClickEntryBtn)
  end
end
function ActivityEntryPanel:OnClickEntryBtn()
  ViewMgr:OpenPage(self, UIPageNameDefine.ActivityEntryListPage)
end
function ActivityEntryPanel:SetViewVisible(visible)
  self.apartmentVisible = visible
  if table.count(GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):GetAllEnableActivities()) > 1 then
    self:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return ActivityEntryPanel
