local SurveyPageMediatorMobile = require("Business/Survey/Mediators/Mobile/SurveyPageMediatorMobile")
local SurveyPageMobile = class("SurveyPageMobile", PureMVC.ViewComponentPage)
function SurveyPageMobile:ListNeededMediators()
  return {SurveyPageMediatorMobile}
end
function SurveyPageMobile:InitializeLuaEvent()
  self.actionOnClickOpenSurveyBtn = LuaEvent.new()
  self.actionOnClickReceiveBtn = LuaEvent.new()
end
function SurveyPageMobile:OnOpen(luaOpenData, nativeOpenData)
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
function SurveyPageMobile:OnPressedOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(2)
end
function SurveyPageMobile:OnReleasedOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(1)
end
function SurveyPageMobile:OnHoveredOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(1)
end
function SurveyPageMobile:OnUnhoveredOpenSurveyBtn()
  self.WS_OpenSurvey:SetActiveWidgetIndex(0)
end
function SurveyPageMobile:OnPressedReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(2)
end
function SurveyPageMobile:OnReleasedReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(1)
end
function SurveyPageMobile:OnHoveredReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(1)
end
function SurveyPageMobile:OnUnhoveredReceiveBtn()
  self.WS_receive:SetActiveWidgetIndex(0)
end
function SurveyPageMobile:OnClose()
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
function SurveyPageMobile:OnClickReceiveBtn()
  self.actionOnClickReceiveBtn()
end
function SurveyPageMobile:OnClickOpenSurveyBtn()
  self.actionOnClickOpenSurveyBtn()
end
function SurveyPageMobile:OnClickGoBack()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SurveyPageMobile:OnClickImageGoBack()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return SurveyPageMobile
