local HintPage = class("HintPage", PureMVC.ViewComponentPage)
function HintPage:ListNeededMediators()
  return {}
end
function HintPage:InitializeLuaEvent()
  self.Button_Confirm.OnClicked:Add(self, HintPage.OnClickConfirm)
  self.Button_Cancel.OnClicked:Add(self, HintPage.OnClickCancel)
  self.Button_Confirm_Hotkey.OnClickEvent:Add(self, HintPage.OnClickConfirm)
  self.Button_Cancel_Hotkey.OnClickEvent:Add(self, HintPage.OnClickCancel)
end
function HintPage:OnOpen(luaOpenData, nativeOpenData)
  local inData
  if luaOpenData then
    inData = luaOpenData
    local cnt = #inData
    if self.ListView_ModifyKeyEntry then
      self.ListView_ModifyKeyEntry:ClearListItems()
      for i, value in ipairs(luaOpenData.keyItemList) do
        local itemObj = ObjectUtil:CreateLuaUObject(self)
        itemObj.data = value
        self.ListView_ModifyKeyEntry:AddItem(itemObj)
      end
    end
    self.OkCallfunc = inData.OkCallfunc
    self.CancelCallfunc = inData.CancelCallfunc
  end
end
function HintPage:OnClickConfirm()
  self:DoConfirm()
end
function HintPage:OnClickCancel()
  self:DoCancel()
end
function HintPage:DoConfirm()
  if self.OkCallfunc then
    self.OkCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function HintPage:DoCancel()
  if self.CancelCallfunc then
    self.CancelCallfunc()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.HintPge)
end
function HintPage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Confirm_Hotkey:MonitorKeyDown(key, inputEvent) or self.Button_Cancel_Hotkey:MonitorKeyDown(key, inputEvent)
end
function HintPage:OnClose()
  self.CancelCallfunc = nil
  self.OkCallfunc = nil
end
return HintPage
