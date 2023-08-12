local ResultRolePanel_PC = class("ResultRolePanel_PC", PureMVC.ViewComponentPanel)
local ProgressAniTimePeriod = 1.5
local MaxProgressWidth = 420
function ResultRolePanel_PC:OnListItemObjectSet(RoleDataItemObject)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  self.RoleData = RoleDataItemObject.RoleData
  self.TextName:SetText(self.RoleData.Name)
  self.Image_Head:SetBrushFromSoftTexture(self.RoleData.IconRoleSkin)
  self:UpdateLv()
  self:UpdateNextReward()
  self.ListView_Task:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local UnLockRoles = KaPhoneProxy:GetUnLockRoles()
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local IsRoleUnLock = roleProxy:IsUnlockRole(self.RoleData.RoleId)
  local IsLoungeUnLock = RoleProxy:GetRole(self.RoleData.RoleId).Navigation >= 1
  if IsRoleUnLock and IsLoungeUnLock then
    self.WS_RoleInfo:SetActiveWidgetIndex(0)
  elseif IsRoleUnLock and not IsLoungeUnLock then
    self.WS_RoleInfo:SetActiveWidgetIndex(1)
  else
    self.WS_RoleInfo:SetActiveWidgetIndex(2)
  end
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local RoleIdSigned = kaNavigationProxy:GetCurrentRoleId()
  if self.RoleData.RoleId == RoleIdSigned then
    self.WBP_ResultNextReward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ProgressExp.Slot:SetSize(UE4.FVector2D(420, 12))
    self.HB_Name.Slot:SetSize(UE4.FVector2D(420, 12))
    MaxProgressWidth = 420
  else
    self.ProgressExp.Slot:SetSize(UE4.FVector2D(500, 12))
    self.HB_Name.Slot:SetSize(UE4.FVector2D(500, 12))
    self.WBP_ResultNextReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    MaxProgressWidth = 500
  end
  self.AddedExp = 0
  if self.RoleData.CurIntimacyData.Lv >= RoleProxy:GetRoleFavorabilityMaxLv() then
    self.AddExp = 0
    self.ProgressAniTime = nil
    self.ProgressAniTimeTotal = 0
  else
    self.AddExp = self.RoleData.IntimacyAdd
    self.ProgressAniTime = 0
    self.ProgressAniTimeTotal = self:CalculateAniTotalTime()
    LogDebug("ProgressAniTimeTotal ResultRolePanel_PC", "%s", self.ProgressAniTimeTotal)
    self.ProgressAniTime = self.ProgressAniTimeTotal > 0 and 0 or nil
  end
  self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Particle_LevelUp_Role:SetVisibility(UE4.ESlateVisibility.Hidden)
  if self.AddExp > 0 then
    self.TextExp:SetText(string.format("+%s", self.AddExp))
    self.TextExp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TextExp:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end
function ResultRolePanel_PC:CalculateAniTotalTime()
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local LeftAddExp = self.AddExp
  local Level = self.RoleData.PreIntimacyData.Lv
  local UpExp = self.RoleData.PreIntimacyData.UpIntimacy
  local UpLeftExp = self.RoleData.PreIntimacyData.UpIntimacy - self.RoleData.PreIntimacyData.Intimacy
  local Percent = 0
  while LeftAddExp > 0 do
    if LeftAddExp > UpLeftExp then
      if Level < self.RoleData.NewIntimacyData.Lv then
        Percent = Percent + UpLeftExp / UpExp
        LeftAddExp = LeftAddExp - UpLeftExp
        Level = Level + 1
        local RoleFavorabilityTableRow = RoleProxy:GetRoleFavoribility(Level)
        UpLeftExp = RoleFavorabilityTableRow.FExp
        UpExp = UpLeftExp
      else
        LeftAddExp = 0
      end
    else
      Percent = Percent + LeftAddExp / UpExp
      LeftAddExp = 0
    end
  end
  return Percent * ProgressAniTimePeriod
end
function ResultRolePanel_PC:UpdateLv()
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  if self.RoleData.CurIntimacyData.Lv >= RoleProxy:GetRoleFavorabilityMaxLv() then
    self.TextLevel:SetText("Max")
    self.ProgressExp:SetPercent(1)
    self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
    self.WidgetSwitcher_MaxLv:SetActiveWidgetIndex(1)
  else
    self.TextLevel:SetText(self.RoleData.CurIntimacyData.Lv)
    local percent = self.RoleData.CurIntimacyData.Intimacy / self.RoleData.CurIntimacyData.UpIntimacy
    self.ProgressExp:SetPercent(percent)
    self.SizeBox_ProgressAni.Slot:SetPosition(UE4.FVector2D(MaxProgressWidth * percent, self.SizeBox_ProgressAni.Slot:GetPosition().Y))
    self.WidgetSwitcher_MaxLv:SetActiveWidgetIndex(0)
  end
