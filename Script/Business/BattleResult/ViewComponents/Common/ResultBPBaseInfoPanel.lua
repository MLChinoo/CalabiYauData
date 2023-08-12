local ResultBPBaseInfoPanel = class("ResultBPBaseInfoPanel", PureMVC.ViewComponentPanel)
local ResultBPBaseInfoMediator = require("Business/BattleResult/Mediators/ResultBPBaseInfoMediator")
function ResultBPBaseInfoPanel:ListNeededMediators()
  return {ResultBPBaseInfoMediator}
end
local ProgressAniTimePeriod = 1
function ResultBPBaseInfoPanel:Update(Explore, AddExplore)
  self.PreExplore = Explore
  self.AddExplore = AddExplore
  self.NewExplore = self.PreExplore + self.AddExplore
  self.CurExplore = self.PreExplore
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local Lv = bpProxy:GetLvByExplore(self.CurExplore)
  self.Lv = Lv
  self:UpdateLv()
  self:UpdateNextReward()
  if AddExplore > 0 then
    self.TextAddExp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextAddExp_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextAddExp:SetText(string.format("+%s", AddExplore))
    self.TextAddExp_1:SetText(string.format("+%s", AddExplore))
    self:PlayAnimation(self.Anim_Exp, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  else
    self.TextAddExp:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TextAddExp_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self.ProgressAniTimeTotal = self:CalculateAniTotalTime()
  self.ProgressAniTime = self.ProgressAniTimeTotal > 0 and 0 or nil
  self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
end
local MaxProgressWidth = 420
function ResultBPBaseInfoPanel:UpdateLv()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local Lv = bpProxy:GetLvByExplore(self.CurExplore)
  local curExplore, maxExplore = bpProxy:GetExploreProgress(tonumber(self.CurExplore))
  self.Text_Lv:SetText(Lv)
  local percent = curExplore / maxExplore
  self.ProgressExp:SetPercent(percent)
  if Lv >= bpProxy:GetExploreLvMax() then
    self.TextExp:SetText("Max")
    self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
    self.WidgetSwitcher_MaxLv:SetActiveWidgetIndex(1)
  else
    self.TextExp:SetText(string.format("%s/%s", math.floor(curExplore), math.floor(maxExplore)))
    self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth * percent, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
    self.WidgetSwitcher_MaxLv:SetActiveWidgetIndex(0)
  end
end
function ResultBPBaseInfoPanel:CalculateAniTotalTime()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local OriginLv = bpProxy:GetLvByExplore(self.PreExplore)
  local OriginCurExplore, OringinMaxExplore = bpProxy:GetExploreProgress(tonumber(self.PreExplore))
  local Lv = bpProxy:GetLvByExplore(tonumber(self.NewExplore))
  local CurExplore, MaxExplore = bpProxy:GetExploreProgress(tonumber(self.NewExplore))
  local Percent = 0
  if OriginLv < Lv then
    Percent = 1 - OriginCurExplore / OringinMaxExplore
    Percent = Percent + (Lv - OriginLv - 1)
    Percent = Percent + CurExplore / MaxExplore
  else
    Percent = CurExplore / MaxExplore - OriginCurExplore / OringinMaxExplore
  end
  return Percent * ProgressAniTimePeriod
end
function ResultBPBaseInfoPanel:Tick(MyGeometry, InDeltaTime)
  if self.ProgressAniTime and self.ProgressAniTime >= self.ProgressAniTimeTotal then
    self:StopProgressAni()
  end
  if self.ProgressAniTime and self.ProgressAniTime <= self.ProgressAniTimeTotal then
    self.ProgressAniTime = math.clamp(self.ProgressAniTime + InDeltaTime, 0, self.ProgressAniTimeTotal)
    self.CurExplore = self.PreExplore + self.AddExplore * (self.ProgressAniTime / self.ProgressAniTimeTotal)
    local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    local Lv = bpProxy:GetLvByExplore(self.CurExplore)
    if Lv > self.Lv then
      self.Lv = Lv
      self:UpdateNextReward()
      self:StopAnimation(self.Animation)
      self.Text_Lv:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimation(self.Animation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
      self:K2_PostAkEvent(self.AK_Map:Find("LevelUp"), true)
    end
    self:UpdateLv()
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.ShowTime then
      self.ShowTime = os.time()
    end
  end
end
function ResultBPBaseInfoPanel:UpdateNextReward()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local Lv = bpProxy:GetLvByExplore(self.CurExplore)
  local progressPrizeCfg = bpProxy:GetPrizeCfgList()
  local BPPrizeTableRow = progressPrizeCfg[tonumber(Lv) + 1]
  if not BPPrizeTableRow then
    return
  end
  local Prize = BPPrizeTableRow.Prize2:Length() > 0 and BPPrizeTableRow.Prize2 or BPPrizeTableRow.Prize1
  if Prize:Length() > 0 then
    local itemData = {}
    local itemId = Prize:Get(1).ItemId
    local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
    itemData.ItemId = itemId
    itemData.img = itemCfg.image
    itemData.num = Prize:Get(1).ItemAmount
    local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
    if qualityInfo then
      itemData.qualityColor = qualityInfo.Color
    end
    self.itemData = itemData
    self.WBP_ResultNextReward:UpdatePanel(itemData)
    if self.HB_Name and self.ProgressExp then
      self.ProgressExp.Slot:SetSize(UE4.FVector2D(420, 12))
      self.HB_Name.Slot:SetSize(UE4.FVector2D(420, 12))
      MaxProgressWidth = 420
    end
  else
    if self.WBP_ResultNextReward then
      self.WBP_ResultNextReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.HB_Name and self.ProgressExp then
      self.ProgressExp.Slot:SetSize(UE4.FVector2D(500, 12))
      self.HB_Name.Slot:SetSize(UE4.FVector2D(500, 12))
      MaxProgressWidth = 500
    end
  end
end
function ResultBPBaseInfoPanel:StopProgressAni()
  self.ProgressAniTime = nil
  self.CurExplore = self.NewExplore
  self:UpdateLv()
  self:UpdateNextReward()
  local AniShowTime = 0.5
  if self.ShowTime and AniShowTime > self.ShowTime then
    TimerMgr:AddTimeTask(AniShowTime - self.ShowTime, 0, 1, function()
      self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
    end)
  else
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
function ResultBPBaseInfoPanel:IsProgressAniPlaying()
  return self.ProgressAniTime
end
function ResultBPBaseInfoPanel:GetProgressAniMaxTime()
  return self.ProgressAniTimeTotal
end
return ResultBPBaseInfoPanel
