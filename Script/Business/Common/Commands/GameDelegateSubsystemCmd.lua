local GameDelegateSubsystemCmd = class("GameDelegateSubsystemCmd", PureMVC.Command)
local NotificationDefines = NotificationDefines
function GameDelegateSubsystemCmd:Execute(notification)
  if not GameFacade then
    return
  end
  local notificationType = notification:GetType()
  if NotificationDefines.GameDelegateSubsystemCmdType.Begin == notificationType then
    GameFacade:SetupGame()
  elseif NotificationDefines.GameDelegateSubsystemCmdType.End == notificationType then
    GameFacade:UninstallGame()
  end
end
return GameDelegateSubsystemCmd
