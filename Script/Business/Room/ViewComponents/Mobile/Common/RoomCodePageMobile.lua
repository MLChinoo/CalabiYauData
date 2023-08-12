local RoomCodePageMobile = class("RoomCodePageMobile", PureMVC.ViewComponentPage)
function RoomCodePageMobile:ListNeededMediators()
  return {}
end
function RoomCodePageMobile:Construct()
  RoomCodePageMobile.super.Construct(self)
  self.Btn_ClosePage.OnClickEvent:Add(self, self.OnClickRoomCodePageMobile)
  self.Btn_PasteRoomCode.OnClickEvent:Add(self, self.OnClickPasteRoomCode)
  self.Button_Num1.OnClicked:Add(self, self.OnClickButtonNum1)
  self.Button_Num2.OnClicked:Add(self, self.OnClickButtonNum2)
  self.Button_Num3.OnClicked:Add(self, self.OnClickButtonNum3)
  self.Button_Num4.OnClicked:Add(self, self.OnClickButtonNum4)
  self.Button_Num5.OnClicked:Add(self, self.OnClickButtonNum5)
  self.Button_Num6.OnClicked:Add(self, self.OnClickButtonNum6)
  self.Button_Num7.OnClicked:Add(self, self.OnClickButtonNum7)
  self.Button_Num8.OnClicked:Add(self, self.OnClickButtonNum8)
  self.Button_Num9.OnClicked:Add(self, self.OnClickButtonNum9)
  self.Button_Num0.OnClicked:Add(self, self.OnClickButtonNum0)
  self.Button_Delete.OnClicked:Add(self, self.OnClickButtonNumDel)
  self.timeHandlerGetClipboardPasteContent = TimerMgr:AddTimeTask(0, 1, 0, function()
    local ClipboardPasteContent = UE4.UPMLuaBridgeBlueprintLibrary.GetClipboardPasteContent()
    if self:ContentIsNumber(ClipboardPasteContent) then
      self.Text_PasteRoomCodeTip:SetText(ClipboardPasteContent)
      self.WS_PasteRoomCodeTips:SetActiveWidgetIndex(1)
      self.Btn_PasteRoomCode:SetButtonIsEnabled(true)
    else
      self.WS_PasteRoomCodeTips:SetActiveWidgetIndex(0)
      self.Btn_PasteRoomCode:SetButtonIsEnabled(false)
    end
  end)
  self:SetKeyboardFocus()
end
function RoomCodePageMobile:Destruct()
  RoomCodePageMobile.super.Destruct(self)
  self.Btn_ClosePage.OnClickEvent:Remove(self, self.OnClickRoomCodePageMobile)
  self.Btn_PasteRoomCode.OnClickEvent:Remove(self, self.OnClickPasteRoomCode)
  self.Button_Num1.OnClicked:Remove(self, self.OnClickButtonNum1)
  self.Button_Num2.OnClicked:Remove(self, self.OnClickButtonNum2)
  self.Button_Num3.OnClicked:Remove(self, self.OnClickButtonNum3)
  self.Button_Num4.OnClicked:Remove(self, self.OnClickButtonNum4)
  self.Button_Num5.OnClicked:Remove(self, self.OnClickButtonNum5)
  self.Button_Num6.OnClicked:Remove(self, self.OnClickButtonNum6)
  self.Button_Num7.OnClicked:Remove(self, self.OnClickButtonNum7)
  self.Button_Num8.OnClicked:Remove(self, self.OnClickButtonNum8)
  self.Button_Num9.OnClicked:Remove(self, self.OnClickButtonNum9)
  self.Button_Num0.OnClicked:Remove(self, self.OnClickButtonNum0)
  self.Button_Delete.OnClicked:Remove(self, self.OnClickButtonNumDel)
  if self.timeHandlerGetClipboardPasteContent then
    self.timeHandlerGetClipboardPasteContent:EndTask()
    self.timeHandlerGetClipboardPasteContent = nil
  end
end
function RoomCodePageMobile:ContentIsNumber(content)
  if 6 ~= #tostring(content) then
    return false
  else
    for i = 1, #content do
      local bIsNumber = self:StrIsNumber(string.sub(content, i, i))
      if not bIsNumber then
        return false
      end
    end
  end
  return true
end
function RoomCodePageMobile:StrIsNumber(str)
  if not str then
    return false
  end
  if string.byte(str) >= 48 and string.byte(str) <= 57 then
    return true
  end
  return false
end
function RoomCodePageMobile:OnClickRoomCodePageMobile()
  ViewMgr:ClosePage(self, UIPageNameDefine.RoomCodePageMobile)
end
function RoomCodePageMobile:OnClickPasteRoomCode()
  local ClipboardPasteContent = UE4.UPMLuaBridgeBlueprintLibrary.GetClipboardPasteContent()
  if self:ContentIsNumber(ClipboardPasteContent) then
    self.RoomCodeInputPanel_Mobile:SearchRoomByPasteContent(ClipboardPasteContent)
  end
end
function RoomCodePageMobile:OnClickButtonNum1()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("1")
end
function RoomCodePageMobile:OnClickButtonNum2()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("2")
end
function RoomCodePageMobile:OnClickButtonNum3()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("3")
end
function RoomCodePageMobile:OnClickButtonNum4()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("4")
end
function RoomCodePageMobile:OnClickButtonNum5()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("5")
end
function RoomCodePageMobile:OnClickButtonNum6()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("6")
end
function RoomCodePageMobile:OnClickButtonNum7()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("7")
end
function RoomCodePageMobile:OnClickButtonNum8()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("8")
end
function RoomCodePageMobile:OnClickButtonNum9()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("9")
end
function RoomCodePageMobile:OnClickButtonNum0()
  self.RoomCodeInputPanel_Mobile:RoomCodeInput("0")
end
function RoomCodePageMobile:OnClickButtonNumDel()
  self.RoomCodeInputPanel_Mobile:RoomCodeDelete()
end
return RoomCodePageMobile
