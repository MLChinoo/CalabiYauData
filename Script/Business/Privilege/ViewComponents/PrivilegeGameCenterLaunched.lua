local PrivilegeGameCenterLaunched = class("PrivilegeGameCenterLaunched", PureMVC.ViewComponentPanel)
function PrivilegeGameCenterLaunched:Construct()
  self.super.Construct(self)
  self.TodayLaunched = false
  self.LoginDC = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  self.LoginType = UE4.ELoginType.ELT_None
  if self.LoginDC then
    self.LoginType = self.LoginDC:GetLoginType()
  end
  if self.LoginType == UE4.ELoginType.ELT_QQ then
    self.LaunchStateDelegateHandler = DelegateMgr:AddDelegate(self.LoginDC.QQGameCenterLaunchedDelegate, self, PrivilegeGameCenterLaunched.LaunchedStateChanged)
    self.ImageBgUnactive.OnMouseButtonDownEvent:Bind(self, self.EnterQQPrivilegeCenter)
    self.ImageBgActive.OnMouseButtonDownEvent:Bind(self, self.EnterQQPrivilegeCenter)
  end
end
function PrivilegeGameCenterLaunched:Destruct()
  self.super.Destruct(self)
  if self.LoginType == UE4.ELoginType.ELT_QQ and self.LaunchStateDelegateHandler then
    DelegateMgr:RemoveDelegate(self.LoginDC.QQGameCenterLaunchedDelegate, self.LaunchStateDelegateHandler)
    self.LaunchStateDelegateHandler = nil
  end
end
function PrivilegeGameCenterLaunched:CheckIsLaunchedFromQQGCToday(lastLaunchedTime)
  self.TodayLaunched = false
  if lastLaunchedTime and lastLaunchedTime > 0 then
    local curDate = os.date("*t")
    local lastDate = os.date("*t", lastLaunchedTime)
    if curDate.year == lastDate.year and curDate.month == lastDate.month and curDate.day == lastDate.day then
      self.TodayLaunched = true
    end
  end
end
function PrivilegeGameCenterLaunched:UpdateDisplay(privilegeInfo, ruleType)
  if not privilegeInfo then
    return
  end
  if self.LoginType ~= UE4.ELoginType.ELT_QQ then
    return
  end
  self:CheckIsLaunchedFromQQGCToday(privilegeInfo.lastQQLoginTime)
  if self.TodayLaunched then
    self:LaunchedStateChanged(self.TodayLaunched)
  end
  local visibleRule = ruleType or 1
  if 1 == visibleRule then
    self.CanvasLaunched:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif 2 == visibleRule and self.TodayLaunched then
    self.CanvasLaunched:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function PrivilegeGameCenterLaunched:LaunchedStateChanged(newState)
  local idx = newState and 1 or 0
  self.SwitcherState:SetActiveWidgetIndex(idx)
end
function PrivilegeGameCenterLaunched:EnterQQPrivilegeCenter()
  local GCloudSdkSubSystem = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  if GCloudSdkSubSystem then
    GCloudSdkSubSystem:OpenWebView(self.QQGameCenterUrl, 2, 1)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return PrivilegeGameCenterLaunched
