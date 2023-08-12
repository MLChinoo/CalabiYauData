local ResultAchvPanel_PC = class("ResultAchvPanel_PC", PureMVC.ViewComponentPanel)
function ResultAchvPanel_PC:Construct()
  self:PlayAnimation()
end
function ResultAchvPanel_PC:Destruct()
  if self.AnimationTimer then
    self.AnimationTimer:EndTask()
    self.AnimationTimer = nil
  end
end
function ResultAchvPanel_PC:PlayAnimation()
  self.ListView_Achv:ClearChildren()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  if battleResultProxy.MyObTeamId then
    return
  end
  local MyPlayerInfo = battleResultProxy:GetMyPlayerInfo()
  self.CanvasPanel_Achv:SetVisibility(table.count(MyPlayerInfo.achievement_ids) > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.idx = 1
  if table.count(MyPlayerInfo.achievement_ids) > 0 then
    if self.AnimationTimer then
      self.AnimationTimer:EndTask()
      self.AnimationTimer = nil
    end
    self.AnimationTimer = TimerMgr:AddTimeTask(0, 0.5, table.count(MyPlayerInfo.achievement_ids), function()
      self:PlayAnimationTimer()
    end)
  end
end
function ResultAchvPanel_PC:PlayAnimationTimer()
  local battleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not battleResultProxy then
    return
  end
  local MyPlayerInfo = battleResultProxy:GetMyPlayerInfo()
  local AchievementDataProxy = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy)
  local AchvId = MyPlayerInfo.achievement_ids[self.idx]
  if not AchvId then
    if self.AnimationTimer then
      self.AnimationTimer:EndTask()
      self.AnimationTimer = nil
    end
    return
  end
  local cardDataProxy = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy)
  local idCardTableRow = cardDataProxy:GetCardResourceTableFromId(AchvId)
  if not idCardTableRow then
    LogError("achievement config error", "id=%s not found", AchvId)
  else
    local AchievementItemDataObject = {}
    AchievementItemDataObject.AchievementId = idCardTableRow.Id
    AchievementItemDataObject.TableRow = idCardTableRow
    AchievementItemDataObject.Icon = idCardTableRow.IconItem
    local ArchvItem = UE4.UWidgetBlueprintLibrary.Create(self, self.AchvItemClass)
    self.ListView_Achv:AddChild(ArchvItem)
    ArchvItem:OnListItemObjectSet(AchievementItemDataObject)
  end
  self.idx = self.idx + 1
end
return ResultAchvPanel_PC
