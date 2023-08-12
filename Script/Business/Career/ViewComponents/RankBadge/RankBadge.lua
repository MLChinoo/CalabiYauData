local RankBadge = class("RankBadge", PureMVC.ViewComponentPanel)
function RankBadge:ListNeededMediators()
  return {}
end
function RankBadge:InitRankBadge(starId)
  self.stars = starId
  local starShow, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(starId)
  self:BadgeDownDisappear()
  if 0 == divisionCfg.Gradation then
    return
  end
  if divisionCfg and self.WidgetSwitcher_Division and self.LvSwicthArray then
    self.WidgetSwitcher_Division:SetActiveWidgetIndex(divisionCfg.Gradation - 1)
    local lvSwitch = self.LvSwicthArray:Get(divisionCfg.Gradation)
    if divisionCfg.Level > 0 and lvSwitch then
      lvSwitch:SetActiveWidgetIndex(divisionCfg.Level - 1)
    end
    if self.BadgeLightArray then
      self:PlayAnimation(self.BadgeLightArray:Get(divisionCfg.Gradation), 0, 0)
      self.activeHoldOnPS = self.BadgeLightArray:Get(divisionCfg.Gradation)
    end
  end
  for _, value in pairs(self.starTracks) do
    value:RemoveFromParent()
  end
  self.starTracks = {}
  if starShow and divisionCfg and self.AnchorArray then
    self.anchor = self.AnchorArray:Get(divisionCfg.Gradation)
    if divisionCfg.Gradation == self.AnchorArray:Length() and self.TextBlock_StarNum then
      self.TextBlock_StarNum:SetText(starShow)
      return
    end
    if 0 == starShow then
      self:HideStarTrack(self.anchor, true)
      return
    end
    self:HideStarTrack(self.anchor, false)
    if self.badgeStarClass then
      for index = 1, starShow do
        local starIns = UE4.UWidgetBlueprintLibrary.Create(self, self.badgeStarClass)
        if starIns then
          local slot = self.anchor:AddChild(starIns)
          slot:SetSize(UE4.FVector2D(0, 0))
          local slotAnchor = UE4.FAnchors()
          slotAnchor.Minimum.X = 0.5
          slotAnchor.Minimum.Y = 0.5
          slotAnchor.Maximum.X = 0.5
          slotAnchor.Maximum.Y = 0.5
          slot:SetAnchors(slotAnchor)
          starIns:SetRenderTransformAngle(self.TrackAngleArr:Get(divisionCfg.Gradation) or 0)
          starIns:SetStarLevel(divisionCfg.Gradation)
          starIns.changeZOrder:Add(self.ChangeTrackZOrder, self)
          table.insert(self.starTracks, starIns)
        end
      end
    end
  end
end
function RankBadge:Construct()
  RankBadge.super.Construct(self)
  self.starTracks = {}
  if self.RankBadgeStarPanel then
    self.badgeStarClass = ObjectUtil:LoadClass(self.RankBadgeStarPanel)
    if self.badgeStarClass == nil then
      LogError("RankBadge", "Load RankBadgeStarPanel failed!")
    end
  end
end
function RankBadge:ChangeTrackZOrder(target, isFront)
  local slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(target)
  if slot then
    slot:SetZOrder(isFront and 10 or 0)
  end
