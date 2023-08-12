local GameModeSelectMediator = require("Business/Lobby/Mediators/GameModeSelectMediator")
local GameModeSelectPage = class("GameModeSelectPage", PureMVC.ViewComponentPage)
function GameModeSelectPage:ListNeededMediators()
  return {GameModeSelectMediator}
end
function GameModeSelectPage:InitializeLuaEvent()
  LogDebug("GameModeSelectPage", "InitializeLuaEvent")
  self.actionLuaHandleKeyEvent = LuaEvent.new()
  self.actionOnShow = LuaEvent.new()
end
function GameModeSelectPage:Construct()
  GameModeSelectPage.super.Construct(self)
end
function GameModeSelectPage:Destruct()
  GameModeSelectPage.super.Destruct(self)
end
function GameModeSelectPage:OnShow(luaData, originOpenData)
  self.actionOnShow()
end
function GameModeSelectPage:LuaHandleKeyEvent(key, inputEvent)
  self.actionLuaHandleKeyEvent(key, inputEvent)
  return false
end
return GameModeSelectPage
