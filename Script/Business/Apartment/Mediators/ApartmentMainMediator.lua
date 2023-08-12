local ApartmentMainMediator = class("ApartmentMainMediator", PureMVC.Mediator)
local ApartmentMainPage, CySequenceMgr, CyAVGMgr, ApartmentStateMachineConfigProxy, StateMachineConfig, GlobalDelegateManager
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
function ApartmentMainMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
end
function ApartmentMainMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  ApartmentStateMachineConfigProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy)
  StateMachineConfig = ApartmentStateMachineConfigProxy:GetApartmentConfigData().ApartmentPromiseAVGConfig
  self:SetPageVisibility(true)
end
function ApartmentMainMediator:OnRegister()
end
function ApartmentMainMediator:OnRemove()
  self:ClearSequenceStopDelegate()
  self:ClearAVGEventStopDelegate()
  self:ClearClickLobbyCharacterDelegate()
end
function ApartmentMainMediator:ListNotificationInterests()
  return {
    NotificationDefines.ApartmentMainPageVisibility,
    NotificationDefines.PlayApartmentGiftFeedbackAnimation,
    NotificationDefines.PlayApartmentGetRewardAnimation,
    NotificationDefines.SkipApartmentCurAnimation,
    NotificationDefines.NewPlayerGuideGetGift,
    NotificationDefines.ShowPlayerGuideCurrentIndex,
    NotificationDefines.ApartmentMainPageClose,
    NotificationDefines.SetApartmentRoleInfo,
    NotificationDefines.PromisePlayAVGEvent,
    NotificationDefines.PromisePlayAVGSequence
  }
end
function ApartmentMainMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  ApartmentMainPage = self:GetViewComponent()
  CySequenceMgr = UE4.UCySequenceManager.Get(LuaGetWorld())
  CyAVGMgr = UE4.UCyAVGEventManager.Get(LuaGetWorld())
  GlobalDelegateManager = GetGlobalDelegateManager()
  if not (ApartmentMainPage and CySequenceMgr and GlobalDelegateManager) or not CyAVGMgr then
    return
  end
  if Name == NotificationDefines.ApartmentMainPageVisibility then
    self:SetPageVisibility(Body)
  elseif Name == NotificationDefines.PlayApartmentGetRewardAnimation then
    self:PlayApartmentGetRewardAnimation(Body)
  elseif Name == NotificationDefines.PlayApartmentGiftFeedbackAnimation then
    self:PlayApartmentGiftFeedbackAnimation()
  elseif Name == NotificationDefines.SkipApartmentCurAnimation then
    self:SkipCurSequence()
  elseif Name == NotificationDefines.NewPlayerGuideGetGift then
    self:GetGiftCallback()
  elseif Name == NotificationDefines.ShowPlayerGuideCurrentIndex then
    self:OnShowPlayerGuide(Body)
  elseif Name == NotificationDefines.ApartmentMainPageClose then
    self:ClearSequenceStopDelegate()
    self:ClearAVGEventStopDelegate()
    self:ClearClickLobbyCharacterDelegate()
    if self.RoleUpdateTimer then
      self.RoleUpdateTimer:EndTask()
      self.RoleUpdateTimer = nil
    end
    if self.PlaySequenceTimer then
      self.PlaySequenceTimer:EndTask()
      self.PlaySequenceTimer = nil
    end
    if self.PlayAVGEventTimer then
      self.PlayAVGEventTimer:EndTask()
      self.PlayAVGEventTimer = nil
    end
    self:PlaySequence(StateMachineConfig.OnCloseSequenceID)
  elseif Name == NotificationDefines.SetApartmentRoleInfo then
    ApartmentMainPage:UpdateRoleInfo(Body)
  elseif Name == NotificationDefines.PromisePlayAVGEvent then
    if not Body then
      return
    end
    if not self:CheckCanPlayAvg() then
      return
    end
    self.PromisePlayAVGId = Body
    GameFacade:SendNotification(NotificationDefines.ApartmentTurnOffBgm)
    self:PlayAVGEvent(self.PromisePlayAVGId)
    self:SetPageVisibility(false, true)
    ApartmentMainPage:SetChatVisibility(NotificationDefines.ChatState.Hide)
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(ApartmentMainPage, true)
  elseif Name == NotificationDefines.PromisePlayAVGSequence then
    if not self:CheckCanPlayAvg() then
      return
    end
    self.PromisePlayAVGId = Body
    self:PlaySequence(self.PromisePlayAVGId, true)
    self:SetPageVisibility(false, true)
    ApartmentMainPage:SetChatVisibility(NotificationDefines.ChatState.Hide)
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(ApartmentMainPage, true)
  end
