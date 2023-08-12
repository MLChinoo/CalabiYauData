local FriendSidePullPageMobile = class("FriendSidePullPageMobile", PureMVC.ViewComponentPage)
local FriendSidePullPageMobileMediator = require("Business/Friend/Mediators/Mobile/FriendSidePullPageMobileMediator")
function FriendSidePullPageMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendSidePullPageMobile:ListNeededMediators()
  return {FriendSidePullPageMobileMediator}
end
function FriendSidePullPageMobile:InitializeLuaEvent()
  self.actionOnClickFriendList = LuaEvent.new()
  self.actionOnClickRecentPlayerList = LuaEvent.new()
end
function FriendSidePullPageMobile:Construct()
  FriendSidePullPageMobile.super.Construct(self)
  self.Btn_CloseSidePullPage.OnClicked:Add(self, self.OnCloseSidePullPage)
  self.CheckBox_FriendList.OnCheckStateChanged:Add(self, self.OnCheckFriendList)
  self.CheckBox_RecentPlayerList.OnCheckStateChanged:Add(self, self.OnCheckRecentPlayerList)
  self.Btn_ShowSetup.OnClicked:Add(self, self.OnShowSetup)
  self.Btn_CloseSetup.OnClicked:Add(self, self.OnCloseSetup)
  self.Img_back.OnMouseButtonDownEvent:Bind(self, self.CloseFriendSidePullPage)
end
function FriendSidePullPageMobile:Destruct()
  FriendSidePullPageMobile.super.Destruct(self)
  self.Btn_CloseSidePullPage.OnClicked:Remove(self, self.OnCloseSidePullPage)
  self.CheckBox_FriendList.OnCheckStateChanged:Remove(self, self.OnCheckFriendList)
  self.CheckBox_RecentPlayerList.OnCheckStateChanged:Remove(self, self.OnCheckRecentPlayerList)
  self.Btn_ShowSetup.OnClicked:Remove(self, self.OnShowSetup)
  self.Btn_CloseSetup.OnClicked:Add(self, self.OnCloseSetup)
  self.Img_back.OnMouseButtonDownEvent:Unbind()
end
function FriendSidePullPageMobile:OnCloseSidePullPage()
  ViewMgr:ClosePage(self)
end
function FriendSidePullPageMobile:OnCheckFriendList(bIsChecked)
  if bIsChecked then
    self.CheckBox_RecentPlayerList:SetCheckedState(0)
  else
    self.CheckBox_FriendList:SetCheckedState(1)
  end
  self:ClearAllCheckBox()
  self.Txt_FriendList:SetColorAndOpacity(self.bp_textSelectedColor)
  self.Img_friendList:SetVisibility(UE4.ESlateVisibility.Visible)
  self.actionOnClickFriendList()
end
function FriendSidePullPageMobile:OnCheckRecentPlayerList(bIsChecked)
  if bIsChecked then
    self.CheckBox_FriendList:SetCheckedState(0)
  else
    self.CheckBox_RecentPlayerList:SetCheckedState(1)
  end
  self:ClearAllCheckBox()
  self.Txt_RecentPlayerList:SetColorAndOpacity(self.bp_textSelectedColor)
  self.Img_recentPlayerList:SetVisibility(UE4.ESlateVisibility.Visible)
  self.actionOnClickRecentPlayerList()
end
function FriendSidePullPageMobile:ClearAllCheckBox()
  self.Txt_FriendList:SetColorAndOpacity(self.bp_textUnSelectedColor)
  self.Txt_RecentPlayerList:SetColorAndOpacity(self.bp_textUnSelectedColor)
  self.Img_friendList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Img_recentPlayerList:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function FriendSidePullPageMobile:OnShowSetup()
  self.WS_SwitchStatus:SetActiveWidgetIndex(1)
  self.WBP_FriendSetupPanelMobile:SetVisibility(UE4.ESlateVisibility.Visible)
end
function FriendSidePullPageMobile:OnCloseSetup()
  self.WS_SwitchStatus:SetActiveWidgetIndex(0)
  self.WBP_FriendSetupPanelMobile:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function FriendSidePullPageMobile:CloseFriendSidePullPage()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return FriendSidePullPageMobile
