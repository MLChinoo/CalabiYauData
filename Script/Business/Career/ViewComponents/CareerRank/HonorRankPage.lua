local HonorRankPage = class("HonorRankPage", PureMVC.ViewComponentPage)
local HonorRankMediator = require("Business/Career/Mediators/CareerRank/HonorRankMediator")
local numPerPage
function HonorRankPage:ListNeededMediators()
  return {HonorRankMediator}
end
function HonorRankPage:InitializeLuaEvent()
  self.actionOnNewPage = LuaEvent.new(pageIndex)
  self.actionOnChooseSeason = LuaEvent.new(seasonIndex)
  self.actionOnChosenRankAll = LuaEvent.new(isRankAll)
end
function HonorRankPage:UpdateView(rankToShow)
  if 0 == table.count(rankToShow) then
    LogWarn("HonorRankPage", "Don't have rank data!")
    if self.WidgetSwitcher_HasInfo then
      self.WidgetSwitcher_HasInfo:SetActiveWidgetIndex(1)
    end
    return
  end
  if self.RankList then
    self:InitRankItems()
    local rankItems = self.RankList:GetAllChildren()
    for i = 1, rankItems:Length() do
      table.insert(self.rankItems, rankItems:Get(i))
    end
    for index = 1, numPerPage do
      if index > rankToShow["end"] - rankToShow.start + 1 then
        self.rankItems[index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.rankItems[index]:UpdateView(rankToShow.rowsInfo[index], rankToShow.start + index - 1)
        self.rankItems[index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  local selfRankInfo = {}
  honorRankDataProxy:InitRankRowsInfo(selfRankInfo, honorRankDataProxy:GetSelfRankInfo(honorRankDataProxy:GetCurrentReqLeadboardType(), honorRankDataProxy:GetLeaderboardRelationshipChain()))
  if self.RankSelf and selfRankInfo[1] then
    self.RankSelf:UpdateView(selfRankInfo[1], selfRankInfo[1].rankPos)
  end
  self:UpdatePage(rankToShow["end"], rankToShow.rankTotal)
  if self.WidgetSwitcher_HasInfo then
    self.WidgetSwitcher_HasInfo:SetActiveWidgetIndex(0)
  end
end
function HonorRankPage:UpdatePage(endPos, total)
  self.pageIndex = math.ceil(endPos / numPerPage)
  self.maxPage = math.ceil(total / numPerPage)
  if self.Text_Page then
    self.Text_Page:SetText(self.pageIndex .. "/" .. self.maxPage)
  end
end
function HonorRankPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("HonorRankPage", "Lua implement OnOpen")
  self.pageIndex = 1
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, false)
  self.parentPage = luaOpenData
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.WidgetSwitcher_HasInfo then
    self.WidgetSwitcher_HasInfo:SetActiveWidgetIndex(0)
  end
  if self.ComboBox_Season then
    self.ComboBox_Season.OnSelectionChanged:Add(self, self.SelectSeason)
    self.ComboBox_Season.OnMenuOpenChanged:Add(self, self.OnSeasonMenuOpenChanged)
  end
  if self.Button_Previous then
    self.Button_Previous.OnClicked:Add(self, self.PrePage)
  end
  if self.Button_Next then
    self.Button_Next.OnClicked:Add(self, self.NextPage)
  end
  if self.Button_ToBegin then
    self.Button_ToBegin.OnClicked:Add(self, self.ToBeginPage)
  end
  if self.Button_ToEnd then
    self.Button_ToEnd.OnClicked:Add(self, self.ToEndPage)
  end
  if self.CheckBox_AllRank and self.CheckBox_FriendRank then
    self.CheckBox_AllRank.OnCheckStateChanged:Add(self, self.RankAll)
    self.CheckBox_FriendRank.OnCheckStateChanged:Add(self, self.RankFriend)
  end
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Add(self.OnClickReturn, self)
  end
  if self.Btn_ChooseLeaderboardType then
    self.Btn_ChooseLeaderboardType.OnClicked:Add(self, self.OnClickChooseLeaderboardType)
  end
  if self.Btn_OpenRoleListPanel then
    self.Btn_OpenRoleListPanel.OnClicked:Add(self, self.OnClickOpenRoleListPanel)
  end
  self:InitRankItems()
end
function HonorRankPage:InitRankItems()
  if self.RankList and not self.rankItems then
    self.rankItems = {}
    local rankItems = self.RankList:GetAllChildren()
    for i = 1, rankItems:Length() do
      table.insert(self.rankItems, rankItems:Get(i))
    end
  end
end
function HonorRankPage:InitPageWidget(seasonId)
  if self.ComboBox_Season and seasonId then
    self.ComboBox_Season:ClearOptions()
    for i = 1, seasonId do
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "SeasonText")
      local stringMap = {
        [0] = i
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.ComboBox_Season:AddOption(text)
    end
    self.ComboBox_Season:SetSelectedIndex(seasonId - 1)
  end
  numPerPage = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy):GetNumPerPage()
