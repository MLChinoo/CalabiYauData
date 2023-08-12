local ResultAccountPanel_PC = class("ResultAccountPanel_PC", PureMVC.ViewComponentPanel)
local ResultAccountMediator = require("Business/BattleResult/Mediators/ResultAccountMediator")
function ResultAccountPanel_PC:ListNeededMediators()
  return {ResultAccountMediator}
end
function ResultAccountPanel_PC:Construct()
  ResultAccountPanel_PC.super.Construct(self)
end
function ResultAccountPanel_PC:Update(AccountData)
  LogDebug("ResultAccountPanel_PC", "UpdatePanel")
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  self.AccountData = AccountData
  self.AddExp = AccountData.AddExp
  self.AddedExp = 0
  self.ProgressAniTimeTotal = self:CalculateAniTotalTime()
  LogDebug("ProgressAniTimeTotal", "%s", self.ProgressAniTimeTotal)
  self.ProgressAniTime = self.ProgressAniTimeTotal > 0 and 0 or nil
  self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(MyPlayerInfo.icon)
  if avatarIcon then
    self.Image_Head:SetBrushFromSoftTexture(avatarIcon)
  else
    LogError("ResultAccountPanel_PC", "Player icon or config error %s", MyPlayerInfo.icon)
  end
  self:UpdateLv()
  self:UpdateNextReward()
  self.TextAddExp:SetText(string.format("+%s", self.AddExp))
  self.TextAddExp_1:SetText(string.format("+%s", self.AddExp))
  self.TextIdeal:SetText(string.format("+%s", AccountData.gain_ideal))
  self:PlayAnimation(self.Anim_Exp, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  if self.HB_QQ then
    local PlayerDC = UE4.UPMPlayerDataCenter.Get(LuaGetWorld())
    local lastQQLoginTime = PlayerDC:GetLastQQLaunchTime()
    LogDebug("lastQQLoginTime", "%s", lastQQLoginTime)
    if self:CheckIsLaunchedFromQQGCToday(lastQQLoginTime) then
      self.HB_QQ:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.HB_QQ:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local CafePrivilegeProxy = GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy)
  if CafePrivilegeProxy then
    local privilegeStr = CafePrivilegeProxy:GetPrivilegeExpAddDesc()
    if string.len(privilegeStr) > 0 and self.HB_Privilege then
      self.HB_Privilege:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self.Text_Privilege then
        self.Text_Privilege:SetText(privilegeStr)
      end
    end
  end
end
local MaxProgressWidth = 420
function ResultAccountPanel_PC:UpdateLv()
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  self.TextAccountLv:SetText(self.AccountData.CurLevelData.Level)
  if self.AccountData.CurLevelData.Level >= playerAttrProxy:GetPlayerMaxLv() then
    self.TextExp:SetText("Max")
    self.ProgressExp:SetPercent(1)
    self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
    self.WidgetSwitcher_MaxLv:SetActiveWidgetIndex(1)
  else
    local percent = self.AccountData.CurLevelData.Exp / self.AccountData.CurLevelData.UpExp
    self.ProgressExp:SetPercent(percent)
    self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth * percent, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
    self.TextExp:SetText(string.format("%s/%s", math.floor(self.AccountData.CurLevelData.Exp), math.floor(self.AccountData.CurLevelData.UpExp)))
    self.WidgetSwitcher_MaxLv:SetActiveWidgetIndex(0)
  end
end
local ProgressAniTimePeriod = 1
function ResultAccountPanel_PC:CalculateAniTotalTime()
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local LeftAddExp = self.AddExp
  local Level = self.AccountData.PreLevelData.Level
  local UpExp = self.AccountData.PreLevelData.UpExp
  local UpLeftExp = self.AccountData.PreLevelData.UpExp - self.AccountData.PreLevelData.Exp
  local Percent = 0
  while LeftAddExp > 0 do
    if LeftAddExp > UpLeftExp then
      Percent = Percent + UpLeftExp / UpExp
      LeftAddExp = LeftAddExp - UpLeftExp
      Level = Level + 1
      UpLeftExp = playerAttrProxy:GetLevelUpExperience(Level)
      UpExp = UpLeftExp
    else
      Percent = Percent + LeftAddExp / UpExp
      LeftAddExp = 0
    end
  end
  Level = math.clamp(Level, 0, playerAttrProxy:GetPlayerMaxLv())
  return Percent * ProgressAniTimePeriod
