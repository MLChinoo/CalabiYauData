local MichellePlaytimeRewardChestPage = class("MichellePlaytimeRewardChestPage", PureMVC.ViewComponentPage)
function MichellePlaytimeRewardChestPage:ListNeededMediators()
  return {}
end
function MichellePlaytimeRewardChestPage:Construct()
  MichellePlaytimeRewardChestPage.super.Construct(self)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local currentRewardPhase = MichellePlaytimeProxy:GetCurrentRewardPhase() - 1
  local maxRewardPhase = MichellePlaytimeProxy:GetMaxRewardPhase()
  self.Txt_TotalRewardPhase:SetText(maxRewardPhase)
  if currentRewardPhase > maxRewardPhase then
    currentRewardPhase = maxRewardPhase
  end
  self.Txt_CurrentRewardPhase:SetText(currentRewardPhase)
  if currentRewardPhase == maxRewardPhase then
    self:PlayAnimation(self.AllRewardsCollectedCompleted, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
  local activityGainRewardData = MichellePlaytimeProxy:GetActivityGainRewardData()
  if activityGainRewardData then
    table.sort(activityGainRewardData, function(a, b)
      local itemQualityA = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(a.item_id)
      local itemQualityB = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemQuality(b.item_id)
      return itemQualityA > itemQualityB
    end)
    if #activityGainRewardData > 0 then
      for key, value in pairs(activityGainRewardData) do
        local itemObj = ObjectUtil:CreateLuaUObject(self)
        itemObj.itemId = value.item_id
        itemObj.itemCnt = value.item_cnt
        self.ListView_RewardChest:AddItem(itemObj)
      end
    else
      self.Canvas_NoRewardTips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function MichellePlaytimeRewardChestPage:Destruct()
  MichellePlaytimeRewardChestPage.super.Destruct(self)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
end
function MichellePlaytimeRewardChestPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
function MichellePlaytimeRewardChestPage:LuaHandleKeyEvent(key, inputEvent)
  return self.HotKeyButton_ClosePage:MonitorKeyDown(key, inputEvent)
end
return MichellePlaytimeRewardChestPage
