local FriendGroupMenuPanelMediator = class("FriendGroupMenuPanelMediator", PureMVC.Mediator)
function FriendGroupMenuPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmd,
    NotificationDefines.FriendCmdType.ResetGroupMenuLayout
  }
end
function FriendGroupMenuPanelMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmd then
    if notify:GetType() == NotificationDefines.FriendCmdType.InitGroupMenu then
      self:InitGroupMenu(notify:GetBody().inParent, notify:GetBody().bRename)
    end
  elseif notify:GetName() == NotificationDefines.FriendCmdType.ResetGroupMenuLayout then
    local margin = UE4.FMargin()
    if self.parentGroupWidget then
      margin.Top = 6
      self.parentGroupWidget:SetPadding(margin)
    end
  end
end
function FriendGroupMenuPanelMediator:OnRegister()
  self:GetViewComponent().actionOnCommittedGroupName:Add(self.OnCommittedGroupName, self)
  self:GetViewComponent().actionOnInputGroupName:Add(self.OnInputGroupName, self)
  self:GetViewComponent().actionOnCommittedEmptyText:Add(self.OnCommittedEmptyText, self)
  self:GetViewComponent().actionOnClickNewGroup:Add(self.OnClickNewGroup, self)
  self:GetViewComponent().actionOnPressedNewGroup:Add(self.OnPressedNewGroup, self)
  self:GetViewComponent().actionOnReleasedNewGroup:Add(self.OnReleasedNewGroup, self)
  self:GetViewComponent().actionOnClickRenameGroup:Add(self.OnClickRenameGroup, self)
  self:GetViewComponent().actionOnPressedRenameGroup:Add(self.OnPressedRenameGroup, self)
  self:GetViewComponent().actionOnReleasedRenameGroup:Add(self.OnReleasedRenameGroup, self)
  self:GetViewComponent().actionOnClickDeleteGroup:Add(self.OnClickDeleteGroup, self)
  self:GetViewComponent().actionOnPressedDeleteGroup:Add(self.OnPressedDeleteGroup, self)
  self:GetViewComponent().actionOnReleasedDeleteGroup:Add(self.OnReleasedDeleteGroup, self)
  self.parentGroupWidget = nil
  self.friendGroupData = nil
  self.bRenameGroup = false
  self.bAddGroup = false
  self.bShouldShowHint = true
  self:OnInit()
end
function FriendGroupMenuPanelMediator:OnRemove()
  self:GetViewComponent().actionOnCommittedGroupName:Remove(self.OnCommittedGroupName, self)
  self:GetViewComponent().actionOnInputGroupName:Remove(self.OnInputGroupName, self)
  self:GetViewComponent().actionOnCommittedEmptyText:Remove(self.OnCommittedEmptyText, self)
  self:GetViewComponent().actionOnClickNewGroup:Remove(self.OnClickNewGroup, self)
  self:GetViewComponent().actionOnPressedNewGroup:Remove(self.OnPressedNewGroup, self)
  self:GetViewComponent().actionOnReleasedNewGroup:Remove(self.OnReleasedNewGroup, self)
  self:GetViewComponent().actionOnClickRenameGroup:Remove(self.OnClickRenameGroup, self)
  self:GetViewComponent().actionOnPressedRenameGroup:Remove(self.OnPressedRenameGroup, self)
  self:GetViewComponent().actionOnReleasedRenameGroup:Remove(self.OnReleasedRenameGroup, self)
  self:GetViewComponent().actionOnClickDeleteGroup:Remove(self.OnClickDeleteGroup, self)
  self:GetViewComponent().actionOnPressedDeleteGroup:Remove(self.OnPressedDeleteGroup, self)
  self:GetViewComponent().actionOnReleasedDeleteGroup:Remove(self.OnReleasedDeleteGroup, self)
end
function FriendGroupMenuPanelMediator:OnInit()
  local parentWidget
  if self:GetViewComponent().EditTextBox_GroupName then
    parentWidget = self:GetViewComponent().EditTextBox_GroupName:GetParent()
    if parentWidget then
      parentWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:GetViewComponent().EditTextBox_GroupName:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self:GetViewComponent().EmptyHint then
    self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function FriendGroupMenuPanelMediator:OnClickNewGroup()
  local parentPage
  if self:GetViewComponent().EditTextBox_GroupName then
    self:GetViewComponent().EditTextBox_GroupName:SetKeyboardFocus()
    parentWidget = self:GetViewComponent().EditTextBox_GroupName:GetParent()
    if parentWidget then
      parentWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self:GetViewComponent().VB_Buttons then
    self:GetViewComponent().VB_Buttons:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bRenameGroup = false
  self.bAddGroup = true
  if self:GetViewComponent().EmptyHint then
    self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local margin = UE4.FMargin()
  if self.parentGroupWidget then
    margin.Top = 35
    self.parentGroupWidget:SetPadding(margin)
  end
  margin.Top = -65
  self:GetViewComponent():SetPadding(margin)
end
function FriendGroupMenuPanelMediator:OnClickRenameGroup()
  local parentPage
  if self:GetViewComponent().EditTextBox_GroupName and self.friendGroupData then
    self:GetViewComponent().EditTextBox_GroupName:SetKeyboardFocus()
    parentPage = self:GetViewComponent().EditTextBox_GroupName:GetParent()
    self:GetViewComponent().EditTextBox_GroupName:SetText(self.friendGroupData.groupData.groupName)
    if parentPage then
      parentPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self:GetViewComponent().VB_Buttons then
    self:GetViewComponent().VB_Buttons:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetViewComponent().EmptyHint then
    self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bRenameGroup = true
  self.bAddGroup = false
  local margin = UE4.FMargin()
  if self.parentGroupWidget then
    margin.Top = 35
    self.parentGroupWidget:SetPadding(margin)
  end
  margin.Top = -65
  self:GetViewComponent():SetPadding(margin)
