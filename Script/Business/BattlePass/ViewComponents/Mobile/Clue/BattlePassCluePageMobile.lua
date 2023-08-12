local BattlePassCluePageMobile = class("BattlePassCluePageMobile", PureMVC.ViewComponentPage)
local BattlePassClueMediatorMobile = require("Business/BattlePass/Mediators/Mobile/Clue/BattlePassClueMediatorMobile")
local CLUE_ITME_MAX = 5
function BattlePassCluePageMobile:ListNeededMediators()
  return {BattlePassClueMediatorMobile}
end
function BattlePassCluePageMobile:InitializeLuaEvent()
  self.clueItems = {}
  if self.Panel_AllClues then
    for index = 1, CLUE_ITME_MAX do
      table.insert(self.clueItems, self.Panel_AllClues:GetChildAt(index - 1))
    end
  end
  self.currentIndex = 1
  self.switchEvent = LuaEvent.new()
  self.waitTime = 0
end
function BattlePassCluePageMobile:OnOpen(luaOpenData, nativeOpenData)
end
function BattlePassCluePageMobile:OnShow(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.Anim_ClueIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function BattlePassCluePageMobile:OnClose()
  if self.rollTimer then
    self.rollTimer:EndTask()
  end
  if self.waitTimer then
    self.waitTimer:EndTask()
  end
  if self.dateTimer then
    self.dateTimer:EndTask()
  end
end
function BattlePassCluePageMobile:UpdateCluePage(data)
  local maxUnlock = 1
  for index = 1, #self.clueItems do
    if data[index] then
      self.clueItems[index]:SetItemInfo(self, data[index], index == self.currentIndex and true or false)
      if data[index].isUnlock then
        maxUnlock = index
      end
    end
  end
  if data[maxUnlock] then
    if self.Txt_NewsTitle then
      self.Txt_NewsTitle:SetText(data[maxUnlock].newsTitle)
    end
    if self.Txt_NewsDetail then
      self.Txt_NewsDetail:SetText(data[maxUnlock].newsContent)
    end
  end
  if self.Txt_NewsDetail then
    self.rollTimer = TimerMgr:AddFrameTask(0, 1, 0, function()
      self:RollTimerHandler()
    end)
  end
  self.dateTimer = TimerMgr:AddTimeTask(0, 1, 0, function()
    self:DateTimerHandler()
  end)
end
function BattlePassCluePageMobile:RollTimerHandler()
  if self.Txt_NewsDetail then
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_NewsDetail)
    local txtPosition = canvasSlot:GetPosition()
    if txtPosition.X < -self.Txt_NewsDetail:GetDesiredSize().X then
      self.rollTimer:EndTask()
      self.waitTimer = TimerMgr:AddTimeTask(1, 1, 0, function()
        self:WaitTimerHandler()
      end)
    else
      local newX = txtPosition.X - self.DistancePerFrame
      canvasSlot:SetPosition(UE4.FVector2D(newX, txtPosition.Y))
    end
  end
end
function BattlePassCluePageMobile:WaitTimerHandler()
  if self.waitTime >= 3 then
    self.waitTimer:EndTask()
    self.waitTime = 0
    if self.Txt_NewsDetail then
      local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Txt_NewsDetail)
      local txtPosition = canvasSlot:GetPosition()
      local viewSize = UE4.UWidgetLayoutLibrary.GetViewportSize(LuaGetWorld())
      local viewScale = UE4.UWidgetLayoutLibrary.GetViewportScale(LuaGetWorld())
      local initX = viewSize.X / viewScale
      canvasSlot:SetPosition(UE4.FVector2D(initX, txtPosition.Y))
    end
    self.rollTimer = TimerMgr:AddFrameTask(0, 1, 0, function()
      self:RollTimerHandler()
    end)
  else
    self.waitTime = self.waitTime + 1
  end
end
function BattlePassCluePageMobile:DateTimerHandler()
  local timeStr = os.date("%H : %M")
  if self.Txt_CurTime then
    self.Txt_CurTime:SetText(timeStr)
  end
end
function BattlePassCluePageMobile:ItemClick(index)
  if self.currentIndex then
    self.clueItems[self.currentIndex]:SetSelected(false)
  end
  self.currentIndex = index
  self.clueItems[self.currentIndex]:SetSelected(true)
  self.switchEvent(index)
end
function BattlePassCluePageMobile:UpdateRewardState(clueId)
  if self.currentIndex == clueId then
    self.clueItems[self.currentIndex]:UpdateRewardState(false)
  end
end
function BattlePassCluePageMobile:SeasonIntermission()
  if self.WidgetSwitcher_Season then
    self.WidgetSwitcher_Season:SetActiveWidgetIndex(1)
  end
end
return BattlePassCluePageMobile
