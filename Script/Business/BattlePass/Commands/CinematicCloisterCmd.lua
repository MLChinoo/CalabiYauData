local CinematicCloisterCmd = class("CinematicCloisterCmd", PureMVC.Command)
function CinematicCloisterCmd:Execute(notification)
  local type = notification:GetType()
  local body = notification:GetBody()
  local world = LuaGetWorld()
  if type == NotificationDefines.BattlePass.CinematicCloistertype.CinematicCloisterPlay then
    if world then
      local GlobalStateMachine = UE4.UPMGlobalStateMachine.Get(world)
      if GlobalStateMachine then
        GlobalStateMachine:TransferGlobalScenarioState()
      end
      UE4.UCySequenceManager.Get(world):PlaySequence(body.sequenceId, UE4.ESequencePlayType.CinematicCloister)
    end
  elseif type == NotificationDefines.BattlePass.CinematicCloistertype.ReturnCinematicCloister and world then
    local gameInstance = UE4.UGameplayStatics.GetGameInstance(world)
    if gameInstance then
      gameInstance:GotoLobbyScene()
    end
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, {
      pageType = UE4.EPMFunctionTypes.BattlePass,
      secondIndex = 4
    })
  end
end
return CinematicCloisterCmd
