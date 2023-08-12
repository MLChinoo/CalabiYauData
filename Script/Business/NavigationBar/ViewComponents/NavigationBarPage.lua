local NavigationBarPage = class("NavigationBarPage", PureMVC.ViewComponentPage)
local NavigationBarMediator = require("Business/NavigationBar/Mediators/NavigationBarMediator")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local ESideWidgetType = {
  None = 0,
  Chat = 1,
  Friend = 2,
  Menu = 3
}
local ENavBarType = {
  UE4.EPMFunctionTypes.Apartment,
  UE4.EPMFunctionTypes.EquipmentRoom,
  UE4.EPMFunctionTypes.BattlePass,
  UE4.EPMFunctionTypes.Play,
  UE4.EPMFunctionTypes.Career,
  UE4.EPMFunctionTypes.Shop
}
function NavigationBarPage:ListNeededMediators()
  return {NavigationBarMediator}
end
function NavigationBarPage:InitializeLuaEvent()
  self.bIgnoreEsc = false
  self.currentSideWidgetType = ESideWidgetType.None
  self.navBarBtnArray = {}
  self.currentNavBarType = UE4.EPMFunctionTypes.Apartment
  self.currentSecondNavBar = -1
end
function NavigationBarPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Btn_UserInfoArea then
    self.Btn_UserINfoArea.OnClicked:Add(self, NavigationBarPage.OnClickAvatar)
  end
  if self.Image_ProgressBarSensor then
    self.Image_ProgressBarSensor.OnHovered:Add(self, NavigationBarPage.OnEnterExpProgressBar)
    self.Image_ProgressBarSensor.OnUnhovered:Add(self, NavigationBarPage.OnLeaveExpProgressBar)
  end
  if self.Btn_CurrencySensor then
    self.Btn_CurrencySensor.OnHovered:Add(self, NavigationBarPage.OnHoveredCurrency)
    self.Btn_CurrencySensor.OnUnhovered:Add(self, NavigationBarPage.OnUnhoveredCurrency)
    self.Btn_CurrencySensor.OnClicked:Add(self, NavigationBarPage.OnClickCurrency)
  end
  if self.Button_Chat then
    self.Button_Chat.OnClicked:Add(self, NavigationBarPage.OnClickChat)
    self.Button_Chat.OnHovered:Add(self, NavigationBarPage.HoveredChat)
    self.Button_Chat.OnUnhovered:Add(self, NavigationBarPage.UnHoveredChat)
  end
  if self.Button_Friend then
    self.Button_Friend.OnClicked:Add(self, NavigationBarPage.OnClickFriend)
    self.Button_Friend.OnHovered:Add(self, NavigationBarPage.HoveredFriend)
    self.Button_Friend.OnUnhovered:Add(self, NavigationBarPage.UnHoveredFriend)
  end
  if self.Button_Menu then
    self.Button_Menu.OnClicked:Add(self, NavigationBarPage.OnClickMenu)
    self.Button_Menu.OnHovered:Add(self, NavigationBarPage.HoveredMenu)
    self.Button_Menu.OnUnhovered:Add(self, NavigationBarPage.UnHoveredMenu)
  end
  self:InitNavigationBarBtn()
  local AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy then
    AccountBindProxy:ReqQueryAccountInfo()
  end
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  local ActivitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if ActivitiesProxy and RoleWarmUpProxy then
    local data = ActivitiesProxy:GetActivityById(RoleWarmUpProxy:GetActivityId())
    if data and data.status == GlobalEnumDefine.EActivityStatus.Runing then
      RoleWarmUpProxy:ReqRoleWarmUpGetData(RoleWarmUpProxy:GetActivityId())
    end
  end