end
function HonorRankPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, true)
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.ComboBox_Season then
    self.ComboBox_Season.OnSelectionChanged:Remove(self, self.SelectSeason)
    self.ComboBox_Season.OnMenuOpenChanged:Remove(self, self.OnSeasonMenuOpenChanged)
  end
  if self.Button_Previous then
    self.Button_Previous.OnClicked:Remove(self, self.PrePage)
  end
  if self.Button_Next then
    self.Button_Next.OnClicked:Remove(self, self.NextPage)
  end
  if self.Button_ToBegin then
    self.Button_ToBegin.OnClicked:Remove(self, self.ToBeginPage)
  end
  if self.Button_ToEnd then
    self.Button_ToEnd.OnClicked:Remove(self, self.ToEndPage)
  end
  if self.CheckBox_AllRank and self.CheckBox_FriendRank then
    self.CheckBox_AllRank.OnCheckStateChanged:Remove(self, self.RankAll)
    self.CheckBox_FriendRank.OnCheckStateChanged:Remove(self, self.RankFriend)
  end
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Remove(self.OnClickReturn, self)
  end
  if self.Btn_ChooseLeaderboardType then
    self.Btn_ChooseLeaderboardType.OnClicked:Remove(self, self.OnClickChooseLeaderboardType)
  end
  if self.Btn_OpenRoleListPanel then
    self.Btn_OpenRoleListPanel.OnClicked:Remove(self, self.OnClickOpenRoleListPanel)
  end
end
function HonorRankPage:SelectSeason(seasonStr, selectionType)
  self.pageIndex = 1
  local seasonId = self.ComboBox_Season:FindOptionIndex(seasonStr) + 1
  self.actionOnChooseSeason(seasonId)
end
function HonorRankPage:PrePage()
  if 1 == self.pageIndex then
    return
  end
  self.actionOnNewPage(self.pageIndex - 1)
end
function HonorRankPage:NextPage()
  if self.pageIndex == self.maxPage then
    return
  end
  self.actionOnNewPage(self.pageIndex + 1)
end
function HonorRankPage:ToBeginPage()
  if 1 == self.pageIndex then
    return
  end
  self.actionOnNewPage(1)
end
function HonorRankPage:ToEndPage()
  if self.pageIndex == self.maxPage then
    return
  end
  self.actionOnNewPage(self.maxPage)
end
function HonorRankPage:RankAll(isChosen)
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  if honorRankDataProxy:GetIsInLoadingData() then
    if self.oldRankAllCheck and not isChosen then
      return
    end
    local tips = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "RequestLeadboardTooFrequently")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tips)
    self.CheckBox_AllRank:SetIsChecked(false)
    self.CheckBox_FriendRank:SetIsChecked(true)
    return
  end
  if isChosen then
    self:ChooseRankMode(true)
    if self.ComboBox_Season then
      self.ComboBox_Season:SetIsEnabled(true)
    end
  else
    self.CheckBox_AllRank:SetIsChecked(true)
    self.CheckBox_FriendRank:SetIsChecked(false)
  end
  self.oldRankAllCheck = isChosen
end
function HonorRankPage:RankFriend(isChosen)
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  if honorRankDataProxy:GetIsInLoadingData() then
    if self.oldRankFriendCheck and not isChosen then
      return
    end
    local tips = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "RequestLeadboardTooFrequently")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tips)
    self.CheckBox_AllRank:SetIsChecked(true)
    self.CheckBox_FriendRank:SetIsChecked(false)
    return
  end
  if isChosen then
    self:ChooseRankMode(false)
    if self.ComboBox_Season then
      local seasonCnt = self.ComboBox_Season:GetOptionCount()
      self.ComboBox_Season:SetSelectedIndex(seasonCnt - 1)
      self.ComboBox_Season:SetIsEnabled(false)
    end
  else
    self.CheckBox_AllRank:SetIsChecked(false)
    self.CheckBox_FriendRank:SetIsChecked(true)
  end
  self.oldRankFriendCheck = isChosen
end
function HonorRankPage:ChooseRankMode(isAll)
  if self.CheckBox_AllRank and self.CheckBox_FriendRank then
    if isAll then
      self.CheckBox_AllRank:SetIsChecked(true)
      self.CheckBox_FriendRank:SetIsChecked(false)
    else
      self.CheckBox_AllRank:SetIsChecked(false)
      self.CheckBox_FriendRank:SetIsChecked(true)
    end
  end
  self.actionOnChosenRankAll(isAll)
end
function HonorRankPage:OnSeasonMenuOpenChanged(isOpen)
  if self.Image_Arrow then
    if isOpen then
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, 1))
    else
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
    end
  end
end
function HonorRankPage:LuaHandleKeyEvent(key, inputEvent)
  if self.Button_Return then
    return self.Button_Return:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function HonorRankPage:OnClickReturn()
  ViewMgr:ClosePage(self)
end
function HonorRankPage:OnClickChooseLeaderboardType()
  if self.MenuAnchor_LeaderboardTypeDir then
    self.MenuAnchor_LeaderboardTypeDir:Open(true)
  end
end
function HonorRankPage:OnClickOpenRoleListPanel()
  if self.MenuAnchor_RoleListPanel then
    self.MenuAnchor_RoleListPanel:Open(true)
  end
end
return HonorRankPage
