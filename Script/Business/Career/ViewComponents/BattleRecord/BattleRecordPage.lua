local BattleRecordMediator = require("Business/Career/Mediators/BattleRecord/BattleRecordMediator")
local BattleRecordPage = class("BattleRecordPage", PureMVC.ViewComponentPage)
function BattleRecordPage:ListNeededMediators()
  return {BattleRecordMediator}
end
function BattleRecordPage:InitializeLuaEvent()
  LogDebug("BattleRecordPage", "Init lua event")
  self.actionOnReqRecordList = LuaEvent.new()
  self.actionOnChooseRecord = LuaEvent.new(roomId)
end
function BattleRecordPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("BattleRecordPage", "Lua implement OnOpen")
  if self.WidgetSwitcher_HasData then
    self.WidgetSwitcher_HasData:SetActiveWidgetIndex(0)
  end
  if self.Button_Load then
    self.Button_Load.OnClickEvent:Add(self, self.OnClickLoad)
  end
  if self.ListView_Record then
    self.ListView_Record.BP_OnItemClicked:Add(self, self.ClickRecordItem)
  end
  if self.HotKeyShare then
    self.HotKeyShare.OnClickEvent:Add(self, self.OnClickedShare)
  end
  self.ScreenPrintSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self, "OnScreenPrintSuccess")
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  self.currentPage = 1
  if luaOpenData then
    if luaOpenData.standings and luaOpenData.selectedBattle then
      self:UpdateRecordList(luaOpenData.standings, luaOpenData.selectedBattle)
    end
  else
    self.actionOnReqRecordList(self.currentPage)
  end
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  ReplayProxy:ClearNotValidFiles()
end
function BattleRecordPage:OnClose()
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  end
  if self.Button_Load then
    self.Button_Load.OnClickEvent:Remove(self, self.OnClickLoad)
  end
  if self.ListView_Record then
    self.ListView_Record.BP_OnItemClicked:Remove(self, self.ClickRecordItem)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
  if self.HotKeyShare then
    self.HotKeyShare.OnClickEvent:Remove(self, self.OnClickedShare)
  end
  if self.ScreenPrintSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self.ScreenPrintSuccessHandler)
    self.ScreenPrintSuccessHandler = nil
  end
end
function BattleRecordPage:ShowRecord(recordList)
  if 0 == table.count(recordList) then
    if 1 == self.currentPage then
      self:HasNoRecord()
    else
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "NoMoreRecord")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
      self.currentPage = self.currentPage - 1
    end
  else
    self:UpdateRecordList(recordList)
  end
end
function BattleRecordPage:HasNoRecord()
  LogDebug("BattleRecordPage", "Has no record...")
  ViewMgr:ClosePage(self, UIPageNameDefine.PendingPage)
  if self.WidgetSwitcher_HasData then
    self.WidgetSwitcher_HasData:SetActiveWidgetIndex(1)
    self.WidgetSwitcher_HasData:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local hintWidget = self.WidgetSwitcher_HasData:GetActiveWidget()
    if hintWidget then
      hintWidget:PlayOpenAnim()
    end
  end
end
function BattleRecordPage:UpdateRecordList(newRecord, recordChosen)
  local shouldChosen = true
  local itemChosen
  if self.ListView_Record then
    if self.ListView_Record:GetListItems():Length() > 0 or recordChosen then
      shouldChosen = false
    end
    if self.ListView_Record:GetListItems():Length() > 0 and recordChosen then
      self.ListView_Record:ClearListItems()
    end
    if self.EnterInto and shouldChosen then
      self:PlayAnimation(self.EnterInto, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
    local roomIdList = {}
    for key, value in pairs(newRecord) do
      if roomIdList[value.room_id] == nil then
        local itemObj = ObjectUtil:CreateLuaUObject(self)
        itemObj.data = value
        itemObj.parentPage = self
        if recordChosen then
          itemObj.shouldChosen = recordChosen.room_id == value.room_id
        else
          itemObj.shouldChosen = shouldChosen
        end
        self.ListView_Record:AddItem(itemObj)
        if itemObj.shouldChosen then
          self:ClickRecordItem(itemObj)
          itemChosen = itemObj
        end
        shouldChosen = false
        roomIdList[value.room_id] = 1
      else
        LogError("BattleRecordPage", "Room id has exist, please check!")
      end
    end
  end
  self.WidgetSwitcher_HasData:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.ListView_Record and itemChosen then
    local itemIndex = self.ListView_Record:GetIndexForItem(itemChosen)
    if itemIndex >= 4 then
      if self.ListView_Record:GetListItems():Length() > itemIndex + 2 then
        self.ListView_Record:ScrollIndexIntoView(itemIndex + 2)
      else
        self.ListView_Record:ScrollToBottom()
      end
    end
  end
end
function BattleRecordPage:ClearRecord()
  if self.ListView_Record then
    self.ListView_Record:ClearListItems()
  end
end
function BattleRecordPage:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.HotKeyShare and self.HotKeyShare:IsVisible() and not ret then
    ret = self.HotKeyShare:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function BattleRecordPage:ClickRecordItem(item)
  LogDebug("BattleRecordPage", "Require room: %d battle info", item.data.room_id)
  self.currentChosen = item.data.room_id
  self.actionOnChooseRecord(self.currentChosen)
  GameFacade:SendNotification(NotificationDefines.Career.BattleRecord.ShowBattleInfo, item.data)
end
function BattleRecordPage:OnEscHotKeyClick()
  LogInfo("BattleRecordPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function BattleRecordPage:OnClickLoad()
  self.Button_Load:SetButtonIsEnabled(false)
  TimerMgr:AddTimeTask(0.5, 0, 1, function()
    self.Button_Load:SetButtonIsEnabled(true)
  end)
  self.currentPage = self.currentPage + 1
  self.actionOnReqRecordList(self.currentPage)
end
function BattleRecordPage:OnClickedShare()
  if self.HotKeyShare then
    self.HotKeyShare:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
  if not self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.CareerRecord)
end
function BattleRecordPage:OnScreenPrintSuccess()
  if self.HotKeyShare then
    self.HotKeyShare:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
  if not self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  end
end
return BattleRecordPage
