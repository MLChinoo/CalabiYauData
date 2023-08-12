local firendListDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
local FriendSidePullPageMobileMediator = class("FriendSidePullPageMobileMediator", PureMVC.Mediator)
FriendSidePullPageMobileMediator.FriendListType = {
  AddFriend = 0,
  Team = 1,
  Voice = 2,
  Dropline = 3
}
function FriendSidePullPageMobileMediator:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendSidePullPageMobileMediator:ListNotificationInterests()
  return {}
end
function FriendSidePullPageMobileMediator:HandleNotification(notify)
  return
end
function FriendSidePullPageMobileMediator:OnRegister()
  self:GetViewComponent().actionOnClickFriendList:Add(self.OnClickFriendList, self)
  self:GetViewComponent().actionOnClickRecentPlayerList:Add(self.OnClickRecentPlayerList, self)
  self:OnInit()
end
function FriendSidePullPageMobileMediator:OnRemove()
  self:GetViewComponent().actionOnClickFriendList:Remove(self.OnClickFriendList, self)
  self:GetViewComponent().actionOnClickRecentPlayerList:Remove(self.OnClickRecentPlayerList, self)
end
function FriendSidePullPageMobileMediator:OnInit()
  self:UpdatePlayerList(true)
end
function FriendSidePullPageMobileMediator:OnClickFriendList()
  self:UpdatePlayerList(true)
end
function FriendSidePullPageMobileMediator:OnClickRecentPlayerList()
  self:UpdatePlayerList(false)
end
function FriendSidePullPageMobileMediator:UpdatePlayerList(bFriendList)
  if not bFriendList then
    if self:GetViewComponent().LV_RecentPlayerList then
      self:GetViewComponent().WS_PlayerLv:SetActiveWidgetIndex(1)
      self:GetViewComponent().LV_RecentPlayerList:ClearListItems()
      local playerDatas = {}
      if firendListDataProxy.nearList then
        for key, value in pairs(firendListDataProxy.nearList) do
          local obj = ObjectUtil:CreateLuaUObject(self:GetViewComponent())
          obj.data = value
          self:GetViewComponent().LV_RecentPlayerList:AddItem(obj)
        end
      end
    end
  else
    self:GetViewComponent().WS_PlayerLv:SetActiveWidgetIndex(0)
    if self:GetViewComponent().LV_FriendList then
      self:GetViewComponent().LV_FriendList:ClearListItems()
      if firendListDataProxy.onlineList then
        for key, value in pairs(firendListDataProxy.onlineList) do
          local obj = ObjectUtil:CreateLuaUObject(self:GetViewComponent())
          obj.data = value
          self:GetViewComponent().LV_FriendList:AddItem(obj)
        end
      end
      playerDatas = {}
      if firendListDataProxy.offlineList then
        for key, value in pairs(firendListDataProxy.offlineList) do
          local obj = ObjectUtil:CreateLuaUObject(self:GetViewComponent())
          obj.data = value
          self:GetViewComponent().LV_FriendList:AddItem(obj)
        end
      end
    end
  end
end
return FriendSidePullPageMobileMediator
