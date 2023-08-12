local SpaceTimePyramid = class("SpaceTimePyramid", PureMVC.ViewComponentPanel)
local PyramidStage = {
  First = 2,
  Second = 4,
  Third = 6,
  Fourth = 7
}
function SpaceTimePyramid:Construct()
  SpaceTimePyramid.super.Construct(self)
end
function SpaceTimePyramid:PlayPyramidAnimation(inDay)
  self:InitAnimatino()
  if inDay <= PyramidStage.First then
    self:PlayAnimation(self.Anim_01, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid01 then
      self.PS_Pyramid01:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid01:SetReactivate(true)
    end
  elseif inDay <= PyramidStage.Second then
    self:PlayAnimation(self.Anim_02, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid02 then
      self.PS_Pyramid02:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid02:SetReactivate(true)
    end
  elseif inDay <= PyramidStage.Third then
    self:PlayAnimation(self.Anim_03, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid03 then
      self.PS_Pyramid03:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid03:SetReactivate(true)
    end
  elseif inDay <= PyramidStage.Fourth then
    self:PlayAnimation(self.Anim_04, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid04 then
      self.PS_Pyramid04:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid04:SetReactivate(true)
    end
    if self.PS_BlackHole then
      self.PS_BlackHole:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_BlackHole:SetReactivate(true)
    end
  end
end
function SpaceTimePyramid:InitAnimatino()
  self:StopAllAnimations()
  if self.PS_BlackHole then
    self.PS_BlackHole:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PS_Pyramid01 then
    self.PS_Pyramid01:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PS_Pyramid02 then
    self.PS_Pyramid02:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PS_Pyramid03 then
    self.PS_Pyramid03:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PS_Pyramid04 then
    self.PS_Pyramid04:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return SpaceTimePyramid