end
function RankBadge:HideStarTrack(anchor, shouldHide)
  if anchor then
    local trackBack = anchor:GetChildAt(0)
    if trackBack then
      trackBack:SetVisibility(shouldHide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    local trackFront = anchor:GetChildAt(4)
    if trackFront then
      trackFront:SetVisibility(shouldHide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function RankBadge:StartRotate()
  local trackNum = table.count(self.starTracks)
  for key, value in pairs(self.starTracks) do
    value:PlayAnimBasedOnIndex(key, trackNum)
  end
end
function RankBadge:ShowRankDivision(starId)
  if self.stars == starId then
    return
  end
  self:InitRankBadge(starId)
  self:StartRotate()
end
function RankBadge:AddStar(oldStar, newStar)
  if self.stars == newStar or oldStar < 0 or newStar < 0 then
    return
  end
  local _, oldDivisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(oldStar)
  local newStarShow, newDivisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(newStar)
  if oldDivisionCfg.Gradation ~= newDivisionCfg.Gradation then
    self:ShowRankDivision(oldStar)
    self:PlayWidgetAnimationWithCallBack("BadgeUpgrade_Disappear", {
      self,
      function()
        self.starTracks = {}
        self:ShowRankDivision(newStar)
        self:PlayAnimation(self.BadgeUpgrade_Appear, 0, 1)
      end
    })
  elseif oldDivisionCfg.Id ~= newDivisionCfg.Id then
    self:InitRankBadge(oldStar)
    for _, value in pairs(self.starTracks) do
      value:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.stars = newStar
    local lvEffectWidget = self.anchor:GetChildAt(3)
    lvEffectWidget.OnLvChanged:Clear()
    lvEffectWidget.OnLvChanged:Add(self, self.RankLevelUp)
    lvEffectWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    lvEffectWidget:PlayAnimation(lvEffectWidget.LvUpgrade)
  else
    if newDivisionCfg.Gradation == self.AnchorArray:Length() then
      self:InitRankBadge(oldStar)
      self.stars = newStar
      local lvEffectWidget = self.anchor:GetChildAt(3)
      lvEffectWidget.OnLvChanged:Clear()
      lvEffectWidget.OnLvChanged:Add(self, self.RankLevelUp)
      lvEffectWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      lvEffectWidget:PlayAnimation(lvEffectWidget.LvUpgrade)
      return
    end
    self:InitRankBadge(newStar)
    if table.count(self.starTracks) == newStarShow then
      for index = 1, newStar - oldStar do
        self.starTracks[newStarShow - index + 1]:PlayStarAddAnim()
      end
    end
    self:StartRotate()
  end
end
function RankBadge:DecreaseStar(oldStar, newStar)
  if self.stars == newStar or oldStar < 0 or newStar < 0 then
    return
  end
  local starShow, oldDivisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(oldStar)
  local _, newDivisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(newStar)
  if oldDivisionCfg.Gradation ~= newDivisionCfg.Gradation then
    self:ShowRankDivision(oldStar)
    self:PlayWidgetAnimationWithCallBack("BadgeDowngrade_Disappear", {
      self,
      function()
        self.starTracks = {}
        self:ShowRankDivision(newStar)
        self:PlayAnimation(self.BadgeDowngrade_Appear)
      end
    })
  elseif oldDivisionCfg.Id ~= newDivisionCfg.Id then
    self:InitRankBadge(oldStar)
    self.stars = newStar
    local lvEffectWidget = self.anchor:GetChildAt(3)
    lvEffectWidget.OnLvChanged:Clear()
    lvEffectWidget.OnLvChanged:Add(self, self.RankLevelDown)
    lvEffectWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    lvEffectWidget:PlayAnimation(lvEffectWidget.LvDowngrade)
  else
    if newDivisionCfg.Gradation == self.AnchorArray:Length() then
      self:InitRankBadge(oldStar)
      self.stars = newStar
      local lvEffectWidget = self.anchor:GetChildAt(3)
      lvEffectWidget.OnLvChanged:Clear()
      lvEffectWidget.OnLvChanged:Add(self, self.RankLevelDown)
      lvEffectWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      lvEffectWidget:PlayAnimation(lvEffectWidget.LvDowngrade)
      return
    end
    self:InitRankBadge(oldStar)
    self:StartRotate()
    self.stars = newStar
    self.starTracks[starShow].onStarDisappearAnimFinished:Add(self.DecreaseTrack, self)
    self.starTracks[starShow]:PlayStarDecreaseAnim()
  end
end
function RankBadge:DecreaseTrack(trackIndex)
  self.starTracks[trackIndex]:RemoveFromParent()
  table.remove(self.starTracks, trackIndex)
  local trackNum = table.count(self.starTracks)
  if trackNum <= 0 then
    self:HideStarTrack(self.anchor, true)
  elseif trackNum > 1 then
    for index = 1, trackNum do
      self.starTracks[index]:UpdatePosition(trackNum)
    end
  end
end
function RankBadge:RankLevelUp()
  self.starTracks = {}
  self:InitRankBadge(self.stars)
  local starShow, _ = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(self.stars)
  if table.count(self.starTracks) == starShow then
    for _, value in pairs(self.starTracks) do
      value:PlayStarAddAnim()
    end
  end
  self:StartRotate()
end
function RankBadge:RankLevelDown()
  self.starTracks = {}
  self:InitRankBadge(self.stars)
  self:StartRotate()
end
function RankBadge:BadgeDownDisappear()
  if self.activeHoldOnPS then
    self:StopAnimation(self.activeHoldOnPS)
    self.activeHoldOnPS = nil
  end
end
return RankBadge
