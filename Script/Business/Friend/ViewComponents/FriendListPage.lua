local FriendListPageMediator = require("Business/Friend/Mediators/FriendListPageMediator")
local FriendListPage = class("FriendListPage", PureMVC.ViewComponentPage)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function FriendListPage:ListNeededMediators()
  return {FriendListPageMediator}
end
function FriendListPage:InitializeLuaEvent()
  self.actionOnClickCleanSearch = LuaEvent.new()
  self.actionOnClickCopyID = LuaEvent.new()
  self.actionOnClickSetting = LuaEvent.new()
end
function FriendListPage:Construct()
  FriendListPage.super.Construct(self)
  self.hasInitList = false
  self.groupPanelList = {}
  self.isSettingOpen = false
  if self.Button_CleanSearch then
    self.Button_CleanSearch.OnClicked:Add(self, self.OnClickCleanSearch)
  end
  if self.Button_Setting then
    self.Button_Setting.OnClicked:Add(self, self.OnClickSetting)
  end
  if self.Button_CopyID then
    self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyID)
  end
  if self.EditableTextBox_Search then
    self.EditableTextBox_Search.OnTextChanged:Add(self, self.OnFriendSearchTextChange)
    self.EditableTextBox_Search.OnTextCommitted:Add(self, self.OnFriendSearchCommit)
  end
  if self.Btn_SearchStranger then
    self.Btn_SearchStranger.OnClicked:Add(self, self.OnClickSearchStranger)
  end
  if self.SizeBox_FriendPanel then
    self.friendPanelSize = self.SizeBox_FriendPanel.HeightOverride
  end
  if self.Img_BackgroundBlur then
    self.Img_BackgroundBlur.OnMouseButtonDownEvent:Bind(self, self.OnClickBackground)
  end
  if self.Image_SetupBg then
    self.Image_SetupBg.OnMouseButtonDownEvent:Bind(self, self.OnClickSetupBackground)
  end
  self:InitView()
end
function FriendListPage:Destruct()
  if self.Button_CleanSearch then
    self.Button_CleanSearch.OnClicked:Remove(self, self.OnClickCleanSearch)
  end
  if self.Button_Setting then
    self.Button_Setting.OnClicked:Remove(self, self.OnClickSetting)
  end
  if self.Button_CopyID then
    self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyID)
  end
  if self.EditableTextBox_Search then
    self.EditableTextBox_Search.OnTextChanged:Remove(self, self.OnFriendSearchTextChange)
    self.EditableTextBox_Search.OnTextCommitted:Remove(self, self.OnFriendSearchCommit)
  end
  if self.Btn_SearchStranger then
    self.Btn_SearchStranger.OnClicked:Remove(self, self.OnClickSearchStranger)
  end
  if self.Img_BackgroundBlur then
    self.Img_BackgroundBlur.OnMouseButtonDownEvent:Unbind()
  end
  if self.Image_SetupBg then
    self.Image_SetupBg.OnMouseButtonDownEvent:Unbind()
  end
  FriendListPage.super.Destruct(self)
end
function FriendListPage:OnShow(luaData, originOpenData)
  self:PlayAnimation(self.FriendList_Main_Open, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:ShowSetupPanel(false)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.HoldOn)
  GameFacade:SendNotification(NotificationDefines.FriendGetPlayerInfoCmd)
  local showApplyPanel = false
  if luaData and luaData == FriendEnum.FriendType.Apply then
    showApplyPanel = true
  else
    local applyPlayers = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetApplyPlayers()
    if table.count(applyPlayers) > 0 then
      showApplyPanel = true
    end
  end
  if showApplyPanel then
    if self.ApplyPanel then
      self.ApplyPanel:SetPanelCollapsed(false)
    end
  elseif self.FriendPanel then
    self.FriendPanel:SetPanelCollapsed(false)
  end
  if self.UpdateDuration and self.UpdateDuration > 0 then
    self.updateTask = TimerMgr:AddTimeTask(0, self.UpdateDuration, 0, function()
      self:UpdatePlayerList()
    end)
  end
end
function FriendListPage:UpdatePlayerList()
  LogDebug("FriendListPage", "Update Player List")
  GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):ReqFriendListUpdate()
end
function FriendListPage:OnClose()
  self:PlayAnimation(self.FriendList_Main_Close, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:OnClickCleanSearch()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.CancelHoldOn)
  GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):ClearNewFriendMsg()
  if self.updateTask then
    self.updateTask:EndTask()
    self.updateTask = nil
  end
end
function FriendListPage:InitPlayerInfo(info)
  if self.Text_PlayerName then
    self.Text_PlayerName:SetText(info.nick)
  end
  if self.Text_PlayerID then
    self.Text_PlayerID:SetText(info.playerID)
  end
  if self.Image_Division and self.Image_DivisionLevel then
    local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(info.stars)
    if divisionCfg then
      self:SetImageByPaperSprite(self.Image_Division, divisionCfg.IconDivisionS)
      local pathString = UE4.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(divisionCfg.IconDivisionLevelS)
      if "" ~= pathString then
        self:SetImageByPaperSprite(self.Image_DivisionLevel, divisionCfg.IconDivisionLevelS)
        self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Image_DivisionLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      LogError("GroupMemberItem", "Division config error")
    end
  end
  self:SetOnlineStatus(info.onlineStatus)
  self:UpdatePlayerAvatar()
end
function FriendListPage:UpdatePlayerAvatar()
  local avatarId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIcon))
  if nil == avatarId then
    avatarId = GameFacade:RetrieveProxy(ProxyNames.CardDataProxy):GetAvatarId()
  end
  local frameId = tonumber(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId))
  GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Img_HeadIcon, avatarId, self.Image_BorderIcon, frameId)
