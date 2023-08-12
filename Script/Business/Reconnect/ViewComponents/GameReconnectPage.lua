local GameReconnectPage = class("GameReconnectPage", PureMVC.ViewComponentPage)
local GameReconnectMediator = require("Business/Reconnect/Mediators/GameReconnectMediator")
function GameReconnectPage:ListNeededMediators()
  return {GameReconnectMediator}
end
function GameReconnectPage:InitializeLuaEvent()
end
function GameReconnectPage:OnOpen(luaOpenData, nativeOpenData)
  self.ReconnectInfoFormat = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Lobby, "ReconnectStatText")
  self:UpdateReconnectState(0, 0)
  self:PlayAnimation(self.Opening, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function GameReconnectPage:OnClose()
end
function GameReconnectPage:UpdateReconnectState(reconnectTimes, maxReconnectTimes)
  local reconnectInfo = ObjectUtil:GetTextFromFormat(self.ReconnectInfoFormat, {
    [0] = reconnectTimes,
    [1] = maxReconnectTimes
  })
  self.Text_ReconnectStat:SetText(reconnectInfo)
end
return GameReconnectPage
