local InvitationLetterActivityRulesPage = class("InvitationLetterActivityRulesPage", PureMVC.ViewComponentPage)
function InvitationLetterActivityRulesPage:ListNeededMediators()
  return {}
end
function InvitationLetterActivityRulesPage:Construct()
  InvitationLetterActivityRulesPage.super.Construct(self)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.EntryActivityRulesPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self.Button_Return.OnClickEvent:Add(self, self.OnClickClosePage)
end
function InvitationLetterActivityRulesPage:Destruct()
  InvitationLetterActivityRulesPage.super.Destruct(self)
  self.Button_Return.OnClickEvent:Remove(self, self.OnClickClosePage)
end
function InvitationLetterActivityRulesPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function InvitationLetterActivityRulesPage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Return:MonitorKeyDown(key, inputEvent)
end
return InvitationLetterActivityRulesPage
