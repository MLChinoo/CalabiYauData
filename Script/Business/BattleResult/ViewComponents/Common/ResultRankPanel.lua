local ResultRankPanel = class("ResultRankPanel", PureMVC.ViewComponentPanel)
local ResultRankMediator = require("Business/BattleResult/Mediators/ResultRankMediator")
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
function ResultRankPanel:ListNeededMediators()
  return {ResultRankMediator}
end
function ResultRankPanel:Construct()
  self.DivisionCnt = 5
  local basicProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if basicProxy then
    self.DivisionCnt = basicProxy:GetParameterIntValue("5910")
  end
  ResultRankPanel.super.Construct(self)
end
function ResultRankPanel:Destruct()
  ResultRankPanel.super.Destruct(self)
  if self.SubScoreAniTimer1 then
    self.SubScoreAniTimer1:EndTask()
    self.SubScoreAniTimer1 = nil
  end
  if self.SubScoreAniTimer2 then
    self.SubScoreAniTimer2:EndTask()
    self.SubScoreAniTimer2 = nil
  end
  if self.SubScoreAniTimer3 then
    self.SubScoreAniTimer3:EndTask()
    self.SubScoreAniTimer3 = nil
  end
  if self.SubScoreAniTimer4 then
    self.SubScoreAniTimer4:EndTask()
    self.SubScoreAniTimer4 = nil
  end
  if self.SubScoreAniTimer5 then
    self.SubScoreAniTimer5:EndTask()
    self.SubScoreAniTimer5 = nil
  end
