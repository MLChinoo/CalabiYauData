local PlayerManagerButton = class("PlayerManagerButton", PureMVC.ViewComponentPanel)
function PlayerManagerButton:ListNeededMediators()
  return {}
end
function PlayerManagerButton:InitializeLuaEvent()
  self.actionOnClick = LuaEvent.new(behaviorIndex)
end
function PlayerManagerButton:Construct()
  PlayerManagerButton.super.Construct(self)
  if self.Button_Execute then
    self.Button_Execute.OnClicked:Add(self, self.OnClickButton)
  end
end
function PlayerManagerButton:Destruct()
  if self.Button_Execute then
    self.Button_Execute.OnClicked:Remove(self, self.OnClickButton)
  end
  PlayerManagerButton.super.Destruct(self)
end
function PlayerManagerButton:OnClickButton()
  self.actionOnClick(self.BehaviorIndex)
end
function PlayerManagerButton:SetInviteState(bCanInvite)
  if self.Button_Execute then
    self.Button_Execute:SetIsEnabled(bCanInvite)
  end
  if self.WidgetSwitcher_TextState then
    self.WidgetSwitcher_TextState:SetActiveWidgetIndex(bCanInvite and 0 or 1)
  end
end
function PlayerManagerButton:SetJoinState(bCanJoin)
  if self.Button_Execute then
    self.Button_Execute:SetIsEnabled(bCanJoin)
  end
  if self.WidgetSwitcher_TextState then
    self.WidgetSwitcher_TextState:SetActiveWidgetIndex(bCanJoin and 0 or 2)
  end
end
return PlayerManagerButton
