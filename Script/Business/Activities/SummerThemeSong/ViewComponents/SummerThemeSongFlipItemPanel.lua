local SummerThemeSongFlipItemPanel = class("SummerThemeSongFlipItemPanel", PureMVC.ViewComponentPage)
local SummerThemeSongFlipItemPanelMediator = require("Business/Activities/SummerThemeSong/Mediators/SummerThemeSongFlipItemPanelMediator")
function SummerThemeSongFlipItemPanel:ListNeededMediators()
  return {SummerThemeSongFlipItemPanelMediator}
end
function SummerThemeSongFlipItemPanel:Construct()
  SummerThemeSongFlipItemPanel.super.Construct(self)
  self.Btn_Flip.OnClicked:Add(self, self.OnClickFlipBtn)
  self.bIsOpen = false
  self.bReqOpen = false
end
function SummerThemeSongFlipItemPanel:Destruct()
  SummerThemeSongFlipItemPanel.super.Destruct(self)
  self.Btn_Flip.OnClicked:Remove(self, self.OnClickFlipBtn)
  self:ClearStopParticleHandle()
  self:ClearResetReqOpenHandle()
end
function SummerThemeSongFlipItemPanel:InitData(itemId, bCue, gridId)
  self:ResetPanel()
  self:StopAnimation(self.CardNormalStateAnim)
  self.lizi_nomarl:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.lizi_special:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.currentGripId = gridId
  self.bIsOpen = true
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local ItemConfig = ItemsProxy:GetItemTableConfig(itemId)
  if ItemConfig then
    if ItemConfig.IconItem then
      self:SetImageByTexture2D(self.Img_Background_Award, ItemConfig.IconItem)
    end
    if ItemConfig.name then
      self.Txt_FlipName:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Txt_FlipName:SetText(ItemConfig.name)
    end
    self.Img_Background_Normal:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Img_Background_Award:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Img_Background_Award:SetRenderOpacity(1)
    if bCue then
      self.WS_FlipItemParticle:SetActiveWidgetIndex(1)
      self.lizi_01:SetVisibility(UE4.ESlateVisibility.Visible)
      self.lizi_special:SetVisibility(UE4.ESlateVisibility.Visible)
      self.lizi_special:SetReactivate(true)
    else
      self.WS_FlipItemParticle:SetActiveWidgetIndex(0)
      self.lizi_01:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.Btn_Flip:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    LogInfo("SummerThemeSong FlipItem Log", "ItemConfig is nil, itemId is %d", itemId)
  end
end
function SummerThemeSongFlipItemPanel:ResetPanel()
  self.bIsOpen = false
  if self.bp_defaultName then
    self.Txt_FlipName:SetText(self.bp_defaultName)
  end
  if self.bp_defaultTexture then
    self:SetImageByTexture2D(self.Img_Background_Award, self.bp_defaultTexture)
  end
  self.Btn_Flip:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.CardNormalStateAnim then
    self:StopAnimation(self.CardFlipAnim)
    self:PlayAnimation(self.CardNormalStateAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
  self:SetFlipItemParticleVisible()
end
function SummerThemeSongFlipItemPanel:InitGrid(gridId)
  self.currentGripId = gridId
end
function SummerThemeSongFlipItemPanel:OnClickFlipBtn()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  if self.currentGripId and not self.bReqOpen and not self.bIsOpen and not SummerThemeSongProxy:GetIsInActiveMainPagePhaseFinishedParticle() then
    local eventTouch = SummerThemeSongProxy.ActivityTouchTypeEnum.ClickFlipItemBtn
    SummerThemeSongProxy:SetActivityEventInfoOfTLOG(0, 0, eventTouch)
    SummerThemeSongProxy:ReqScOpenCard(self.currentGripId)
    self.bReqOpen = true
    self:ClearResetReqOpenHandle()
    self.delayResetReqOpenHandle = TimerMgr:AddTimeTask(2, 0, 1, function()
      self.bReqOpen = false
    end)
  end
end
function SummerThemeSongFlipItemPanel:SetFlipItemParticleVisible()
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  local BtnFlipParticleVisible = UE4.ESlateVisibility.Visible
  local flipTimes = SummerThemeSongProxy:GetFlipChanceItemCnt()
  if SummerThemeSongProxy:GetAllPhaseFinished() or flipTimes <= 0 then
    BtnFlipParticleVisible = UE4.ESlateVisibility.Collapsed
  end
  self.lizi_01:SetVisibility(BtnFlipParticleVisible)
end
function SummerThemeSongFlipItemPanel:ClearStopParticleHandle()
  if self.StopParticleHandle then
    self.StopParticleHandle:EndTask()
    self.StopParticleHandle = nil
  end
end
function SummerThemeSongFlipItemPanel:PlayFlipAnimation(bCue)
  self:ClearStopParticleHandle()
  self:PlayAnimation(self.CardFlipAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local audio = UE4.UPMLuaAudioBlueprintLibrary
  if not bCue then
    self.StopParticleHandle = TimerMgr:AddTimeTask(2.8, 0, 1, function()
      self.WS_FlipItemParticle:GetActiveWidget():SetReactivate(false)
    end)
    audio.PostEvent(audio.GetID(self.bp_normalFlipSound))
  else
    self.StopParticleHandle = TimerMgr:AddTimeTask(1.2, 0, 1, function()
      self.lizi_special:SetVisibility(UE4.ESlateVisibility.Visible)
      self.lizi_special:SetReactivate(true)
      self.lizi_special:SetRenderOpacity(1)
    end)
    audio.PostEvent(audio.GetID(self.bp_specialFlipSound))
  end
end
function SummerThemeSongFlipItemPanel:ClearResetReqOpenHandle()
  if self.delayResetReqOpenHandle then
    self.delayResetReqOpenHandle:EndTask()
    self.delayResetReqOpenHandle = nil
  end
end
return SummerThemeSongFlipItemPanel
