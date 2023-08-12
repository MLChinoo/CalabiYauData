local RoomCodePage = class("RoomCodePage", PureMVC.ViewComponentPage)
function RoomCodePage:ListNeededMediators()
  return {}
end
function RoomCodePage:Construct()
  RoomCodePage.super.Construct(self)
  self.Btn_ClosePage.OnClickEvent:Add(self, self.OnClickRoomCodePage)
  self.Btn_PasteRoomCode.OnClickEvent:Add(self, self.OnClickPasteRoomCode)
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
function RoomCodePage:Destruct()
  RoomCodePage.super.Destruct(self)
  self.Btn_ClosePage.OnClickEvent:Remove(self, self.OnClickRoomCodePage)
  self.Btn_PasteRoomCode.OnClickEvent:Remove(self, self.OnClickPasteRoomCode)
  if self.timeHandlerGetClipboardPasteContent then
    self.timeHandlerGetClipboardPasteContent:EndTask()
    self.timeHandlerGetClipboardPasteContent = nil
  end
end
function RoomCodePage:OnKeyDown(MyGrometry, InKeyEvent)
  local isControlDown = UE4.UPMLuaBridgeBlueprintLibrary.IsControlDown(InKeyEvent)
  local FKey = UE4.UKismetInputLibrary.GetKey(InKeyEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(FKey)
  if isControlDown and "V" == keyName then
    self:OnClickPasteRoomCode()
  end
  return UE4.UWidgetBlueprintLibrary.UnHandled()
end
function RoomCodePage:ContentIsNumber(content)
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
function RoomCodePage:StrIsNumber(str)
  if not str then
    return false
  end
  if string.byte(str) >= 48 and string.byte(str) <= 57 then
    return true
  end
  return false
end
function RoomCodePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    return self.Btn_ClosePage:MonitorKeyDown(key, inputEvent)
  end
  self.WBP_RoomCodeInputPanel_PC:LuaHandleKeyEvent(key, inputEvent)
  return false
end
function RoomCodePage:OnClickRoomCodePage()
  ViewMgr:ClosePage(self, UIPageNameDefine.RoomCodePage)
end
function RoomCodePage:OnClickPasteRoomCode()
  local ClipboardPasteContent = UE4.UPMLuaBridgeBlueprintLibrary.GetClipboardPasteContent()
  if self:ContentIsNumber(ClipboardPasteContent) then
    self.WBP_RoomCodeInputPanel_PC:SearchRoomByPasteContent(ClipboardPasteContent)
  end
end
return RoomCodePage
