local SurveyPageMediator = class("SurveyPageMediator", PureMVC.Mediator)
function SurveyPageMediator:ListNotificationInterests()
  return {}
end
function SurveyPageMediator:OnRegister()
  self.super:OnRegister()
  self:GetViewComponent().actionOnClickOpenSurveyBtn:Add(self.OnClickOpenSurveyBtn, self)
  self:GetViewComponent().actionOnClickReceiveBtn:Add(self.OnClickReceiveBtn, self)
  self:GetViewComponent().actionLuaHandleKeyEvent:Add(self.LuaHandleKeyEvent, self)
  self:InitPage()
  local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
  if SuveyDC then
    SuveyDC.QuestionnaireCb:Bind(self:GetViewComponent(), function()
      self:UpdataBtnStatu()
    end)
    SuveyDC.RewardCb:Bind(self:GetViewComponent(), function()
      self:UpdataBtnStatu()
      self:ShowReward()
    end)
  end
end
function SurveyPageMediator:OnRemove()
  self.super:OnRemove()
  self:GetViewComponent().actionOnClickOpenSurveyBtn:Remove(self.OnClickOpenSurveyBtn, self)
  self:GetViewComponent().actionOnClickReceiveBtn:Remove(self.OnClickReceiveBtn, self)
  self:GetViewComponent().actionLuaHandleKeyEvent:Remove(self.LuaHandleKeyEvent, self)
  local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
  if SuveyDC then
    SuveyDC.QuestionnaireCb:Unbind()
    SuveyDC.RewardCb:Unbind()
  end
end
function SurveyPageMediator:HandleNotification(notification)
end
function SurveyPageMediator:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return
  end
  local name = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  LogDebug("SurveyPageMediator", name)
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Y" then
    local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
    if SuveyDC:IsReward() then
    elseif SuveyDC:IsCanReceive() then
      self:OnClickReceiveBtn()
    else
      self:OnClickOpenSurveyBtn()
    end
  end
end
function SurveyPageMediator:UpdataBtnStatu()
  local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
  if SuveyDC:IsReward() then
    self:GetViewComponent().receivedBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:GetViewComponent().OpenSurveyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().receiveBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif SuveyDC:IsCanReceive() then
    self:GetViewComponent().receivedBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().OpenSurveyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().receiveBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:GetViewComponent().receivedBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:GetViewComponent().OpenSurveyBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self:GetViewComponent().receiveBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SurveyPageMediator:ShowReward()
  GameFacade:SendNotification(NotificationDefines.ReceiveSurveyReward)
  ViewMgr:ClosePage(self:GetViewComponent())
end
function SurveyPageMediator:InitPage()
  local SurveyIndex = 8104
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local SurveyIndexText = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(SurveyIndex).ParaValue
  SurveyIndexText = string.gsub(SurveyIndexText, ":", "=")
  SurveyIndexText = string.gsub(SurveyIndexText, "\"", "")
  local tb = load("return " .. SurveyIndexText)()
  self:GetViewComponent().itemNum:SetText("X " .. tb.item_count)
  local ItemImg = ItemsProxy:GetAnyItemImg(tb.item_id)
  local ItemName = ItemsProxy:GetAnyItemName(tb.item_id)
  self:GetViewComponent():SetImageByTexture2D(self:GetViewComponent().ItemIcon, ItemImg)
  self:GetViewComponent().ItemName:SetText(ItemName)
  local quality = ItemsProxy:GetAnyItemQuality(tb.item_id)
  local qualityInfo = ItemsProxy:GetItemQualityConfig(quality)
  if self:GetViewComponent().Img_Quality then
    self:GetViewComponent().Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(qualityInfo.Color)))
  end
  self:UpdataBtnStatu()
end
function SurveyPageMediator:OnClickOpenSurveyBtn()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  local SurveyUrlIndex = 8106
  local url = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(SurveyUrlIndex).ParaValue
  GCloudSdk.WebViewCloseCb:Bind(self:GetViewComponent(), SurveyPageMediator.WebViewCloseCb)
  local playerId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  LogDebug("SurveyPageMediator:OnClickOpenSurveyBtn:")
  GCloudSdk:OpenWebView(url, 1, 0.7)
end
function SurveyPageMediator:WebViewCloseCb()
  LogDebug("SurveyPageMediator:WebViewCloseCb:")
end
function SurveyPageMediator:OnClickReceiveBtn()
  local SuveyDC = UE4.UPMSuveyDataCenter.Get(LuaGetWorld())
  if SuveyDC then
    SuveyDC:ReqReward()
  end
end
return SurveyPageMediator
