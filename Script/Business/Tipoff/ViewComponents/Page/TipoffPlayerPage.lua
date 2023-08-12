local TipoffPlayerMediator = require("Business/Tipoff/Mediators/TipoffPlayerMediator")
local TipoffPlayerPage = class("TipoffPlayerPage", PureMVC.ViewComponentPage)
function TipoffPlayerPage:ListNeededMediators()
  return {TipoffPlayerMediator}
end
function TipoffPlayerPage:InitializeLuaEvent()
  self.ActionOnShowEvent = LuaEvent.new()
  self.ActionCancelEvent = LuaEvent.new()
  self.ActionComfirmEvent = LuaEvent.new()
  self.ActionEditBoxCommitEvent = LuaEvent.new()
end
function TipoffPlayerPage:Construct()
  TipoffPlayerPage.super.Construct(self)
  self.TipoffTabItemList = {
    [1] = self.TipoffTabItem_1,
    [2] = self.TipoffTabItem_2,
    [3] = self.TipoffTabItem_3,
    [4] = self.TipoffTabItem_4
  }
  local MaxReasonItem = 15
  self.TipoffBehaviorCheckBoxItemList = {}
  if self.ReasonDynamicEntryBox then
    for i = 1, MaxReasonItem do
      local CreateItem = self.ReasonDynamicEntryBox:BP_CreateEntry()
      if CreateItem then
        table.insert(self.TipoffBehaviorCheckBoxItemList, CreateItem)
      end
    end
  end
  self.TipoffEmptyCloseTop_Btn.OnPMButtonClicked:Add(self, self.OnClickedCancelBtn)
  self.TipoffEmptyCloseDown_Btn.OnPMButtonClicked:Add(self, self.OnClickedCancelBtn)
  self.TipoffCancel_Btn.Btn_Item.OnPMButtonClicked:Add(self, self.OnClickedCancelBtn)
  self.TipoffConfirm_Btn.Btn_Item.OnPMButtonClicked:Add(self, self.OnClickedComfirmBtn)
  self.TipoffReason_EditableTextBox.OnTextCommitted:Add(self, self.OnChangeEditTextBox)
  self.TipoffReason_EditableTextBox.OnTextChanged:Add(self, self.OnEditTextBoxTextChanged)
  self.TipoffReason_EditableTextBox.OnPMFocusReceivedEvent:Add(self, self.OnEditFocusReceived)
  self.TipoffReason_EditableTextBox.OnPMFocusLostEvent:Add(self, self.OnEditFocusLost)
end
function TipoffPlayerPage:Destruct()
  self.TipoffBehaviorCheckBoxItemList = nil
  self.TipoffCancel_Btn.Btn_Item.OnPMButtonClicked:Remove(self, self.OnClickedCancelBtn)
  self.TipoffConfirm_Btn.Btn_Item.OnPMButtonClicked:Remove(self, self.OnClickedComfirmBtn)
  self.TipoffEmptyCloseTop_Btn.OnPMButtonClicked:Remove(self, self.OnClickedCancelBtn)
  self.TipoffEmptyCloseDown_Btn.OnPMButtonClicked:Remove(self, self.OnClickedCancelBtn)
  self.TipoffReason_EditableTextBox.OnTextChanged:Remove(self, self.OnChangeEditTextBox)
  self.TipoffReason_EditableTextBox.OnTextChanged:Remove(self, self.OnEditTextBoxTextChanged)
  self.TipoffReason_EditableTextBox.OnPMFocusReceivedEvent:Remove(self, self.OnEditFocusReceived)
  self.TipoffReason_EditableTextBox.OnPMFocusLostEvent:Remove(self, self.OnEditFocusLost)
  TipoffPlayerPage.super.Destruct(self)
end
function TipoffPlayerPage:OnEditFocusReceived()
  LogDebug("TipoffPlayerPage", "OnEditFocusReceived")
  self:OnHandleHintext(false)
end
function TipoffPlayerPage:OnEditFocusLost()
  LogDebug("TipoffPlayerPage", "OnEditFocusLost")
  self:OnHandleHintext(true)
end
function TipoffPlayerPage:OnHandleHintext(bShow)
end
function TipoffPlayerPage:OnClickedCancelBtn()
  LogDebug("TipoffPlayerPage", "TipoffPlayerPage OnClickedCancelBtn Call .")
  if self.ActionCancelEvent then
    self.ActionCancelEvent()
  end
end
function TipoffPlayerPage:OnClickedComfirmBtn()
  LogDebug("TipoffPlayerPage", "TipoffPlayerPage OnClickedComfirmBtn Call .")
  if self.ActionComfirmEvent then
    self.ActionComfirmEvent()
  end
end
function TipoffPlayerPage:OnChangeEditTextBox(text, commitMethod)
  if self.ActionEditBoxCommitEvent then
    self.ActionEditBoxCommitEvent(text, commitMethod)
  end
end
function TipoffPlayerPage:OnEditTextBoxTextChanged(text)
  TimerMgr:RunNextFrame(function()
    if self.ActionEditBoxCommitEvent then
      self.ActionEditBoxCommitEvent(text, UE4.ETextCommit.OnUserMovedFocus)
    end
  end)
end
return TipoffPlayerPage
