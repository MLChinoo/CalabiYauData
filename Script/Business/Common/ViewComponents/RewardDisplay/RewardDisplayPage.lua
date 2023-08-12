local RewardDisplayMediator = require("Business/Common/Mediators/RewardDisplay/RewardDisplayMediator")
local RewardDisplayPage = class("RewardDisplayPage", PureMVC.ViewComponentPage)
function RewardDisplayPage:ListNeededMediators()
  return {RewardDisplayMediator}
end
function RewardDisplayPage:InitializeLuaEvent()
  self.updateViewEvent = LuaEvent.new()
  if self.Btn_Close then
    self.Btn_Close.OnClickEvent:Add(self, self.OnBtnClose)
  end
end
function RewardDisplayPage:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Escape" and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnBtnClose()
    return true
  end
  if self.Btn_Close and not ret then
    ret = self.Btn_Close:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function RewardDisplayPage:OnOpen(luaOpenData, nativeOpenData)
  if luaOpenData then
    self.updateViewEvent(luaOpenData, nil)
  elseif nativeOpenData then
    self.updateViewEvent(nil, nativeOpenData)
  end
  if self.Img_Close then
    self.Img_Close.OnMouseButtonDownEvent:Bind(self, self.OnBtnClose)
  end
  self:BindToAnimationFinished(self.Anim_FadeIn, {
    self,
    self.ShowRewardAnimationFinish
  })
  self:PlayAnimation(self.Anim_FadeIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RewardDisplayPage:ShowRewardAnimationFinish()
  local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if NewPlayerGuideProxy:IsShowGuideUI(NewPlayerGuideEnum.GuideStep.Gift3DBox) then
    local NewPlayerGuideTriggerProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideTriggerProxy)
    NewPlayerGuideTriggerProxy:ShowNextStep(0)
  end
end
function RewardDisplayPage:OnClose()
  if self.Btn_Close then
    self.Btn_Close.OnClickEvent:Remove(self, self.OnBtnClose)
  end
  if self.Img_Close then
    self.Img_Close.OnMouseButtonDownEvent:Unbind()
  end
end
function RewardDisplayPage:OnBtnClose()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function RewardDisplayPage:UpdatePageView(data)
  if data.isOverflow and self.CP_Tip then
    self.CP_Tip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.DynamicEntryBox_Items then
    local index = 0
    for key, value in pairs(data.itemInfoList) do
      local rewardItem = self.DynamicEntryBox_Items:BP_CreateEntry()
      local animTime = self.StartTime + index * self.IntervalTime
      rewardItem:UpdateView(value, animTime)
      index = index + 1
    end
    if table.count(data.itemInfoList) < self.DefaultCnt then
      self.ScrollBox_Items:SetScrollBarVisibility(UE4.ESlateVisibility.Collapsed)
      self.Img_ScrollBarBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
return RewardDisplayPage
