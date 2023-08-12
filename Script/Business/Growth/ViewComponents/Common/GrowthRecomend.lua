local GrowthRecomend = class("GrowthRecomend", PureMVC.ViewComponentPanel)
function GrowthRecomend:Construct()
  GrowthRecomend.super.Construct(self)
end
function GrowthRecomend:Destruct()
  GrowthRecomend.super.Destruct(self)
  if self.PlayLoopTimer then
    self.PlayLoopTimer:EndTask()
  end
end
function GrowthRecomend:SetRecommend(Recommend)
  self.recommend:SetVisibility(Recommend and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  if self.Recommended then
    return
  end
  if Recommend then
    self:PlayAnimation(self.Anim_start, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    if self.PlayLoopTimer then
      self.PlayLoopTimer:EndTask()
      self.PlayLoopTimer = nil
    end
    self.PlayLoopTimer = TimerMgr:AddTimeTask(0.25, 0, 1, function()
      self:OnAnimStartFinish()
    end)
  end
  self.Recommended = Recommend
end
function GrowthRecomend:OnAnimStartFinish()
  self:PlayAnimation(self.Anim_loop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
end
return GrowthRecomend
