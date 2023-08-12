local FriendGroupMenuPanelMediator = require("Business/Friend/Mediators/FriendGroupMenuPanelMediator")
local FriendGroupMenuPanel = class("FriendGroupMenuPanel", PureMVC.ViewComponentPanel)
function FriendGroupMenuPanel:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendGroupMenuPanel:ListNeededMediators()
  return {FriendGroupMenuPanelMediator}
end
function FriendGroupMenuPanel:InitializeLuaEvent()
  self.actionOnCommittedGroupName = LuaEvent.new()
  self.actionOnInputGroupName = LuaEvent.new()
  self.actionOnCommittedEmptyText = LuaEvent.new()
  self.actionOnClickNewGroup = LuaEvent.new()
  self.actionOnPressedNewGroup = LuaEvent.new()
  self.actionOnReleasedNewGroup = LuaEvent.new()
  self.actionOnClickRenameGroup = LuaEvent.new()
  self.actionOnPressedRenameGroup = LuaEvent.new()
  self.actionOnReleasedRenameGroup = LuaEvent.new()
  self.actionOnClickDeleteGroup = LuaEvent.new()
  self.actionOnPressedDeleteGroup = LuaEvent.new()
  self.actionOnReleasedDeleteGroup = LuaEvent.new()
end
function FriendGroupMenuPanel:Construct()
  FriendGroupMenuPanel.super.Construct(self)
  if self.EditTextBox_GroupName then
    self.EditTextBox_GroupName.OnTextCommitted:Add(self, self.OnCommittedGroupName)
    self.EditTextBox_GroupName.OnTextChanged:Add(self, self.OnInputGroupName)
  end
  if self.Button_NewGroup then
    self.Button_NewGroup.OnClicked:Add(self, self.OnClickNewGroup)
    self.Button_NewGroup.OnPressed:Add(self, self.OnPressedNewGroup)
    self.Button_NewGroup.OnReleased:Add(self, self.OnReleasedNewGroup)
  end
  if self.Button_RenameGroup then
    self.Button_RenameGroup.OnClicked:Add(self, self.OnClickRenameGroup)
    self.Button_RenameGroup.OnPressed:Add(self, self.OnPressedRenameGroup)
    self.Button_RenameGroup.OnReleased:Add(self, self.OnReleasedRenameGroup)
  end
  if self.Button_DeleteGroup then
    self.Button_DeleteGroup.OnClicked:Add(self, self.OnClickDeleteGroup)
    self.Button_DeleteGroup.OnPressed:Add(self, self.OnPressedDeleteGroup)
    self.Button_DeleteGroup.OnReleased:Add(self, self.OnReleasedDeleteGroup)
  end
end
function FriendGroupMenuPanel:Destruct()
  FriendGroupMenuPanel.super.Destruct(self)
  if self.EditTextBox_GroupName then
    self.EditTextBox_GroupName.OnTextCommitted:Remove(self, self.OnCommittedGroupName)
    self.EditTextBox_GroupName.OnTextChanged:Remove(self, self.OnInputGroupName)
  end
  if self.Button_NewGroup then
    self.Button_NewGroup.OnClicked:Remove(self, self.OnClickNewGroup)
    self.Button_NewGroup.OnPressed:Remove(self, self.OnPressedNewGroup)
    self.Button_NewGroup.OnReleased:Remove(self, self.OnReleasedNewGroup)
  end
  if self.Button_RenameGroup then
    self.Button_RenameGroup.OnClicked:Remove(self, self.OnClickRenameGroup)
    self.Button_RenameGroup.OnPressed:Remove(self, self.OnPressedRenameGroup)
    self.Button_RenameGroup.OnReleased:Remove(self, self.OnReleasedRenameGroup)
  end
  if self.Button_DeleteGroup then
    self.Button_DeleteGroup.OnClicked:Remove(self, self.OnClickDeleteGroup)
    self.Button_DeleteGroup.OnPressed:Remove(self, self.OnPressedDeleteGroup)
    self.Button_DeleteGroup.OnReleased:Remove(self, self.OnReleasedDeleteGroup)
  end
end
function FriendGroupMenuPanel:OnCommittedGroupName(inText, inCommitMethod)
  self.actionOnCommittedGroupName(inText, inCommitMethod)
  if inCommitMethod == UE4.ETextCommit.Default or inCommitMethod == UE4.ETextCommit.OnEnter then
    UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  elseif inCommitMethod == UE4.ETextCommit.OnCleared or inCommitMethod == UE4.ETextCommit.OnUserMovedFocus then
    if self.TextCommitClearedTimeHander then
      self.TextCommitClearedTimeHander:EndTask()
    end
    self.TextCommitClearedTimeHander = TimerMgr:AddTimeTask(0.3, 0, 0, function()
      UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
    end)
  end
end
function FriendGroupMenuPanel:OnInputGroupName()
  self.actionOnInputGroupName()
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
end
function FriendGroupMenuPanel:OnCommittedEmptyText()
  self.actionOnCommittedEmptyText()
end
function FriendGroupMenuPanel:OnClickNewGroup()
  self.actionOnClickNewGroup()
end
function FriendGroupMenuPanel:OnPressedNewGroup()
  self.actionOnPressedNewGroup()
end
function FriendGroupMenuPanel:OnReleasedNewGroup()
  self.actionOnReleasedNewGroup()
end
function FriendGroupMenuPanel:OnClickRenameGroup()
  self.actionOnClickRenameGroup()
end
function FriendGroupMenuPanel:OnPressedRenameGroup()
  self.actionOnPressedRenameGroup()
end
function FriendGroupMenuPanel:OnReleasedRenameGroup()
  self.actionOnReleasedRenameGroup()
end
function FriendGroupMenuPanel:OnClickDeleteGroup()
  self.actionOnClickDeleteGroup()
end
function FriendGroupMenuPanel:OnPressedDeleteGroup()
  self.actionOnPressedDeleteGroup()
end
function FriendGroupMenuPanel:OnReleasedDeleteGroup()
  self.actionOnReleasedDeleteGroup()
end
return FriendGroupMenuPanel
