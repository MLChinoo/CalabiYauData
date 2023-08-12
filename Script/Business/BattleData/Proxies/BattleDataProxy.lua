local BattleDataProxy = class("BattleDataProxy", PureMVC.Proxy)
local GameplayActorCfg
function BattleDataProxy:OnRegister()
  BattleDataProxy.super.OnRegister(self)
  self:InitCyGameplayActorCfg()
end
function BattleDataProxy:OnRemove()
  BattleDataProxy.super.OnRemove(self)
end
function BattleDataProxy:GetCyGameplayActorCfg(Tag)
  return GameplayActorCfg[tostring(Tag)]
end
function BattleDataProxy:GetBattleReportComponent(UWidget)
  local BattleReportComponent = UE4.UPMLuaBridgeBlueprintLibrary.GetBattleReportComponent(UWidget)
  local DamageList = BattleReportComponent and BattleReportComponent:GetTakeDamageList()
  return DamageList
end
function BattleDataProxy:InitCyGameplayActorCfg()
  local arrRows = ConfigMgr:GetCyGameplayActorInfoTableRow()
  if arrRows then
    GameplayActorCfg = arrRows:ToLuaTable()
  end
end
return BattleDataProxy
