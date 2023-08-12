local CharacterDrawingPage = class("CharacterDrawingPage", PureMVC.ViewComponentPage)
function CharacterDrawingPage:ListNeededMediators()
  return {}
end
function CharacterDrawingPage:InitializeLuaEvent()
end
function CharacterDrawingPage:Construct()
  CharacterDrawingPage.super.Construct(self)
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Add(self, self.OnClickEsc)
  end
  if self.Button_ScreenShot then
    self.Button_ScreenShot.OnClickEvent:Add(self, self.OnClickScreenShot)
  end
  self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnStopScreenShot")
end
function CharacterDrawingPage:Destruct()
  CharacterDrawingPage.super.Destruct(self)
  if self.Button_ScreenShot then
    self.Button_ScreenShot.OnClickEvent:Remove(self, self.OnClickScreenShot)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnClickEsc)
  end
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
end
function CharacterDrawingPage:OnOpen(luaOpenData, nativeOpenData)
  if nil == luaOpenData then
    LogError("CharacterDrawingPage:OnOpen", "luaOpenData is nil")
    return
  end
  if nil == luaOpenData.roleSkinID then
    LogError("CharacterDrawingPage:OnOpen", "luaOpenData.roleSkinID is nil")
    return
  end
  self:UpdateItemIcon(luaOpenData.roleSkinID)
end
function CharacterDrawingPage:OnClose()
end
function CharacterDrawingPage:OnClickScreenShot()
  self.startShot = true
  self:SetHotKeyVisible(false)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.CharacterDrawing)
end
function CharacterDrawingPage:OnStopScreenShot()
  self.startShot = false
  self:SetHotKeyVisible(true)
end
function CharacterDrawingPage:OnClickEsc()
  ViewMgr:ClosePage(self)
end
function CharacterDrawingPage:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.Button_Esc and not ret then
    ret = self.Button_Esc:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_ScreenShot and not ret then
    ret = self.Button_ScreenShot:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function CharacterDrawingPage:UpdateItemIcon(roleSkinID)
  local roleSkinRow = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleSkin(roleSkinID)
  if nil == roleSkinRow then
    LogError("CharacterDrawingPage:UpdateItemIcon", "SkinRow is nil, skinID is " .. tostring(roleSkinID))
    return
  end
  if self.Img_Item then
    self:SetImageByTexture2D_MatchSize(self.Img_Item, roleSkinRow.IconRedskin)
  end
end
function CharacterDrawingPage:SetHotKeyVisible(bShow)
  if self.HorizontalBox_BottomKey then
    self.HorizontalBox_BottomKey:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return CharacterDrawingPage
