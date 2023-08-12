local MemoryPictureDisplay = class("MemoryPictureDisplay", PureMVC.ViewComponentPage)
function MemoryPictureDisplay:ListNeededMediators()
  return {}
end
function MemoryPictureDisplay:OnOpen(luaOpenData, nativeOpenData)
  if luaOpenData.MemoryPicture then
    self.ImgMemPicture:SetBrushFromSoftTexture(luaOpenData.MemoryPicture)
  end
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys.actionOnReturn:Add(self.ClosePage, self)
  end
end
function MemoryPictureDisplay:OnClose()
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys.actionOnReturn:Remove(self.ClosePage, self)
  end
end
function MemoryPictureDisplay:ClosePage()
  ViewMgr:ClosePage(self)
end
function MemoryPictureDisplay:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:ClosePage()
    return true
  end
  return false
end
return MemoryPictureDisplay