end
function ApartmentMainMediator:SetPageVisibility(bIsShow, bIsAvg)
  ApartmentMainPage = self:GetViewComponent()
  if not ApartmentMainPage or not ApartmentMainPage:IsValid() then
    return
  end
  local Valid = ApartmentMainPage.Button_Esc and ApartmentMainPage.Button_Esc:SetVisibility((bIsShow or bIsAvg) and UE.ESlateVisibility.Collapsed or UE.ESlateVisibility.SelfHitTestInvisible)
  Valid = ApartmentMainPage.Button_Esc and ApartmentMainPage.Button_Esc:SetIsEnabled(not bIsShow)
  Valid = ApartmentMainPage.CanvasPanel_All and ApartmentMainPage.CanvasPanel_All:SetVisibility(bIsShow and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = ApartmentMainPage.Button_Return and ApartmentMainPage.Button_Return:SetVisibility(bIsShow and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = ApartmentMainPage.Button_Return and ApartmentMainPage.Button_Return:SetIsEnabled(bIsShow)
  Valid = ApartmentMainPage.MenuPanel and ApartmentMainPage.MenuPanel:SetVisibility(bIsShow and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  if bIsShow then
    self:RoleDoPromiseIdle()
  end
end
function ApartmentMainMediator:PlayApartmentGiftFeedbackAnimation()
  local ApartmentGiftProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy)
  local RoleId = ApartmentGiftProxy:GetGiveRoleId()
  local GiveGiftId = ApartmentGiftProxy:GetGiveGiftId()
  local giftCfg = ApartmentGiftProxy:GetGiftToRoleCfg(GiveGiftId, RoleId)
  local GiftFeedbackSequenceId = StateMachineConfig.NormalGiveRoleGiftSequenceID
  if giftCfg and giftCfg.favorability and giftCfg.favorability >= ApartmentMainPage.InitmacyLimit then
    GiftFeedbackSequenceId = StateMachineConfig.SpecialGiveRoleGiftSequenceID
  end
  ApartmentGiftProxy:ClearGiftInfo()
  self:SetPageVisibility(false)
  self.IsGiftFeedbackSeq = true
  self:PlaySequence(GiftFeedbackSequenceId, true)
  ApartmentMainPage:SetIsNeedListenKey(true)
  ApartmentMainPage:SetIsCanSkipSequence(true)
end
function ApartmentMainMediator:PlayApartmentGetRewardAnimation(Data)
  if not Data then
    return
  end
  self.RewardSkip = true
  self.bIsLongGetRewardAnimation = false
  self:SetPageVisibility(false)
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if NewPlayerGuideProxy:IsShowGuideUI(NewPlayerGuideEnum.GuideStep.GiftFirstItem) then
    self:PlaySequence(StateMachineConfig.NewGuideGetRewardSequenceID, true)
    ApartmentMainPage:SetIsOnlyCheckLeftClick(true)
    ApartmentMainPage:SetIsCanSkipSequence(false)
  elseif 1 == Data.Level or Data.bIsPromiseTask then
    self.bIsLongGetRewardAnimation = true
    self:PlaySequence(StateMachineConfig.GetRewardLongSequenceID, true)
  else
    self:PlaySequence(StateMachineConfig.GetRewardSequenceID, true)
  end
end
function ApartmentMainMediator:PlayApartmentSkipGetRewardAnimation()
  if self.bIsLongGetRewardAnimation then
    self:PlaySequence(StateMachineConfig.SkipRewardLongSequenceID, true)
  else
    self:PlaySequence(StateMachineConfig.SkipRewardSequenceID, true)
  end
  self.bIsLongGetRewardAnimation = nil
  ApartmentMainPage:SetIsOnlyCheckLeftClick(true)
  ApartmentMainPage:SetIsCanSkipSequence(false)
end
function ApartmentMainMediator:BindOnSequenceStopCallBack()
  if GlobalDelegateManager and DelegateMgr then
    ApartmentMainPage:SetIsNeedListenKey(true)
    self.SequenceStopDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self, "OnSequenceStopCallBack")
  end
end
function ApartmentMainMediator:OnSequenceStopCallBack(sequenceId, reasonType)
  if not self.SequenceStopDelegate or not ApartmentMainPage then
    return
  end
  if sequenceId == StateMachineConfig.NormalGiveRoleGiftSequenceID or sequenceId == StateMachineConfig.SpecialGiveRoleGiftSequenceID then
    ApartmentMainPage:OnPlayProgressLevelAnim()
    self:SetPageVisibility(true)
    ApartmentMainPage:SetIsNeedListenKey(false)
    if self.IsGiftFeedbackSeq then
      self.IsGiftFeedbackSeq = false
      self.RoleUpdateTimer = TimerMgr:RunNextFrame(function()
        if GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):CheckContractAnimUpgrade() then
          GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):ShowContractUpgrade()
          local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
          RoleAttrMap.UpdateFunc(RoleAttrMap.EnumConditionType.IntimacyLvCond)
        end
        self.RoleUpdateTimer = nil
      end)
    end
  elseif sequenceId == StateMachineConfig.NewGuideGetRewardSequenceID or sequenceId == StateMachineConfig.SkipRewardSequenceID or sequenceId == StateMachineConfig.SkipRewardLongSequenceID then
    self.OnClickLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self, "OnClickLobbyCharacterCallBack")
    local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
    if NewPlayerGuideProxy:IsShowGuideUI(NewPlayerGuideEnum.GuideStep.GiftFirstItem) then
      local NewPlayerGuideTriggerProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideTriggerProxy)
      NewPlayerGuideTriggerProxy:ShowNextStep(0)
    end
  elseif sequenceId == StateMachineConfig.GetRewardSequenceID or sequenceId == StateMachineConfig.GetRewardLongSequenceID then
    ApartmentMainPage:SetIsCanSkipSequence(true)
    self.RewardSkip = false
    self:PlayApartmentSkipGetRewardAnimation()
  elseif sequenceId == StateMachineConfig.EndRewardSequenceID then
    self:RoleDoPromiseIdle()
  elseif sequenceId == self.PromisePlayAVGId then
    self:SetPageVisibility(true)
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(ApartmentMainPage, false)
    ApartmentMainPage:SetChatVisibility(NotificationDefines.ChatState.Show)
    GameFacade:SendNotification(NotificationDefines.RcvGetRewardSequencerFinish)
    GameFacade:SendNotification(NotificationDefines.ApartmentAvgStoryFinish, self.PromisePlayAVGId)
  end
  self:ClearSequenceStopDelegate()
