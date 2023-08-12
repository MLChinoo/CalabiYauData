local NoticePageMediator = require("Business/Notice/Mediators/NoticePageMediator")
local NoticePage = class("NoticePage", PureMVC.ViewComponentPage)
function NoticePage:ListNeededMediators()
  return {NoticePageMediator}
end
function NoticePage:InitializeLuaEvent()
end
function NoticePage:OnOpen(luaOpenData, nativeOpenData)
  self.NoticeType = luaOpenData
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
end
function NoticePage:OnClose()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
end
function NoticePage:OnEscHotKeyClick()
  LogInfo("NoticePage", "OnEscHotKeyClick")
  ViewMgr:ClosePage(self)
end
function NoticePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnEscHotKeyClick()
    end
    return true
  else
    return false
  end
end
return NoticePage