end
function ResultRankPanel:Update(SettleQualifyingData)
  if not SettleQualifyingData then
    return
  end
  if SettleQualifyingData.is_grading and #SettleQualifyingData.grading_standing < self.DivisionCnt then
    if self.WS_Division then
      self.WS_Division:SetActiveWidgetIndex(1)
      if self.DivisionCompetition then
        self.DivisionCompetition:UpdateView(SettleQualifyingData.grading_standing, self.DivisionCnt)
      end
    end
    return
  end
  if SettleQualifyingData.is_grading and #SettleQualifyingData.grading_standing == self.DivisionCnt then
    ViewMgr:OpenPage(self, UIPageNameDefine.DivisionCompetitionDownPage, false, {
      SettleQualifyingData.grading_standing,
      SettleQualifyingData.stars
    })
  end
  local stars = SettleQualifyingData.stars
  local score = SettleQualifyingData.scores
  if not stars or not score then
    return
  end
  local dataProxy = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy)
  local starShow, divisionCfg = dataProxy:GetDivision(stars)
  if self.Text_RankName then
    self.Text_RankName:SetText(divisionCfg.Name)
  end
  if self.RankBadge then
    if stars > SettleQualifyingData.old_stars then
      self.RankBadge:AddStar(SettleQualifyingData.old_stars, stars)
    elseif stars < SettleQualifyingData.old_stars then
      self.RankBadge:DecreaseStar(SettleQualifyingData.old_stars, stars)
    else
      self.RankBadge:ShowRankDivision(stars)
    end
  end
  if score then
    if self.Text_Score and self.Text_SocreMax then
      self.Text_Score:SetText(score)
      self.Text_SocreMax:SetText(divisionCfg.ScoreMax)
    end
    if self.Progress_Fraction then
      self.Progress_Fraction:SetPercent(score / divisionCfg.ScoreMax)
    end
    if self.RankScoreProgress then
      self.RankScoreProgress:InitView(math.ceil(divisionCfg.ScoreMax / divisionCfg.ScoreProtect))
      self.RankScoreProgress:SetPercent(score / divisionCfg.ScoreMax)
    end
    self.ProgressAniTime = 0
    local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
    if not battleResultProxy then
      return
    end
    local RankDataPreBattle = battleResultProxy:GetRankDataPreBattle()
    self.AddScore = 0
    self.AddScore = self.AddScore + (SettleQualifyingData.mode_score or 0)
    self.AddScore = self.AddScore + (SettleQualifyingData.onhook_score or 0)
    self.AddScore = self.AddScore + (SettleQualifyingData.streak_score or 0)
    self.AddScore = self.AddScore + (SettleQualifyingData.display_score or 0)
    self.AddScore = self.AddScore + (SettleQualifyingData.power_score or 0)
    self.Text_AddScore:SetText(string.format("+%s", 0))
    local SubScoreNum = 0
    if (SettleQualifyingData.mode_score or 0) > 0 then
      SubScoreNum = SubScoreNum + 1
    end
    if (SettleQualifyingData.onhook_score or 0) > 0 then
      SubScoreNum = SubScoreNum + 1
    end
    if (SettleQualifyingData.streak_score or 0) > 0 then
      SubScoreNum = SubScoreNum + 1
    end
    if (SettleQualifyingData.display_score or 0) > 0 then
      SubScoreNum = SubScoreNum + 1
    end
    if (SettleQualifyingData.power_score or 0) > 0 then
      SubScoreNum = SubScoreNum + 1
    end
    LogDebug("SubScoreNum", "%s", SubScoreNum)
    self.Text_SubScore_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_SubScore_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_SubScore_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_SubScore_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_SubScore_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local CurSubScoreIdx = 6 - SubScoreNum
    local DelayIdx = 0
    if SettleQualifyingData.mode_score and SettleQualifyingData.mode_score > 0 then
      local TextSubScore = self["Text_SubScore_" .. CurSubScoreIdx]
      local TempCurSubScoreIdx = CurSubScoreIdx
      local TempDelayIdx = DelayIdx
      self.SubScoreAniTimer1 = TimerMgr:AddTimeTask(DelayIdx * 0.3, 1, 1, function()
        LogDebug("SubScore", "mode_score Text_SubScore_%s SubScoreAni%s DelayIdx=%s", TempCurSubScoreIdx, TempCurSubScoreIdx, TempDelayIdx)
        TextSubScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimation(self["SubScoreAni" .. TempCurSubScoreIdx], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
      end)
      CurSubScoreIdx = CurSubScoreIdx + 1
      DelayIdx = DelayIdx + 1
      local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
      if not BattleResultProxy then
        return
      end
      local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
      local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
      if SettleBattleGameData.room_mode == GlobalEnumDefine.EGameModeType.RankBomb then
        if BattleResultProxy:IsWinnerTeam(MyPlayerInfo.team_id) then
          local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScoreBombVictory")
          TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.mode_score))
        else
          local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScoreBomb")
          TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.mode_score))
        end
      elseif SettleBattleGameData.room_mode == GlobalEnumDefine.EGameModeType.RankTeam then
        if BattleResultProxy:IsWinnerTeam(MyPlayerInfo.team_id) then
          local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScoreTeamVictory")
          TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.mode_score))
        else
          local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScoreTeam")
          TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.mode_score))
        end
      end
    end
    if SettleQualifyingData.onhook_score and SettleQualifyingData.onhook_score > 0 then
      local TextSubScore = self["Text_SubScore_" .. CurSubScoreIdx]
      local TempCurSubScoreIdx = CurSubScoreIdx
      local TempDelayIdx = DelayIdx
      self.SubScoreAniTimer2 = TimerMgr:AddTimeTask(DelayIdx * 0.3, 1, 1, function()
        LogDebug("SubScore", "onhook_score Text_SubScore_%s SubScoreAni%s DelayIdx=%s", TempCurSubScoreIdx, TempCurSubScoreIdx, TempDelayIdx)
        TextSubScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimation(self["SubScoreAni" .. TempCurSubScoreIdx], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
      end)
      CurSubScoreIdx = CurSubScoreIdx + 1
      DelayIdx = DelayIdx + 1
      CurSubScoreIdx = CurSubScoreIdx + 1
      local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RanScoreNoHook")
      TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.onhook_score))
    end
    if SettleQualifyingData.streak_score and SettleQualifyingData.streak_score > 0 then
      local TextSubScore = self["Text_SubScore_" .. CurSubScoreIdx]
      local TempCurSubScoreIdx = CurSubScoreIdx
      local TempDelayIdx = DelayIdx
      self.SubScoreAniTimer3 = TimerMgr:AddTimeTask(DelayIdx * 0.3, 1, 1, function()
        LogDebug("SubScore", "streak_score Text_SubScore_%s SubScoreAni%s DelayIdx=%s", TempCurSubScoreIdx, TempCurSubScoreIdx, TempDelayIdx)
        TextSubScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimation(self["SubScoreAni" .. TempCurSubScoreIdx], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
      end)
      CurSubScoreIdx = CurSubScoreIdx + 1
      DelayIdx = DelayIdx + 1
      local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScoreWinStreak")
      TextSubScore:SetText(string.format("%s%s+%s", SettleQualifyingData.streak_win, str, SettleQualifyingData.streak_score))
    end
    if SettleQualifyingData.display_score and SettleQualifyingData.display_score > 0 then
      local TextSubScore = self["Text_SubScore_" .. CurSubScoreIdx]
      local TempCurSubScoreIdx = CurSubScoreIdx
      local TempDelayIdx = DelayIdx
      self.SubScoreAniTimer4 = TimerMgr:AddTimeTask(DelayIdx * 0.3, 1, 1, function()
        LogDebug("SubScore", "display_score Text_SubScore_%s SubScoreAni%s DelayIdx=%s", TempCurSubScoreIdx, TempCurSubScoreIdx, TempDelayIdx)
        TextSubScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimation(self["SubScoreAni" .. TempCurSubScoreIdx], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
      end)
      CurSubScoreIdx = CurSubScoreIdx + 1
      DelayIdx = DelayIdx + 1
      local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScorePerformance")
      TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.display_score))
    end
    if SettleQualifyingData.power_score and SettleQualifyingData.power_score > 0 then
      local TextSubScore = self["Text_SubScore_" .. CurSubScoreIdx]
      local TempCurSubScoreIdx = CurSubScoreIdx
      local TempDelayIdx = DelayIdx
      self.SubScoreAniTimer5 = TimerMgr:AddTimeTask(DelayIdx * 0.3, 1, 1, function()
        LogDebug("SubScore", "power_score Text_SubScore_%s SubScoreAni%s DelayIdx=%s", TempCurSubScoreIdx, TempCurSubScoreIdx, TempDelayIdx)
        TextSubScore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimation(self["SubScoreAni" .. TempCurSubScoreIdx], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
      end)
      CurSubScoreIdx = CurSubScoreIdx + 1
      DelayIdx = DelayIdx + 1
      local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "RankScoreAbility")
      TextSubScore:SetText(string.format("%s+%s", str, SettleQualifyingData.power_score))
    end
  end
end
local ProgressAniTimeTotal = 1
function ResultRankPanel:Tick(MyGeometry, InDeltaTime)
  if self.ProgressAniTime and self.ProgressAniTime <= ProgressAniTimeTotal then
    self.ProgressAniTime = math.clamp(self.ProgressAniTime + InDeltaTime, 0, ProgressAniTimeTotal)
    local Score = self.AddScore * (self.ProgressAniTime / ProgressAniTimeTotal)
    if Score < 0 then
      self.Text_AddScore:SetText(string.format("-%s", math.floor(Score)))
    else
      self.Text_AddScore:SetText(string.format("+%s", math.floor(Score)))
    end
  end
end
return ResultRankPanel