end
function ApartmentMainMediator:OnAVGEventStopCallBack(EventId)
  if not self.AVGEventStopDelegate or not ApartmentMainPage then
    return
  end
  if EventId == self.PromisePlayAVGId then
    self:SetPageVisibility(true)
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(ApartmentMainPage, false)
    ApartmentMainPage:SetChatVisibility(NotificationDefines.ChatState.Show)
    GameFacade:SendNotification(NotificationDefines.RcvGetRewardSequencerFinish)
    GameFacade:SendNotification(NotificationDefines.ApartmentTurnOnBgm)
    GameFacade:SendNotification(NotificationDefines.ApartmentAvgStoryFinish, self.PromisePlayAVGId)
  end
  self:ClearAVGEventStopDelegate()
end
function ApartmentMainMediator:OnClickLobbyCharacterCallBack(ClickPartType)
  if not self.OnClickLobbyCharacterDelegate then
    return
  end
  LogDebug("ApartmentMainMediator:OnClickLobbyCharacterCallBack", "ClickPartType is : " .. ClickPartType)
  if ClickPartType == UE4.EPMApartmentWholeBodyType.None then
    return
  end
  ApartmentMainPage:SetIsCanSkipSequence(true)
  self:GetGiftCallback()
end
function ApartmentMainMediator:GetGiftCallback()
  ApartmentMainPage:SetIsOnlyCheckLeftClick(false)
  self:SetPageVisibility(true)
  self:ClearClickLobbyCharacterDelegate()
  UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):ClearCharacterAllAttachActor()
  self:PlaySequence(StateMachineConfig.EndRewardSequenceID)
  GameFacade:SendNotification(NotificationDefines.RcvGetRewardAnimationFinish)
