local FriendRemarkDialogPageMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendRemarkDialogPageMediatorMobile")
local FriendRemarkDialogPageMobile = class("FriendRemarkDialogPageMobile", PureMVC.ViewComponentPage)
function FriendRemarkDialogPageMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendRemarkDialogPageMobile:ListNeededMediators()
  return {FriendRemarkDialogPageMediatorMobile}
end
function FriendRemarkDialogPageMobile:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClose = LuaEvent.new()
  self.actionOnClickConfirm = LuaEvent.new()
  self.actionOnClickESC = LuaEvent.new()
end
function FriendRemarkDialogPageMobile:Construct()
  FriendRemarkDialogPageMobile.super.Construct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Add(self, self.OnClickConfirm)
  end
  if self.Btn_MenuReturn then
    self.Btn_MenuReturn.OnClicked:Add(self, self.OnClickESC)
  end
  if self.InputText then
    self.InputText.OnTextChanged:Add(self, self.OnInputTextChange)
  end
  if self.Img_116 then
    self.Img_116.OnMouseButtonDownEvent:Bind(self, self.OnClickBG)
  end
end
function FriendRemarkDialogPageMobile:Destruct()
  FriendRemarkDialogPageMobile.super.Destruct(self)
  if self.Btn_Confirm then
    self.Btn_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  end
  if self.Btn_MenuReturn then
    self.Btn_MenuReturn.OnClicked:Remove(self, self.OnClickESC)
  end
  if self.InputText then
    self.InputText.OnTextChanged:Remove(self, self.OnInputTextChange)
  end
  if self.Img_116 then
    self.Img_116.OnMouseButtonDownEvent:Unbind()
  end
end
local getByteCount = function(str)
  local realByteCount = #str
  local length = 0
  local curBytePos = 1
  while true do
    local isSingleChar = false
    local step = 1
    local byteVal = string.byte(str, curBytePos)
    if byteVal > 239 then
      step = 4
    elseif byteVal > 223 then
      step = 3
    elseif byteVal > 191 then
      step = 2
    else
      isSingleChar = true
      step = 1
    end
    curBytePos = curBytePos + step
    if isSingleChar then
      length = length + 1
    else
      length = length + 2
    end
    if realByteCount < curBytePos then
      break
    end
  end
  return length
end
function FriendRemarkDialogPageMobile:OnInputTextChange(inText)
  local str
  if "" == inText or nil == inText then
    str = "0/15"
  elseif getByteCount(inText) > 15 then
    str = "15/15"
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "备注不能超过15个字符")
    self.InputText:SetText(self.LastRemark)
  else
    str = getByteCount(inText) .. "/15"
    self.LastRemark = inText
  end
  self.textNum:SetText(str)
end
function FriendRemarkDialogPageMobile:OnShow()
  self.actionOnShow()
end
function FriendRemarkDialogPageMobile:OnClose()
  self.actionOnClose()
end
function FriendRemarkDialogPageMobile:OnClickConfirm()
  self.actionOnClickConfirm()
end
function FriendRemarkDialogPageMobile:OnClickESC()
  self.actionOnClickESC()
end
function FriendRemarkDialogPageMobile:OnClickBG()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return FriendRemarkDialogPageMobile
