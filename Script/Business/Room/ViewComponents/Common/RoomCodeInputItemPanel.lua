local RoomCodeInputItemPanel = class("RoomCodeInputItemPanel", PureMVC.ViewComponentPanel)
function RoomCodeInputItemPanel:ListNeededMediators()
  return {}
end
function RoomCodeInputItemPanel:Construct()
  RoomCodeInputItemPanel.super.Construct(self)
  self.bSet = false
  self.currentText = nil
end
function RoomCodeInputItemPanel:Destruct()
  RoomCodeInputItemPanel.super.Destruct(self)
end
function RoomCodeInputItemPanel:InputCode(keyName)
  self.bSet = true
  self.PMEditableTextBox_Code:SetText(keyName)
  self.currentText = keyName
end
function RoomCodeInputItemPanel:DeleteCode()
  self.bSet = false
  self.PMEditableTextBox_Code:SetText("")
  self.currentText = ""
end
function RoomCodeInputItemPanel:GetIsSet()
  return self.bSet
end
function RoomCodeInputItemPanel:GetCode()
  return self.currentText
end
function RoomCodeInputItemPanel:OnRoomCodeTextChanged(text)
  if "" == text then
    return
  end
  local temp1 = #text
  local numKeyName = tonumber(text)
  local temp2 = #tostring(numKeyName)
  if numKeyName and temp1 == temp2 then
    local inputText = math.floor(numKeyName % 10)
    self.PMEditableTextBox_Code:SetText(inputText)
    self.currentText = inputText
  else
    self.PMEditableTextBox_Code:SetText(self.currentText)
  end
end
return RoomCodeInputItemPanel
