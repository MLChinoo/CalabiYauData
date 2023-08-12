local KaMailItem = class("KaMailItem", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaMailItem:OnListItemObjectSet(UObject)
  self.Parent = UObject.Parent
  self.UObject = UObject
  self:InitItem(UObject.data)
  UObject.Item = self
end
function KaMailItem:InitItem(Data)
  Valid = self.WidgetSwitcher_Image and self.WidgetSwitcher_Image:SetActiveWidgetIndex(0)
  local ImageMap = self.Parent:GetImageMap()
  if ImageMap[Data.MailId] then
    self.Img_Mail:SetBrush(ImageMap[Data.MailId])
  elseif Data.ImageURL then
    local DownLoadTask = UE4.UAsyncTaskDownloadImage.DownloadImage(Data.ImageURL)
    DownLoadTask.OnSuccess:Add(self, self.LoadImgSuc)
  elseif Data.ItemImg then
    Valid = self.Img_Mail and self:SetImageByTexture2D(self.Img_Mail, Data.ItemImg)
    Valid = self.WidgetSwitcher_Image and self.WidgetSwitcher_Image:SetActiveWidgetIndex(1)
  end
  Valid = self.NewMailTip and self.NewMailTip:SetVisibility(Data.IsShowTip and SelfHitTestInvisible or Collapsed)
  Valid = self.WidgetSwitcher_Text and self.WidgetSwitcher_Text:SetActiveWidgetIndex(Data.IsShowTip and 0 or 1)
  Valid = self.CanvasPanel_MailItem and self.CanvasPanel_MailItem:SetRenderOpacity(Data.IsShowTip and 1 or 0.6)
  Valid = self.ImageAttached and self.ImageAttached:SetVisibility(Data.ShowAttach and (Data.IsAttached and SelfHitTestInvisible or Collapsed) or Collapsed)
  Valid = self.ImageAttach and self.ImageAttach:SetVisibility(Data.ShowAttach and (Data.IsAttached and Collapsed or SelfHitTestInvisible) or Collapsed)
  self.MailId = Data.MailId
  local DateTime = os.date("*t", Data.SendTime)
  local SendTime = DateTime.year .. "/" .. DateTime.month .. "/" .. DateTime.day
  local FailureTime = 86400 * self.FailureTime + Data.SendTime
  local TempTime = FunctionUtil:FormatTime(FailureTime - os.time())
  if TempTime.Day < 1 then
    Valid = self.ValidityTime and self.ValidityTime:SetText(TempTime.PMGameUtil_Format_Hours)
  else
    Valid = self.ValidityTime and self.ValidityTime:SetText(TempTime.PMGameUtil_Format_Days)
  end
  self.Time:SetText(SendTime)
  local ContentLength = FunctionUtil:getByteCount(Data.MainTitle)
  ContentLength = ContentLength > self.TextLength and self.TextLength or ContentLength
  local ContentText = FunctionUtil:getSubStringByCount(Data.MainTitle, 1, ContentLength)
  self.MainTitle:SetText(ContentText)
  self:ResetState()
  self:UpdateStateColor()
end
function KaMailItem:LoadImgSuc(InTexture)
  self.Img_Mail:SetBrushFromTextureDynamic(InTexture)
  Valid = self.WidgetSwitcher_Image and self.WidgetSwitcher_Image:SetActiveWidgetIndex(1)
  self.Parent:AddImageMap(self.MailId, self.Img_Mail.Brush)
end
function KaMailItem:OnClickMailItem()
  local MailIds = {}
  table.insert(MailIds, self.MailId)
  Valid = self.Button and self.Button:SetIsEnabled(false)
  GameFacade:SendNotification(NotificationDefines.NtfClickMailItem, self)
  GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqReadMail(MailIds)
  self.bIsSelected = true
  self:UpdateStateColor()
end
function KaMailItem:ResetState(bChangeData)
  Valid = self.Button and self.Button:SetIsEnabled(true)
  self.bIsSelected = false
  self:UpdateStateColor()
end
function KaMailItem:UpdateStateColor()
  Valid = self.MainTitle and self.MainTitle:SetColorAndOpacity(self.bIsSelected and self.TitleSelectedColor or self.TitleNormalColor)
  Valid = self.ValidityTime and self.ValidityTime:SetColorAndOpacity(self.bIsSelected and self.TimeSelectedColor or self.TimeNormalColor)
  Valid = self.ValidityTime_1 and self.ValidityTime_1:SetColorAndOpacity(self.bIsSelected and self.TimeSelectedColor or self.TimeNormalColor)
  Valid = self.ValidityTime_3 and self.ValidityTime_3:SetColorAndOpacity(self.bIsSelected and self.TimeSelectedColor or self.TimeNormalColor)
end
function KaMailItem:RefreshMainItemState(NewData)
  if NewData.AttachList and NewData.IsAttached == false then
  else
    if self.UObject and self.UObject.data then
      self.UObject.data.IsAttached = true
      self.UObject.data.IsShowTip = false
    end
    Valid = self.NewMailTip and self.NewMailTip:SetVisibility(Collapsed)
    Valid = self.WidgetSwitcher_Text and self.WidgetSwitcher_Text:SetActiveWidgetIndex(1)
    Valid = self.CanvasPanel_MailItem and self.CanvasPanel_MailItem:SetRenderOpacity(0.6)
  end
end
function KaMailItem:Construct()
  KaMailItem.super.Construct(self)
  self.Button.OnClicked:Add(self, self.OnClickMailItem)
end
function KaMailItem:Destruct()
  self.Button.OnClicked:Remove(self, self.OnClickMailItem)
  KaMailItem.super.Destruct(self)
end
return KaMailItem
