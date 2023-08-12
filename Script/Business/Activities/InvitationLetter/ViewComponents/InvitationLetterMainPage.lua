local InvitationLetterMainPage = class("InvitationLetterMainPage", PureMVC.ViewComponentPage)
local InvitationLetterMainPageMediator = require("Business/Activities/InvitationLetter/Mediators/InvitationLetterMainPageMediator")
function InvitationLetterMainPage:ListNeededMediators()
  return {InvitationLetterMainPageMediator}
end
function InvitationLetterMainPage:Construct()
  InvitationLetterMainPage.super.Construct(self)
  local InvitationLetterProxy = GameFacade:RetrieveProxy(ProxyNames.InvitationLetterProxy)
  InvitationLetterProxy:ReqGetInvitationLetterData()
  self.Btn_OpenRulesPage.OnClicked:Add(self, self.OnClickOpenActivityRulesPage)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  local ActivityPreTable = ActivitiesProxy:GetActivityPreTable()
  local ActivityId = 10009
  if ActivityPreTable and ActivityPreTable[ActivityId] and ActivityPreTable[ActivityId].cfg then
    self:InitPageData(ActivityPreTable[ActivityId].cfg)
  end
  local eventType = InvitationLetterProxy.ActivityEventTypeEnum.EntryMainPage
  InvitationLetterProxy:SetActivityEventInfoOfTLOG(eventType)
  InvitationLetterProxy:SetRedRotNum(0)
end
function InvitationLetterMainPage:Destruct()
  InvitationLetterMainPage.super.Destruct(self)
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  self.Btn_OpenRulesPage.OnClicked:Remove(self, self.OnClickOpenActivityRulesPage)
  local InvitationLetterProxy = GameFacade:RetrieveProxy(ProxyNames.InvitationLetterProxy)
  local eventType = InvitationLetterProxy.ActivityEventTypeEnum.QuitActivity
  InvitationLetterProxy:SetActivityEventInfoOfTLOG(eventType)
end
function InvitationLetterMainPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function InvitationLetterMainPage:OnClickOpenActivityRulesPage()
  ViewMgr:OpenPage(self, UIPageNameDefine.InvitationLetterActivityRulesPage)
end
function InvitationLetterMainPage:InitPageData(pageData)
  local monthStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Month")
  local dayStr = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Day")
  local startTimeStr = "%m" .. monthStr .. "%d" .. dayStr
  startTimeStr = os.date(startTimeStr, pageData.start_time)
  local expireTimeStr = "%m" .. monthStr .. "%d" .. dayStr
  expireTimeStr = os.date(expireTimeStr, pageData.expire_time)
  local activityTimeIntervalStr = startTimeStr .. "-" .. expireTimeStr
  self.Txt_ActivityTime:SetText(activityTimeIntervalStr)
  self.Txt_ActivityDesc:SetText(pageData.simple_desc)
end
function InvitationLetterMainPage:LuaHandleKeyEvent(key, inputEvent)
  return self.HotKeyButton_ClosePage:MonitorKeyDown(key, inputEvent)
end
return InvitationLetterMainPage
