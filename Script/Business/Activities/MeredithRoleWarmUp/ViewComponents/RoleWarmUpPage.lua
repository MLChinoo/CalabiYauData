local RoleWarmUpPageMediator = require("Business/Activities/MeredithRoleWarmUp/Mediators/RoleWarmUpPageMediator")
local RoleWarmUpPage = class("RoleWarmUpPage", PureMVC.ViewComponentPage)
local RoleWarmUpProxy
function RoleWarmUpPage:ListNeededMediators()
  return {RoleWarmUpPageMediator}
end
function RoleWarmUpPage:InitializeLuaEvent()
end
function RoleWarmUpPage:OnOpen(luaOpenData, nativeOpenData)
  RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:ReqRoleWarmUpGetData(RoleWarmUpProxy:GetActivityId())
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.EntryMainPage, 0)
  end
  UE4.UPMLuaAudioBlueprintLibrary.PostEvent(UE4.UPMLuaAudioBlueprintLibrary.GetID(self.OpenMainAudio))
  self.Herotouchactnum = 0
  self.PhaseDesPageIndex = 1
  self.PhaseDesPageText = ""
  self.PhaseDesPageTB = {}
  self:PlayWidgetAnimation("Meredith_Open")
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickCloseBtn)
  self.Button_GetRole.OnClicked:Add(self, self.OnClickGetRoleBtn)
  self.CallRoleBtn.OnClicked:Add(self, self.OnClickCallRoleBtn)
  self.CheckClueBtn.OnClicked:Add(self, self.OnClickCheckClueBtn)
  self.ExchangeBtn.OnClicked:Add(self, self.OnClickExchangeBtn)
  self.ExplainBtn.OnClicked:Add(self, self.OnClickExplainBtn)
  self.RoleBtnLight.OnClicked:Add(self, self.OnClickRoleBtnLight)
  for index = 1, 5 do
    self["PhaseBtn_" .. index].Button.OnClicked:Add(self, function()
      self:OnClickPhaseBtn(index)
    end)
    self["PhaseBtn_" .. index].Button.OnHovered:Add(self, function()
      self:OnHoveredPhaseBtn(index)
    end)
    self["PhaseBtn_" .. index].Button.OnUnhovered:Add(self, function()
      self:OnUnhoveredPhaseBtn(index)
    end)
    self["PhaseBtn_" .. index].WidgetSwitcher_Numb:SetActiveWidgetIndex(index - 1)
  end
  self.FlyTargetPos = UE4.FVector2D(self.WidgetSwitcher_Progress.Slot:GetPosition().X + 360.0, self.WidgetSwitcher_Progress.Slot:GetPosition().Y)
end
function RoleWarmUpPage:OnClickGetRoleBtn()
  self.Button_Role:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetSwitcher_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayWidgetAnimationWithCallBack("Button_Role_Light", {
    self,
    self.OnGetRolePlayAnimComplete
  })
  local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  if NoticeSubSys then
    NoticeSubSys:SetPageNameIsTouch("GetRolePlayAnimComplete", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
  end
  RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.ClickGetRoleBtn, 0)
end
function RoleWarmUpPage:OnGetRoleSuccess()
  if RoleWarmUpProxy then
    RoleWarmUpProxy:ReqRoleWarmUpGetData(RoleWarmUpProxy:GetActivityId())
  end
end
function RoleWarmUpPage:OnGetRolePlayAnimComplete()
  if RoleWarmUpProxy then
    RoleWarmUpProxy:ReqRoleWarmUpRoleAward(RoleWarmUpProxy:GetActivityId())
  end
end
function RoleWarmUpPage:OnClickCallRoleBtn()
  if RoleWarmUpProxy then
    if RoleWarmUpProxy:HasAwardPhaseNotReceive() then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "阶段奖励未领取完，请先领取奖励")
      return
    else
      local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
      if NoticeSubSys then
        NoticeSubSys:SetPageNameIsTouch("CallRolePlayAnimComplete", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
      end
      RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.ClickCallRoleBtn, 0)
      self.Button_Role:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayWidgetAnimationWithCallBack("Button_Role_SHadow", {
        self,
        self.OnPlayCallRoleAnimSuccess
      })
      self.WidgetSwitcher_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
      local ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
      if ActivitiesProxy then
        if RoleWarmUpProxy:HasRoleNotReceive() then
          ActivitiesProxy:SetRedNumByActivityID(RoleWarmUpProxy:GetActivityId(), 1)
        else
          ActivitiesProxy:SetRedNumByActivityID(RoleWarmUpProxy:GetActivityId(), 0)
        end
      end
    end
  end
