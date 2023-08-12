local FriendPanelMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendPanelMediatorMobile")
local FriendPanelMobile = class("FriendPanelMobile", PureMVC.ViewComponentPanel)
function FriendPanelMobile:OnInitialized()
  FriendPanelMobile.super.OnInitialized(self)
end
function FriendPanelMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendPanelMobile:ListNeededMediators()
  return {FriendPanelMediatorMobile}
end
function FriendPanelMobile:InitializeLuaEvent()
  self.actionOnListItemObjectSet = LuaEvent.new()
  self.actionOnClickJoinBtn = LuaEvent.new()
  self.actionOnClickApplyAdd = LuaEvent.new()
  self.actionOnClickChatBtn = LuaEvent.new()
  self.actionOnClickRejectInviteBtn = LuaEvent.new()
  self.actionOnClickPassInviteBtn = LuaEvent.new()
  self.actionOnClickCancelShieldBtn = LuaEvent.new()
  self.actionOnClickHeadBtn = LuaEvent.new()
  self.actionOnClickRecentData = LuaEvent.new()
  self.actionOnClickQQInviteSilent = LuaEvent.new()
  self.actionOnClickWXInviteSingle = LuaEvent.new()
end
function FriendPanelMobile:Construct()
  FriendPanelMobile.super.Construct(self)
  self.JoinTeamBtn.OnClicked:Add(self, self.OnClickJoinBtn)
  self.AddPlayerBtn_1.OnClicked:Add(self, self.OnClickApplyAdd)
  self.AddPlayerBtn_2.OnClicked:Add(self, self.OnClickApplyAdd)
  self.ChatBtn.OnClicked:Add(self, self.OnClickChatBtn)
  self.RejectInviteBtn.OnClicked:Add(self, self.OnClickRejectInviteBtn)
  self.PassInviteBtn.OnClicked:Add(self, self.OnClickPassInviteBtn)
  self.CancelShieldBtn.OnClicked:Add(self, self.OnClickCancelShieldBtn)
  self.HeadBtn.OnClicked:Add(self, self.OnClickHeadBtn)
  self.MenuAnchor_ShowInfo.OnGetMenuContentEvent:Bind(self, self.CreateShowInfoPanel)
  self.RecentDataBtn.OnClicked:Add(self, self.OnClickRecentDataBtn)
  self.QQInviteSilent.OnClicked:Add(self, self.OnClickQQInviteSilent)
  self.WXInviteSingle.OnClicked:Add(self, self.OnClickWXInviteSingle)
end
function FriendPanelMobile:Destruct()
  FriendPanelMobile.super.Destruct(self)
  self.JoinTeamBtn.OnClicked:Remove(self, self.OnClickJoinBtn)
  self.AddPlayerBtn_1.OnClicked:Remove(self, self.OnClickApplyAdd)
  self.AddPlayerBtn_2.OnClicked:Remove(self, self.OnClickApplyAdd)
  self.ChatBtn.OnClicked:Remove(self, self.OnClickChatBtn)
  self.RejectInviteBtn.OnClicked:Remove(self, self.OnClickRejectInviteBtn)
  self.PassInviteBtn.OnClicked:Remove(self, self.OnClickPassInviteBtn)
  self.CancelShieldBtn.OnClicked:Remove(self, self.OnClickCancelShieldBtn)
  self.HeadBtn.OnClicked:Remove(self, self.OnClickHeadBtn)
  self.MenuAnchor_ShowInfo.OnGetMenuContentEvent:Unbind()
  self.RecentDataBtn.OnClicked:Remove(self, self.OnClickRecentDataBtn)
  self.QQInviteSilent.OnClicked:Remove(self, self.OnClickQQInviteSilent)
  self.WXInviteSingle.OnClicked:Remove(self, self.OnClickWXInviteSingle)
end
function FriendPanelMobile:CreateShowInfoPanel()
  local ShowInfoPanelIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_ShowInfo.MenuClass)
  if ShowInfoPanelIns then
    ShowInfoPanelIns:OnSetInfoPanelData(self.PanelData)
    return ShowInfoPanelIns
  end
  return nil
end
function FriendPanelMobile:OnListItemObjectSet(listItemObject)
  self.PanelData = listItemObject
  self.actionOnListItemObjectSet(listItemObject)
end
function FriendPanelMobile:OnClickJoinBtn()
  self.actionOnClickJoinBtn()
end
function FriendPanelMobile:OnClickApplyAdd()
  self.actionOnClickApplyAdd()
end
function FriendPanelMobile:OnClickChatBtn()
  self.actionOnClickChatBtn()
end
function FriendPanelMobile:OnClickRejectInviteBtn()
  self.actionOnClickRejectInviteBtn()
end
function FriendPanelMobile:OnClickPassInviteBtn()
  self.actionOnClickPassInviteBtn()
end
function FriendPanelMobile:OnClickCancelShieldBtn()
  self.actionOnClickCancelShieldBtn()
end
function FriendPanelMobile:OnClickHeadBtn()
  self.actionOnClickHeadBtn()
end
function FriendPanelMobile:OnClickRecentDataBtn()
  self.actionOnClickRecentData()
end
function FriendPanelMobile:OnClickQQInviteSilent()
  self.actionOnClickQQInviteSilent()
end
function FriendPanelMobile:OnClickWXInviteSingle()
  self.actionOnClickWXInviteSingle()
end
return FriendPanelMobile
