local MichellePlaytimeExchangeRewardPage = class("MichellePlaytimeExchangeRewardPage", PureMVC.ViewComponentPage)
local MichellePlaytimeExchangeRewardPageMediator = require("Business/Activities/MichellePlaytime/Mediators/MichellePlaytimeExchangeRewardPageMediator")
function MichellePlaytimeExchangeRewardPage:ListNeededMediators()
  return {MichellePlaytimeExchangeRewardPageMediator}
end
function MichellePlaytimeExchangeRewardPage:Construct()
  MichellePlaytimeExchangeRewardPage.super.Construct(self)
  self.Btn_ClosePage.OnClicked:Add(self, self.OnClickClosePage)
  self.Btn_ConfirmExchangeReward.OnClicked:Add(self, self.OnClickConfirmExchangeReward)
  self.Btn_ItemNumAdd.OnClicked:Add(self, self.OnClickItemNumAdd)
  self.Btn_ItemNumMinus.OnClicked:Add(self, self.OnClickItemNumMinus)
  self.Btn_ItemNumMax.OnClicked:Add(self, self.OnClickItemNumAddMax)
  self.Slider_ExchangeReward.OnValueChanged:Add(self, self.OnExchangeNumValueChanged)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local consumeId = MichellePlaytimeProxy:GetConsumeId()
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local ItemImg = ItemsProxy:GetAnyItemImg(consumeId)
  if ItemImg then
    self:SetImageByTexture2D_MatchSize(self.Img_GamePointIcon_Small, ItemImg)
    self:SetImageByTexture2D_MatchSize(self.Img_GamePointIcon, ItemImg)
  else
    LogInfo("MichellePlaytimeExchangeRewardPage:", "ItemImg is invalid.")
  end
  self:InitExchangeInfo()
  self:UpdateItemNumUI()
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryRewardExchangePage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, 0)
  self.opentime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
end
function MichellePlaytimeExchangeRewardPage:InitExchangeInfo()
  self.reqExchangeNum = 1
  self.currentConsumeNum = 1
  self.minConsumeNum = 1
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  self.maxConsumeNum = MichellePlaytimeProxy:GetGamePointCnt()
  self.Slider_ExchangeReward:SetMinValue(self.minConsumeNum - 1)
  self.Slider_ExchangeReward:SetMaxValue(self.maxConsumeNum)
  self:SetProgressUI()
end
function MichellePlaytimeExchangeRewardPage:Destruct()
  MichellePlaytimeExchangeRewardPage.super.Destruct(self)
  self.Btn_ClosePage.OnClicked:Remove(self, self.OnClickClosePage)
  self.Btn_ConfirmExchangeReward.OnClicked:Remove(self, self.OnClickConfirmExchangeReward)
  self.Btn_ItemNumAdd.OnClicked:Remove(self, self.OnClickItemNumAdd)
  self.Btn_ItemNumMinus.OnClicked:Remove(self, self.OnClickItemNumMinus)
  self.Btn_ItemNumMax.OnClicked:Remove(self, self.OnClickItemNumAddMax)
  self.Slider_ExchangeReward.OnValueChanged:Remove(self, self.OnExchangeNumValueChanged)
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local timeStr = MichellePlaytimeProxy:GetRemainingTimeStrFromTimeStamp(UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() - self.opentime)
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryRewardExchangePage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, timeStr)
end
function MichellePlaytimeExchangeRewardPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function MichellePlaytimeExchangeRewardPage:OnClickConfirmExchangeReward()
  if self.reqExchangeNum > 0 then
    local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
    MichellePlaytimeProxy:ReqExchangeReward(MichellePlaytimeProxy:GetActivityId(), self.reqExchangeNum)
  end
end
function MichellePlaytimeExchangeRewardPage:OnClickItemNumAdd()
  if self.maxConsumeNum and 0 ~= self.maxConsumeNum then
    if self.maxConsumeNum > self.currentConsumeNum then
      self.currentConsumeNum = self.currentConsumeNum + 1
    end
    self:SetProgressUI()
  end
