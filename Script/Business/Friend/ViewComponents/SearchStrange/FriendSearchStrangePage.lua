local FriendSearchStrangePage = class("FriendSearchStrangePage", PureMVC.ViewComponentPage)
local FriendSearchStrangePageMediator = require("Business/Friend/Mediators/FriendSearchStrangePageMediator")
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local FindStatus = {
  Finded = 1,
  NotFind = 2,
  Init = 3
}
local SearchBtnStatus = {Search = 0, Add = 1}
function FriendSearchStrangePage:ListNeededMediators()
  return {FriendSearchStrangePageMediator}
end
function FriendSearchStrangePage:InitializeLuaEvent()
end
function FriendSearchStrangePage:Construct()
  FriendSearchStrangePage.super.Construct(self)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  self:ShowStatus(FindStatus.Init)
  if self.Button_Ignore then
    self.Button_Ignore.OnClickEvent:Add(self, self.OnClickIgnore)
  end
  if self.Button_Search then
    self.Button_Search.OnClickEvent:Add(self, self.OnClickSearchStranger)
  end
  if self.Button_Add then
    self.Button_Add.OnClickEvent:Add(self, self.OnClickAdd)
  end
  if self.Button_CleanSearch then
    self.Button_CleanSearch.OnClicked:Add(self, self.OnClickCleanSearch)
  end
  self.EditableTextBox_Search.OnTextCommitted:Add(self, self.OnSearchTextCommited)
  self.EditableTextBox_Search.OnTextChanged:Add(self, self.OnSearchTextChanged)
  self.EditableTextBox_Search:SetKeyboardFocus()
  self.searchBtnStatus = SearchBtnStatus.Search
end
function FriendSearchStrangePage:OnSearchTextChanged(inText)
  if self.MaxSearchTextLength and utf8.len(inText) <= self.MaxSearchTextLength then
    self.lastSearchText = inText
  else
    self.EditableTextBox_Search:SetText(self.lastSearchText)
  end
  if self._curStatus ~= FindStatus.Init then
    self:ShowStatus(FindStatus.Init)
  end
end
function FriendSearchStrangePage:OnSearchTextCommited(inText, inCommitMethod)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
end
function FriendSearchStrangePage:SearchStranger(strangerName)
  local firendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if firendDataProxy:IsStringFullSpacer(strangerName) then
    self.EditableTextBox_Search:SetText("")
  elseif tonumber(strangerName, 10) then
    if firendDataProxy then
      firendDataProxy:ReqFriendSearch(strangerName, tonumber(strangerName, 10))
    end
  elseif type(strangerName) == "string" then
    firendDataProxy:ReqFriendSearch(strangerName, firendDataProxy:GetPlayerID())
  end
end
function FriendSearchStrangePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "N" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if self.EditableTextBox_Search and self.EditableTextBox_Search:HasUserFocus(playerController) then
      return true
    end
  end
  return self.Button_Ignore:MonitorKeyDown(key, inputEvent) or self.Button_Search:MonitorKeyDown(key, inputEvent) or self.Button_Add:MonitorKeyDown(key, inputEvent)
end
function FriendSearchStrangePage:OnClickIgnore()
  ViewMgr:ClosePage(self)
end
function FriendSearchStrangePage:OnClickSearchStranger()
  self.EditableTextBox_Search:SetKeyboardFocus()
  local searchText = tostring(self.EditableTextBox_Search:GetText())
  if "" ~= searchText then
    self:SearchStranger(searchText)
  end
end
function FriendSearchStrangePage:OnClickAdd()
  self:SearchCurrentPlayer()
  self:OnClickCleanSearch()
end
function FriendSearchStrangePage:SearchCurrentPlayer()
  if self.currentPlayerInfo == nil then
    return
  end
  local addFriendData = {}
  addFriendData.playerId = self.currentPlayerInfo.playerId
  addFriendData.nick = self.currentPlayerInfo.nick
  GameFacade:SendNotification(NotificationDefines.AddFriendCmd, addFriendData)
end
function FriendSearchStrangePage:OnClickCleanSearch()
  if self.EditableTextBox_Search then
    self.EditableTextBox_Search:SetText("")
  end
  self:ShowStatus(FindStatus.Init)
end
function FriendSearchStrangePage:ShowStatus(status)
  self._curStatus = status
  self.FailPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PlayerPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Img_Arrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if status == FindStatus.Finded then
    self.PlayerPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Arrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:ChangeAcceptStatus(SearchBtnStatus.Add)
  elseif status == FindStatus.NotFind then
    self.FailPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:ChangeAcceptStatus(SearchBtnStatus.Search)
  elseif status == FindStatus.Init then
    self:ChangeAcceptStatus(SearchBtnStatus.Search)
  end
end
function FriendSearchStrangePage:ChangeAcceptStatus(status)
  self.searchBtnStatus = status
  if status == SearchBtnStatus.Search then
    if self.WidgetSwitcher_Accept then
      self.WidgetSwitcher_Accept:SetActiveWidgetIndex(0)
    end
  elseif status == SearchBtnStatus.Add and self.WidgetSwitcher_Accept then
    self.WidgetSwitcher_Accept:SetActiveWidgetIndex(1)
  end
end
function FriendSearchStrangePage:ShowNotFindStatus()
  self:ShowStatus(FindStatus.NotFind)
  self.currentPlayerInfo = nil
end
function FriendSearchStrangePage:ShowFindStatusByArr(playerInfoArr)
  local cnt = #playerInfoArr
  self.hasTwoFlag = cnt > 1
  self:ShowStatus(FindStatus.Finded)
  self.Player1:InitView(playerInfoArr[1], self, 1)
  self.Player2:InitView(playerInfoArr[2], self, 2)
  self.Player1:DoSelectFunc()
end
function FriendSearchStrangePage:SelectItem(currentPlayerInfo, index)
  self.currentPlayerInfo = currentPlayerInfo
  if self.hasTwoFlag then
    if 1 == index then
      self.Player1:SetSelect(true)
      self.Player2:SetSelect(false)
    elseif 2 == index then
      self.Player1:SetSelect(false)
      self.Player2:SetSelect(true)
    end
  else
    self.Player1:SetSelect(false)
  end
end
function FriendSearchStrangePage:Destruct()
  FriendSearchStrangePage.super.Destruct(self)
end
return FriendSearchStrangePage
