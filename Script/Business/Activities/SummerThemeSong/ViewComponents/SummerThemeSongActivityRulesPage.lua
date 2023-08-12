local SummerThemeSongActivityRulesPage = class("SummerThemeSongActivityRulesPage", PureMVC.ViewComponentPage)
function SummerThemeSongActivityRulesPage:ListNeededMediators()
  return {}
end
function SummerThemeSongActivityRulesPage:Construct()
  SummerThemeSongActivityRulesPage.super.Construct(self)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.EntryActivityRulesPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.bActiveClosePage = false
  self.delayActiveClosePageFunctionTime = 0.8
  self.delayActiveClosePageFunctionHandle = TimerMgr:AddTimeTask(self.delayActiveClosePageFunctionTime, 0, 1, function()
    self.bActiveClosePage = true
  end)
end
function SummerThemeSongActivityRulesPage:Destruct()
  SummerThemeSongActivityRulesPage.super.Destruct(self)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.QuitActivityRulesPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:ClearDelayActiveClosePageHandle()
end
function SummerThemeSongActivityRulesPage:OnClickClosePage()
  if self.bActiveClosePage then
    ViewMgr:ClosePage(self)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SummerThemeSongActivityRulesPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClosePage()
    return true
  end
  return false
end
function SummerThemeSongActivityRulesPage:ClearDelayActiveClosePageHandle()
  if self.delayActiveClosePageFunctionHandle then
    self.delayActiveClosePageFunctionHandle:EndTask()
    self.delayActiveClosePageFunctionHandle = nil
  end
end
return SummerThemeSongActivityRulesPage
