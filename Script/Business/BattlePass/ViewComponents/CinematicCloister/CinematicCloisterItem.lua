local CinematicCloisterItem = class("CinematicCloisterItem", PureMVC.ViewComponentPanel)
function CinematicCloisterItem:InitializeLuaEvent()
  CinematicCloisterItem.super.InitializeLuaEvent()
  self.OnItemSelectedEvent = LuaEvent.new()
  self.itemIndex = 0
  self.chapterId = 0
  self.isCompleted = false
  self.isSelect = false
  if self.ItemBtn then
    self.ItemBtn.OnClicked:Add(self, self.OnCloisterItemClicked)
  end
end
function CinematicCloisterItem:OnCloisterItemClicked()
  self.OnItemSelectedEvent(self.itemIndex, self.chapterId)
end
function CinematicCloisterItem:InitCinematicCloisterItemData(Index, InData)
  self.itemIndex = Index
  self.chapterId = InData.Id
  if self.SeasonText then
    local SeasonFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CinematicCloisterSeason")
    local FormatParam = {
      [0] = InData.SeasonId
    }
    self.SeasonText:SetText(ObjectUtil:GetTextFromFormat(SeasonFormatText, FormatParam))
  end
  self.isCompleted = 0
  local itemId = InData.Rewards:Get(1).ItemId
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if itemId and itemsProxy then
    local ItemName = itemsProxy:GetAnyItemName(itemId)
    if self.RewardText then
      local RewardFormatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CinematicCloisterReward")
      local FormatParam = {
        Amount = tonumber(InData.Rewards:Get(1).ItemAmount),
        RewardType = ItemName
      }
      self.RewardText:SetText(ObjectUtil:GetTextFromFormat(RewardFormatText, FormatParam))
    end
  end
  self:UpdateCompletedState(InData.IsPlayCompleted)
  if self.TitleText then
    self.TitleText:SetText(InData.ChapterTitle)
  end
  if self.SeasonBgImg then
    self:SetImageByTexture2D(self.SeasonBgImg, InData.SeasonBg)
  end
  if self.DescribeText then
    self.DescribeText:SetText(InData.Describe)
  end
  self.isSelect = false
  if self.SelectedImg then
    self.SelectedImg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CinematicCloisterItem:UpdateCompletedState(isCompleted)
  if self.isCompleted ~= isCompleted then
    self.isCompleted = isCompleted
    if isCompleted then
      if self.ReceivedRewardText then
        self.ReceivedRewardText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif self.ReceivedRewardText then
      self.ReceivedRewardText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function CinematicCloisterItem:UpdateSelectedState(isSelected)
  if self.isSelect ~= isSelected then
    self.isSelect = isSelected
    if self.isSelect then
      if self.SelectedImg then
        self.SelectedImg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif self.SelectedImg then
      self.SelectedImg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function CinematicCloisterItem:PlayFadeInAni()
  if self.ItemIn then
    self:PlayAnimation(self.ItemIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
return CinematicCloisterItem
