local DSDisconnectPage = class("DSDisconnectPage", PureMVC.ViewComponentPage)
local DSDisconnectMediator = require("Business/ConnectDS/Mediators/DSDisconnectMediator")
function DSDisconnectPage:ListNeededMediators()
  return {DSDisconnectMediator}
end
function DSDisconnectPage:InitializeLuaEvent()
  self.actionOnReconnectDS = LuaEvent.new()
  self.actionOnGotoLobby = LuaEvent.new()
  LogDebug("DSDisconnectPage", "self:" .. tostring(self))
  LogDebug("DSDisconnectPage", "Btn_Yes:" .. tostring(self.Btn_Yes))
  self.Btn_Yes.OnClickEvent:Add(self, function()
    LogDebug("DSDisconnectPage", "Will reconnect...")
    self.actionOnReconnectDS()
  end)
end
function DSDisconnectPage:RefreshData(title, content, yesBtnTxt, noBtnTxt)
  self.Txt_PanelTitle:SetText(title)
  self.Text_PanelContent:SetText(content)
  self.Btn_Yes:SetPanelName(yesBtnTxt)
end
function DSDisconnectPage:OnOpen(luaOpenData, nativeOpenData)
end
function DSDisconnectPage:OnShow(luaOpenData, nativeOpenData)
end
function DSDisconnectPage:OnHide()
end
function DSDisconnectPage:OnClose()
end
return DSDisconnectPage
