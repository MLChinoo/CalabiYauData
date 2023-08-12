local ExchangePosPage = class("ExchangePosPage", PureMVC.ViewComponentPage)
local ExchangePosPageMediator = require("Business/Room/Mediators/TeamUpRoom/ExchangePosPageMediator")
function ExchangePosPage:ListNeededMediators()
  return {ExchangePosPageMediator}
end
function ExchangePosPage:OnInitialized()
  ExchangePosPage.super.OnInitialized(self)
end
function ExchangePosPage:InitializeLuaEvent()
  self.actionLuaHandleKeyEvent = LuaEvent.new()
  self.actionConfirm = LuaEvent.new()
  self.actionRefuse = LuaEvent.new()
end
function ExchangePosPage:Construct()
  ExchangePosPage.super.Construct(self)
  self.Btn_Confirm.OnClicked:Add(self, self.OnClickConfirm)
  self.Btn_Refuse.OnClicked:Add(self, self.OnClickRefuse)
end
function ExchangePosPage:Destruct()
  ExchangePosPage.super.Destruct(self)
  self.Btn_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  self.Btn_Refuse.OnClicked:Remove(self, self.OnClickRefuse)
end
function ExchangePosPage:LuaHandleKeyEvent(key, inputEvent)
  return self.actionLuaHandleKeyEvent(key, inputEvent)
end
function ExchangePosPage:OnClickConfirm()
  self.actionConfirm()
end
function ExchangePosPage:OnClickRefuse()
  self.actionRefuse()
end
return ExchangePosPage