end
function NavigationBarPage:OnClose()
  if self.Btn_UserInfoArea then
    self.Btn_UserINfoArea.OnClicked:Remove(self, NavigationBarPage.OnClickAvatar)
  end
  if self.Image_ProgressBarSensor then
    self.Image_ProgressBarSensor.OnHovered:Remove(self, NavigationBarPage.OnEnterExpProgressBar)
    self.Image_ProgressBarSensor.OnUnhovered:Remove(self, NavigationBarPage.OnLeaveExpProgressBar)
  end
  if self.Btn_CurrencySensor then
    self.Btn_CurrencySensor.OnHovered:Remove(self, NavigationBarPage.OnHoveredCurrency)
    self.Btn_CurrencySensor.OnUnhovered:Remove(self, NavigationBarPage.OnUnhoveredCurrency)
    self.Btn_CurrencySensor.OnClicked:Remove(self, NavigationBarPage.OnClickCurrency)
  end
  if self.Button_Chat then
    self.Button_Chat.OnClicked:Remove(self, NavigationBarPage.OnClickChat)
    self.Button_Chat.OnHovered:Remove(self, NavigationBarPage.HoveredChat)
    self.Button_Chat.OnUnhovered:Remove(self, NavigationBarPage.UnHoveredChat)
  end
  if self.Button_Friend then
    self.Button_Friend.OnClicked:Remove(self, NavigationBarPage.OnClickFriend)
    self.Button_Friend.OnHovered:Remove(self, NavigationBarPage.HoveredFriend)
    self.Button_Friend.OnUnhovered:Remove(self, NavigationBarPage.UnHoveredFriend)
  end
  if self.Button_Menu then
    self.Button_Menu.OnClicked:Remove(self, NavigationBarPage.OnClickMenu)
    self.Button_Menu.OnHovered:Remove(self, NavigationBarPage.HoveredMenu)
    self.Button_Menu.OnUnhovered:Remove(self, NavigationBarPage.UnHoveredMenu)
  end
  self:UnbindRedDot()
end
function NavigationBarPage:OnShow(luaOpenData, nativeOpenData)
  local enterType = UE4.EPMFunctionTypes.Apartment
  local secondIndex
  local proxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if proxy then
    local curType = proxy:GetRoomPageType()
    if curType ~= RoomEnum.ClientPlayerPageType.Lobby then
      enterType = UE4.EPMFunctionTypes.Play
    end
  end
  local cinematicCloisterProxy = GameFacade:RetrieveProxy(ProxyNames.CinematicCloisterProxy)
  if cinematicCloisterProxy:GetPlayCloisterIndex() then
    cinematicCloisterProxy:ResetPlayCloisterDatas()
    enterType = UE4.EPMFunctionTypes.BattlePass
    secondIndex = 4
  end
  self.BannerPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ActivityEntryPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SurveyEntryPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local activitiesProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  local auto
  if activitiesProxy then
    auto = activitiesProxy:GetAutoShowPageActivity()
  end
  if enterType == UE4.EPMFunctionTypes.Apartment and auto then
    local body = {
      activityId = auto.activityId,
      pageName = auto.cfg.blue_print
    }
    GameFacade:SendNotification(NotificationDefines.Activities.ActivityOperateCmd, body, NotificationDefines.Activities.ActivityReqType)
  end
  self:NavigationBarChange(enterType, secondIndex)
  self:InitPlayerInfo()
  local TeamApplyAndInviteProxy = GameFacade:RetrieveProxy(ProxyNames.TeamApplyAndInviteProxy)
  TeamApplyAndInviteProxy:ShowTeamApplyInfo()
  self:BindRedDot()
  self.BuffPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local BuffProxy = GameFacade:RetrieveProxy(ProxyNames.BuffProxy)
  BuffProxy:CheckShowBuff()
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  local bFromBattelInfo, lastRoomid = ReplayProxy:GetBattleInfoFlag()
  if bFromBattelInfo then
    ReplayProxy:SetBattleInfoFlag(false)
    GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):ShowBattleRecord(lastRoomid)
  end
end
function NavigationBarPage:SetIgnoreEsc(bIgnore)
  self.bIgnoreEsc = bIgnore