end
function FriendGroupMenuPanelMediator:OnClickDeleteGroup()
  ViewMgr:OpenPage(self:GetViewComponent(), "FriendDeleteGroupConfirmPage")
  TimerMgr:AddTimeTask(0.001, 0, 0, function()
    local sendData = {}
    sendData.inGroupID = self.friendGroupData.groupData.groupID
    sendData.inGroupName = self.friendGroupData.groupData.groupName
    GameFacade:SendNotification(NotificationDefines.FriendCmd, sendData, NotificationDefines.FriendCmdType.SetDeleteGroupID)
  end)
  local margin = UE4.FMargin()
  if self.parentGroupWidget then
    margin.Top = 35
    self.parentGroupWidget:SetPadding(margin)
    self.parentGroupWidget.MenuAnchor_Group:Close()
  end
  margin.Top = -35
  self:GetViewComponent().SetPadding(margin)
end
function FriendGroupMenuPanelMediator:OnCommittedGroupName(inText, inCommitMethod)
  if inCommitMethod == UE4.ETextCommit.OnEnter then
    if not inText or "" == inText then
      self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
      if self.friendGroupData and friendDataProxy then
        if self.bAddGroup then
          friendDataProxy:ReqFriendGroupAdd(tostring(inText))
        end
        if self.bRenameGroup then
          friendDataProxy:ReqFriendGroupModify(self.friendGroupData.groupData.groupID, inText)
        end
      end
    end
  end
  if self.parentGroupWidget then
    local margin = UE4.FMargin()
    margin.Top = 35
    self.parentGroupWidget:SetPadding(margin)
    self.parentGroupWidget.MenuAnchor_Group:Close()
  end
  GameFacade:SendNotification(NotificationDefines.FriendCmd, nil, NotificationDefines.FriendCmdType.GroupNtf)
end
function FriendGroupMenuPanelMediator:OnInputGroupName(inText)
  local inTextStr = inText
  if inTextStr and "" ~= inTextStr then
    if self:GetViewComponent().EmptyHint then
      self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local margin = UE4.FMargin()
    if self.parentGroupWidget then
      margin.Top = 35
      self.parentGroupWidget:SetPadding(margin)
    end
    margin.Top = -65
    self:GetViewComponent():SetPadding(margin)
  end
end
function FriendGroupMenuPanelMediator:OnCommittedEmptyText(bShow)
  if self:GetViewComponent().EmptyHint then
    if bShow then
      if self.bShouldShowHint then
        local margin = UE4.FMargin()
        if self.parentGroupWidget then
          margin.Top = 60
          self.parentGroupWidget:SetPadding(margin)
        end
        margin.Top = -95
        self:GetViewComponent():SetPadding(margin)
      end
      self.bShouldShowHint = true
      self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self:GetViewComponent().EditTextBox_GroupName then
        self:GetViewComponent().EditTextBox_GroupName:SetText("")
      end
    else
      self:GetViewComponent().EmptyHint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function FriendGroupMenuPanelMediator:OnPressedNewGroup()
  if self:GetViewComponent().Text_1 then
    self:GetViewComponent().Text_1:SetColorAndOpacity(UE4.FSlateColor(UE4.FLinearColor.Black))
  end
end
function FriendGroupMenuPanelMediator:OnReleasedNewGroup()
  if self:GetViewComponent().Text_1 then
    self:GetViewComponent().Text_1:SetColorAndOpacity(UE4.FSlateColor(UE4.FLinearColor.White))
  end
end
function FriendGroupMenuPanelMediator:OnPressedRenameGroup()
  if self:GetViewComponent().Text_2 then
    self:GetViewComponent().Text_2:SetColorAndOpacity(UE4.FSlateColor(UE4.FLinearColor.Black))
  end
end
function FriendGroupMenuPanelMediator:OnReleasedRenameGroup()
  if self:GetViewComponent().Text_2 then
    self:GetViewComponent().Text_2:SetColorAndOpacity(UE4.FSlateColor(UE4.FLinearColor.White))
  end
end
function FriendGroupMenuPanelMediator:OnPressedDeleteGroup()
  if self:GetViewComponent().Text_3 then
    self:GetViewComponent().Text_3:SetColorAndOpacity(UE4.FSlateColor(UE4.FLinearColor.Black))
  end
end
function FriendGroupMenuPanelMediator:OnReleasedDeleteGroup()
  if self:GetViewComponent().Text_3 then
    self:GetViewComponent().Text_3:SetColorAndOpacity(UE4.FSlateColor(UE4.FLinearColor.White))
  end
end
function FriendGroupMenuPanelMediator:InitGroupMenu(inParent, bRename)
  if inParent then
    self.parentGroupWidget = inParent
    self.friendGroupData = self.parentGroupWidget:GetGroupData()
  end
  if self:GetViewComponent().Button_RenameGroup and self:GetViewComponent().Button_DeleteGroup then
    if bRename then
      local parentWidget = self:GetViewComponent().Button_RenameGroup:GetParent()
      if parentWidget then
        parentWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      parentWidget = self:GetViewComponent().Button_DeleteGroup:GetParent()
      if parentWidget then
        parentWidget:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      local parentWidget = self:GetViewComponent().Button_RenameGroup:GetParent()
      if parentWidget then
        parentWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      parentWidget = self:GetViewComponent().Button_DeleteGroup:GetParent()
      if parentWidget then
        parentWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end
return FriendGroupMenuPanelMediator
