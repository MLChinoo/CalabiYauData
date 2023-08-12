local ResultBombScoreListTitle_PC = class("ResultBombScoreListTitle_PC", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultBombScoreListTitle_PC:Construct()
  ResultBombScoreListTitle_PC.super.Construct(self)
  if self.PMImg_Score then
    self.PMImg_Score.OnMouseEnterEvent:Bind(self, self.OnMouseCursorEnterScore)
    self.PMImg_Score.OnMouseLeaveEvent:Bind(self, self.OnMouseCursorLeaveScore)
  end
end
function ResultBombScoreListTitle_PC:Destruct()
  ResultBombScoreListTitle_PC.super.Destruct(self)
end
function ResultBombScoreListTitle_PC:OnMouseCursorEnterScore()
  if self.MenuAnchor_Score then
    LogDebug("ResultBombScoreListTitle_PC", "OnMouseCursorEnterScore ")
    self.MenuAnchor_Score:Open(true)
  end
end
function ResultBombScoreListTitle_PC:OnMouseCursorLeaveScore()
  if self.MenuAnchor_Score then
    LogDebug("ResultBombScoreListTitle_PC", "OnMouseCursorLeaveScore ")
    self.MenuAnchor_Score:Close()
  end
end
function ResultBombScoreListTitle_PC:SetTeam(bInIsAttack, bInIsMyTeam)
  LogDebug("ResultBombScoreListTitle_PC", "SetTeam ")
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  if SettleBattleGameData.bomb_win_turns ~= "" then
    local AttackUIIndex = bInIsAttack and 1 or 0
    self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(AttackUIIndex)
  elseif bInIsMyTeam then
    self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(1 == MyPlayerInfo.team_id and 0 or 1)
  else
    self.WidgetSwitcher_TeamBg:SetActiveWidgetIndex(1 == MyPlayerInfo.team_id and 1 or 0)
  end
  self.WidgetSwitcher_TeamName:SetActiveWidgetIndex(bInIsMyTeam and 0 or 1)
end
return ResultBombScoreListTitle_PC
