local PyramidPanel = class("PyramidPanel", PureMVC.ViewComponentPanel)
local PyramidStage = {
  First = 1,
  Second = 2,
  Third = 3
}
function PyramidPanel:Construct()
  PyramidPanel.super.Construct(self)
end
function PyramidPanel:PlayPyramidAnimation(Level)
  self:InitAnimatino()
  if Level <= PyramidStage.First then
    self:PlayAnimation(self.Anim_01, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid01 then
      self.PS_Pyramid01:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid01:SetReactivate(true)
    end
  elseif Level <= PyramidStage.Second then
    self:PlayAnimation(self.Anim_02, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid02 then
      self.PS_Pyramid02:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid02:SetReactivate(true)
    end
  elseif Level <= PyramidStage.Third then
    self:PlayAnimation(self.Anim_03, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.PS_Pyramid03 then
      self.PS_Pyramid03:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Pyramid03:SetReactivate(true)
    end
  end
end
function PyramidPanel:InitAnimatino()
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
return PyramidPanel
