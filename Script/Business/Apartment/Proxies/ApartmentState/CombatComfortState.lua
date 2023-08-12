local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
local CombatComfortState = class("CombatComfortState", BaseState)
local ApartmentStateMachineConfigProxy
function CombatComfortState:Start()
  self.super.Start(self)
  self:PlayStateSeqence()
  RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.CombatComfortCond)
end
function CombatComfortState:Stop()
  self.super.Stop(self)
end
function CombatComfortState:Tick(time)
  self.super:Tick(time)
end
function CombatComfortState:OnSequenceStop(sequenceId, reasonType)
  if 1 == reasonType and self.currentPlayingSequenceID == sequenceId then
    self:JudgeCond()
  end
end
function CombatComfortState:PlayStateSeqence()
  LogDebug("CombatComfortState:PlayStateSeqence", "PlayStateSeqence")
  local data = self:GetCurrStateSequenceConfig()
  if data then
    local bHigh = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy):IsHighLevel()
    local battleResultMap = bHigh and data.HighLevelBattleResultMap or data.BattleResultMap
    if battleResultMap then
      local combatResult = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy):GetCombatComfortCondResult()
      local sequenceConfig = battleResultMap:Find(combatResult)
      if sequenceConfig and sequenceConfig.SequenceArray and sequenceConfig.SequenceArray:Length() > 0 then
        local sequenceID = sequenceConfig.SequenceArray:Get(1)
        self:PlaySequence(sequenceID)
      end
    end
  end
end
return CombatComfortState
