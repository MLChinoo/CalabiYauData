local ResultBPBaseInfoMediator = class("ResultBPBaseInfoMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultBPBaseInfoMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultBPBaseInfoUpdated
  }
end
function ResultBPBaseInfoMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("ResultBPBaseInfoMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.BattleResultBPBaseInfoUpdated then
    self:UpdateView()
  end
end
function ResultBPBaseInfoMediator:OnRegister()
  LogDebug("ResultBPBaseInfoMediator", "OnRegister")
  ResultBPBaseInfoMediator.super.OnRegister(self)
  self:InitView()
  self:UpdateView()
end
function ResultBPBaseInfoMediator:OnRemove()
  LogDebug("ResultBPBaseInfoMediator", "OnRemove")
  ResultBPBaseInfoMediator.super.OnRemove(self)
end
function ResultBPBaseInfoMediator:UpdateView()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  if not battleResultProxy:IsBPBaseInfoUpdated() then
    return
  end
  if battleResultProxy.MyObTeamId then
    return
  end
  local BPDataPreBattle = battleResultProxy:GetBPDataPreBattle()
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local Explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
  local AddExplore = Explore - BPDataPreBattle.explore
  LogDebug("Explore", "BPDataPreBattle.explore=%s, Explore=%s, AddExplore=%s", BPDataPreBattle.explore, Explore, AddExplore)
  self.viewComponent:Update(BPDataPreBattle.explore, AddExplore)
end
function ResultBPBaseInfoMediator:InitView()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local BPDataPreBattle = battleResultProxy:GetBPDataPreBattle()
  local AddExplore = 0
  self.viewComponent:Update(BPDataPreBattle.explore, AddExplore)
end
return ResultBPBaseInfoMediator
