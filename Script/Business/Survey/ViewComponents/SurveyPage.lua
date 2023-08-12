local SurveyPageMediator = require("Business/Survey/Mediators/SurveyPageMediator")
local SurveyPage = class("SurveyPage", PureMVC.ViewComponentPage)
function SurveyPage:ListNeededMediators()
  return {SurveyPageMediator}
end
function SurveyPage:InitializeLuaEvent()
  self.actionOnClickOpenSurveyBtn = LuaEvent.new()
  self.actionOnClickReceiveBtn = LuaEvent.new()
  self.actionLuaHandleKeyEvent = LuaEvent.new()
end
function SurveyPage:OnOpen(luaOpenData, nativeOpenData)
  if self.OpenSurveyBtn then
    self.OpenSurveyBtn.OnClicked:Add(self, self.OnClickOpenSurveyBtn)
    self.OpenSurveyBtn.OnPressed:Add(self, self.OnPressedOpenSurveyBtn)
    self.OpenSurveyBtn.OnReleased:Add(self, self.OnReleasedOpenSurveyBtn)
    self.OpenSurveyBtn.OnHovered:Add(self, self.OnHoveredOpenSurveyBtn)
    self.OpenSurveyBtn.OnUnhovered:Add(self, self.OnUnhoveredOpenSurveyBtn)
    self.WS_OpenSurvey:SetActiveWidgetIndex(0)
  end
  if self.receiveBtn then
    self.receiveBtn.OnClicked:Add(self, self.OnClickReceiveBtn)
    self.receiveBtn.OnPressed:Add(self, self.OnPressedReceiveBtn)
    self.receiveBtn.OnReleased:Add(self, self.OnReleasedReceiveBtn)
    self.receiveBtn.OnHovered:Add(self, self.OnHoveredReceiveBtn)
    self.receiveBtn.OnUnhovered:Add(self, self.OnUnhoveredReceiveBtn)
    self.WS_receive:SetActiveWidgetIndex(0)
  end
  if self.goBack then
    self.goBack.OnClicked:Add(self, self.OnClickGoBack)
  end
  if self.Img_bg then
    self.Img_bg.OnMouseButtonDownEvent:Bind(self, self.OnClickImageGoBack)
  end
end
function SurveyPage:OnPressedOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(2)
end
function SurveyPage:OnReleasedOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(1)
end
function SurveyPage:OnHoveredOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(1)
end
function SurveyPage:OnUnhoveredOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(0)
end
function SurveyPage:OnPressedReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(2)
end
function SurveyPage:OnReleasedReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(1)
end
function SurveyPage:OnHoveredReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(1)
end
function SurveyPage:OnUnhoveredReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(0)
end
function SurveyPage:LuaHandleKeyEvent(key, inputEvent)
  self.actionLuaHandleKeyEvent(key, inputEvent)
  return false
end
function SurveyPage:OnClose()
  if self.OpenSurveyBtn then
    self.OpenSurveyBtn.OnClicked:Remove(self, self.OnClickOpenSurveyBtn)
    self.OpenSurveyBtn.OnPressed:Remove(self, self.OnPressedOpenSurveyBtn)
    self.OpenSurveyBtn.OnReleased:Remove(self, self.OnReleasedOpenSurveyBtn)
    self.OpenSurveyBtn.OnHovered:Remove(self, self.OnHoveredOpenSurveyBtn)
    self.OpenSurveyBtn.OnUnhovered:Remove(self, self.OnUnhoveredOpenSurveyBtn)
  end
  if self.receiveBtn then
    self.receiveBtn.OnClicked:Remove(self, self.OnClickReceiveBtn)
    self.receiveBtn.OnPressed:Remove(self, self.OnPressedReceiveBtn)
    self.receiveBtn.OnReleased:Remove(self, self.OnReleasedReceiveBtn)
    self.receiveBtn.OnHovered:Remove(self, self.OnHoveredReceiveBtn)
    self.receiveBtn.OnUnhovered:Remove(self, self.OnUnhoveredReceiveBtn)
  end
  if self.goBack then
    self.goBack.OnClicked:Remove(self, self.OnClickGoBack)
  end
  if self.Img_bg then
    self.Img_bg.OnMouseButtonDownEvent:Unbind()
  end
end
function SurveyPage:OnClickReceiveBtn()
  self.actionOnClickReceiveBtn()
end
function SurveyPage:OnClickOpenSurveyBtn()
  self.actionOnClickOpenSurveyBtn()
end
function SurveyPage:OnClickGoBack()
  ViewMgr:ClosePage(self)
end
function SurveyPage:OnClickImageGoBack()
  ViewMgr:ClosePage(self)
end
return SurveyPage
