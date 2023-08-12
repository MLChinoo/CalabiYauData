local BattlePassProgressPage = class("BattlePassProgressPage", PureMVC.ViewComponentPage)
local BattlePassProgressMediator = require("Business/BattlePass/Mediators/BattlePassProgressMediator")
local LEVEL_PER_PAGE = 10
function BattlePassProgressPage:ListNeededMediators()
  return {BattlePassProgressMediator}
end
function BattlePassProgressPage:InitializeLuaEvent()
  self.itemSelectEvent = LuaEvent.new()
  self.pageEvent = LuaEvent.new()
  self.isPreview = false
  self.currentPageIndex = 1
  self.MaxPageCnt = 1
  self.totalLevel = 1
  self:InitializeWidgets()
end
function BattlePassProgressPage:OnOpen(luaOpenData, nativeOpenData)
  if self.ButtonBuyLevel then
    self.ButtonBuyLevel.OnClicked:Add(self, BattlePassProgressPage.OnBtBuyLvClick)
  end
  if self.ButtonBuyBp then
    self.ButtonBuyBp.OnClickEvent:Add(self, self.OnBtBuyBpClick)
  end
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys.actionOnReturn:Add(self.OnEscHotKeyClick, self)
    self.ItemDisplayKeys.actionOnStartPreview:Add(self.EnterPreview, self)
    self.ItemDisplayKeys.actionOnStopPreview:Add(self.QuitPreview, self)
  end
  self:StartRestTimer()
