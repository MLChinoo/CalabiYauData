local SummerThemeSongMilestoneRewardItem = class("SummerThemeSongMilestoneRewardItem", PureMVC.ViewComponentPage)
local SummerThemeSongMilestoneRewardItemMediator = require("Business/Activities/SummerThemeSong/Mediators/SummerThemeSongMilestoneRewardItemMediator")
local MilestoneRewardItemReceiveStatus = {
  UnableClaim = 0,
  CanReceive = 1,
  Received = 2
}
function SummerThemeSongMilestoneRewardItem:ListNeededMediators()
  return {SummerThemeSongMilestoneRewardItemMediator}
end
function SummerThemeSongMilestoneRewardItem:Construct()
  SummerThemeSongMilestoneRewardItem.super.Construct(self)
  self.Btn_ReceiveReward.OnClicked:Add(self, self.OnClickReceiveReward)
  self.Btn_RewardPreview.OnClicked:Add(self, self.OnClickRewardPreview)
  self.Btn_RewardShow.OnClicked:Add(self, self.OnClickReceiveReward)
  self.rewardItemReceiveStatus = MilestoneRewardItemReceiveStatus.UnableClaim
  self:SetImageMatParamByTexture2D(self.Img_MilestoneIcon_Normal, "Main_Tex", self.bp_milestoneRoundIcon)
  self:SetImageMatParamByTexture2D(self.Img_MilestoneIcon_Reward, "Main_Tex", self.bp_milestoneRoundIcon)
  self:SetImageMatParamByTexture2D(self.Img_MilestoneIcon_AlreadyGet, "Main_Tex", self.bp_milestoneRoundIcon)
end
function SummerThemeSongMilestoneRewardItem:Destruct()
  SummerThemeSongMilestoneRewardItem.super.Destruct(self)
  self.Btn_ReceiveReward.OnClicked:Remove(self, self.OnClickReceiveReward)
  self.Btn_RewardPreview.OnClicked:Remove(self, self.OnClickRewardPreview)
  self.Btn_RewardShow.OnClicked:Remove(self, self.OnClickReceiveReward)
end
function SummerThemeSongMilestoneRewardItem:OnClickReceiveReward()
  if self.bp_CurrentAwardPhase > 0 and self.rewardItemReceiveStatus == MilestoneRewardItemReceiveStatus.CanReceive then
    local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
    local eventTouch = SummerThemeSongProxy.ActivityTouchTypeEnum.ClickMilestoneAwardBtn
    SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, 0, eventTouch)
    local pageData = {}
    pageData.curAwardPhase = self.bp_CurrentAwardPhase
    pageData.rewardCG = self.bp_rewardCG
    pageData.bReceived = false
    ViewMgr:OpenPage(self, UIPageNameDefine.SummerThemeSongMilestoneRewardsPage, true, pageData)
  elseif self.rewardItemReceiveStatus == MilestoneRewardItemReceiveStatus.Received then
    LogInfo("SummerThemeSong-SummerThemeSongMilestoneRewardItem-OnClickReceiveReward:", "already received reward")
    local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
    local eventTouch = SummerThemeSongProxy.ActivityTouchTypeEnum.ClickMilestoneAwardBtn
    SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, 0, eventTouch)
    local pageData = {}
    pageData.curAwardPhase = self.bp_CurrentAwardPhase
    pageData.rewardCG = self.bp_rewardCG
    pageData.bReceived = true
    ViewMgr:OpenPage(self, UIPageNameDefine.SummerThemeSongMilestoneRewardsPage, true, pageData)
  end
end
function SummerThemeSongMilestoneRewardItem:InitMilestoneRewardItem(rewardItemReceiveStatus)
  self.rewardItemReceiveStatus = rewardItemReceiveStatus
  self.WS_ReceivedRewardState:SetActiveWidgetIndex(rewardItemReceiveStatus)
end
function SummerThemeSongMilestoneRewardItem:OnClickRewardPreview()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local rewardIdList = SummerThemeSongProxy:GetScPhaseRewardCfg()
  if rewardIdList then
    for key, value in pairs(rewardIdList) do
      if value.id == self.bp_CurrentAwardPhase and value.items then
        local needToPreviewItems = {}
        for key1, value1 in pairs(value.items) do
          table.insert(needToPreviewItems, {
            itemId = value1.item_id,
            itemCnt = value1.item_cnt
          })
        end
        if table.count(needToPreviewItems) > 0 then
          ViewMgr:OpenPage(self, UIPageNameDefine.CommonItemDisplayPage, false, needToPreviewItems)
        end
        return
      end
    end
  end
end
return SummerThemeSongMilestoneRewardItem