end
function NavigationBarPage:SetDisplayNavBar(params)
  local bDisplay = params
  if type(params) == "table" then
    bDisplay = params.isDisplay
  end
  local bPageHide = type(params) == "table" and params.pageHide or false
  if bDisplay then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not bPageHide then
      self:ToggleDisplayedUI(self.currentNavBarType, true)
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if not bPageHide then
      self:ToggleDisplayedUI(self.currentNavBarType, false)
    end
  end
end
function NavigationBarPage:SetDisplaySecondNavBar(bDisplay)
  if self.SecondaryNavBar then
    self.SecondaryNavBar:SetVisibility(bDisplay and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPage:InitPlayerInfo()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if proxy then
    if self.TextBlock_Name and self.TextBlock_Name_Bigger then
      local nickName = proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emNick)
      local size = string.len(nickName)
      if size > 4 then
        self.TextBlock_Name_Bigger:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.TextBlock_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.TextBlock_Name:SetText(nickName)
      else
        self.TextBlock_Name_Bigger:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.TextBlock_Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.TextBlock_Name_Bigger:SetText(nickName)
      end
    end
    if self.TextBlock_Level then
      self.TextBlock_Level:SetText(proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel))
    end
    local experience = proxy:GetPlayerCurExperience()
    local levelUpExperience = proxy:GetCurLevelUpExperience()
    if self.ProgressBar_Exp then
      self.ProgressBar_Exp:SetPercent(experience / levelUpExperience)
    end
    if self.Text_ExpCurrent then
      self.Text_ExpCurrent:SetText(experience)
    end
    if self.Text_ExpNextLevel then
      self.Text_ExpNextLevel:SetText(levelUpExperience)
    end
  end
end
function NavigationBarPage:InitPlayerAvatar(avatarId, borderId)
  GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Image_Avatar, avatarId, self.Image_BorderIcon, borderId)
end
function NavigationBarPage:UpdateFriendCount(onlineCnt, totalCnt)
  if self.Text_FriendCnt then
    self.Text_FriendCnt:SetText(string.format("%d/%d", onlineCnt, totalCnt))
  end
end
function NavigationBarPage:InitNavigationBarBtn()
  self.navBarBtnArray = {}
  if self.HB_NavBarBtn then
    for index = 1, self.HB_NavBarBtn:GetChildrenCount() do
      local btn = self.HB_NavBarBtn:GetChildAt(index - 1)
      if btn then
        btn:SetIsSelect(false)
        btn:SetNavigationType(ENavBarType[index])
        btn:GetClickEvent():Add(self.NavigationBarClick, self)
        btn:GetMouseEnterOrLeaveEvent():Add(self.NavigationBarMouseEnterOrLeave, self)
        self.navBarBtnArray[ENavBarType[index]] = btn
      end
    end
  end
end
function NavigationBarPage:LuaHandleKeyEvent(key, inputEvent)
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Escape" then
    if self.bIgnoreEsc then
      return false
    elseif inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickEsc()
      return true
    end
  end
  return false
end
function NavigationBarPage:NavigationBarClick(barType, defaultIndex)
  if barType == UE4.EPMFunctionTypes.Career then
    local levelLimit = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy):GetParameterIntValue("5908")
    local level = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
    if levelLimit and level and levelLimit > level then
      defaultIndex = 2
    end
  elseif barType == UE4.EPMFunctionTypes.BattlePass then
    local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    if bpProxy and bpProxy:GetFirstEnter() then
      defaultIndex = 1
    end
  end
  self:NavigationBarChange(barType, defaultIndex)
