local SummerThemeSongMilestoneRewardPage = class("SummerThemeSongMilestoneRewardPage", PureMVC.ViewComponentPage)
local SummerThemeSongMilestoneRewardPageMediator = require("Business/Activities/SummerThemeSong/Mediators/SummerThemeSongMilestoneRewardPageMediator")
function SummerThemeSongMilestoneRewardPage:ListNeededMediators()
  return {SummerThemeSongMilestoneRewardPageMediator}
end
function SummerThemeSongMilestoneRewardPage:OnOpen(luaOpenData, nativeOpenData)
  self.bp_CurrentAwardPhase = luaOpenData.curAwardPhase
  self.bp_rewardCG = luaOpenData.rewardCG
  self.bReceived = luaOpenData.bReceived
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local items = SummerThemeSongProxy:GetItemIDFromScConfigData(self.bp_CurrentAwardPhase)
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if items then
    local bFirst = true
    for k, value in pairs(items) do
      local ItemImage = ItemsProxy:GetAnyItemImg(value.item_id)
      if ItemImage then
        if bFirst then
          if self.Img_RewardIcon_1 then
            self:SetImageByTexture2D(self.Img_RewardIcon_1, ItemImage)
            self.Canvas_RewardFirst:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          end
          bFirst = false
        elseif self.Img_RewardIcon_2 then
          self:SetImageByTexture2D(self.Img_RewardIcon_2, ItemImage)
          self.Canvas_RewardSecond:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
  if self.bp_rewardCG then
    self:SetImageByTexture2D_MatchSize(self.Img_RewardCG, self.bp_rewardCG)
  end
  local phaseDes = SummerThemeSongProxy:GetPhaseDesFromScConfigData(self.bp_CurrentAwardPhase)
  if phaseDes then
    self.Txt_RewardDes:SetText(phaseDes)
  end
  if self.bReceived then
    self.WS_BtnReceiveState:SetActiveWidgetIndex(1)
  else
    self.WS_BtnReceiveState:SetActiveWidgetIndex(0)
  end
end
function SummerThemeSongMilestoneRewardPage:Construct()
  SummerThemeSongMilestoneRewardPage.super.Construct(self)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  self.Btn_ReqReceiveReward.OnClicked:Add(self, self.OnClickReqReceiveReward)
  self.Btn_Share.OnClicked:Add(self, self.OnClickRewardShare)
  self.bp_CurrentAwardPhase = 0
  self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnCaptureScreenshotSuccess")
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.EntryMilestoneAwardPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.delayActiveClosePageFunctionTime = 0.8
  self.bActiveClosePage = false
  self.delayActiveClosePageFunctionHandle = TimerMgr:AddTimeTask(self.delayActiveClosePageFunctionTime, 0, 1, function()
    self.bActiveClosePage = true
  end)
end
function SummerThemeSongMilestoneRewardPage:Destruct()
  SummerThemeSongMilestoneRewardPage.super.Destruct(self)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self.Btn_ReqReceiveReward.OnClicked:Remove(self, self.OnClickReqReceiveReward)
  self.Btn_Share.OnClicked:Remove(self, self.OnClickRewardShare)
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local eventType = SummerThemeSongProxy.ActivityEventTypeEnum.QuitMilestoneAwardPage
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(eventType, 0, 0)
  self:ClearDelayActiveClosePageHandle()
end
function SummerThemeSongMilestoneRewardPage:OnClickClosePage()
  if self.bActiveClosePage then
    ViewMgr:ClosePage(self)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SummerThemeSongMilestoneRewardPage:OnClickReqReceiveReward()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  if self.bp_CurrentAwardPhase > 0 then
    SummerThemeSongProxy:ReqScAwardPhase(self.bp_CurrentAwardPhase)
  end
end
function SummerThemeSongMilestoneRewardPage:OnClickRewardShare()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, self.bp_CurrentAwardPhase, 0)
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.SetPageWidgetVisible, false)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.Activity)
end
function SummerThemeSongMilestoneRewardPage:OnCaptureScreenshotSuccess()
  GameFacade:SendNotification(NotificationDefines.Activities.SummerThemeSong.SetPageWidgetVisible, true)
end
function SummerThemeSongMilestoneRewardPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickClosePage()
    return true
  end
  return false
end
function SummerThemeSongMilestoneRewardPage:ClearDelayActiveClosePageHandle()
  if self.delayActiveClosePageFunctionHandle then
    self.delayActiveClosePageFunctionHandle:EndTask()
    self.delayActiveClosePageFunctionHandle = nil
  end
end
return SummerThemeSongMilestoneRewardPage