end
function BattlePassProgressPage:OnShow(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.Anim_MoveOut, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
end
function BattlePassProgressPage:OnClose()
  if self.ButtonBuyLevel then
    self.ButtonBuyLevel.OnClicked:Remove(self, BattlePassProgressPage.OnBtBuyLvClick)
  end
  if self.ButtonBuyBp then
    self.ButtonBuyBp.OnClickEvent:Remove(self, self.OnBtBuyBpClick)
  end
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys.actionOnReturn:Remove(self.OnEscHotKeyClick, self)
    self.ItemDisplayKeys.actionOnStartPreview:Remove(self.EnterPreview, self)
    self.ItemDisplayKeys.actionOnStopPreview:Remove(self.QuitPreview, self)
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
  self:DestoryRestTimer()
end
function BattlePassProgressPage:InitializeWidgets()
  self.rewardWidgets = {}
  if self.HB_Reward then
    for index = 1, self.HB_Reward:GetChildrenCount() do
      local widget = self.HB_Reward:GetChildAt(index - 1)
      if widget then
        self.rewardWidgets[index] = widget
      end
    end
  end
end
function BattlePassProgressPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function BattlePassProgressPage:OnBtBuyLvClick()
  ViewMgr:OpenPage(self, UIPageNameDefine.BattlePassProgressLv)
end
function BattlePassProgressPage:OnBtBuyBpClick()
  local NavBarBodyTable = {
    pageType = UE4.EPMFunctionTypes.BattlePass,
    secondIndex = 1,
    exData = 2
  }
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
end
function BattlePassProgressPage:OnEscHotKeyClick()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function BattlePassProgressPage:EnterPreview()
  self:PlayAnimation(self.Anim_MoveOut, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function BattlePassProgressPage:QuitPreview()
  self:PlayAnimation(self.Anim_MoveOut, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
end
function BattlePassProgressPage:InitRewards(prizeData, lvData)
  self:UpdateLevel(lvData)
  self.totalLevel = #prizeData
  self.MaxPageCnt = math.floor(#prizeData / LEVEL_PER_PAGE) - 1
  self.currentPageIndex = math.min(self.MaxPageCnt, math.ceil(lvData.curLevel / LEVEL_PER_PAGE))
  self:UpdateRewards(prizeData)
  self:ScrollToView(lvData)
  self.ProgressPagination:InitView(self, self.MaxPageCnt, self.currentPageIndex, self:GetPaginationStr())
end
function BattlePassProgressPage:UpdateVipInfo(isVip)
  if self.ButtonBuyBp then
    self.ButtonBuyBp:SetVisibility(isVip and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function BattlePassProgressPage:UpdateLevel(data)
  if self.Text_Lv then
    self.Text_Lv:SetText(data.curLevel)
  end
  if self.Text_Progress then
    self.Text_Progress:SetText(data.curExp .. "/ " .. data.maxExp)
    if 1 == data.curExp and 1 == data.maxExp then
      self.Text_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.ProgressBar_Lv then
    self.ProgressBar_Lv:SetPercent(data.curExp / data.maxExp)
  end
  if self.ButtonBuyLevel and data.bIsMaxLevel then
    self.ButtonBuyLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function BattlePassProgressPage:UpdateSeasonInfo(data)
  if data then
    if self.Text_SeasonName then
      self.Text_SeasonName:SetText(data.inSeasonName)
    end
    if data.inTime and data.inTime > 0 then
      self.time = data.inTime
      if self.timerHandler then
        self.timerHandler:EndTask()
        self.timerHandler = nil
      end
      self:DrawRemainingTimeTxt()
      self.timerHandler = TimerMgr:AddTimeTask(1, 1, 0, function()
        self:RemainingTimeTxt()
      end)
    end
  end
end
function BattlePassProgressPage:UpdateDesc(data)
  local Valid = self.ItemDescWithHeadPanel and self.ItemDescWithHeadPanel:Update(data.itemId)
end
function BattlePassProgressPage:UpdateModel(itemId, itemType)
  if self.ItemDisplayKeys then
    local data = {}
    data.itemId = itemId
    data.show3DBackground = true
    self.ItemDisplayKeys:SetItemDisplayed(data)
  end
end
function BattlePassProgressPage:UpdateRewards(data)
  local startLevel = self.currentPageIndex * LEVEL_PER_PAGE - (LEVEL_PER_PAGE - 1)
  local endLevel = self.currentPageIndex == self.MaxPageCnt and #data or self.currentPageIndex * LEVEL_PER_PAGE
  local widgetIndex = 0
  for level = startLevel, endLevel do
    local rewards = data[level]
    if rewards and #rewards > 0 then
      local combineData = {}
      combineData.level = level
      combineData.data = rewards
      combineData.parentPage = self
      widgetIndex = widgetIndex + 1
      if self.rewardWidgets[widgetIndex] then
        self.rewardWidgets[widgetIndex]:GenerateCombineItem(combineData)
      end
    end
  end
  self.rewardWidgets[#self.rewardWidgets]:SetVisibility(widgetIndex == #self.rewardWidgets and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function BattlePassProgressPage:ScrollToView(data)
  local fmode = math.fmod(data.curLevel, LEVEL_PER_PAGE)
  local scrollIndex = 0 == fmode and LEVEL_PER_PAGE or fmode
  if data.curLevel > LEVEL_PER_PAGE * LEVEL_PER_PAGE then
    scrollIndex = LEVEL_PER_PAGE + 1
  end
  if self.rewardWidgets[scrollIndex] then
    self.rewardWidgets[scrollIndex]:ScrolledIntoItem()
  end
end
function BattlePassProgressPage:PaginationClick(num)
  self.currentPageIndex = math.clamp(self.currentPageIndex + num, 1, self.MaxPageCnt)
  self.pageEvent()
  self.ProgressPagination:UpdateButtonVisible(self.currentPageIndex, self.MaxPageCnt, self:GetPaginationStr())
end
function BattlePassProgressPage:OnMouseWheel(MyGeometry, MouseEvent)
  local delta = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent)
  if delta > 0 then
    if self.currentPageIndex > 1 then
      self:PaginationClick(-1)
    end
  elseif self.currentPageIndex < self.MaxPageCnt then
    self:PaginationClick(1)
  end
  return true
end
function BattlePassProgressPage:ItemSelect(item, bIsScrolled)
  if self.childItem then
    self.childItem:SetSelect(false)
  end
  self.childItem = item
  self.itemSelectEvent(item.data, bIsScrolled)
end
function BattlePassProgressPage:RemainingTimeTxt()
  if self.time <= 0 then
    return
  end
  self.time = self.time - 1
  self:DrawRemainingTimeTxt()
end
function BattlePassProgressPage:DrawRemainingTimeTxt()
  local timeTable = FunctionUtil:FormatTime(self.time)
  local outText
  if timeTable.Day > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
    local stringMap = {
      Days = timeTable.Day,
      Hours = timeTable.Hour
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  elseif timeTable.Hour > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
    local stringMap = {
      Hours = timeTable.Hour,
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  else
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Minutes")
    local stringMap = {
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  end
  if self.Text_Time then
    self.Text_Time:SetText(outText)
  end
end
function BattlePassProgressPage:SeasonIntermission()
  if self.Img_Bg then
    self.Img_Bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.WidgetSwitcher_Season then
    self.WidgetSwitcher_Season:SetActiveWidgetIndex(1)
  end
end
function BattlePassProgressPage:GetPaginationStr()
  local str = ""
  local startLevel = self.currentPageIndex * LEVEL_PER_PAGE - (LEVEL_PER_PAGE - 1)
  local endLevel = self.currentPageIndex == self.MaxPageCnt and self.totalLevel or self.currentPageIndex * LEVEL_PER_PAGE
  str = "LV." .. startLevel .. " - " .. "LV." .. endLevel
  return str
end
function BattlePassProgressPage:CalculatePage(data)
  do return end
  self.MaxPageCnt = #data - 1
  local pageList = {}
  local levelList = {}
  for index, value in ipairs(data) do
    table.insert(levelList, index)
  end
  for i = 1, #levelList, LEVEL_PER_PAGE do
    table.insert(pageList, table.pack(table.unpack(levelList, i, i + LEVEL_PER_PAGE - 1)))
  end
  if #pageList[#pageList] < LEVEL_PER_PAGE then
    table.insert(pageList[#pageList - 1], pageList[#pageList])
  end
  local t = 0
end
function BattlePassProgressPage:StartRestTimer()
  self:DestoryRestTimer()
  if self.updateTimer == nil then
    self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local intervalTime = 60
    local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    self.updateTimer = TimerMgr:AddTimeTask(0, intervalTime, 0, function()
      local bHide = BattlePassProxy:CheckHideRestTime()
      if bHide then
        self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local showTime = BattlePassProxy:GetSeasonFinishRestShowTime()
        if showTime then
          self.TextBlock_RestTime:SetText(showTime)
        else
          self.HorizontalBox_RestTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self:DestoryRestTimer()
        end
      end
    end)
  end
end
function BattlePassProgressPage:DestoryRestTimer()
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
return BattlePassProgressPage
