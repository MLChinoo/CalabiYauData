local SeasonPrizeMediator = require("Business/Template/Mediators/TemplateMediator")
local SeasonPrizePage = class("SeasonPrizePage", PureMVC.ViewComponentPage)
function SeasonPrizePage:ListNeededMediators()
  return {SeasonPrizeMediator}
end
function SeasonPrizePage:InitializeLuaEvent()
  self.actionOnClose = LuaEvent.new()
end
function SeasonPrizePage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("SeasonPrizePage", "Lua implement OnOpen")
  if self.ViewController then
    self.ButtonEsc = self.ViewController:CreatePanel(UE4.UPMCommonKeyButton:StaticClass(), self.Button_Esc)
    self.ButtonEsc.OnSimpleClickedEvent:Add(self, self.OnClickEscBtn)
  end
end
function SeasonPrizePage:OnClickEscBtn()
  LogDebug("SeasonPrizePage", "Lua implement Click Esc Btn")
  self.actionOnClose()
end
return SeasonPrizePage
