local BattlePassCluePage = class("BattlePassCluePage", PureMVC.ViewComponentPage)
local BattlePassClueMediator = require("Business/BattlePass/Mediators/BattlePassClueMediator")
local CLUE_ITME_MAX = 5
function BattlePassCluePage:ListNeededMediators()
  return {BattlePassClueMediator}
end
function BattlePassCluePage:InitializeLuaEvent()
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
function BattlePassCluePage:OnOpen(luaOpenData, nativeOpenData)
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Add(self, self.OnBtnEsc)
  end
  if self.Btn_Reward then
    self.Btn_Reward.OnClickEvent:Add(self, self.OnBtnReward)
  end
end
function BattlePassCluePage:OnShow(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.Anim_ClueIn, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function BattlePassCluePage:OnClose()
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnBtnEsc)
  end
  if self.Btn_Reward then
    self.Btn_Reward.OnClickEvent:Remove(self, self.OnBtnReward)
  end
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
function BattlePassCluePage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Esc:MonitorKeyDown(key, inputEvent)
end
function BattlePassCluePage:OnBtnEsc()
  self.switchEvent("cluePage", self.currentIndex)
end
function BattlePassCluePage:UpdateCluePage(data)
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
function BattlePassCluePage:RollTimerHandler()
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
function BattlePassCluePage:WaitTimerHandler()
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
function BattlePassCluePage:DateTimerHandler()
  local timeStr = os.date("%H : %M")
  if self.Txt_CurTime then
    self.Txt_CurTime:SetText(timeStr)
  end
end
function BattlePassCluePage:SwitchCluePage(data)
  if self.Panel_CluePage then
    self.Panel_CluePage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Panel_ClueContent then
    self.Panel_ClueContent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function BattlePassCluePage:SwitchClueContent(data)
  if self.Panel_CluePage then
    self.Panel_CluePage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Panel_ClueContent then
    self.Panel_ClueContent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if data then
    if self.Txt_ClueTitle then
      self.Txt_ClueTitle:SetText(data.title)
    end
    if self.RichTxt_ClueContent then
      self.RichTxt_ClueContent:SetText(data.content)
    end
    if self.Btn_Reward then
      self.Btn_Reward:SetButtonIsEnabled(not data.isRewardRecevied and true or false)
      self.Btn_Reward:SetRedDotVisible(not data.isRewardRecevied and true or false)
    end
    if self.WidgetSwitcher_Reward then
      self.WidgetSwitcher_Reward:SetActiveWidgetIndex(data.isRewardRecevied and 1 or 0)
    end
    if self.Img_Prize then
      self:SetImageByTexture2D(self.Img_Prize, data.prizeInfo.img)
    end
    if self.Txt_Reward then
      self.Txt_Reward:SetText(data.prizeInfo.name)
    end
  end
end
function BattlePassCluePage:OnBtnReward()
  GameFacade:SendNotification(NotificationDefines.BattlePass.ClueRewardCmd, self.currentIndex)
end
function BattlePassCluePage:ItemClick(index)
  if self.currentIndex then
    self.clueItems[self.currentIndex]:SetSelected(false)
  end
  self.currentIndex = index
  self.clueItems[self.currentIndex]:SetSelected(true)
  self.switchEvent("clueContent", index)
end
function BattlePassCluePage:UpdateRewardState(clueId)
  if self.currentIndex == clueId then
    if self.Btn_Reward then
      self.Btn_Reward:SetButtonIsEnabled(false)
      self.Btn_Reward:SetRedDotVisible(false)
    end
    if self.WidgetSwitcher_Reward then
      self.WidgetSwitcher_Reward:SetActiveWidgetIndex(1)
    end
    self.clueItems[self.currentIndex]:UpdateRewardState(false)
  end
end
function BattlePassCluePage:SeasonIntermission()
  if self.WidgetSwitcher_Season then
    self.WidgetSwitcher_Season:SetActiveWidgetIndex(1)
  end
end
return BattlePassCluePage