end
function RoleWarmUpPage:OnPlayCallRoleAnimSuccess()
  self:InitState()
  self.Button_Role:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RoleBtnLight:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.RoleImageSHadow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetSwitcher_Progress:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function RoleWarmUpPage:OnClickRoleBtnLight()
  LogDebug("RoleWarmUpPage", "OnClickRoleBtnLight")
  if RoleWarmUpProxy then
    if 1 == self.PhaseDesPageIndex and self.PhaseDesPageText == "" then
      self.PhaseDesPageTB = RoleWarmUpProxy:GetPhaseDesPage()
      self.PhaseDesPageTB = FunctionUtil:randomTable(self.PhaseDesPageTB)
      while FunctionUtil:RemoveByValue(self.PhaseDesPageTB, "") do
      end
    elseif 1 == self.PhaseDesPageIndex and self.PhaseDesPageText ~= "" then
      self.PhaseDesPageTB = RoleWarmUpProxy:GetPhaseDesPage()
      self.PhaseDesPageTB = FunctionUtil:randomTable(self.PhaseDesPageTB)
      while FunctionUtil:RemoveByValue(self.PhaseDesPageTB, "") do
      end
      FunctionUtil:RemoveByValue(self.PhaseDesPageTB, self.PhaseDesPageText)
    end
    self.PhaseDesPageText = self.PhaseDesPageTB[self.PhaseDesPageIndex]
    self.TalkText:SetText(self.PhaseDesPageText)
    if self.TalkTimer then
      self.TalkTimer:EndTask()
      self.TalkTimer = nil
    end
    if self.TalkRoot:GetVisibility() == UE4.ESlateVisibility.Collapsed then
      self.Herotouchactnum = self.Herotouchactnum + 1
      self.TalkRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PhaseDesPageIndex = self.PhaseDesPageIndex + 1
      if self.PhaseDesPageIndex > #self.PhaseDesPageTB then
        self.PhaseDesPageIndex = 1
      end
      self.TalkTimer = TimerMgr:AddTimeTask(3, 0, 1, function()
        self.TalkRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end)
    else
      self.TalkRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function RoleWarmUpPage:InitState()
  if RoleWarmUpProxy then
    if RoleWarmUpProxy:GetIsReceiveRole() then
      self.Button_Role:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.RoleBtnLight:SetVisibility(UE4.ESlateVisibility.Visible)
      self.RoleImageSHadow:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.WidgetSwitcher_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ExchangeRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if RoleWarmUpProxy:HasConvertible() then
        self.ExchangeRedDot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.ExchangeRedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.WidgetSwitcher_Progress:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ExchangeRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
      local IsEnergyComplete = RoleWarmUpProxy:GetIsEnergyComplete()
      if IsEnergyComplete then
        local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
        local IsCallRole = NoticeSubSys:GetIsTouchByName("CallRolePlayAnimComplete", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
        if IsCallRole then
          self.Button_Role:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.RoleBtnLight:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.RoleImageSHadow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.WidgetSwitcher_Progress:SetActiveWidgetIndex(1)
          self.CallRoleBtn:SetVisibility(UE4.ESlateVisibility.Visible)
          local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
          local isFreedRole = servertime > RoleWarmUpProxy.FreedTime
          if isFreedRole then
            self.WidgetSwitcher_Progress_1:SetActiveWidgetIndex(1)
            self:PlayWidgetAnimation("Get_Chracter")
            local IsGetRolePlayAnimComplete = NoticeSubSys:GetIsTouchByName("GetRolePlayAnimComplete", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
            if IsGetRolePlayAnimComplete then
              self.WidgetSwitcher_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
              self:OnGetRolePlayAnimComplete()
            end
          else
            self.WidgetSwitcher_Progress_1:SetActiveWidgetIndex(0)
            self:PlayWidgetAnimation("Get_Chracter")
            if self.updateFreedTimer == nil then
              self.updateFreedTimer = TimerMgr:AddTimeTask(0, 1, 0, function()
                local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
                local countDownTime = RoleWarmUpProxy.FreedTime - servertime
                if countDownTime >= 0 then
                  local countDownTimeText = RoleWarmUpProxy:GetCountDownTimeText(countDownTime)
                  if self.FreedCountDownText then
                    self.FreedCountDownText:SetText(countDownTimeText)
                  end
                else
                  self.WidgetSwitcher_Progress_1:SetActiveWidgetIndex(1)
                end
              end)
            end
          end
        else
          self.Button_Role:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.RoleBtnLight:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.RoleImageSHadow:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.WidgetSwitcher_Progress:SetActiveWidgetIndex(0)
          self.ProgressRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.CallRoleBtn:SetVisibility(UE4.ESlateVisibility.Visible)
        end
      else
        self.ProgressRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.CallRoleBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.WidgetSwitcher_Progress:SetActiveWidgetIndex(0)
      end
    end
  end
end
function RoleWarmUpPage:OnClickCheckClueBtn()
  UE4.UPMLuaAudioBlueprintLibrary.PostEvent(UE4.UPMLuaAudioBlueprintLibrary.GetID(self.OpenPageAudio))
  ViewMgr:OpenPage(self, UIPageNameDefine.RoleWarmUpClewPage)
end
function RoleWarmUpPage:OnClickExchangeBtn()
  UE4.UPMLuaAudioBlueprintLibrary.PostEvent(UE4.UPMLuaAudioBlueprintLibrary.GetID(self.OpenPageAudio))
  ViewMgr:OpenPage(self, UIPageNameDefine.RoleWarmUpExchangeRewardPage)
end
function RoleWarmUpPage:OnClickExplainBtn()
  UE4.UPMLuaAudioBlueprintLibrary.PostEvent(UE4.UPMLuaAudioBlueprintLibrary.GetID(self.OpenPageAudio))
  ViewMgr:OpenPage(self, UIPageNameDefine.RoleWarmUpRulesPage)
end
function RoleWarmUpPage:OnClickPhaseBtn(index)
  LogDebug("OnClickPhaseBtn", "index = " .. tostring(index))
  if RoleWarmUpProxy then
    local IsTake = RoleWarmUpProxy:GetAwardPhaseIsTakeByID(index)
    local PhaseIndex = RoleWarmUpProxy:GetPhaseIndex()
    if false == IsTake and index < PhaseIndex then
      self["PhaseBtn_" .. index].WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self["PhaseBtn_" .. index].WidgetSwitcher_State:SetActiveWidgetIndex(0)
      self["PhaseBtn_" .. index].FX_PS_Meredith_Button_01:SetReactivate(true)
      RoleWarmUpProxy:ReqRoleWarmUpPhaseAward(RoleWarmUpProxy:GetActivityId(), index)
    end
  end
end
function RoleWarmUpPage:OnHoveredPhaseBtn(index)
  LogDebug("OnHoveredPhaseBtn", "index = " .. tostring(index))
  self["PhaseReward_" .. index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function RoleWarmUpPage:OnUnhoveredPhaseBtn(index)
  LogDebug("OnUnhoveredPhaseBtn", "index = " .. tostring(index))
  self["PhaseReward_" .. index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RoleWarmUpPage:OnClose()
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickCloseBtn)
  self.Button_GetRole.OnClicked:Remove(self, self.OnClickGetRoleBtn)
  self.CallRoleBtn.OnClicked:Remove(self, self.OnClickCallRoleBtn)
  self.CheckClueBtn.OnClicked:Remove(self, self.OnClickCheckClueBtn)
  self.ExchangeBtn.OnClicked:Remove(self, self.OnClickExchangeBtn)
  self.ExplainBtn.OnClicked:Remove(self, self.OnClickExplainBtn)
  self.RoleBtnLight.OnClicked:Remove(self, self.OnClickRoleBtnLight)
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
  if self.updateFreedTimer then
    self.updateFreedTimer:EndTask()
    self.updateFreedTimer = nil
  end
  if self.TalkTimer then
    self.TalkTimer:EndTask()
    self.TalkTimer = nil
  end
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.QuitMainPage, self.Herotouchactnum)
  end
end
function RoleWarmUpPage:InitUI()
  self:InitState()
  self:UpdataCurrentEnergy()
  self:UpdataTaskItemList()
  self:UpdataPhaseBtnItemList()
  self:UpdataPhaseAwardItemList()
  self:UpdataPhaseProgressList()
  self:UpdataPyramidItem()
  self:UpdataHeadText()
  self:UpdataCountDownText()
end
function RoleWarmUpPage:UpdataTaskItemList()
  if RoleWarmUpProxy then
    local TaskIdList = RoleWarmUpProxy:GetTaskIdList()
    for key, value in pairs(TaskIdList) do
      LogDebug("RoleWarmUpPage", "TaskId = " .. tostring(value))
      self["TaskItem_" .. key]:InitTaskItem(value)
    end
    self.DetailRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function RoleWarmUpPage:UpdataCurrentEnergy()
  if RoleWarmUpProxy then
    local CurrentEnerg = RoleWarmUpProxy:GetCurrentEnergy()
    LogDebug("RoleWarmUpPage", "CurrentEnerg = " .. tostring(CurrentEnerg))
  end
end
function RoleWarmUpPage:UpdataPhaseBtnItemList()
  if RoleWarmUpProxy then
    local PhaseIndex = RoleWarmUpProxy:GetPhaseIndex()
    for index = 1, 5 do
      if index >= PhaseIndex then
        self["PhaseBtn_" .. index].WidgetSwitcher_BtnImage:SetActiveWidgetIndex(1)
        self["PhaseBtn_" .. index].WidgetSwitcher_Arrow:SetActiveWidgetIndex(1)
      else
        self["PhaseBtn_" .. index].WidgetSwitcher_BtnImage:SetActiveWidgetIndex(0)
        self["PhaseBtn_" .. index].WidgetSwitcher_Arrow:SetActiveWidgetIndex(0)
      end
      local IsTake = RoleWarmUpProxy:GetAwardPhaseIsTakeByID(index)
      if false == IsTake and index < PhaseIndex then
        self["PhaseBtn_" .. index].WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self["PhaseBtn_" .. index].WidgetSwitcher_State:SetActiveWidgetIndex(1)
        self["PhaseBtn_" .. index].FX_PS_Meredith_Button_01:SetReactivate(true)
      else
        self["PhaseBtn_" .. index].WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self["PhaseBtn_" .. index].RotateArrowRoot:SetRenderTransformAngle((index - 1) * 45)
    end
  end
end
function RoleWarmUpPage:UpdataPhaseAwardItemList()
  if RoleWarmUpProxy then
    local AwardTb = RoleWarmUpProxy:GetPhaseAwardTb()
    for index = 1, 5 do
      self["RewardItem_" .. index]:UpdataRewardItem(AwardTb[index])
    end
  end
end
function RoleWarmUpPage:UpdataPhaseProgressList()
  if RoleWarmUpProxy then
    local EnergySum = RoleWarmUpProxy:GetEnergySum()
    local CurrentEnergy = RoleWarmUpProxy:GetCurrentEnergy()
    if EnergySum > CurrentEnergy then
      self.ChargePercentageText:SetText(math.floor(CurrentEnergy * 100 / EnergySum))
    else
      self.ChargePercentageText:SetText("100")
    end
    self.TotalChargeText:SetText(CurrentEnergy)
    self.ClueIndexText:SetText(RoleWarmUpProxy:GetCurrentPhaseDescIndex())
    local IsEnergyComplete = RoleWarmUpProxy:GetIsEnergyComplete()
    if IsEnergyComplete then
      for index = 1, 6 do
        self["PhaseProgressBar_" .. index]:SetPercent(1)
      end
      self.ProgressRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CallRoleBtn:SetVisibility(UE4.ESlateVisibility.Visible)
      return
    end
    self.ProgressRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CallRoleBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local PhaseIndex = RoleWarmUpProxy:GetPhaseIndex()
    for index = 1, 5 do
      if index < PhaseIndex then
        self["PhaseProgressBar_" .. index]:SetPercent(1)
      elseif index == PhaseIndex then
        local MilestonePhases = RoleWarmUpProxy:GetMilestonePhases()
        if 1 == PhaseIndex then
          self["PhaseProgressBar_" .. index]:SetPercent(CurrentEnergy / MilestonePhases[1])
        else
          local ratio = (CurrentEnergy - MilestonePhases[PhaseIndex - 1]) / (MilestonePhases[PhaseIndex] - MilestonePhases[PhaseIndex - 1])
          self["PhaseProgressBar_" .. index]:SetPercent(ratio)
        end
      else
        self["PhaseProgressBar_" .. index]:SetPercent(0)
      end
    end
  end
end
function RoleWarmUpPage:UpdataPyramidItem()
  local PhaseIndex = RoleWarmUpProxy:GetPhaseIndex()
  if 1 == PhaseIndex or 2 == PhaseIndex then
    self.PyramidItem:PlayPyramidAnimation(1)
  elseif 3 == PhaseIndex or 4 == PhaseIndex then
    self.PyramidItem:PlayPyramidAnimation(2)
  else
    self.PyramidItem:PlayPyramidAnimation(3)
  end
end
function RoleWarmUpPage:UpdataCountDownText()
  local activitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if activitiesProxy then
    local activityInfo = activitiesProxy:GetActivityById(RoleWarmUpProxy:GetActivityId())
    if activityInfo then
      local countDownTimeTextPre = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "countDownTimeTextPre")
      LogDebug("RoleWarmUpGoodsPanel", "activityInfo.cfg.expire_time = " .. tostring(activityInfo.cfg.expire_time))
      if self.updateTimer == nil then
        self.updateTimer = TimerMgr:AddTimeTask(0, 1, 0, function()
          local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
          local countDownTime = activityInfo.cfg.expire_time - servertime
          if countDownTime >= 0 then
            local countDownTimeText = countDownTimeTextPre .. RoleWarmUpProxy:GetCountDownTimeText(countDownTime)
            if self.ActivityEndCountDownText then
              self.ActivityEndCountDownText:SetText(countDownTimeText)
            end
          else
            ViewMgr:ClosePage(self)
            ViewMgr:ClosePage(self, UIPageNameDefine.ActivityEntryListPage)
          end
        end)
      end
    end
  end
end
function RoleWarmUpPage:UpdataHeadText()
end
function RoleWarmUpPage:OnClickCloseBtn()
  LogDebug("RoleWarmUpPage", "OnClickCloseBtn")
  ViewMgr:ClosePage(self)
end
function RoleWarmUpPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickCloseBtn()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
function RoleWarmUpPage:CreateActiveFlyEffect(Slot, AbsolutePos)
  local Geometry = self.CanvasPanelRoot:GetCachedGeometry()
  local LocalPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Geometry, AbsolutePos)
  local FlyEffectClass = ObjectUtil:LoadClass(self.FlyEffectClass)
  local FlyEffect = UE4.UWidgetBlueprintLibrary.Create(self, FlyEffectClass)
  self.CanvasPanelRoot:AddChildToCanvas(FlyEffect)
  if not self.FlyEffects then
    self.FlyEffects = {}
  end
  self.FlyEffects[Slot] = FlyEffect
  self.FlyEffects[Slot].Slot:SetZOrder(100)
  self.FlyEffects[Slot].Slot:SetSize(UE4.FVector2D(0, 0))
  self.FlyEffects[Slot].Slot:SetPosition(LocalPos)
