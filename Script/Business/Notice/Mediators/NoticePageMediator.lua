local NoticePageMediator = class("NoticePageMediator", PureMVC.Mediator)
local NoticeSubSys
function NoticePageMediator:ListNotificationInterests()
  return {}
end
function NoticePageMediator:HandleNotification(notification)
end
function NoticePageMediator:OnRegister()
  self.super:OnRegister()
  LogDebug("NoticePage", "OnRegister")
  NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  self.ContentImageItemClass = ObjectUtil:LoadClass(self:GetViewComponent().ContentImageItem)
  self.ContentTextItemClass = ObjectUtil:LoadClass(self:GetViewComponent().ContentTextItem)
  self.NoticeTitlePanelClass = ObjectUtil:LoadClass(self:GetViewComponent().NoticeTitlePanel)
  self.NoticeBtnItemClass = ObjectUtil:LoadClass(self:GetViewComponent().NoticeBtnItem)
  self.ContentRichTextItemClass = ObjectUtil:LoadClass(self:GetViewComponent().ContentRichTextItem)
  self.ContentUrlTextItemClass = ObjectUtil:LoadClass(self:GetViewComponent().ContentUrlTextItem)
  self.index = 1
  self.minEndTime = -1
  self.OnLoadNoticeDataSuccessHandler = DelegateMgr:AddDelegate(NoticeSubSys.OnLoadNoticeDataSuccess, self, "InitView")
  self.UpdataNoticeHandle = TimerMgr:AddTimeTask(0, 300, 0, function()
    NoticeSubSys:LoadNoticeData("0", "zh-CN", 156)
  end)
end
function NoticePageMediator:OnRemove()
  self.super:OnRemove()
  LogDebug("NoticePage", "OnRemove")
  if self.OnLoadNoticeDataSuccessHandler then
    DelegateMgr:RemoveDelegate(NoticeSubSys.OnLoadNoticeDataSuccess, self.OnLoadNoticeDataSuccessHandler)
    self.OnLoadNoticeDataSuccessHandler = nil
  end
  if self.MinEndTimeHandle then
    self.MinEndTimeHandle:EndTask()
    self.MinEndTimeHandle = nil
  end
  if self.UpdataNoticeHandle then
    self.UpdataNoticeHandle:EndTask()
    self.UpdataNoticeHandle = nil
  end
end
function NoticePageMediator:InitView()
  LogDebug("NoticePage", "InitView")
  if self.MinEndTimeHandle then
    self.MinEndTimeHandle:EndTask()
    self.MinEndTimeHandle = nil
  end
  self:GetViewComponent().rightBtnRootBox:ClearChildren()
  self:GetViewComponent().ContentRootBox:ClearChildren()
  self.BtnItemList = {}
  local noticeInfoList
  if 1 == self:GetViewComponent().NoticeType then
    noticeInfoList = NoticeSubSys:GetBlockNoticeInfoList()
  elseif 2 == self:GetViewComponent().NoticeType then
    noticeInfoList = NoticeSubSys:GetLoginBeforeNoticeInfoList()
  else
    noticeInfoList = NoticeSubSys:GetNoticeInfoList()
  end
  LogDebug("NoticePage", "noticeInfoList.Length() = " .. noticeInfoList:Length())
  if noticeInfoList:Length() > 0 then
    self:GetViewComponent().NothingRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    for i = 1, noticeInfoList:Length() do
      if -1 == self.minEndTime then
        self.minEndTime = noticeInfoList:Get(i).endTime
      elseif self.minEndTime > noticeInfoList:Get(i).endTime then
        self.minEndTime = noticeInfoList:Get(i).endTime
      end
      local btnItem = self:BtnRootAddChild()
      table.insert(self.BtnItemList, btnItem)
      btnItem.BtnText:SetText(noticeInfoList:Get(i).textInfo.noticeTitle)
      btnItem.itemBtn.OnClicked:Add(self:GetViewComponent(), function(item)
        self:OnClickBtn(i)
      end)
    end
    local interval = self.minEndTime - os.time()
    if interval > 0 then
      self.MinEndTimeHandle = TimerMgr:AddTimeTask(interval + 1, 1, 1, function()
        self:InitView()
      end)
    end
    if self.index > noticeInfoList:Length() then
      self.index = 1
    end
    self:OnClickBtn(self.index)
  else
    self:GetViewComponent().NothingRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function NoticePageMediator:OnClickBtn(index)
  self.index = index
  for j = 1, #self.BtnItemList do
    if j ~= self.index then
      self.BtnItemList[j].selectImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.BtnItemList[j].itemBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BtnItemList[j].selectImage:SetVisibility(UE4.ESlateVisibility.Visible)
      self.BtnItemList[j].itemBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:UpdataView()
