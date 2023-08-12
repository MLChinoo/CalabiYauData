local ViewSwtichAnimation = class("ViewSwtichAnimation", PureMVC.ViewComponentPanel)
function ViewSwtichAnimation:PlayOpenAnimation(openDelegate)
  if self.Open == nil then
    return
  end
  self:StopAllAnimations()
  if openDelegate then
    self:BindToAnimationFinished(self.Open, openDelegate)
    self:PlayAnimation(self.Open, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  else
    self:PlayAnimation(self.Open, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function ViewSwtichAnimation:PlayCloseAnimation(closeDelegate)
  if self.Close == nil then
    return
  end
  self:StopAllAnimations()
  if closeDelegate then
    self:BindToAnimationFinished(self.Close, closeDelegate)
    self:PlayAnimation(self.Close, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  else
    self:PlayAnimation(self.Close, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function ViewSwtichAnimation:RemoveCloseAnimationFinishedCallback()
  if self.Close then
    self:UnbindAllFromAnimationFinished(self.Close)
  end
end
function ViewSwtichAnimation:Destruct()
  if self.Close then
    self:UnbindAllFromAnimationFinished(self.Close)
  end
  if self.Open then
    self:UnbindAllFromAnimationFinished(self.Open)
  end
  ViewSwtichAnimation.super.Destruct(self)
end
return ViewSwtichAnimation
