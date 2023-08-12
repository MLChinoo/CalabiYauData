local CinematicCloisterPage = class("CinematicCloisterPage", PureMVC.ViewComponentPage)
local CinematicCloisterMediator = require("Business/BattlePass/Mediators/CinematicCloisterMediator")
function CinematicCloisterPage:ListNeededMediators()
  return {CinematicCloisterMediator}
end
function CinematicCloisterPage:InitializeLuaEvent()
  self.onPageOpened = LuaEvent.new()
  self.onItemSelected = LuaEvent.new()
  self.onFadeInCompleted = LuaEvent.new()
  self.cinematicSeasonMap = {}
  self.cinematicItemList = {}
  self.selectedIndex = 0
end
function CinematicCloisterPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("CinematicCloisterPage", "Lua implement OnOpen")
  self.onPageOpened()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
end
function CinematicCloisterPage:OnClose()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
  for k, v in ipairs(self.cinematicItemList) do
    v.OnItemSelectedEvent:Remove(self.OnCinematicCloisterItemSelected, self)
  end
  self.cinematicItemList = nil
  self.cinematicSeasonMap = nil
  self.CloisterPanel:ClearChildren()
  self.selectedIndex = nil
  self:ClearTimer()
end
function CinematicCloisterPage:UpdateDatas(data)
  for index, value in ipairs(data) do
    self:AddCinematicCloisterItem(index, value)
  end
  self:StartFadeInAni()
end
function CinematicCloisterPage:AddSeasonPanel(seasonId, seasonTitle)
  if self.CloisterPanel and self.CinematicCloisterPanelClass then
    local panelClass = ObjectUtil:LoadClass(self.CinematicCloisterPanelClass)
    if panelClass then
      local CinematicCloisterPanelIns = UE4.UWidgetBlueprintLibrary.Create(self, panelClass)
      self.CloisterPanel:AddChild(CinematicCloisterPanelIns)
      CinematicCloisterPanelIns:SetSeasonInfo(seasonId, seasonTitle)
      return CinematicCloisterPanelIns
    else
      LogDebug("CinematicCloisterPage:AddSeasonPanel", "CinematicCloisterSeasonPanel class load failed")
    end
  end
end
function CinematicCloisterPage:AddCinematicCloisterItem(index, data)
  if self.cinematicSeasonMap[data.SeasonId] == nil then
    local seasonPanel = self:AddSeasonPanel(data.SeasonId, data.SeasonTitle)
    self.cinematicSeasonMap[data.SeasonId] = seasonPanel
  end
  if self.cinematicSeasonMap[data.SeasonId] then
    local cloisterItem = self.cinematicSeasonMap[data.SeasonId]:AddCinematicCloisterItem(index, data)
    cloisterItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    cloisterItem.OnItemSelectedEvent:Add(self.OnCinematicCloisterItemSelected, self)
    table.insert(self.cinematicItemList, cloisterItem)
  end
end
function CinematicCloisterPage:UpdateCinematicCloisterItemSelectedState(index)
  local lastItem = self.cinematicItemList[self.selectedIndex]
  if lastItem then
    lastItem:UpdateSelectedState(false)
  end
  self.selectedIndex = index
  local currentItem = self.cinematicItemList[self.selectedIndex]
  if currentItem then
    currentItem:UpdateSelectedState(true)
  end
end
function CinematicCloisterPage:OnCinematicCloisterItemSelected(index, ChapterId)
  self:UpdateCinematicCloisterItemSelectedState(index)
  self.onItemSelected(index, ChapterId)
end
function CinematicCloisterPage:OnCinematicCloisterItemCompleted(sequenceId)
  if self.cinematicItemList then
    for k, v in ipairs(self.cinematicItemList) do
      if v.sequenceId == sequenceId then
        v:UpdateCompletedState(true)
      end
    end
  end
end
function CinematicCloisterPage:StartFadeInAni()
  self:ClearTimer()
  self.FadeInTimerList = {}
  if self.cinematicItemList then
    for k, v in ipairs(self.cinematicItemList) do
      if self.FadeInTime and self.FadeInTime > 0.0 then
        local FadeInTimer = TimerMgr:AddTimeTask(self.FadeInTime * (k - 1), 0, 1, function()
          v:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          v:PlayFadeInAni()
        end)
        table.insert(self.FadeInTimerList, FadeInTimer)
      else
        v:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        v:PlayFadeInAni()
      end
    end
    self.FadeCompletedTimer = TimerMgr:AddTimeTask(self.FadeInTime * #self.cinematicItemList, 0, 1, function()
      self.onFadeInCompleted()
    end)
  end
end
function CinematicCloisterPage:ClearTimer()
  if self.FadeInTimerList then
    for k, v in ipairs(self.FadeInTimerList) do
      if v then
        v:EndTask()
      end
      v = nil
    end
  end
  self.FadeInTimerList = nil
  if self.FadeCompletedTimer then
    self.FadeCompletedTimer:EndTask()
    self.FadeCompletedTimer = nil
  end
end
function CinematicCloisterPage:OnEscHotKeyClick()
  LogInfo("CinematicCloisterPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
return CinematicCloisterPage