end
function NoticePageMediator:UpdataView()
  self:GetViewComponent().ContentRootBox:ClearChildren()
  self:GetViewComponent().ContentRootBox:ScrollToStart()
  local noticeInfoList
  if 1 == self:GetViewComponent().NoticeType then
    noticeInfoList = NoticeSubSys:GetBlockNoticeInfoList()
  elseif 2 == self:GetViewComponent().NoticeType then
    noticeInfoList = NoticeSubSys:GetLoginBeforeNoticeInfoList()
  else
    noticeInfoList = NoticeSubSys:GetNoticeInfoList()
  end
  local Infos = NoticeSubSys:GetNoticeDataByID(noticeInfoList:Get(self.index).noticeID)
  LogDebug("NoticePage", "Infos.Length() = " .. Infos:Length())
  for i = 1, Infos:Length() do
    local data = Infos:Get(i)
    if 1 == i then
      if data.Tag == UE4.ENoteTag.img then
        self:SetImage(data)
        self:SetTitle(noticeInfoList:Get(self.index).textInfo.noticeTitle)
      else
        self:SetTitle(noticeInfoList:Get(self.index).textInfo.noticeTitle)
        self:UpdataContent(data)
      end
    else
      self:UpdataContent(data)
    end
  end
end
function NoticePageMediator:UpdataContent(data)
  if data.Tag == UE4.ENoteTag.p then
    local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.ContentTextItemClass)
    local slot = self:GetViewComponent().ContentRootBox:AddChild(item)
    item.ContentText:SetText(data.Content)
    local margin = UE4.FMargin()
    margin.Bottom = 50
    slot:SetPadding(margin)
  end
  if data.Tag == UE4.ENoteTag.img then
    self:SetImage(data)
  end
  if data.Tag == UE4.ENoteTag.href then
    local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.ContentUrlTextItemClass)
    local slot = self:GetViewComponent().ContentRootBox:AddChild(item)
    local margin = UE4.FMargin()
    margin.Bottom = 50
    slot:SetPadding(margin)
    item.ContentText:SetText(data.Content)
    item.ShowUrlBtn.OnClicked:Add(item, function(item)
      self:OnClickURL(data.AttributeValue)
    end)
  end
  if data.Tag == UE4.ENoteTag.H1 or data.Tag == UE4.ENoteTag.H2 or data.Tag == UE4.ENoteTag.H3 then
    self:SetHeadText(data, data.Tag)
  end
end
function NoticePageMediator:OnClickURL(URL)
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  GCloudSdk:OpenWebView(URL, 1, 0.7)
end
function NoticePageMediator:SetTitle(TitleText)
  local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.NoticeTitlePanelClass)
  local slot = self:GetViewComponent().ContentRootBox:AddChild(item)
  slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Left)
  local margin = UE4.FMargin()
  margin.Bottom = 50
  slot:SetPadding(margin)
  item.TitleText:SetText(TitleText)
end
function NoticePageMediator:SetImage(data)
  local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.ContentImageItemClass)
  local slot = self:GetViewComponent().ContentRootBox:AddChild(item)
  slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Left)
  local margin = UE4.FMargin()
  margin.Bottom = 50
  slot:SetPadding(margin)
  local DownloadProxy = GameFacade:RetrieveProxy(ProxyNames.DownloadProxy)
  local fileDir = UE4.UBlueprintPathsLibrary.ProjectSavedDir() .. "NoticePicture/"
  local fileName = UE4.UBlueprintPathsLibrary.GetBaseFilename(data.AttributeValue)
  local filePath = fileDir .. fileName .. ".png"
  if UE4.UBlueprintPathsLibrary.FileExists(filePath) then
    local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), filePath)
    item.ContentImage:SetBrushFromTexture(InTexture, true)
    item.ContentImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    DownloadProxy:downloadUrl(data.AttributeValue, filePath, function(ret, url, savepath)
      if ret then
        local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), savepath)
        item.ContentImage:SetBrushFromTexture(InTexture, true)
        item.ContentImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        LogError("NoticePageMediator", "Load  Picture Fail  url = " .. url)
      end
    end, function(receiveBytes, totalBytes)
    end)
  end
end
function NoticePageMediator:SetHeadText(data, type)
  local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.ContentRichTextItemClass)
  local slot = self:GetViewComponent().ContentRootBox:AddChild(item)
  local margin = UE4.FMargin()
  margin.Bottom = 30
  margin.Top = 30
  slot:SetPadding(margin)
  local text
  if type == UE4.ENoteTag.H1 then
    text = "<H1>" .. data.Content .. "</>"
  elseif type == UE4.ENoteTag.H2 then
    text = "<H2>" .. data.Content .. "</>"
  elseif type == UE4.ENoteTag.H3 then
    text = "<H3>" .. data.Content .. "</>"
  end
  item.RichText:SetText(text)
end
function NoticePageMediator:BtnRootAddChild()
  if self.NoticeBtnItemClass ~= nil and self.NoticeBtnItemClass:IsValid() then
    local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.NoticeBtnItemClass)
    self:GetViewComponent().rightBtnRootBox:AddChild(item)
    return item
  end
end
return NoticePageMediator
