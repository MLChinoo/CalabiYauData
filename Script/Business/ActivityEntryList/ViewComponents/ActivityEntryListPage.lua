local ActivityEntryListPageMediator = require("Business/ActivityEntryList/Mediators/ActivityEntryListPageMediator")
local ActivityEntryListPage = class("ActivityEntryListPage", PureMVC.ViewComponentPage)
function ActivityEntryListPage:ListNeededMediators()
  return {ActivityEntryListPageMediator}
end
function ActivityEntryListPage:InitializeLuaEvent()
  self.actionOnClickHotBtn = LuaEvent.new()
  self.actionOnClickNormalBtn = LuaEvent.new()
  self.actionOnClickLimitedBtn = LuaEvent.new()
  self.actionOnClickClassicBtn = LuaEvent.new()
  self.actionOnClickGotoBtn = LuaEvent.new()
end
function ActivityEntryListPage:OnOpen(luaOpenData, nativeOpenData)
  if self.NothingHotKeyButton_Esc then
    self.NothingHotKeyButton_Esc.OnClickEvent:Add(self, self.OnNothingEscHotKeyClick)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  if self.HotBtn then
    self.HotBtn.OnClicked:Add(self, self.OnClickHotBtn)
  end
  if self.NormalBtn then
    self.NormalBtn.OnClicked:Add(self, self.OnClickNormalBtn)
  end
  if self.LimitedBtn then
    self.LimitedBtn.OnClicked:Add(self, self.OnClickLimitedBtn)
  end
  if self.ClassicBtn then
    self.ClassicBtn.OnClicked:Add(self, self.OnClickClassicBtn)
  end
  if self.gotoBtn then
    self.gotoBtn.OnClicked:Add(self, self.OnClickGotoBtn)
  end
  self.ViewSwitchAnimation:PlayOpenAnimation()
end
function ActivityEntryListPage:OnClose()
  if self.NothingHotKeyButton_Esc then
    self.NothingHotKeyButton_Esc.OnClickEvent:Remove(self, self.OnNothingEscHotKeyClick)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
  if self.HotBtn then
    self.HotBtn.OnClicked:Remove(self, self.OnClickHotBtn)
  end
  if self.NormalBtn then
    self.NormalBtn.OnClicked:Remove(self, self.OnClickNormalBtn)
  end
  if self.LimitedBtn then
    self.LimitedBtn.OnClicked:Remove(self, self.OnClickLimitedBtn)
  end
  if self.ClassicBtn then
    self.ClassicBtn.OnClicked:Remove(self, self.OnClickClassicBtn)
  end
  if self.gotoBtn then
    self.gotoBtn.OnClicked:Remove(self, self.OnClickGotoBtn)
  end
end
function ActivityEntryListPage:OnClickHotBtn()
  LogInfo("ActivityEntryListPage", "OnClickHotBtn")
  self.actionOnClickHotBtn()
end
function ActivityEntryListPage:OnClickNormalBtn()
  LogInfo("ActivityEntryListPage", "OnClickNormalBtn")
  self.actionOnClickNormalBtn()
end
function ActivityEntryListPage:OnClickLimitedBtn()
  LogInfo("ActivityEntryListPage", "OnClickLimitedBtn")
  self.actionOnClickLimitedBtn()
end
function ActivityEntryListPage:OnClickClassicBtn()
  LogInfo("ActivityEntryListPage", "OnClickClassicBtn")
  self.actionOnClickClassicBtn()
end
function ActivityEntryListPage:OnClickGotoBtn()
  LogInfo("ActivityEntryListPage", "OnClickClassicBtn")
  self.actionOnClickGotoBtn()
end
function ActivityEntryListPage:OnEscHotKeyClick()
  LogInfo("ActivityEntryListPage", "OnEscHotKeyClick")
  ViewMgr:ClosePage(self)
end
function ActivityEntryListPage:OnNothingEscHotKeyClick()
  LogInfo("ActivityEntryListPage", "OnNothingEscHotKeyClick")
  ViewMgr:ClosePage(self)
end
function ActivityEntryListPage:AnimClosed()
  ViewMgr:ClosePage(self)
end
function ActivityEntryListPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnEscHotKeyClick()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
return ActivityEntryListPage