end
function NavigationBarPage:NavigationBarMouseEnterOrLeave(barType, bIsEnter)
  if barType == UE4.EPMFunctionTypes.BattlePass then
    local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    if bpProxy and bpProxy:IsSeasonIntermission() then
      return
    end
    if bIsEnter then
      self.ShortCutTaskPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.ShortCutTaskPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function NavigationBarPage:NavigationBarChange(barType, secondIndex, exData)
  if barType == self.currentNavBarType and type(self.currentSecondNavBar) == type(secondIndex) and self.currentSecondNavBar == secondIndex then
    return
  end
  self.currentSecondNavBar = secondIndex
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.navBarBtnArray[self.currentNavBarType] then
    self.navBarBtnArray[self.currentNavBarType]:SetIsSelect(false)
  end
  self:ToggleDisplayedUI(self.currentNavBarType, false, secondIndex)
  self.currentNavBarType = barType
  if self.navBarBtnArray[self.currentNavBarType] then
    self.navBarBtnArray[self.currentNavBarType]:SetIsSelect(true)
  end
  self:ToggleDisplayedUI(self.currentNavBarType, true, secondIndex, exData)
  GameFacade:SendNotification(NotificationDefines.SetChatState, "", NotificationDefines.ChatState.Collapsed)
end
function NavigationBarPage:ToggleDisplayedUI(barType, bToggleShowUI, secondIndex, exData)
  self:OpenMenuBar(false)
  if barType == UE4.EPMFunctionTypes.Apartment then
    self:HandlerApartMent(bToggleShowUI, secondIndex, exData)
  elseif barType == UE4.EPMFunctionTypes.EquipmentRoom then
    self:HandlerEquipRoom(bToggleShowUI)
  elseif barType == UE4.EPMFunctionTypes.BattlePass then
    self:HandlerHasSecondaryNavBar(barType, bToggleShowUI, secondIndex, exData)
  elseif barType == UE4.EPMFunctionTypes.Play then
    self:HandlerPlay(bToggleShowUI)
  elseif barType == UE4.EPMFunctionTypes.Career then
    self:HandlerHasSecondaryNavBar(barType, bToggleShowUI, secondIndex, exData)
  elseif barType == UE4.EPMFunctionTypes.Shop then
    self:HandlerHasSecondaryNavBar(barType, bToggleShowUI, secondIndex)
  end
end
function NavigationBarPage:HandlerApartMent(bToggleShowUI, secondIndex, exData)
  if bToggleShowUI then
    ViewMgr:OpenPage(self, UIPageNameDefine.ApartmentPage, nil, exData)
  else
    ViewMgr:ClosePage(self, UIPageNameDefine.ApartmentPage)
  end
  self.BannerPanel:SetViewVisible(bToggleShowUI)
  self.ActivityEntryPanel:SetViewVisible(bToggleShowUI)
  self.SurveyEntryPanel:SetViewVisible(bToggleShowUI)
  self.BuffPanel:SetViewVisible(true)
end
function NavigationBarPage:HandlerEquipRoom(bToggleShowUI)
  if bToggleShowUI then
    ViewMgr:OpenPage(self, UIPageNameDefine.EquipRoomMainPage)
  else
    ViewMgr:ClosePage(self, UIPageNameDefine.EquipRoomMainPage)
  end
end
function NavigationBarPage:HandlerPlay(bToggleShowUI)
  if bToggleShowUI then
    ViewMgr:OpenPage(self, UIPageNameDefine.GameModeSelectPage)
  else
    ViewMgr:ClosePage(self, UIPageNameDefine.GameModeSelectPage)
  end
end
function NavigationBarPage:HandlerHasSecondaryNavBar(barType, bToggleShowUI, secondIndex, exData)
  if self.SecondaryNavBar then
    if bToggleShowUI then
      self.SecondaryNavBar:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SecondaryNavBar:GenerateNavbar(barType, secondIndex, exData, self)
    else
      self.SecondaryNavBar:CloseActivePage()
    end
  end
end
function NavigationBarPage:OnClickAvatar()
  ViewMgr:OpenPage(self, UIPageNameDefine.PlayerProfilePage)
