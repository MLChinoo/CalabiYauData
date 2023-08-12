local BallSetDisplay = class("BallSetDisplay", PureMVC.ViewComponentPage)
local BallSetDisplayMediator = require("Business/Lottery/Mediators/BallSetDisplayMediator")
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
local lotteryProxy
function BallSetDisplay:ListNeededMediators()
  return {BallSetDisplayMediator}
end
function BallSetDisplay:InitView()
  self:StopAllAnimations()
  if self.start then
    self:PlayAnimationReverse(self.start, 100, false)
  end
  if self.ballItems then
    for i = 1, self.ballItems:Length() do
      self.ballItems:Get(i):SetItemSelected(false)
      self.ballItems:Get(i):SetItemType(LotteryEnum.ballItemType.Null)
    end
  end
  self:CloseBallSetScreen()
  if self.WS_Tip then
    self.WS_Tip:SetActiveWidgetIndex(0)
  end
  if self.WS_PlaceComplete then
    self.WS_PlaceComplete:SetActiveWidgetIndex(0)
  end
  if self.Text_NumSet and self.ballItems then
    self.Text_NumSet:SetText(0 .. " / " .. self.ballItems:Length())
  end
  self.bCanDisplay = false
  self.ballItemSelected = 0
  self.itemDisplayCnt = 0
  self.bCanPlaySound = false
  self.bIsFull = false
  if self.autoProcessTask then
    self.autoProcessTask:EndTask()
    self.autoProcessTask = nil
  end
end
function BallSetDisplay:InitOperationDesk()
  if self.chuxian then
    self:PlayWidgetAnimationWithCallBack("chuxian", {
      self,
      self.EnableDisplayInput
    })
  end
  self:SelectFirstItem()
  self.bCanPlaySound = true
end
function BallSetDisplay:EnableDisplayInput()
  if lotteryProxy:GetIsInLottery() then
    self.bCanDisplay = true
    lotteryProxy:EnableOperationDesk(true)
  end
end
function BallSetDisplay:SetEnableInput(bEnabled)
  self:SetVisibility(bEnabled and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.HitTestInvisible)
end
function BallSetDisplay:QuickPlay()
  LogDebug("BallSetDisplay", "Quick play ball")
  if self.bCanDisplay == false then
    LogDebug("BallSetDisplay", "Quick play ball failed")
    return
  end
  if self.ballItemSelected <= self.itemDisplayCnt then
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(false)
    self.ballItemSelected = self.itemDisplayCnt + 1
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(true)
  end
  local maxCount = lotteryProxy:GetMaxCount()
  if self.autoProcessTask then
    self.autoProcessTask:EndTask()
  end
  for i = 1, self.itemDisplayCnt do
    self:SetItemType(i)
  end
  self.autoProcessTask = TimerMgr:AddTimeTask(0.05, 0.05, maxCount - self.ballItemSelected + 1, function()
    self:SetItemType(self.ballItemSelected)
    self:ChangeDisplayProp(self.ballItemSelected)
  end)
end
function BallSetDisplay:Clear()
  if self.ballItemSelected < self.itemDisplayCnt then
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(false)
    self.ballItemSelected = self.itemDisplayCnt
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(true)
  end
  if self.autoProcessTask then
    self.autoProcessTask:EndTask()
  end
  self.autoProcessTask = TimerMgr:AddTimeTask(0, 0.05, self.ballItemSelected, function()
    self:ClearBallTask()
  end)
end
function BallSetDisplay:ClearBallTask()
  self:SetItemType(self.ballItemSelected)
  local existNum = table.count(lotteryProxy:GetLotteryBallSet())
  if self.ballItemSelected > existNum + 1 then
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(false)
    self.ballItemSelected = self.ballItemSelected - 1
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(true)
    self.itemDisplayCnt = self.ballItemSelected
  else
    if self.autoProcessTask then
      self.autoProcessTask:EndTask()
    end
    self.itemDisplayCnt = existNum
    for i = 1, self.itemDisplayCnt do
      self:SetItemType(i)
    end
    self:SetActiveItem(self.ballItemSelected)
  end
end
function BallSetDisplay:StartLotteryProcess()
  lotteryProxy:SetLotteryStatus(UE4.ELotteryState.GatherEnergy)
  self:CloseBallSetScreen()
end
function BallSetDisplay:InitializeLuaEvent()
  self.actionOnSetActiveItem = LuaEvent.new()
end
function BallSetDisplay:Construct()
  BallSetDisplay.super.Construct(self)
  lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  if self.BallArray then
    self.ballItems = self.BallArray:GetAllChildren()
    for i = 1, self.ballItems:Length() do
      local ballItem = self.ballItems:Get(i)
      ballItem:SetItemIndex(i)
      ballItem:SetItemSelected(false)
      ballItem.actionOnSelectBallItem:Add(self.SelectBallItem, self)
      ballItem.actionOnSetItemTypeFinished:Add(self.SetBallItemFinish, self)
    end
  end
  if self.ballItems == nil or self.ballItems:Length() ~= lotteryProxy:GetMaxCount() then
    LogErrorP("BallSetDisplay", "Ball items number is wrong")
  end
end
function BallSetDisplay:Destrcut()
  if self.autoProcessTask then
    self.autoProcessTask:EndTask()
    self.autoProcessTask = nil
  end
