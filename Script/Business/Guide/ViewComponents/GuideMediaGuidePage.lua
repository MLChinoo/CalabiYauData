local GuideMediaGuidePage = class("GuideMediaGuidePage", PureMVC.ViewComponentPage)
function GuideMediaGuidePage:ListNeededMediators()
  return {
    require("Business/Guide/Mediators/GuideMediaGuideMediator")
  }
end
function GuideMediaGuidePage:InitializeLuaEvent()
  self.OnClickCloseEvent = LuaEvent.new()
  self.OnDestructEvent = LuaEvent.new()
end
function GuideMediaGuidePage:LuaHandleKeyEvent(key, inputEvent)
  if self.Button_Sure then
    return self.Button_Sure:HandleKeyEvent(key, inputEvent)
  end
  return false
end
function GuideMediaGuidePage:OnOpen(luaOpenData, nativeOpenData)
  self:BindEvent()
  if self.Widget_DefaultMouseLocationUI and self.SetMouseToUIPresetsLocation then
    self:SetMouseToUIPresetsLocation(self.Widget_DefaultMouseLocationUI)
  end
end
function GuideMediaGuidePage:BindEvent()
  if self.Button_Sure then
    self.Button_Sure.OnPMButtonClicked:Add(self, function()
      self.OnClickCloseEvent()
    end)
  end
end
function GuideMediaGuidePage:Destruct()
  GuideMediaGuidePage.super.Destruct(self)
  self.OnDestructEvent()
end
return GuideMediaGuidePage