end
function FriendListPage:InitView()
  if self.hasInitList then
    return
  end
  local friendProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if self.FriendPanel then
    table.insert(self.groupPanelList, self.FriendPanel)
    local allFriends = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy):GetAllFriends()
    local friendTitle = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupFriendText")
    self.FriendPanel:InitView(friendTitle, allFriends, FriendEnum.FriendType.Friend, Pb_ncmd_cs.EFriendSystemGroup.EFriendSystemGroup_NONE)
  end
  if self.SocialFriendPanel then
    if friendProxy.bShowPlatformFriend then
      table.insert(self.groupPanelList, self.SocialFriendPanel)
      local socialFriends = friendProxy:GetPlatformFriends()
      local friendTitle = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupSocialFriendText")
      self.SocialFriendPanel:InitView(friendTitle, socialFriends, FriendEnum.FriendType.Social)
      self.SocialFriendPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.SocialFriendPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.BlacklistPanel then
    table.insert(self.groupPanelList, self.BlacklistPanel)
    local blacklistPlayers = friendProxy:GetShieldlist()
    local blacklistTitle = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupBlackText")
    self.BlacklistPanel:InitView(blacklistTitle, blacklistPlayers, FriendEnum.FriendType.Friend, Pb_ncmd_cs.EFriendSystemGroup.EFriendSystemGroup_SHIELD)
  end
  if self.RecentPanel then
    table.insert(self.groupPanelList, self.RecentPanel)
    local recentPlayers = friendProxy:GetNearPlayers()
    local recentTitle = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupNearText")
    self.RecentPanel:InitView(recentTitle, recentPlayers, FriendEnum.FriendType.Near)
  end
  if self.ApplyPanel then
    table.insert(self.groupPanelList, self.ApplyPanel)
    local applyPlayers = friendProxy:GetApplyPlayers()
    local applyTitle = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupInviteText")
    self.ApplyPanel:InitView(applyTitle, applyPlayers, FriendEnum.FriendType.Apply)
  end
  for _, value in pairs(self.groupPanelList) do
    value.actionOnUncollapsed:Add(self.SetActivePlayerPanel, self)
  end
  self:UpdateGroup()
  self.hasInitList = true
end
function FriendListPage:UpdateGroup()
  if self.friendPanelSize then
    local groupNum = table.count(self.groupPanelList)
    for _, value in pairs(self.groupPanelList) do
      value:SetMaxSize(self.friendPanelSize, groupNum)
    end
  end
end
function FriendListPage:SetOnlineStatus(setupStatus)
  if self.WS_OnlineState then
    self.WS_OnlineState:SetActiveWidgetIndex(setupStatus)
  end
end
function FriendListPage:ShowSetupPanel(bShown)
  if self.Image_SetupBg then
    self.Image_SetupBg:SetVisibility(bShown and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  end
  if self.WBP_FriendSetup then
    self.WBP_FriendSetup:SetVisibility(bShown and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  self.isSettingOpen = bShown
end
function FriendListPage:SetActivePlayerPanel(activePanel)
  for _, value in pairs(self.groupPanelList) do
    if value ~= activePanel then
      value:SetPanelCollapsed(true)
    end
  end
end
function FriendListPage:DeleteFriend(playerId)
  for _, value in pairs(self.groupPanelList) do
    value:DeletePlayer(playerId)
  end
end
function FriendListPage:UpdateFriendInfo(player)
  if self.FriendPanel then
    self.FriendPanel:UpdatePlayerInfo(player)
  end
end
function FriendListPage:ChangePlayerList(player)
  for _, value in pairs(self.groupPanelList) do
    value:ChangePlayer(player)
  end
end
function FriendListPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Esc" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    ViewMgr:ClosePage(self)
    return true
  end
  return false
end
function FriendListPage:OnClickCleanSearch()
  if self.EditableTextBox_Search then
    self.EditableTextBox_Search:SetText("")
  end
  if self.WidgetSwitcher_Search then
    self.WidgetSwitcher_Search:SetActiveWidgetIndex(0)
  end
  if self.FriendPanel then
    self.FriendPanel:SearchPlayer()
  end
end
function FriendListPage:OnClickCopyID()
  if self.Text_PlayerID then
    UE4.UPMLuaBridgeBlueprintLibrary.ClipboardCopy(self.Text_PlayerID:GetText())
    local stFriendName = StringTablePath.ST_FriendName
    local showMsg = ConfigMgr:FromStringTable(stFriendName, "Copy_FriendListText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function FriendListPage:OnClickSetting()
  self:ShowSetupPanel(not self.isSettingOpen)
end
function FriendListPage:OnFriendSearchTextChange(inText)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  if "" == inText then
    self:OnClickCleanSearch()
    return
  end
  if self.MaxSearchTextLength and utf8.len(inText) <= self.MaxSearchTextLength then
    self.maxFriendSearchText = inText
  else
    self.EditableTextBox_Search:SetText(self.maxFriendSearchText)
  end
  if self.maxFriendSearchText and self.FriendPanel then
    self:SetActivePlayerPanel(self.FriendPanel)
    self.FriendPanel:SearchPlayer(self.maxFriendSearchText)
  end
  if self.WidgetSwitcher_Search then
    self.WidgetSwitcher_Search:SetActiveWidgetIndex(1)
  end
end
function FriendListPage:OnFriendSearchCommit(text, commitMethod)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
end
function FriendListPage:OnClickSearchStranger()
  ViewMgr:OpenPage(self, UIPageNameDefine.FriendSearchStrangePage)
end
function FriendListPage:OnClickBackground()
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.FriendList
  })
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function FriendListPage:OnClickSetupBackground()
  self:ShowSetupPanel(false)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return FriendListPage
