local GuideMediaGuideMediator = class("GuideMediaGuideMediator", PureMVC.Mediator)
function GuideMediaGuideMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnClickCloseEvent:Add(self.OnClickClose, self)
  viewComponent.OnDestructEvent:Add(self.OnDestruct, self)
end
function GuideMediaGuideMediator:OnRemove()
  if self.autoCloseTask then
    self.autoCloseTask:EndTask()
    self.autoCloseTask = nil
  end
  if self.closeAnimTask then
    self.closeAnimTask:EndTask()
    self.closeAnimTask = nil
  end
end
function GuideMediaGuideMediator:OnViewComponentPagePreOpen(luaOpenData, nativeOpenData)
  self:OnInitPage(luaOpenData)
end
function GuideMediaGuideMediator:OnInitPage(InData)
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  if viewComponent.MediaPlay and viewComponent.MediaPlayList and InData.Media then
    viewComponent.MediaPlayList:RemoveAt(0)
    viewComponent.MediaPlayList:Add(InData.Media)
    viewComponent.MediaPlay:SetLooping(true)
    viewComponent.MediaPlay:OpenPlaylist(viewComponent.MediaPlayList)
  end
  if viewComponent.TextBlock_Title then
    viewComponent.TextBlock_Title:SetText(InData.Title)
  end
  if viewComponent.RichTextBlock_Content then
    viewComponent.RichTextBlock_Content:SetText(InData.ContentText)
  end
  if viewComponent.Button_Sure and viewComponent.TextBlock_Key then
    viewComponent.TextBlock_Key:SetText(viewComponent.Button_Sure:GetMonitorKeyName())
  end
  if viewComponent.Anim_Show and viewComponent.Anim_Show:GetEndTime() > 0.0 then
    viewComponent:PlayAnimation(viewComponent.Anim_Show, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  end
  if TimerMgr then
    self.autoCloseCountDown = viewComponent.AutoCloseDelay or 30
    if self.autoCloseCountDown > 0 then
      self.autoCloseTask = TimerMgr:AddTimeTask(0, 1.0, self.autoCloseCountDown, function()
        self:OnUpdateCountDown()
      end)
    end
  end
end
function GuideMediaGuideMediator:OnClickClose()
  if self.autoCloseTask then
    self.autoCloseTask:EndTask()
    self.autoCloseTask = nil
  end
  local viewComponent = self.viewComponent
  if TimerMgr and viewComponent and viewComponent.Anim_Close and viewComponent.Anim_Close:GetEndTime() > 0.0 then
    viewComponent:PlayAnimation(viewComponent.Anim_Close, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
    self.closeAnimTask = TimerMgr:AddTimeTask(viewComponent.Anim_Close:GetEndTime(), 0.0, 0, function()
      self:SureClose()
    end)
    return
  end
  self:SureClose()
end
function GuideMediaGuideMediator:SureClose()
  self.closeAnimTask = nil
  local world = LuaGetWorld()
  if ViewMgr and world then
    ViewMgr:ClosePage(world, UIPageNameDefine.GuideMediaGuidePage)
  end
end
function GuideMediaGuideMediator:OnDestruct()
  local viewComponent = self.viewComponent
  if viewComponent and viewComponent:IsValid() and viewComponent.MediaPlay then
    viewComponent.MediaPlay:Close()
  end
end
function GuideMediaGuideMediator:OnUpdateCountDown()
  local viewComponent = self.viewComponent
  if not viewComponent:IsValid() then
    if self.autoCloseTask then
      self.autoCloseTask:EndTask()
      self.autoCloseTask = nil
    end
    return
  end
  self.autoCloseCountDown = self.autoCloseCountDown - 1
  if self.autoCloseCountDown < 0 then
    self.autoCloseCountDown = 0
  end
  if viewComponent.TextBlock_CountDown then
    viewComponent.TextBlock_CountDown:SetText(self.autoCloseCountDown)
  end
  if self.autoCloseCountDown <= 0 then
    self:OnClickClose()
  end
end
return GuideMediaGuideMediator
