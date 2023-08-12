local FriendProfilePageMobile = class("FriendProfilePageMobile", PureMVC.ViewComponentPage)
local PlayerProfileMediator = require("Business/PlayerProfile/Mediators/PlayerProfileMediator")
function FriendProfilePageMobile:ListNeededMediators()
  return {PlayerProfileMediator}
end
function FriendProfilePageMobile:InitializeLuaEvent()
  LogDebug("FriendProfilePageMobile", "Init lua event")
end
function FriendProfilePageMobile:OnOpen(luaOpenData, nativeOpenData)
  if self.Information_Open then
    self:PlayAnimationForward(self.Information_Open)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.ClosePage)
  end
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  GameFacade:SendNotification(NotificationDefines.PlayerProfile.GetPlayerDataCmd, luaOpenData)
end
function FriendProfilePageMobile:OnClose()
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.ClosePage)
  end
end
function FriendProfilePageMobile:UpdateView(cardInfo, collectionInfo, privilegeInfo)
  if self.CardPanel then
    self.CardPanel:InitView(cardInfo)
  end
  if self.CollectableDataPanel then
    self.CollectableDataPanel:UpdateView(collectionInfo)
  end
  if self.PrivilegeGameCenterLaunched then
    self.PrivilegeGameCenterLaunched:UpdateDisplay(privilegeInfo)
  end
end
function FriendProfilePageMobile:ClosePage()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  ViewMgr:ClosePage(self)
end
return FriendProfilePageMobile
