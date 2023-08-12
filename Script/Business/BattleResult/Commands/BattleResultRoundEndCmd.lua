local BattleResultRoundEndCmd = class("BattleResultRoundEndCmd", PureMVC.Command)
function BattleResultRoundEndCmd:Execute(notification)
  LogDebug("BattleResultRoundEndCmd", "Execute ")
  if notification:GetName() == NotificationDefines.BattleResult.BattleResultRoundEnd then
  end
end
return BattleResultRoundEndCmd
