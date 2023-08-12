local BattleResultEventProxy = class("BattleResultEventProxy", PureMVC.Proxy)
LogDebug("BattleResult", "Required self")
function BattleResultEventProxy:OnBattleEnd()
  LogDebug("BattleResult", "Receive end")
end
function BattleResultEventProxy.SetUpDelegates()
  local global_delegate_manager = GetGlobalDelegateManager()
  LogDebug("global delegate", tostring(global_delegate_manager))
  return {
    {
      global_delegate_manager.OnReceiveDSGameEndNty,
      "OnBattleEnd",
      true
    }
  }
end
function BattleResultEventProxy:OnDirectAdd()
  LogDebug("BattleResult", "OnDirectAdd")
end
return BattleResultEventProxy
