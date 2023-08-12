local KaMailDetailPanel = class("KaMailDetailPanel", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
local Platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
function KaMailDetailPanel:Update(DetailData)
  if nil == DetailData then
    return nil
  end
  self:SetVisibility(SelfHitTestInvisible)
  self.MailIds = {
    DetailData.MailId
  }
  self.MailId = DetailData.MailId
  local TitleTextStyle = platform == GlobalEnumDefine.EPlatformType.Mobile and ConfigMgr:GetRichTextStyle("MailTitleMobile") or ConfigMgr:GetRichTextStyle("MailTitle")
  local ContentTextStyle = platform == GlobalEnumDefine.EPlatformType.Mobile and ConfigMgr:GetRichTextStyle("MailTextMobile") or ConfigMgr:GetRichTextStyle("MailText")
  self.Title:SetDefaultTextStyle(TitleTextStyle)
  self.Title:SetText(DetailData.Title)
  self.Content:SetDefaultTextStyle(ContentTextStyle)
  self.Content:SetText(DetailData.Content)
  self.ButtonSwitcher:SetActiveWidgetIndex(0)
  self.AttachList:ClearListItems()
  if DetailData.AttachList then
    self.AttachCanvas:SetVisibility(Visible)
    for index, value in pairs(DetailData.AttachList or {}) do
      local obj = ObjectUtil:CreateLuaUObject(self)
      obj.data = value
      self.IsAttached = value.IsAttached
      self.AttachList:AddItem(obj)
    end
  else
    self.AttachCanvas:SetVisibility(Collapsed)
    self.ButtonSwitcher:SetActiveWidgetIndex(1)
  end
  Valid = self.IsAttached and self.ButtonSwitcher:SetActiveWidgetIndex(1)
  local FailureTime = 2592000 + DetailData.SendTime - os.time()
  local ValidityTime = FunctionUtil:FormatTime(FailureTime)
  local SendMailTimeText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "LuaSendMailTime")
  local TimeText = FailureTime <= 0 and SendMailTimeText or ValidityTime.PMGameUtil_Format_DaysHours
  self.Time:SetText(TimeText)
  local DateTime = os.date("*t", DetailData.SendTime)
  local SendTime = DateTime.year .. "/" .. DateTime.month .. "/" .. DateTime.day
  self.SendTime:SetText(SendTime)
end
function KaMailDetailPanel:RefreshSelf()
  if self.MailId then
    GameFacade:SendNotification(NotificationDefines.UpdateMailDetail, self.MailId)
  end
end
function KaMailDetailPanel:Construct()
  KaMailDetailPanel.super.Construct(self)
  self:SetVisibility(Collapsed)
  self:BindEvent()
end
function KaMailDetailPanel:Destruct()
  self:RemoveEvent()
  KaMailDetailPanel.super.Destruct(self)
end
function KaMailDetailPanel:BindEvent()
  Valid = self.Button_Attach and self.Button_Attach.OnClicked:Add(self, self.OnClickGetAttach)
  Valid = self.Button_Delete and self.Button_Delete.OnClicked:Add(self, self.OnClickDelete)
end
function KaMailDetailPanel:RemoveEvent()
  Valid = self.Button_Attach and self.Button_Attach.OnClicked:Remove(self, self.OnClickGetAttach)
  Valid = self.Button_Delete and self.Button_Delete.OnClicked:Remove(self, self.OnClickDelete)
end
function KaMailDetailPanel:OnClickGetAttach()
  if self.IsAttached then
    return
  end
  GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqTakeAttachMail(self.MailIds, true)
end
function KaMailDetailPanel:OnClickDelete()
  local pageData = {
    contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "Text_DeleteSingleMail"),
    confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "ButtonText_Confirm"),
    returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "ButtonText_Return"),
    source = self,
    cb = self.ConfirmDelete
  }
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function KaMailDetailPanel:ConfirmDelete(bIsConfirm)
  Valid = bIsConfirm and GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqDeleteMail(self.MailIds)
  Valid = bIsConfirm and GameFacade:SendNotification(NotificationDefines.DeleteCurMail)
end
return KaMailDetailPanel
