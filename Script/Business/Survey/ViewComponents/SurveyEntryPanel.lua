local SurveyEntryPanelMediator = require("Business/Survey/Mediators/SurveyEntryPanelMediator")
local SurveyEntryPanel = class("SurveyEntryPanel", PureMVC.ViewComponentPage)
function SurveyEntryPanel:ListNeededMediators()
  return {SurveyEntryPanelMediator}
end
function SurveyEntryPanel:InitializeLuaEvent()
end
function SurveyEntryPanel:Construct()
  SurveyEntryPanel.super.Construct(self)
  if self.OpenSurveyPageBtn then
    self.OpenSurveyPageBtn.OnClicked:Add(self, self.OnClickOpenSurveyPage)
  end
end
function SurveyEntryPanel:Destruct()
  SurveyEntryPanel.super.Destruct(self)
  if self.OpenSurveyPageBtn then
    self.OpenSurveyPageBtn.OnClicked:Remove(self, self.OnClickOpenSurveyPage)
  end
end
function SurveyEntryPanel:OnClickOpenSurveyPage()
  ViewMgr:OpenPage(self, UIPageNameDefine.SurveyPage)
end
function SurveyEntryPanel:SetViewVisible(visible)
  self.apartmentVisible = visible
  local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
  if SuveyDC:IsReward() then
    LogDebug("SurveyEntryPanel", "SuveyDC:IsReward() == true")
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if visible then
    LogDebug("SurveyEntryPanel", "SuveyDC:IsReward() == false")
    GameFacade:RetrieveProxy(ProxyNames.QuestionnaireProxy):ReqQuestionnaire()
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return SurveyEntryPanel
