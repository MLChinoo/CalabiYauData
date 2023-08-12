local SummerThemeSongDeliveryOpportunityPage = class("SummerThemeSongDeliveryOpportunityPage", PureMVC.ViewComponentPage)
local SummerThemeSongDeliveryOpportunityPageMediator = require("Business/Activities/SummerThemeSong/Mediators/SummerThemeSongDeliveryOpportunityPageMediator")
function SummerThemeSongDeliveryOpportunityPage:ListNeededMediators()
  return {SummerThemeSongDeliveryOpportunityPageMediator}
end
function SummerThemeSongDeliveryOpportunityPage:Construct()
  SummerThemeSongDeliveryOpportunityPage.super.Construct(self)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  self.Btn_ReqDeliverOnce.OnClicked:Add(self, self.OnClickReqDeliverOnce)
  self.Btn_ReqDeliverMoreTimes.OnClicked:Add(self, self.OnClickReqDeliverMoreTimes)
  self:UpdateRemainingFlipTimes()
  self:UpdateDeliverRewardIcon()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.EntryDeliveryOpportunityPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.bActiveClosePage = false
  self.delayActiveClosePageFunctionTime = 0.8
  self.delayActiveClosePageFunctionHandle = TimerMgr:AddTimeTask(self.delayActiveClosePageFunctionTime, 0, 1, function()
    self.bActiveClosePage = true
  end)
end
function SummerThemeSongDeliveryOpportunityPage:Destruct()
  SummerThemeSongDeliveryOpportunityPage.super.Destruct(self)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self.Btn_ReqDeliverOnce.OnClicked:Remove(self, self.OnClickReqDeliverOnce)
  self.Btn_ReqDeliverMoreTimes.OnClicked:Remove(self, self.OnClickReqDeliverMoreTimes)
  self:ClearDelayReqDeliverHandle()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.QuitDeliveryOpportunityPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:ClearDelayActiveClosePageHandle()
end
function SummerThemeSongDeliveryOpportunityPage:OnClickClosePage()
  if self.bActiveClosePage then
    ViewMgr:ClosePage(self)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SummerThemeSongDeliveryOpportunityPage:OnClickReqDeliverOnce()
  self:PlayDeliverAnimation()
  self.DelayReqDeliverHandle = TimerMgr:AddTimeTask(2.0, 0, 1, function()
    local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
    SummerThemeSongProxy:ReqScDeliverReq(1)
    self:ResetDeliverAnimation()
  end)
end
function SummerThemeSongDeliveryOpportunityPage:OnClickReqDeliverMoreTimes()
  self:PlayDeliverAnimation()
  self.DelayReqDeliverHandle = TimerMgr:AddTimeTask(2.0, 0, 1, function()
    local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
    SummerThemeSongProxy:ReqScDeliverReq(5)
    self:ResetDeliverAnimation()
  end)
end
function SummerThemeSongDeliveryOpportunityPage:PlayDeliverAnimation()
  self:PlayAnimation(self.DeliveryLoopAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.WS_BtnDeliverOnceState:SetActiveWidgetIndex(0)
  self.WS_BtnDeliverMoreTimesState:SetActiveWidgetIndex(0)
end
function SummerThemeSongDeliveryOpportunityPage:ResetDeliverAnimation()
  self.WS_BtnDeliverOnceState:SetActiveWidgetIndex(1)
  self.WS_BtnDeliverMoreTimesState:SetActiveWidgetIndex(1)
  self:ClearDelayReqDeliverHandle()
end
function SummerThemeSongDeliveryOpportunityPage:ClearDelayReqDeliverHandle()
  if self.DelayReqDeliverHandle then
    self.DelayReqDeliverHandle:EndTask()
    self.DelayReqDeliverHandle = nil
  end
end
function SummerThemeSongDeliveryOpportunityPage:UpdateDeliverRewardIcon()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local deliverRewardConfigData = SummerThemeSongProxy:GetScDeliverRewardConfigData()
  for index, value in ipairs(deliverRewardConfigData) do
    if value.item_id then
      local imageItemWidget = self["Image_Reward" .. tostring(index)]
      if imageItemWidget then
        imageItemWidget:InitRewardItem(value.item_id, value.item_num)
      end
    end
  end
end
function SummerThemeSongDeliveryOpportunityPage:UpdateRemainingFlipTimes()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local flipTimes = SummerThemeSongProxy:GetFlipChanceItemCnt()
  self.Txt_RemainingDeliveryoOpportunities:SetText(tostring(flipTimes))
  local flipCostCnt = SummerThemeSongProxy:GetExchangeNum()
  if flipTimes >= flipCostCnt then
    self.WS_BtnDeliverOnceState:SetActiveWidgetIndex(1)
  else
    self.WS_BtnDeliverOnceState:SetActiveWidgetIndex(0)
  end
  if flipTimes >= flipCostCnt * 5 then
    self.WS_BtnDeliverMoreTimesState:SetActiveWidgetIndex(1)
  else
    self.WS_BtnDeliverMoreTimesState:SetActiveWidgetIndex(0)
  end
end
function SummerThemeSongDeliveryOpportunityPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClosePage()
    return true
  end
  return false
end
function SummerThemeSongDeliveryOpportunityPage:ClearDelayActiveClosePageHandle()
  if self.delayActiveClosePageFunctionHandle then
    self.delayActiveClosePageFunctionHandle:EndTask()
    self.delayActiveClosePageFunctionHandle = nil
  end
end
return SummerThemeSongDeliveryOpportunityPage
