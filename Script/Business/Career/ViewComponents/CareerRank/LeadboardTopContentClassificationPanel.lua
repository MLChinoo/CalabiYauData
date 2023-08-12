local LeadboardTopContentClassificationPanel = class("LeadboardTopContentClassificationPanel", PureMVC.ViewComponentPanel)
function LeadboardTopContentClassificationPanel:ListNeededMediators()
  return {}
end
LeadboardTopContentClassificationPanel.ClassificationStatusEnum = {Close = 0, Open = 1}
function LeadboardTopContentClassificationPanel:Construct()
  if self.Btn_ShowLocationHelpTips then
    self.Btn_ShowLocationHelpTips.OnHovered:Add(self, self.OnHoveredShowLocationHelpTips)
    self.Btn_ShowLocationHelpTips.OnUnhovered:Add(self, self.OnUnHoveredShowLocationHelpTips)
  end
end
function LeadboardTopContentClassificationPanel:Destruct()
  if self.Btn_ShowLocationHelpTips then
    self.Btn_ShowLocationHelpTips.OnHovered:Remove(self, self.OnHoveredShowLocationHelpTips)
    self.Btn_ShowLocationHelpTips.OnUnhovered:Remove(self, self.OnUnHoveredShowLocationHelpTips)
  end
end
function LeadboardTopContentClassificationPanel:UpdateContentClassification(showLeaderboardType)
  local leaderboardContentDisplayControlCfg = ConfigMgr:GetLeaderboardContentDisplayControl()
  if leaderboardContentDisplayControlCfg then
    leaderboardContentDisplayControlCfg = leaderboardContentDisplayControlCfg:ToLuaTable()
    for row, value in pairs(leaderboardContentDisplayControlCfg) do
      if value.LeaderboardType == showLeaderboardType then
        local itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.RankNumber == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_Number then
          self.Canvas_Number:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.PlayerName == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_PlayerName then
          self.Canvas_PlayerName:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.Title == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_Title then
          self.Canvas_Title:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.RankLevel == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_RankLevel then
          self.Canvas_RankLevel:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.CharacterCombatPower == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_CharacterCombatPower then
          self.Canvas_CharacterCombatPower:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.Area == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_Area then
          self.Canvas_Area:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.Wins == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_Wins then
          self.Canvas_Wins:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.CommonUsedHeros == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_CommonUsedHeros then
          self.Canvas_CommonUsedHeros:SetVisibility(itemVisibility)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.TotalKiller == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.Canvas_TotalKill then
          self.Canvas_TotalKill:SetVisibility(itemVisibility)
        end
        return
      end
    end
  end
end
function LeadboardTopContentClassificationPanel:OnHoveredShowLocationHelpTips()
  if self.CanvasPanel_AreaTip then
    self.CanvasPanel_AreaTip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LeadboardTopContentClassificationPanel:OnUnHoveredShowLocationHelpTips()
  if self.CanvasPanel_AreaTip then
    self.CanvasPanel_AreaTip:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return LeadboardTopContentClassificationPanel
