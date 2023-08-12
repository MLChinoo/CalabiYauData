local ResultAccountMediator = class("ResultAccountMediator", PureMVC.Mediator)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultAccountMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattleResult.BattleResultReviceData,
    NotificationDefines.LevelUpGrade.LevelUpPageClose
  }
end
function ResultAccountMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  LogDebug("ResultAccountMediator", "HandleNotification name=%s", name)
  if name == NotificationDefines.BattleResult.BattleResultReviceData then
    self:UpdateView()
  elseif name == NotificationDefines.LevelUpGrade.LevelUpPageClose then
    self.viewComponent:OnLevelUpPageClose()
  end
end
function ResultAccountMediator:OnRegister()
  LogDebug("ResultAccountMediator", "OnRegister")
  ResultAccountMediator.super.OnRegister(self)
  self:UpdateView()
end
function ResultAccountMediator:UpdateView()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local SettleBattleGameData = battleResultProxy:GetSettleBattleGameData()
  if not SettleBattleGameData then
    return
  end
  if battleResultProxy.MyObTeamId then
    return
  end
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local ResultAccountData = {}
  ResultAccountData.PreLevelData = {}
  ResultAccountData.PreLevelData.Level = battleResultProxy:GetAccountDataPreBattle().PreLevel
  ResultAccountData.PreLevelData.Exp = battleResultProxy:GetAccountDataPreBattle().PreExp
  ResultAccountData.PreLevelData.UpExp = battleResultProxy:GetAccountDataPreBattle().PreUpExp
  ResultAccountData.PreLevelData.ExpTotal = battleResultProxy:GetAccountDataPreBattle().PreExpTotal
  ResultAccountData.AddExp = SettleBattleGameData.gain_exp
  ResultAccountData.gain_ideal = SettleBattleGameData.gain_ideal
  ResultAccountData.NewLevelData = {}
  ResultAccountData.NewLevelData.ExpTotal = ResultAccountData.PreLevelData.ExpTotal + ResultAccountData.AddExp
  ResultAccountData.NewLevelData.Level = playerAttrProxy:GetLevelByTotleExp(ResultAccountData.NewLevelData.ExpTotal)
  ResultAccountData.NewLevelData.Exp = ResultAccountData.NewLevelData.ExpTotal - playerAttrProxy:GetLevelTotalExperience(ResultAccountData.NewLevelData.Level - 1)
  ResultAccountData.NewLevelData.UpExp = playerAttrProxy:GetLevelUpExperience(ResultAccountData.NewLevelData.Level)
  ResultAccountData.CurLevelData = table.clone(ResultAccountData.PreLevelData)
  for Lv = ResultAccountData.PreLevelData.Level, ResultAccountData.NewLevelData.Level - 1 do
    local NextPlayerLevelRow = playerAttrProxy:GetPlayerLevelTableRow(Lv + 1)
    if NextPlayerLevelRow and NextPlayerLevelRow.Prize:Get(1) then
      local ItemId = NextPlayerLevelRow.Prize:Get(1).ItemId
      local ItemAmount = NextPlayerLevelRow.Prize:Get(1).ItemAmount
      local item = {}
      item.itemId = ItemId
      item.itemCnt = ItemAmount
      battleResultProxy:AddAccountAndRoleRewardItem(item)
    end
  end
  LogDebug("ResultAccountData", TableToString(ResultAccountData))
  self.viewComponent:Update(ResultAccountData)
end
function ResultAccountMediator:OnRemove()
  LogDebug("ResultAccountMediator", "OnRemove")
  ResultAccountMediator.super.OnRemove(self)
end
return ResultAccountMediator