end
function NavigationBarPage:OnEnterExpProgressBar()
  if self.Canvas_Exp then
    self.Canvas_Exp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function NavigationBarPage:OnLeaveExpProgressBar()
  if self.Canvas_Exp then
    self.Canvas_Exp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPage:OnHoveredCurrency()
  if self.ShorcutCurrencyPanel then
    self.ShorcutCurrencyPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function NavigationBarPage:OnUnhoveredCurrency()
  if self.ShorcutCurrencyPanel then
    self.ShorcutCurrencyPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPage:OnClickCurrency()
  if UE4.EPMFunctionTypes.Shop == self.currentNavBarType then
    return
  end
  self:NavigationBarChange(UE4.EPMFunctionTypes.Shop, 2)
end
function NavigationBarPage:OnClickEsc()
  if self.currentSideWidgetType == ESideWidgetType.None then
    if self.currentNavBarType ~= UE4.EPMFunctionTypes.Apartment then
      self:NavigationBarChange(UE4.EPMFunctionTypes.Apartment)
    else
      self:OpenMenuBar(true)
    end
  else
    self:OpenMenuBar(false)
  end
end
function NavigationBarPage:OpenMenuBar(bOpen)
  if bOpen then
    self:CheckMenu(true)
  else
    self:CloseCurrentSideWidget()
  end
end
function NavigationBarPage:OnClickChat()
  if self.currentSideWidgetType == ESideWidgetType.Chat then
    self:OpenMenuBar(false)
  else
    self:CheckChat(true)
  end
end
function NavigationBarPage:JumpToChat()
  if self.currentSideWidgetType == ESideWidgetType.Chat then
  else
    self:CheckChat(true)
  end
end
function NavigationBarPage:OnClickFriend()
  if self.currentSideWidgetType == ESideWidgetType.Friend then
    self:OpenMenuBar(false)
  else
    self:CheckFriend(true)
  end
end
function NavigationBarPage:OnClickMenu()
  if self.currentSideWidgetType == ESideWidgetType.Menu then
    self:OpenMenuBar(false)
  else
    self:CheckMenu(true)
  end
end
function NavigationBarPage:CheckChat(bCheck)
  if bCheck then
    if self.currentSideWidgetType ~= ESideWidgetType.Chat then
      self:CloseCurrentSideWidget()
      self.currentSideWidgetType = ESideWidgetType.Chat
      ViewMgr:OpenPage(self, UIPageNameDefine.KaPhonePage)
    end
  elseif self.currentSideWidgetType == ESideWidgetType.Chat then
    self.currentSideWidgetType = ESideWidgetType.None
    ViewMgr:ClosePage(self, UIPageNameDefine.KaPhonePage)
  end
end
function NavigationBarPage:CheckFriend(bCheck)
  if bCheck then
    if self.currentSideWidgetType ~= ESideWidgetType.Friend then
      self:CloseCurrentSideWidget()
      self.currentSideWidgetType = ESideWidgetType.Friend
      ViewMgr:OpenPage(self, UIPageNameDefine.FriendList)
    end
  elseif self.currentSideWidgetType == ESideWidgetType.Friend then
    self.currentSideWidgetType = ESideWidgetType.None
    ViewMgr:ClosePage(self, UIPageNameDefine.FriendList)
  end
end
function NavigationBarPage:CheckMenu(bCheck)
  if bCheck then
    if self.currentSideWidgetType ~= ESideWidgetType.Menu then
      self:CloseCurrentSideWidget()
      self.currentSideWidgetType = ESideWidgetType.Menu
      ViewMgr:OpenPage(self, UIPageNameDefine.NavigationMenuPage)
    end
  elseif self.currentSideWidgetType == ESideWidgetType.Menu then
    self.currentSideWidgetType = ESideWidgetType.None
    ViewMgr:ClosePage(self, UIPageNameDefine.NavigationMenuPage)
  end
end
function NavigationBarPage:CloseCurrentSideWidget()
  if self.currentSideWidgetType == ESideWidgetType.Chat then
    self:CheckChat(false)
  elseif self.currentSideWidgetType == ESideWidgetType.Friend then
    self:CheckFriend(false)
  elseif self.currentSideWidgetType == ESideWidgetType.Menu then
    self:CheckMenu(false)
  end
