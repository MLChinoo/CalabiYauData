local OnResBattleInfoCmd = class("OnResBattleInfoCmd", PureMVC.Command)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function OnResBattleInfoCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.Career.BattleRecord.OnResBattleInfoCmd then
    if 0 ~= notification:GetType() then
      GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.RequireBattleInfo, notification:GetBody(), notification:GetType())
      return
    end
    local battleInfo = notification:GetBody()
    local battleRoomInfo = {}
    battleRoomInfo.playerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
    local bestPlayerScore = -1
    for key, value in pairs(battleInfo) do
      if value.win == CareerEnumDefine.winType.draw and value.mvp then
        if bestPlayerScore < value.scores then
          battleRoomInfo.bestPlayerTeam = value.team_id
          bestPlayerScore = value.scores
        elseif value.scores == bestPlayerScore and battleRoomInfo.bestPlayerTeam and battleRoomInfo.bestPlayerTeam ~= value.team_id then
          battleRoomInfo.bestPlayerTeam = 0
        end
      end
    end
    battleRoomInfo.battlePlayersInfo = battleInfo
    GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.RequireBattleInfo, battleRoomInfo, notification:GetType())
  end
end
return OnResBattleInfoCmd