end
function MichellePlaytimeExchangeRewardPage:OnClickItemNumAddMax()
  if self.maxConsumeNum and 0 ~= self.maxConsumeNum then
    self.currentConsumeNum = self.maxConsumeNum
    self:SetProgressUI()
  end
end
function MichellePlaytimeExchangeRewardPage:OnClickItemNumMinus()
  if 1 == self.currentConsumeNum then
    self.currentConsumeNum = 1
  else
    self.currentConsumeNum = self.currentConsumeNum - 1
  end
  self:SetProgressUI()
end
function MichellePlaytimeExchangeRewardPage:OnExchangeNumValueChanged(value)
  self.currentConsumeNum = math.floor(value)
  if 0 == self.currentConsumeNum then
    self.currentConsumeNum = self.minConsumeNum
  end
  self:SetProgressUI()
end
function MichellePlaytimeExchangeRewardPage:SetProgressUI()
  if 0 == self.maxConsumeNum then
    self.WS_ExchangeRewardInfo:SetActiveWidgetIndex(1)
    self.WS_ConsumptionPointInfo:SetActiveWidgetIndex(1)
    self.WS_ItemNumMaxTxtState:SetActiveWidgetIndex(1)
    self.Canvas_Max:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ProgressBar_ExchangeReward:SetPercent(0)
    self.Slider_ExchangeReward:SetValue(0)
    self.Btn_ConfirmExchangeReward:SetIsEnabled(false)
    self.Txt_ItemNumMin:SetText(0)
    self.Btn_ItemNumMinus:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Canvas_Max:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_ItemNumMinus:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_ConfirmExchangeReward:SetIsEnabled(true)
    local ratio = self.currentConsumeNum / self.maxConsumeNum
    self.ProgressBar_ExchangeReward:SetPercent(ratio)
    self.Slider_ExchangeReward:SetValue(self.currentConsumeNum)
    self.Txt_ConsumeNum:SetText(self.currentConsumeNum)
    local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
    local baseExchangeNum = MichellePlaytimeProxy:GetConsumeNumWhileExchange()
    self.reqExchangeNum = math.floor(self.currentConsumeNum / baseExchangeNum)
    self.Txt_ExchangeNum:SetText(self.reqExchangeNum)
    self.Txt_ItemNumMin:SetText(1)
    self.Txt_ItemNumMax:SetText(self.maxConsumeNum)
    self:UpdateItemNumUI()
  end
end
function MichellePlaytimeExchangeRewardPage:UpdateItemNumUI()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local consumeId = MichellePlaytimeProxy:GetConsumeId()
  if consumeId and 0 ~= consumeId then
    local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    self.Txt_GamePointName:SetText(ItemsProxy:GetAnyItemName(consumeId))
    self.Txt_ItemRarity_GamePoint:SetText(tostring(self.reqExchangeNum))
  else
    LogInfo("MichellePlaytimeExchangeRewardPage:", "consumeId is invalid.")
  end
  local redeemRewardId = MichellePlaytimeProxy:GetRedeemRewardId()
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local redeemRewardImg = ItemsProxy:GetAnyItemImg(redeemRewardId)
  self:SetImageByTexture2D_MatchSize(self.Img_ItemIcon, redeemRewardImg)
  self:SetImageByTexture2D_MatchSize(self.Img_RewardIcon, redeemRewardImg)
  self.Txt_ItemName:SetText(ItemsProxy:GetAnyItemName(redeemRewardId))
  local redeemRewardNum = MichellePlaytimeProxy:GetRedeemRewardNum()
  if self.reqExchangeNum and self.reqExchangeNum > 0 and redeemRewardNum and redeemRewardNum > 0 then
    self.Txt_ItemNum:SetText(self.reqExchangeNum * redeemRewardNum)
  else
    LogInfo("UpdateItemNumUI:", "reqExchangeNum or redeemRewardNum is invalid.")
  end
end
function MichellePlaytimeExchangeRewardPage:LuaHandleKeyEvent(key, inputEvent)
  return self.HotKeyButton_ClosePage:MonitorKeyDown(key, inputEvent)
end
return MichellePlaytimeExchangeRewardPage
