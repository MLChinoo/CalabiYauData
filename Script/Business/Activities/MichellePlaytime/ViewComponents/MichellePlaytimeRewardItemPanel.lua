local MichellePlaytimeRewardItemPanel = class("MichellePlaytimeRewardItemPanel", PureMVC.ViewComponentPage)
local MichellePlaytimeRewardItemPanelMediator = require("Business/Activities/MichellePlaytime/Mediators/MichellePlaytimeRewardItemPanelMediator")
function MichellePlaytimeRewardItemPanel:ListNeededMediators()
  return {MichellePlaytimeRewardItemPanelMediator}
end
function MichellePlaytimeRewardItemPanel:Construct()
  MichellePlaytimeRewardItemPanel.super.Construct(self)
  if self.bp_special then
    self.WS_RewardState:SetActiveWidgetIndex(1)
  end
  self.Btn_ReceiveNormalReward.OnClicked:Add(self, self.OnClickReceiveReward)
  self.Btn_ReceiveSpecialReward.OnClicked:Add(self, self.OnClickReceiveReward)
  self.Btn_UnlockRewardPreview_Normal.OnClicked:Add(self, self.OnClickPreviewReward)
  self.Btn_ReceivedRewardPreview_Normal.OnClicked:Add(self, self.OnClickPreviewReward)
  self.Btn_UnlockRewardPreview_Special.OnClicked:Add(self, self.OnClickPreviewReward)
  self.Btn_ReceivedRewardPreview_Special.OnClicked:Add(self, self.OnClickPreviewReward)
end
function MichellePlaytimeRewardItemPanel:Destruct()
  MichellePlaytimeRewardItemPanel.super.Destruct(self)
  self.Btn_ReceiveNormalReward.OnClicked:Remove(self, self.OnClickReceiveReward)
  self.Btn_ReceiveSpecialReward.OnClicked:Remove(self, self.OnClickReceiveReward)
  self.Btn_UnlockRewardPreview_Normal.OnClicked:Remove(self, self.OnClickPreviewReward)
  self.Btn_ReceivedRewardPreview_Normal.OnClicked:Remove(self, self.OnClickPreviewReward)
  self.Btn_UnlockRewardPreview_Special.OnClicked:Remove(self, self.OnClickPreviewReward)
  self.Btn_ReceivedRewardPreview_Special.OnClicked:Remove(self, self.OnClickPreviewReward)
  self:ClearTimerHandle()
end
function MichellePlaytimeRewardItemPanel:InitItem(data)
  if data and data.item_id and data.item_cnt then
    local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    local ItemImg = ItemsProxy:GetAnyItemImg(data.item_id)
    self.itemId = data.item_id
    for index = 1, 6 do
      self:SetImageByTexture2D_MatchSize(self["Img_Reward" .. tostring(index)], ItemImg)
    end
    self.Txt_NormalRewardNum:SetText(tostring(data.item_cnt))
    self.Txt_SpecialRewardNum:SetText(tostring(data.item_cnt))
  else
    LogInfo("MichellePlaytimeRewardItemPanel InitItem", "data or data.item_id or data.item_cnt is nil")
  end
  self:SetItemUnlockedState()
end
function MichellePlaytimeRewardItemPanel:SetItemUnlockedState()
  self.WS_NormalRewardState:SetActiveWidgetIndex(0)
  self.WS_SpecialRewardState:SetActiveWidgetIndex(0)
  self.Img_Abot:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function MichellePlaytimeRewardItemPanel:SetItemPendingState()
  self.WS_NormalRewardState:SetActiveWidgetIndex(1)
  self.WS_SpecialRewardState:SetActiveWidgetIndex(1)
  self:PlayAnimation(self.Abot_Ani_land, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.updateTimer = TimerMgr:AddTimeTask(1.0, 0, 1, function()
    if 2 == self.WS_NormalRewardState.ActiveWidgetIndex then
      self:ClearTimerHandle()
      return
    end
    self:PlayAnimation(self.Abot_Ani_loop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end)
end
function MichellePlaytimeRewardItemPanel:SetItemReceivedState()
  self:ClearTimerHandle()
  self:StopAnimation(self.Abot_Ani_land)
  self:StopAnimation(self.Abot_Ani_loop)
  self.WS_NormalRewardState:SetActiveWidgetIndex(2)
  self.WS_SpecialRewardState:SetActiveWidgetIndex(2)
  self.Img_Abot:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function MichellePlaytimeRewardItemPanel:OnClickReceiveReward()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  MichellePlaytimeProxy:ReqUnlockReward(MichellePlaytimeProxy:GetActivityId(), self.bp_gridId)
  self.ReceiveConfirmNormalPS:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.rewardReceivePS, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function MichellePlaytimeRewardItemPanel:OnClickPreviewReward()
  if self.itemId and 0 ~= self.itemId then
    ViewMgr:OpenPage(self, UIPageNameDefine.SpaceTimeCardDetailPage, false, {
      itemId = self.itemId
    })
  else
    LogInfo("MichellePlaytimeRewardItemPanel OnClickPreviewReward", "itemId is invalid")
  end
end
function MichellePlaytimeRewardItemPanel:ShowPendingReceiveStateAnimation()
  if self.bp_special then
    self:PlayAnimation(self.ps_PendingReceiveState_1, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  else
    self:PlayAnimation(self.ps_PendingReceiveState, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function MichellePlaytimeRewardItemPanel:ClearTimerHandle()
  if self.delayPlayAbotLandTimer then
    self.delayPlayAbotLandTimer:EndTask()
    self.delayPlayAbotLandTimer = nil
  end
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
return MichellePlaytimeRewardItemPanel
