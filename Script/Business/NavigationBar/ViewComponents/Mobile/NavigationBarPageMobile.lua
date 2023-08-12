local NavigationBarPageMobile = class("NavigationBarPageMobile", PureMVC.ViewComponentPage)
local NavigationBarMediatorMobile = require("Business/NavigationBar/Mediators/Mobile/NavigationBarMediatorMobile")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
function NavigationBarPageMobile:ListNeededMediators()
  return {NavigationBarMediatorMobile}
end
function NavigationBarPageMobile:InitializeLuaEvent()
end
function NavigationBarPageMobile:OnOpen(luaOpenData, nativeOpenData)
  self.closeApartmentPage = true
  if self.Button_Rank then
    self.Button_Rank.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickRank)
  end
  if self.Button_BattlePass then
    self.Button_BattlePass.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickBattlePass)
  end
  if self.Button_Equip then
    self.Button_Equip.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickEquip)
  end
  if self.Button_Play then
    self.Button_Play.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickPlay)
  end
  if self.Button_Career then
    self.Button_Career.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickCareer)
  end
  if self.Button_Hermes then
    self.Button_Hermes.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickHermes)
  end
  if self.Button_Friend then
    self.Button_Friend.OnClickEvent:Add(self, NavigationBarPageMobile.OnClickFriend)
  end
  if self.Btn_UserInfoArea then
    self.Btn_UserInfoArea.OnClicked:Add(self, NavigationBarPageMobile.OnClickUserInfo)
  end
  self:BindRedDot()
end
function NavigationBarPageMobile:OnClose()
  if self.Button_Rank then
    self.Button_Rank.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickRank)
  end
  if self.Button_BattlePass then
    self.Button_BattlePass.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickBattlePass)
  end
  if self.Button_Equip then
    self.Button_Equip.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickEquip)
  end
  if self.Button_Play then
    self.Button_Play.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickPlay)
  end
  if self.Button_Career then
    self.Button_Career.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickCareer)
  end
  if self.Button_Hermes then
    self.Button_Hermes.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickHermes)
  end
  if self.Button_Friend then
    self.Button_Friend.OnClickEvent:Remove(self, NavigationBarPageMobile.OnClickFriend)
  end
  if self.Btn_UserInfoArea then
    self.Btn_UserInfoArea.OnClicked:Remove(self, NavigationBarPageMobile.OnClickUserInfo)
  end
  self:UnbindRedDot()
  self:HandlerApartMent(false)
end
function NavigationBarPageMobile:OnShow(luaOpenData, nativeOpenData)
  local proxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if proxy then
    local curType = proxy:GetRoomPageType()
    if curType == RoomEnum.ClientPlayerPageType.Lobby then
      self:HandlerApartMent(true)
    else
      ViewMgr:PushPage(self, UIPageNameDefine.GameModeSelectPage)
    end
  end
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  self.SurveyEntryPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function NavigationBarPageMobile:InitPlayerInfo()
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
function NavigationBarPageMobile:InitPlayerAvatar(texture)
  if self.Image_Avatar and texture then
    self:SetImageByTexture2D(self.Image_Avatar, texture)
  end
end
function NavigationBarPageMobile:OnClickRank()
  ViewMgr:PushPage(self, UIPageNameDefine.CareerRank)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function NavigationBarPageMobile:OnClickBattlePass()
  ViewMgr:PushPage(self, UIPageNameDefine.BattlePassProgressPage)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function NavigationBarPageMobile:OnClickEquip()
  ViewMgr:PushPage(self, UIPageNameDefine.EquipRoomMainPage)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function NavigationBarPageMobile:OnClickPlay()
  ViewMgr:PushPage(self, UIPageNameDefine.GameModeSelectPage)
end
function NavigationBarPageMobile:OnClickCareer()
  ViewMgr:PushPage(self, UIPageNameDefine.Achievement)
end
function NavigationBarPageMobile:OnClickHermes()
  ViewMgr:PushPage(self, UIPageNameDefine.HermesHotListPage)
end
function NavigationBarPageMobile:OnClickFriend()
  ViewMgr:PushPage(self, UIPageNameDefine.FriendList)
end
function NavigationBarPageMobile:OnClickUserInfo()
  ViewMgr:OpenPage(self, UIPageNameDefine.PlayerProfilePage)
end
function NavigationBarPageMobile:SetCloseApartmentPage(inClose)
  self.closeApartmentPage = inClose
end
function NavigationBarPageMobile:HandlerApartMent(bToggleShowUI)
  if bToggleShowUI then
    ViewMgr:OpenPage(self, UIPageNameDefine.ApartmentPage)
    self.closeApartmentPage = true
  else
    if self.closeApartmentPage then
      ViewMgr:ClosePage(self, UIPageNameDefine.ApartmentPage)
    else
    end
  end
  self.SurveyEntryPanel:SetViewVisible(bToggleShowUI)
end
function NavigationBarPageMobile:BindRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.NavAvatar, function(cnt)
    self:UpdateRedDotAvatar(cnt)
  end)
  self:UpdateRedDotAvatar(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.NavAvatar))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.CareerRank, function(cnt)
    self:UpdateRedDotRank(cnt)
  end)
  self:UpdateRedDotRank(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.CareerRank))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Career, function(cnt)
    self:UpdateRedDotCareer(cnt)
  end)
  self:UpdateRedDotCareer(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Career))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.FriendMB, function(cnt)
    self:UpdateRedDotFriend(cnt)
  end)
  self:UpdateRedDotFriend(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.FriendMB))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.KaPhone, function(cnt)
    self:UpdateRedDotKaPhone(cnt)
  end)
  self:UpdateRedDotKaPhone(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.KaPhone))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.Battlepass, function(cnt)
    self:UpdateRedDotBP(cnt)
  end)
  self:UpdateRedDotBP(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.Battlepass))
end
function NavigationBarPageMobile:UnbindRedDot()
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.NavAvatar)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.CareerRank)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Career)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.FriendMB)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaPhone)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.Battlepass)
end
function NavigationBarPageMobile:UpdateRedDotAvatar(cnt)
  if self.RedDot_BusinessCard then
    self.RedDot_BusinessCard:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function NavigationBarPageMobile:UpdateRedDotRank(cnt)
  if self.Button_Rank then
    self.Button_Rank:SetRedDot(cnt)
  end
end
function NavigationBarPageMobile:UpdateRedDotCareer(cnt)
  if self.Button_Career then
    self.Button_Career:SetRedDot(cnt)
  end
end
function NavigationBarPageMobile:UpdateRedDotFriend(cnt)
  if self.Button_Friend then
    self.Button_Friend:SetRedDot(cnt)
  end
end
function NavigationBarPageMobile:UpdateRedDotKaPhone(cnt)
  if self.MenuPanel then
    self.MenuPanel:UpdateRedDotKaPhone(cnt)
  end
end
function NavigationBarPageMobile:UpdateRedDotBP(cnt)
  if self.Button_BattlePass then
    self.Button_BattlePass:SetRedDot(cnt)
  end
end
return NavigationBarPageMobile
