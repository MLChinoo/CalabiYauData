local RoomCodeInputPanel = class("RoomCodeInputPanel", PureMVC.ViewComponentPanel)
function RoomCodeInputPanel:ListNeededMediators()
  return {}
end
function RoomCodeInputPanel:Construct()
  RoomCodeInputPanel.super.Construct(self)
  self.RoomCodeInputItems = {}
  for index = 1, self.bp_RoomCodeItemNums do
    local roomCodeItemName = "RoomCodeInputItem_" .. tostring(index)
    self.RoomCodeInputItems[index] = self[roomCodeItemName]
  end
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.HoldOn)
end
function RoomCodeInputPanel:Destruct()
  RoomCodeInputPanel.super.Destruct(self)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.CancelHoldOn)
  if self.timeHandlerInputPasteContent then
    self.timeHandlerInputPasteContent:EndTask()
    self.timeHandlerInputPasteContent = nil
  end
  if self.timeHandlerSearchRoom then
    self.timeHandlerSearchRoom:EndTask()
    self.timeHandlerSearchRoom = nil
  end
  if self.timeHandlerResetLockStatus then
    self.timeHandlerResetLockStatus:EndTask()
    self.timeHandlerResetLockStatus = nil
  end
end
function RoomCodeInputPanel:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent == UE4.EInputEvent.IE_Released then
    if self.autoInputLock then
      return false
    end
    local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
    if "Backspace" == keyName or "回格键" == keyName then
      self:RoomCodeDelete()
      return
    end
    if string.find(keyName, "Num") or string.find(keyName, "数字键") then
      keyName = keyName:sub(#keyName, #keyName)
    end
    local numKeyName = tonumber(keyName)
    if numKeyName and numKeyName >= 0 and numKeyName < 10 then
      self:RoomCodeInput(keyName)
    end
  end
  return false
end
function RoomCodeInputPanel:RoomCodeInput(keyName)
  if self:IsAnyRoomCodeHasKeyboardFocus() then
    return
  end
  for index = 1, self.bp_RoomCodeItemNums do
    local item = self.RoomCodeInputItems[index]
    if item and not item:GetIsSet() then
      item:InputCode(keyName)
      if 6 == index then
        self.timeHandlerSearchRoom = TimerMgr:AddTimeTask(0.2, 0, 0, function()
          self:SearchRoomByCode()
        end)
      end
      return
    end
  end
end
function RoomCodeInputPanel:RoomCodeDelete()
  if self:IsAnyRoomCodeHasKeyboardFocus() then
    return
  end
  for index = self.bp_RoomCodeItemNums, 1, -1 do
    local item = self.RoomCodeInputItems[index]
    if item and item:GetIsSet() then
      item:DeleteCode()
      return
    end
  end
end
function RoomCodeInputPanel:ClearAllRoomCode()
  for index = self.bp_RoomCodeItemNums, 1, -1 do
    local item = self.RoomCodeInputItems[index]
    if item and item:GetIsSet() then
      item:DeleteCode()
    end
  end
end
function RoomCodeInputPanel:IsAnyRoomCodeHasKeyboardFocus()
  for index = 1, self.bp_RoomCodeItemNums do
    local item = self.RoomCodeInputItems[index]
    if item and item:HasKeyboardFocus() then
      return true
    end
  end
  return false
end
function RoomCodeInputPanel:SearchRoomByCode()
  local roomCode = ""
  for index = 1, self.bp_RoomCodeItemNums do
    local item = self.RoomCodeInputItems[index]
    if item and item:GetCode() then
      roomCode = roomCode .. item:GetCode()
    end
  end
  roomCode = tonumber(roomCode)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomCode then
    roomDataProxy:ReqTeamEnter(roomCode)
    ViewMgr:ClosePage(self, UIPageNameDefine.RoomCodePage)
  end
end
function RoomCodeInputPanel:SearchRoomByPasteContent(content)
  if self.autoInputLock then
    return
  else
    self.autoInputLock = true
  end
  self:ClearAllRoomCode()
  self.inputPasteContentCnt = 1
  self.timeHandlerInputPasteContent = TimerMgr:AddTimeTask(0, 0.1, 6, function()
    self:RoomCodeInput(string.sub(content, self.inputPasteContentCnt, self.inputPasteContentCnt))
    self.inputPasteContentCnt = self.inputPasteContentCnt + 1
  end)
  self.timeHandlerResetLockStatus = TimerMgr:AddTimeTask(0.7, 0, 1, function()
    self.autoInputLock = false
  end)
end
return RoomCodeInputPanel
