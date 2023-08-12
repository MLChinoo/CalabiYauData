local MatchTimeCounterPage = class("MatchTimeCounterPage", PureMVC.ViewComponentPage)
local MatchTimeCounterPageMediator = require("Business/Room/Mediators/Common/MatchTimeCounterPageMediator")
function MatchTimeCounterPage:ListNeededMediators()
  return {MatchTimeCounterPageMediator}
end
function MatchTimeCounterPage:InitializeLuaEvent()
  self.actionOnQuitMatchBtnDown = LuaEvent.new()
  self.actionOnBackRoomBtnBtnDown = LuaEvent.new()
end
function MatchTimeCounterPage:Construct()
  MatchTimeCounterPage.super.Construct(self)
  self.QuitBtn.OnClicked:Add(self, function()
    self.actionOnQuitMatchBtnDown()
  end)
  self.BackRoomBtn.OnMouseButtonDownEvent:Bind(self, function()
    self.actionOnBackRoomBtnBtnDown()
    UE4.UWidgetBlueprintLibrary.Unhandled()
  end)
end
function MatchTimeCounterPage:Destruct()
  MatchTimeCounterPage.super.Destruct(self)
  self.QuitBtn.OnClicked:Remove(self, function()
    self.actionOnQuitMatchBtnDown()
  end)
  self.BackRoomBtn.OnMouseButtonDownEvent:Unbind()
end
return MatchTimeCounterPage