end
function ResultRolePanel_PC:Tick(MyGeometry, InDeltaTime)
  if self.ProgressAniTime and self.ProgressAniTime >= self.ProgressAniTimeTotal then
    self:StopSelfProgressAni()
  end
  if self.ProgressAniTime and self.ProgressAniTime <= self.ProgressAniTimeTotal then
    local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    self.ProgressAniTime = math.clamp(self.ProgressAniTime + InDeltaTime, 0, self.ProgressAniTimeTotal)
    local CurAddExp = self.AddExp * (self.ProgressAniTime / self.ProgressAniTimeTotal) - self.AddedExp
    self.RoleData.CurIntimacyData.Intimacy = self.RoleData.CurIntimacyData.Intimacy + CurAddExp
    if self.RoleData.CurIntimacyData.Intimacy >= self.RoleData.CurIntimacyData.UpIntimacy and self.RoleData.CurIntimacyData.Lv < self.RoleData.NewIntimacyData.Lv then
      self.RoleData.CurIntimacyData.Lv = self.RoleData.CurIntimacyData.Lv + 1
      self.RoleData.CurIntimacyData.Lv = math.clamp(self.RoleData.CurIntimacyData.Lv, 0, RoleProxy:GetRoleFavorabilityMaxLv())
      self.RoleData.CurIntimacyData.Intimacy = self.RoleData.CurIntimacyData.Intimacy - self.RoleData.CurIntimacyData.UpIntimacy
      local RoleFavorabilityTableRow = RoleProxy:GetRoleFavoribility(self.RoleData.CurIntimacyData.Lv)
      self.RoleData.CurIntimacyData.UpIntimacy = RoleFavorabilityTableRow.FExp
      self:UpdateNextReward()
      if self.Particle_LevelUp_Role:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
        self.Particle_LevelUp_Role:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Particle_LevelUp_Role:SetReactivate(true)
      end
    end
    self.AddedExp = self.AddedExp + CurAddExp
    self:UpdateLv()
    self.SizeBox_ProgressAni:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.ShowTime then
      self.ShowTime = os.time()
    end
  end
end
function ResultRolePanel_PC:UpdateNextReward()
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleLvRewards = RoleProxy:GetRoleFavorabilityRewardData(self.RoleData.RoleId)
  local RoleLvReward = RoleLvRewards[self.RoleData.CurIntimacyData.Lv + 1]
  if RoleLvReward then
    local NextRewardItem = {}
    local ItemId = RoleLvReward.itemId
    local ItemAmount = RoleLvReward.itemAmount
    local itemCfg = itemsProxy:GetAnyItemInfoById(ItemId)
    NextRewardItem.ItemId = ItemId
    NextRewardItem.img = itemCfg.image
    NextRewardItem.num = ItemAmount
    local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
    if qualityInfo then
      NextRewardItem.qualityColor = qualityInfo.Color
    end
    self.RoleData.NextRewardItem = NextRewardItem
    self.WBP_ResultNextReward:UpdatePanel(self.RoleData.NextRewardItem)
  else
    self.WBP_ResultNextReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ResultRolePanel_PC:StopSelfProgressAni()
  self.ProgressAniTime = nil
  self.RoleData.CurIntimacyData = table.clone(self.RoleData.NewIntimacyData)
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
function ResultRolePanel_PC:StopProgressAni()
  self:StopSelfProgressAni()
  local ChildPanelArray = self.ListView_Task:GetDisplayedEntryWidgets()
  for i = 1, ChildPanelArray:Length() do
    local ResultRoleTaskPanel_PC = ChildPanelArray:Get(i)
    if ResultRoleTaskPanel_PC:IsProgressAniPlaying() then
      ResultRoleTaskPanel_PC:StopProgressAni()
    end
  end
end
function ResultRolePanel_PC:IsProgressAniPlaying()
  local IsPlaying = self.ProgressAniTime and 0 ~= self.ProgressAniTime
  local ChildPanelArray = self.ListView_Task:GetDisplayedEntryWidgets()
  for i = 1, ChildPanelArray:Length() do
    local ResultRoleTaskPanel_PC = ChildPanelArray:Get(i)
    IsPlaying = IsPlaying or ResultRoleTaskPanel_PC:IsProgressAniPlaying()
  end
  return IsPlaying
end
function ResultRolePanel_PC:GetProgressAniMaxTime()
  local MaxTime = self.ProgressAniTimeTotal
  local ChildPanelArray = self.ListView_Task:GetDisplayedEntryWidgets()
  for i = 1, ChildPanelArray:Length() do
    local ResultRoleTaskPanel_PC = ChildPanelArray:Get(i)
    local Time = ResultRoleTaskPanel_PC:GetProgressAniMaxTime()
    if MaxTime < Time then
      MaxTime = Time
    end
  end
  return MaxTime
end
return ResultRolePanel_PC