end
function RoleWarmUpPage:DestroyActiveFlyEffect(Slot)
  if self.FlyEffects then
    if self.FlyEffects[Slot] then
      self.FlyEffects[Slot]:RemoveFromViewport()
    end
    self.FlyEffects[Slot] = nil
  end
end
local FlySpeed = 2000
function RoleWarmUpPage:Tick(MyGeometry, InDeltaTime)
  if not self.FlyEffects then
    return
  end
  for Slot, Effect in pairs(self.FlyEffects) do
    if Effect then
      local NewPos = UE4.UKismetMathLibrary.Vector2DInterpTo_Constant(Effect.Slot:GetPosition(), self.FlyTargetPos, InDeltaTime, FlySpeed)
      Effect.Slot:SetPosition(NewPos)
      if UE4.UKismetMathLibrary.EqualEqual_Vector2DVector2D(NewPos, self.FlyTargetPos, 0) then
        self:DestroyActiveFlyEffect(Slot)
        self:PlayWidgetAnimation("PyramidItem_Active")
        UE4.UPMLuaAudioBlueprintLibrary.PostEvent(UE4.UPMLuaAudioBlueprintLibrary.GetID(self.EnergyChargeAudio))
      end
    end
  end
end
function RoleWarmUpPage:TakeTaskAwardSuccess(TaskId)
  local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  if NoticeSubSys then
    local IsCallRole = NoticeSubSys:GetIsTouchByName("CallRolePlayAnimComplete", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
    if IsCallRole then
      return
    end
  end
  if RoleWarmUpProxy then
    local TaskIdList = RoleWarmUpProxy:GetTaskIdList()
    for key, value in pairs(TaskIdList) do
      if TaskId == value then
        local LocalPos = self["TaskItem_" .. key].ReceiveBtn.Slot:GetPosition()
        local Geometry = self["TaskItem_" .. key].ReceiveBtn:GetCachedGeometry()
        local AbsolutePos = UE4.USlateBlueprintLibrary.LocalToAbsolute(Geometry, LocalPos)
        LogDebug("TakeTaskAwardSuccess", "AbsolutePos  = " .. tostring(AbsolutePos))
        LogDebug("TakeTaskAwardSuccess", "TaskId  = " .. tostring(TaskId))
        self:CreateActiveFlyEffect(key, AbsolutePos)
      end
    end
  end
end
return RoleWarmUpPage
