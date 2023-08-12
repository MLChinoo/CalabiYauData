local MichellePlaytimeRulesPage = class("MichellePlaytimeRulesPage", PureMVC.ViewComponentPage)
function MichellePlaytimeRulesPage:ListNeededMediators()
  return {}
end
function MichellePlaytimeRulesPage:Construct()
  MichellePlaytimeRulesPage.super.Construct(self)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryRewardRulesPage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, 0)
  self.opentime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
end
function MichellePlaytimeRulesPage:Destruct()
  MichellePlaytimeRulesPage.super.Destruct(self)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local timeStr = MichellePlaytimeProxy:GetRemainingTimeStrFromTimeStamp(UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() - self.opentime)
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryRewardRulesPage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, timeStr)
end
function MichellePlaytimeRulesPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function MichellePlaytimeRulesPage:LuaHandleKeyEvent(key, inputEvent)
  return self.HotKeyButton_ClosePage:MonitorKeyDown(key, inputEvent)
end
return MichellePlaytimeRulesPage
