local PlayerProfilePageMobile = class("PlayerProfilePageMobile", PureMVC.ViewComponentPage)
local PlayerProfileMediator = require("Business/PlayerProfile/Mediators/PlayerProfileMediator")
function PlayerProfilePageMobile:ListNeededMediators()
  return {PlayerProfileMediator}
end
function PlayerProfilePageMobile:InitializeLuaEvent()
  LogDebug("PlayerProfilePageMobile", "Init lua event")
end
function PlayerProfilePageMobile:OnOpen(luaOpenData, nativeOpenData)
  if self.Information_Open then
    self:PlayAnimationForward(self.Information_Open)
  end
  if self.Button_CopyID then
    self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyID)
  end
  if self.Button_BCSetting then
    self.Button_BCSetting.OnClicked:Add(self, self.EnterBCSettingPage)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.ClosePage)
  end
  RedDotTree:Bind(RedDotModuleDef.ModuleName.BusinessCard, function(cnt)
    self:UpdateRedDotBusinessCard(cnt)
  end)
  self:UpdateRedDotBusinessCard(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.BusinessCard))
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.GetPlayerDataCmd)
end
function PlayerProfilePageMobile:OnClose()
  if self.Button_CopyID then
    self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyID)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.ClosePage)
  end
  if self.Button_BCSetting then
    self.Button_BCSetting.OnClicked:Remove(self, self.EnterBCSettingPage)
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.BusinessCard)
end
function PlayerProfilePageMobile:UpdateView(cardInfo, collectionInfo, privilegeInfo)
  if self.CardPanel then
    self.CardPanel:InitView(cardInfo)
  end
  if self.CollectableDataPanel then
    self.CollectableDataPanel:UpdateView(collectionInfo)
  end
  if self.PrivilegeGameCenterLaunched then
    self.PrivilegeGameCenterLaunched:UpdateDisplay(privilegeInfo)
  end
  if self.Text_PlayerID then
    self.Text_PlayerID:SetText(GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId())
  end
end
function PlayerProfilePageMobile:EnterBCSettingPage()
  LogDebug("PlayerProfilePageMobile", "Open businesscard setting page")
  ViewMgr:OpenPage(self, UIPageNameDefine.BCSettingPage)
end
function PlayerProfilePageMobile:OnClickCopyID()
  if self.Text_PlayerID then
    UE4.UPMLuaBridgeBlueprintLibrary.ClipboardCopy(self.Text_PlayerID:GetText())
    local stFriendName = StringTablePath.ST_FriendName
    local showMsg = ConfigMgr:FromStringTable(stFriendName, "Copy_FriendListText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
  end
end
function PlayerProfilePageMobile:ClosePage()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  ViewMgr:ClosePage(self)
end
function PlayerProfilePageMobile:UpdateRedDotBusinessCard(cnt)
  if self.RedDot_BusinessCard then
    self.RedDot_BusinessCard:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return PlayerProfilePageMobile