end
function BallSetDisplay:SelectFirstItem()
  if self.ballItems:Length() > 0 then
    self.ballItems:Get(1):SetItemSelected(true)
    self.ballItemSelected = 1
    self:SetActiveItem(1)
  end
end
function BallSetDisplay:SetActiveItem(index)
  self.actionOnSetActiveItem(index)
end
function BallSetDisplay:SetBallType(itemIndex)
  LogDebug("BallSetDisplay", "Set Ball:%d", itemIndex)
  if self.bCanDisplay == false or itemIndex and itemIndex ~= self.ballItemSelected then
    LogDebug("BallSetDisplay", "Set Ball Type failed")
    return
  end
  self:SetItemType(itemIndex)
  self:ChangeDisplayProp(itemIndex)
  self:SetActiveItem(self.ballItemSelected)
end
function BallSetDisplay:SetItemType(itemIndex)
  local lastBallType = LotteryEnum.ballItemType.Null
  local curLotteryBallSet = lotteryProxy:GetLotteryBallSet()
  local itemType = curLotteryBallSet[itemIndex]
  if nil == itemType then
    self.ballItems:Get(itemIndex):SetItemType(lastBallType, lastBallType)
    lotteryProxy:SetLotteryBallSwitcherIndex(itemIndex, self.ballItems:Get(itemIndex):GetActiveWidgetIndex())
    if self.Text_NumSet then
      self.Text_NumSet:SetText(0 .. " / " .. self.ballItems:Length())
    end
    self:SwitchSetDisplay(false)
    return
  end
  if itemIndex > 1 then
    lastBallType = curLotteryBallSet[itemIndex - 1]
  end
  self.ballItems:Get(itemIndex):SetItemType(itemType, lastBallType)
  lotteryProxy:SetLotteryBallSwitcherIndex(itemIndex, self.ballItems:Get(itemIndex):GetActiveWidgetIndex())
end
function BallSetDisplay:ChangeDisplayProp(modifyIndex)
  if modifyIndex > self.itemDisplayCnt then
    self.itemDisplayCnt = modifyIndex
  end
  if self.itemDisplayCnt < lotteryProxy:GetMaxCount() then
    self.ballItems:Get(modifyIndex):SetItemSelected(false)
    self.ballItemSelected = self.itemDisplayCnt + 1
    self.ballItems:Get(self.ballItemSelected):SetItemSelected(true)
  else
    self.ballItems:Get(modifyIndex):SetItemSelected(false)
  end
  if self.Text_NumSet then
    self.Text_NumSet:SetText(self.itemDisplayCnt .. " / " .. self.ballItems:Length())
  end
  self:SwitchSetDisplay(self.itemDisplayCnt == self.ballItems:Length())
end
function BallSetDisplay:SelectBallItem(itemIndex)
  if self.ballItemSelected > 0 and itemIndex <= self.itemDisplayCnt then
    self:SetItemType(itemIndex)
    self:ChangeDisplayProp(itemIndex)
  end
end
function BallSetDisplay:SetBallItemFinish(itemIndex)
  local curLotteryBallSet = lotteryProxy:GetLotteryBallSet()
  if itemIndex < self.itemDisplayCnt then
    self.ballItems:Get(itemIndex + 1):SetItemType(curLotteryBallSet[itemIndex + 1], curLotteryBallSet[itemIndex])
  end
end
function BallSetDisplay:SwitchSetDisplay(bIsFull)
  if bIsFull then
    if self.WS_Tip then
      self.WS_Tip:SetActiveWidgetIndex(1)
    end
    if self.WS_PlaceComplete then
      self.WS_PlaceComplete:SetActiveWidgetIndex(1)
    end
    if self.zibianhuan then
      self:PlayWidgetAnimationWithCallBack("zibianhuan", {
        self,
        function()
          if self.zibianhuanhouxu then
            self:PlayAnimation(self.zibianhuanhouxu, 0, 0)
          end
          if self.guangbiao then
            self:PlayAnimation(self.guangbiao, 0, 0)
          end
        end
      })
    end
    if self.ActivateSound and self.bCanPlaySound and not self.bIsFull then
      if self.DeactivateSound then
        self:K2_StopAkEvent(self.DeactivateSound)
      end
      self:K2_PostAkEvent(self.ActivateSound)
      if self.start then
        self:PlayAnimation(self.start)
      end
    end
  else
    if self.WS_Tip then
      self.WS_Tip:SetActiveWidgetIndex(0)
    end
    if self.WS_PlaceComplete then
      self.WS_PlaceComplete:SetActiveWidgetIndex(0)
    end
    self:StopAllAnimations()
    if self.DeactivateSound and self.bCanPlaySound and self.bIsFull then
      if self.ActivateSound then
        self:K2_StopAkEvent(self.ActivateSound)
      end
      self:K2_PostAkEvent(self.DeactivateSound)
    end
    if self.start then
      self:PlayAnimationReverse(self.start, 100)
    end
  end
  self.bIsFull = bIsFull
end
function BallSetDisplay:CloseBallSetScreen()
  if self.ActivateSound then
    self:K2_StopAkEvent(self.ActivateSound)
  end
  if self.DeactivateSound then
    self:K2_StopAkEvent(self.DeactivateSound)
  end
end
return BallSetDisplay