end
function ApartmentMainMediator:ClearSequenceStopDelegate()
  if GlobalDelegateManager and DelegateMgr and self.SequenceStopDelegate then
    ApartmentMainPage:SetIsNeedListenKey(false)
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnSequenceStopGlobalDelegate, self.SequenceStopDelegate)
    self.SequenceStopDelegate = nil
  end
end
function ApartmentMainMediator:ClearAVGEventStopDelegate()
  if DelegateMgr and self.AVGEventStopDelegate then
    ApartmentMainPage:SetIsNeedListenKey(false)
    DelegateMgr:RemoveDelegate(CyAVGMgr.OnAVGEventStopDelegate, self.AVGEventStopDelegate)
    self.AVGEventStopDelegate = nil
  end
end
function ApartmentMainMediator:ClearClickLobbyCharacterDelegate()
  if GlobalDelegateManager and DelegateMgr and self.OnClickLobbyCharacterDelegate then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnClickLobbyCharacter, self.OnClickLobbyCharacterDelegate)
    self.OnClickLobbyCharacterDelegate = nil
  end
end
function ApartmentMainMediator:RoleDoPromiseIdle()
  self:PlaySequence(StateMachineConfig.IdleSequenceID)
end
function ApartmentMainMediator:SkipCurSequence()
  if not self.SequenceStopDelegate then
    return
  end
  if self.RewardSkip then
    self:ClearSequenceStopDelegate()
    self.RewardSkip = false
    self:PlayApartmentSkipGetRewardAnimation()
  else
    CySequenceMgr:GotoEndAndStop()
    self:RoleDoPromiseIdle()
  end
end
function ApartmentMainMediator:OnShowPlayerGuide(step)
end
function ApartmentMainMediator:CheckCanPlayAvg()
  local canPlay = true
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomDataProxy:GetIsInMatch() then
    canPlay = false
    local tipsMsg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Apartment, "ForbiddenAvgForMatching")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
  end
  return canPlay
end
function ApartmentMainMediator:PlaySequence(SequenceId, NeedCallBack)
  self.PlaySequenceTimer = TimerMgr:RunNextFrame(function()
    if SequenceId and CySequenceMgr then
      CySequenceMgr:PlaySequence(SequenceId)
      if NeedCallBack then
        self:BindOnSequenceStopCallBack()
      end
    end
    self.PlaySequenceTimer = nil
  end)
end
function ApartmentMainMediator:PlayAVGEvent(EventId)
  self.PlayAVGEventTimer = TimerMgr:RunNextFrame(function()
    if EventId and CyAVGMgr then
      CyAVGMgr:PlayAVGEvent(EventId)
      self.AVGEventStopDelegate = DelegateMgr and DelegateMgr:AddDelegate(CyAVGMgr.OnAVGEventStopDelegate, self, "OnAVGEventStopCallBack")
    end
    self.PlayAVGEventTimer = nil
  end)
end
return ApartmentMainMediator