end
function NavigationBarPage:BindRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.NavAvatar, function(cnt)
    self:UpdateRedDotAvatar(cnt)
  end)
  self:UpdateRedDotAvatar(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.NavAvatar))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Career, function(cnt)
    self:UpdateRedDotCareer(cnt)
  end)
  self:UpdateRedDotCareer(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Career))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.KaPhone, function(cnt)
    self:UpdateRedDotKaPhone(cnt)
  end)
  self:UpdateRedDotKaPhone(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.KaPhone))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Friend, function(cnt)
    self:UpdateRedDotFriend(cnt)
  end)
  self:UpdateRedDotFriend(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Friend))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Battlepass, function(cnt)
    self:UpdateRedDotBP(cnt)
  end)
  self:UpdateRedDotBP(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Battlepass))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.EquipRoom, function(cnt)
    self:UpdateRedDotEquipRoom(cnt)
  end)
  self:UpdateRedDotEquipRoom(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.EquipRoom))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Apartment, function(cnt)
    self:UpdateRedDotApartment(cnt)
  end)
  self:UpdateRedDotApartment(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Apartment))
end
function NavigationBarPage:UnbindRedDot()
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.NavAvatar)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Career)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaPhone)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Friend)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Battlepass)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.EquipRoom)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Apartment)
end
function NavigationBarPage:UpdateRedDotAvatar(cnt)
  if self.RedDot_BusinessCard then
    self.RedDot_BusinessCard:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPage:UpdateRedDotCareer(cnt)
  if self.NavBP_Career then
    self.NavBP_Career:SetRedDot(cnt)
  end
end
function NavigationBarPage:UpdateRedDotKaPhone(cnt)
  if self.RedDot_KaPhone then
    self.RedDot_KaPhone:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPage:UpdateRedDotFriend(cnt)
  if self.RedDot_Friend then
    self.RedDot_Friend:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPage:UpdateRedDotMenu()
  local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
  local AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  if AccountBindProxy and NoticeSubSys then
    local isTouch = NoticeSubSys:GetIsTouchByName("AccountBindPage", GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
    if AccountBindProxy:GetPhoneBingHasReward() == false or false == AccountBindProxy:GetFBBingHasReward() or isTouch then
      self.RedDot_Menu:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.RedDot_Menu:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function NavigationBarPage:UpdateRedDotBP(cnt)
  if self.NavBP_BP then
    self.NavBP_BP:SetRedDot(cnt)
  end
end
function NavigationBarPage:UpdateRedDotEquipRoom(cnt)
  if self.NavBp_Equipment then
    self.NavBp_Equipment:SetRedDot(cnt)
  end
end
function NavigationBarPage:UpdateRedDotApartment(cnt)
  if self.NavBP_Apartment then
    self.NavBP_Apartment:SetRedDot(cnt)
  end
end
function NavigationBarPage:HoveredChat()
  if self.WS_Chat then
    self.WS_Chat:SetActiveWidgetIndex(1)
  end
end
function NavigationBarPage:UnHoveredChat()
  if self.WS_Chat then
    self.WS_Chat:SetActiveWidgetIndex(0)
  end
end
function NavigationBarPage:HoveredFriend()
  if self.WS_Friend then
    self.WS_Friend:SetActiveWidgetIndex(1)
  end
end
function NavigationBarPage:UnHoveredFriend()
  if self.WS_Friend then
    self.WS_Friend:SetActiveWidgetIndex(0)
  end
end
function NavigationBarPage:HoveredMenu()
  if self.WS_Menu then
    self.WS_Menu:SetActiveWidgetIndex(1)
  end
end
function NavigationBarPage:UnHoveredMenu()
  if self.WS_Menu then
    self.WS_Menu:SetActiveWidgetIndex(0)
  end
end
return NavigationBarPage
