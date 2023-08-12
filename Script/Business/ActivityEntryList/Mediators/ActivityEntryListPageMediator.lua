local ActivityEntryListPageMediator = class("ActivityEntryListPageMediator", PureMVC.Mediator)
local ActivitiesProxy
function ActivityEntryListPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.EntryListUpdate,
    NotificationDefines.Activities.ActivityRedDotUpdate
  }
end
function ActivityEntryListPageMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  if noteName == NotificationDefines.Activities.EntryListUpdate then
    self:UpdateView()
  elseif noteName == NotificationDefines.Activities.ActivityRedDotUpdate then
    self:UpdateView()
  end
end
function ActivityEntryListPageMediator:OnRegister()
  self:GetViewComponent().actionOnClickGotoBtn:Add(self.OnClickGotoBtn, self)
  self.BtnItemClass = ObjectUtil:LoadClass(self:GetViewComponent().ActivityEntryBtnItem)
  self.ContentItemClass = ObjectUtil:LoadClass(self:GetViewComponent().ActivityEntryContentItem)
  self.index = 1
  ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  self.ActivityPreTable = ActivitiesProxy:GetActivityPreTable()
  self:UpdateView()
end
function ActivityEntryListPageMediator:OnRemove()
  self:GetViewComponent().actionOnClickGotoBtn:Remove(self.OnClickGotoBtn, self)
end
function ActivityEntryListPageMediator:UpdateView()
  self:GetViewComponent().BtnRootBox:ClearChildren()
  self:GetViewComponent().ContentRoot:ClearChildren()
  self.data = {}
  for key, value in pairs(self.ActivityPreTable) do
    if value.status < GlobalEnumDefine.EActivityStatus.Closed then
      table.insert(self.data, value)
    end
  end
  table.sort(self.data, function(a, b)
    return a.cfg.sort > b.cfg.sort
  end)
  LogDebug("ActivityEntryListPageMediator", "  #self.data  = " .. #self.data)
  if 0 == #self.data then
    self:GetViewComponent().ContentRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().ViewSwitchAnimation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().NothingRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    return
  else
    self:GetViewComponent().ContentRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().ViewSwitchAnimation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().NothingRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.index > #self.data then
    self.index = 1
  end
  local BtnItemList = {}
  local ContentItemList = {}
  local OnClickBtn = function(i)
    self.index = i
    for j = 1, #BtnItemList do
      if j ~= self.index then
        BtnItemList[j].selectImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
        BtnItemList[j].itemBtn:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        BtnItemList[j].selectImage:SetVisibility(UE4.ESlateVisibility.Visible)
        BtnItemList[j].itemBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
        LogDebug("ActivityEntryListPageMediator", " but_text = " .. self.data[self.index].cfg.but_text)
        self:GetViewComponent().gotoBtnName:SetText(self.data[self.index].cfg.but_text)
        if self.data[self.index].cfg.picture ~= "" then
          local DownloadProxy = GameFacade:RetrieveProxy(ProxyNames.DownloadProxy)
          local fileDir = UE4.UBlueprintPathsLibrary.ProjectSavedDir() .. "ActivityPicture/"
          local fileName = UE4.UBlueprintPathsLibrary.GetBaseFilename(self.data[self.index].cfg.picture)
          local filePath = fileDir .. fileName .. ".png"
          if UE4.UBlueprintPathsLibrary.FileExists(filePath) then
            local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), filePath)
            ContentItemList[j].BigImage:SetBrushFromTexture(InTexture)
            local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
            if NoticeSubSys:GetFileIsExpired(filePath, 3600) then
              DownloadProxy:downloadUrl(self.data[self.index].cfg.picture, filePath, function(ret, url, savepath)
                if ret then
                  if ContentItemList[j].BigImage then
                    local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), savepath)
                    ContentItemList[j].BigImage:SetBrushFromTexture(InTexture)
                  end
                else
                  LogError("ActivityEntryListPageMediator", "Load  Picture Fail  url = " .. url)
                end
              end, function(receiveBytes, totalBytes)
              end)
            end
          else
            DownloadProxy:downloadUrl(self.data[self.index].cfg.picture, filePath, function(ret, url, savepath)
              if ret then
                if ContentItemList[j].BigImage then
                  local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), savepath)
                  ContentItemList[j].BigImage:SetBrushFromTexture(InTexture)
                end
              else
                LogError("ActivityEntryListPageMediator", "Load  Picture Fail  url = " .. url)
              end
            end, function(receiveBytes, totalBytes)
            end)
          end
        else
          local Localpicture = ActivitiesProxy:GetActivityTableCfg(self.data[self.index].activityId).Localpicture
          self:GetViewComponent():SetImageByTexture2D(ContentItemList[j].BigImage, Localpicture)
        end
        ContentItemList[j].BigImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:GetViewComponent().ContentRoot:SetActiveWidgetIndex(self.index - 1)
      end
    end
  end
  for i = 1, #self.data do
    local BtnItem = self:BtnRootAddChild()
    table.insert(BtnItemList, BtnItem)
    local ContentIntem = self:ContentRootAddChild()
    table.insert(ContentItemList, ContentIntem)
    ContentIntem.BigImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    BtnItem.BtnText:SetText(self.data[i].cfg.name)
    local reddot = ActivitiesProxy:GetRedNumByActivityID(self.data[i].activityId)
    LogDebug("ActivityEntryListPageMediator", "activityId = " .. tostring(self.data[i].activityId) .. "  num = " .. reddot)
    if BtnItem.RedDot then
      BtnItem.RedDot:SetVisibility(reddot > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    BtnItem.itemBtn.OnClicked:Add(BtnItem, function(BtnItem)
      OnClickBtn(i)
    end)
  end
  OnClickBtn(self.index)
end
function ActivityEntryListPageMediator:OnClickGotoBtn()
  if 1 == self.data[self.index].cfg.jump_type then
    LogDebug("ActivityEntryListPageMediator", " jump_type = " .. self.data[self.index].cfg.jump_url)
    local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
    GCloudSdk:OpenWebView(self.data[self.index].cfg.jump_url, 1, 0.7)
  else
    LogDebug("ActivityEntryListPageMediator", " data[self.index].blue_print = " .. self.data[self.index].cfg.blue_print)
    ViewMgr:OpenPage(LuaGetWorld(), self.data[self.index].cfg.blue_print)
  end
end
function ActivityEntryListPageMediator:BtnRootAddChild()
  if self.BtnItemClass ~= nil and self.BtnItemClass:IsValid() then
    local BtnItem = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.BtnItemClass)
    self:GetViewComponent().BtnRootBox:AddChild(BtnItem)
    return BtnItem
  end
end
function ActivityEntryListPageMediator:ContentRootAddChild()
  if self.ContentItemClass ~= nil and self.ContentItemClass:IsValid() then
    local ContentItem = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), self.ContentItemClass)
    self:GetViewComponent().ContentRoot:AddChild(ContentItem)
    return ContentItem
  end
end
return ActivityEntryListPageMediator
