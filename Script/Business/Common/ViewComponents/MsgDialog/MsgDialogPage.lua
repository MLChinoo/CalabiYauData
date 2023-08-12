local MsgDialogPage = class("MsgDialogPage", PureMVC.ViewComponentPage)
function MsgDialogPage:ListNeededMediators()
  return {}
end
function MsgDialogPage:InitializeLuaEvent()
  self.Btn_Confirm.OnClickEvent:Add(self, self.OnClickConfirm)
  self.Btn_Return.OnClickEvent:Add(self, self.OnClickReturn)
  self.Btn_Confirm_One.OnClickEvent:Add(self, self.OnClickConfirmOne)
  self.Btn_Return_Three.OnClickEvent:Add(self, self.OnClickReturnThree)
  self.Btn_Confirm_1_Three.OnClickEvent:Add(self, self.OnClickConfirm1Three)
  self.Btn_Confirm_2_Three.OnClickEvent:Add(self, self.OnClickConfirm2Three)
  self.isConfirm = false
end
function MsgDialogPage:OnShow()
end
function MsgDialogPage:OnClose()
  self.Btn_Confirm.OnClickEvent:Remove(self, self.OnClickConfirm)
  self.Btn_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  self.Btn_Confirm_One.OnClickEvent:Remove(self, self.OnClickConfirmOne)
  self.Btn_Return_Three.OnClickEvent:Remove(self, self.OnClickReturnThree)
  self.Btn_Confirm_1_Three.OnClickEvent:Remove(self, self.OnClickConfirm1Three)
  self.Btn_Confirm_2_Three.OnClickEvent:Remove(self, self.OnClickConfirm2Three)
end
function MsgDialogPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  local activeIndex = self.WS_Button:GetActiveWidgetIndex()
  local bTag = false
  if "Escape" == keyName then
    if 0 == activeIndex then
      self.Btn_Return:MonitorKeyDown(key, inputEvent)
    elseif 2 == activeIndex then
      self.Btn_Return_Three:MonitorKeyDown(key, inputEvent)
    end
    bTag = true
  elseif "Y" == keyName then
    if 0 == activeIndex then
      bTag = self.Btn_Confirm:MonitorKeyDown(key, inputEvent)
    elseif 1 == activeIndex then
      bTag = self.Btn_Confirm_One:MonitorKeyDown(key, inputEvent)
    elseif 2 == activeIndex then
      bTag = self.Btn_Confirm_2_Three:MonitorKeyDown(key, inputEvent)
    end
  elseif "H" == keyName and 2 == activeIndex then
    bTag = self.Btn_Confirm_1_Three:MonitorKeyDown(key, inputEvent)
  end
  return bTag
end
function MsgDialogPage:OnOpen(luaOpenData, nativeOpenData)
  local inData
  if luaOpenData then
    inData = luaOpenData
    if inData.contentTxt then
      self.RichText_Content:SetText(inData.contentTxt)
    end
    if inData.bIsOneBtn then
      if inData.bIsOneBtn == "three" then
        self.WS_Button:SetActiveWidgetIndex(2)
        self.Btn_Return_Three:SetPanelName(inData.btnTxtList[1])
        self.Btn_Confirm_1_Three:SetPanelName(inData.btnTxtList[2])
        self.Btn_Confirm_2_Three:SetPanelName(inData.btnTxtList[3])
      else
        self.WS_Button:SetActiveWidgetIndex(1)
      end
    end
    if inData.confirmTxt then
      self.Btn_Confirm:SetPanelName(inData.confirmTxt)
      self.Btn_Confirm_One:SetPanelName(inData.confirmTxt)
    end
    if inData.returnTxt then
      self.Btn_Return:SetPanelName(inData.returnTxt)
    end
    if inData.cb then
      self.btnFuncSlot = FuncSlot(inData.cb, inData.source)
    end
  end
  self:PlayAnimation(self.Anim_OpenPage, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function MsgDialogPage:OnClickConfirm()
  self.isConfirm = true
  self:ClosePage()
end
function MsgDialogPage:OnClickReturn()
  self.isConfirm = false
  self:ClosePage()
end
function MsgDialogPage:OnClickConfirmOne()
  self.isConfirm = true
  self:ClosePage()
end
function MsgDialogPage:OnClickReturnThree()
  self.isConfirm = 1
  self:ClosePage()
end
function MsgDialogPage:OnClickConfirm1Three()
  self.isConfirm = 2
  self:ClosePage()
end
function MsgDialogPage:OnClickConfirm2Three()
  self.isConfirm = 3
  self:ClosePage()
end
function MsgDialogPage:ClosePage()
  if self:IsAnimationPlaying(self.Anim_ClosePage) then
    return
  end
  self:BindToAnimationFinished(self.Anim_ClosePage, {
    self,
    self.OnCloseAnimFinished
  })
  self:PlayAnimationForward(self.Anim_ClosePage, 1, false)
end
function MsgDialogPage:OnCloseAnimFinished()
  self:UnbindAllFromAnimationFinished(self.Anim_ClosePage)
  if self.btnFuncSlot then
    self.btnFuncSlot(self.isConfirm)
  end
  ViewMgr:ClosePage(self)
end
return MsgDialogPage
