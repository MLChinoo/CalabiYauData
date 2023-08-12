local ActiveCodePage = class("ActiveCodePage", PureMVC.ViewComponentPage)
function ActiveCodePage:OnOpen(luaOpenData, nativeOpenData)
end
function ActiveCodePage:InitializeLuaEvent()
  if self.PMBtnPaste then
    self.PMBtnPaste.OnClicked:Add(self, self.OnClickedPaste)
  end
  if self.BtnConfirm then
    self.BtnConfirm.OnClickEvent:Add(self, self.OnClickedConfirm)
  end
  if self.BtnCancel then
    self.BtnCancel.OnClickEvent:Add(self, self.OnClickedCancel)
  end
end
function ActiveCodePage:OnClickedPaste()
  local ClipboardPasteContent = UE4.UPMLuaBridgeBlueprintLibrary.GetClipboardPasteContent()
  if ClipboardPasteContent then
    self.CodeEditor:SetText(ClipboardPasteContent)
  end
end
function ActiveCodePage:OnClickedConfirm()
  local inputCode = ""
  if self.CodeEditor then
    inputCode = self.CodeEditor:GetText()
  end
  if "" ~= inputCode then
    local loginDC = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
    if loginDC then
      loginDC:SetAccountActiveCode(inputCode)
      local loginSubsystem = UE4.UPMLoginSubSystem.GetInstance(LuaGetWorld())
      if loginSubsystem then
        loginSubsystem:LoginLobbyWithActiveCode()
      end
    end
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.ActiveCodePage)
  else
  end
end
function ActiveCodePage:OnClickedCancel()
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.ActiveCodePage)
end
function ActiveCodePage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    self:OnClickedCancel()
    return true
  elseif "Enter" == keyName then
    self:OnClickedConfirm()
    return true
  end
  return false
end
return ActiveCodePage
