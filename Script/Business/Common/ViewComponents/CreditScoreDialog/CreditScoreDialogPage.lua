local CreditScoreDialogPage = class("CreditScoreDialogPage", PureMVC.ViewComponentPage)
function CreditScoreDialogPage:InitializeLuaEvent()
  self.Btn_Confirm.OnClickEvent:Add(self, self.OnClickConfirm)
  self.Btn_Return.OnClickEvent:Add(self, self.OnClickReturn)
  self.isConfirm = false
end
function CreditScoreDialogPage:OnShow()
end
function CreditScoreDialogPage:OnClose()
  self.Btn_Confirm.OnClickEvent:Remove(self, self.OnClickConfirm)
  self.Btn_Return.OnClickEvent:Remove(self, self.OnClickReturn)
end
function CreditScoreDialogPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  local bTag = false
  if "Escape" == keyName then
    self.Btn_Return:MonitorKeyDown(key, inputEvent)
    bTag = true
  elseif "Y" == keyName then
    bTag = self.Btn_Confirm:MonitorKeyDown(key, inputEvent)
  end
  return bTag
end
function CreditScoreDialogPage:OnOpen(luaOpenData, nativeOpenData)
  local inData
  if luaOpenData then
    inData = luaOpenData
    if inData.contentText then
      self.RichText_Content:SetText(inData.contentText)
    end
    if inData.confirmTxt then
      self.Btn_Confirm:SetPanelName(inData.confirmTxt)
    end
    if inData.returnTxt then
      self.Btn_Return:SetPanelName(inData.returnTxt)
    end
  end
  self:PlayAnimation(self.Anim_OpenPage, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function CreditScoreDialogPage:OnClickConfirm()
  self.isConfirm = true
  GameFacade:RetrieveProxy(ProxyNames.CreditProxy):OpenCreditPage()
end
function CreditScoreDialogPage:OnClickReturn()
  self.isConfirm = false
  self:ClosePage()
end
function CreditScoreDialogPage:ClosePage()
  if self:IsAnimationPlaying(self.Anim_ClosePage) then
    return
  end
  self:BindToAnimationFinished(self.Anim_ClosePage, {
    self,
    self.OnCloseAnimFinished
  })
  self:PlayAnimationForward(self.Anim_ClosePage, 1, false)
end
function CreditScoreDialogPage:OnCloseAnimFinished()
  self:UnbindAllFromAnimationFinished(self.Anim_ClosePage)
  ViewMgr:ClosePage(self)
end
return CreditScoreDialogPage
