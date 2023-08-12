local GuideDeathTipsMediator = class("GuideDeathTipsMediator", PureMVC.Mediator)
function GuideDeathTipsMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnViewTargetChangedEvent:Add(self.OnViewTargetChangedEvent, self)
end
function GuideDeathTipsMediator:OnRemove()
  if self.AutoCloseTask then
    self.AutoCloseTask:EndTask()
    self.AutoCloseTask = nil
  end
  if self.CloseAnimTask then
    self.CloseAnimTask:EndTask()
    self.CloseAnimTask = nil
  end
end
function GuideDeathTipsMediator:OnViewComponentPagePreOpen(luaOpenData, nativeOpenData)
  self:OnInitPage(luaOpenData)
end
function GuideDeathTipsMediator:OnInitPage(InData)
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  if viewComponent.TextBlock_DeathInfo then
    viewComponent.TextBlock_DeathInfo:SetText(InData.DeathInfo)
  end
  if viewComponent.TextBlock_Tips then
    viewComponent.TextBlock_Tips:SetText(InData.Tips)
  end
  if viewComponent.Anim_Show and viewComponent.Anim_Show:GetEndTime() > 0.0 then
    viewComponent:PlayAnimation(viewComponent.Anim_Show, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
  if TimerMgr then
    local autoCloseCountDown = viewComponent.AutoCloseDelay or 3.0
    self.AutoCloseTask = TimerMgr:AddTimeTask(autoCloseCountDown, 0.0, 0, function()
      self:OnAutoClose()
    end)
  end
end
function GuideDeathTipsMediator:OnAutoClose()
  self.AutoCloseTask = nil
  local viewComponent = self.viewComponent
  if TimerMgr and viewComponent and viewComponent.Anim_Close and viewComponent.Anim_Close:GetEndTime() > 0.0 then
    viewComponent:PlayAnimation(viewComponent.Anim_Close, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    self.CloseAnimTask = TimerMgr:AddTimeTask(viewComponent.Anim_Close:GetEndTime(), 0.0, 0, function()
      self:SureClose()
    end)
    return
  end
  self:SureClose()
end
function GuideDeathTipsMediator:SureClose()
  self.CloseAnimTask = nil
  local world = LuaGetWorld()
  if ViewMgr and world then
    ViewMgr:ClosePage(world, UIPageNameDefine.GuideDeathTipsPage)
  end
end
function GuideDeathTipsMediator:OnViewTargetChangedEvent(InViewTarget)
  local bPawnControlled = InViewTarget and InViewTarget.IsPawnControlled and InViewTarget:IsPawnControlled() or false
  if not bPawnControlled or not self.AutoCloseTask then
    return
  end
  self.AutoCloseTask:EndTask()
  self.AutoCloseTask = nil
  self:OnAutoClose()
end
return GuideDeathTipsMediator