end
function ResultAccountPanel_PC:Tick(MyGeometry, InDeltaTime)
  if self.ProgressAniTime and self.ProgressAniTime >= self.ProgressAniTimeTotal then
    self:StopProgressAni()
  end
  if self.ProgressAniTime and self.ProgressAniTime <= self.ProgressAniTimeTotal then
    self.ProgressAniTime = math.clamp(self.ProgressAniTime + InDeltaTime, 0, self.ProgressAniTimeTotal)
    local CurAddExp = self.AddExp * (self.ProgressAniTime / self.ProgressAniTimeTotal) - self.AddedExp
    self.AccountData.CurLevelData.Exp = self.AccountData.CurLevelData.Exp + CurAddExp
    if self.AccountData.CurLevelData.Exp >= self.AccountData.CurLevelData.UpExp then
      self.AccountData.CurLevelData.Level = self.AccountData.CurLevelData.Level + 1
      local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
      self.AccountData.CurLevelData.Level = math.clamp(self.AccountData.CurLevelData.Level, 0, playerAttrProxy:GetPlayerMaxLv())
      self.AccountData.CurLevelData.Exp = self.AccountData.CurLevelData.Exp - self.AccountData.CurLevelData.UpExp
      self.AccountData.CurLevelData.UpExp = playerAttrProxy:GetLevelUpExperience(self.AccountData.CurLevelData.Level)
      self:UpdateNextReward()
    end
    self:UpdateLv()
    self.AddedExp = self.AddedExp + CurAddExp
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.ShowTime then
      self.ShowTime = os.time()
    end
  end
end
function ResultAccountPanel_PC:OnLevelUpPageClose()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local AccountAndRoleRewards = battleResultProxy:GetAccountAndRoleRewards()
  if table.count(AccountAndRoleRewards.itemList) > 0 then
    ViewMgr:OpenPage(self, UIPageNameDefine.RewardDisplayPage, true, AccountAndRoleRewards)
  end
end
function ResultAccountPanel_PC:UpdateNextReward()
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local hasPrize = false
  local NextPlayerLevelRow = playerAttrProxy:GetPlayerLevelTableRow(self.AccountData.CurLevelData.Level + 1)
  if NextPlayerLevelRow then
    local NextRewardItem = {}
    if NextPlayerLevelRow.Prize:Num() > 0 and NextPlayerLevelRow.Prize:Get(1) then
      local ItemId = NextPlayerLevelRow.Prize:Get(1).ItemId
      local ItemAmount = NextPlayerLevelRow.Prize:Get(1).ItemAmount
      local itemCfg = itemsProxy:GetAnyItemInfoById(ItemId)
      NextRewardItem.ItemId = ItemId
      NextRewardItem.img = itemCfg.image
      NextRewardItem.num = ItemAmount
      local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
      if qualityInfo then
        NextRewardItem.qualityColor = qualityInfo.Color
      end
      self.AccountData.NextRewardItem = NextRewardItem
      self.WBP_ResultNextReward:UpdatePanel(self.AccountData.NextRewardItem)
      self.WBP_ResultNextReward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ProgressExp.Slot:SetSize(UE4.FVector2D(420, 12))
      self.HB_Name.Slot:SetSize(UE4.FVector2D(420, 12))
      MaxProgressWidth = 420
      hasPrize = true
    end
  end
  if not hasPrize then
    self.ProgressExp.Slot:SetSize(UE4.FVector2D(500, 12))
    self.HB_Name.Slot:SetSize(UE4.FVector2D(500, 12))
    self.WBP_ResultNextReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    MaxProgressWidth = 500
  end
end
function ResultAccountPanel_PC:StopProgressAni()
  self.ProgressAniTime = nil
  self.AccountData.CurLevelData = table.clone(self.AccountData.NewLevelData)
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
  if self.AccountData.NewLevelData.Level > self.AccountData.PreLevelData.Level then
    ViewMgr:OpenPage(self, UIPageNameDefine.UpgradePage, nil, self.AccountData.NewLevelData.Level)
  end
end
function ResultAccountPanel_PC:IsProgressAniPlaying()
  return self.ProgressAniTime
end
function ResultAccountPanel_PC:GetProgressAniMaxTime()
  return self.ProgressAniTimeTotal
end
function ResultAccountPanel_PC:CheckIsLaunchedFromQQGCToday(lastLaunchedTime)
  local TodayLaunched = false
  if lastLaunchedTime and lastLaunchedTime > 0 then
    local curDate = os.date("*t")
    local lastDate = os.date("*t", lastLaunchedTime)
    if curDate.year == lastDate.year and curDate.month == lastDate.month and curDate.day == lastDate.day then
      TodayLaunched = true
    end
  end
  return TodayLaunched
end
return ResultAccountPanel_PC
