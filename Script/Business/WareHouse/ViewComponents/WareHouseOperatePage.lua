local WareHouseOperatePage = class("WareHouseOperatePage", PureMVC.ViewComponentPage)
local WareHouseOperateMediator = require("Business/WareHouse/Mediators/WareHouseOperateMediator")
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
local Valid
function WareHouseOperatePage:OnOpen(luaOpenData, nativeOpenData)
  self:BindEvent()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
end
function WareHouseOperatePage:OnClose()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  self:RemoveEvent()
end
function WareHouseOperatePage:LuaHandleKeyEvent(key, inputEvent)
  if 0 == self.SwitcherUi then
    Valid = self.ButtonSave and self.ButtonSave:MonitorKeyDown(key, inputEvent)
    Valid = self.ButtonClose and self.ButtonClose:MonitorKeyDown(key, inputEvent)
  elseif 1 == self.SwitcherUi then
    Valid = self.ButtonY and self.ButtonY:MonitorKeyDown(key, inputEvent)
    Valid = self.ButtonClose_1 and self.ButtonClose_1:MonitorKeyDown(key, inputEvent)
  end
  return false
end
function WareHouseOperatePage:UpdatePanel(AllData)
  if not AllData then
    return
  end
  local Data = AllData.OperateData
  Valid = self.TextSwitcher and self.TextSwitcher:SetActiveWidgetIndex(AllData.IsUseOperate and 1 or 0)
  Valid = self.ItemCurrency and self.ItemCurrency:SetVisibility(AllData.IsUseOperate and Collapsed or Visible)
  Valid = self.Switcher and self.Switcher:SetActiveWidgetIndex(AllData.IsUseOperate and Data.bIsModNameCard and 0 or 1)
  Valid = self.ItemMaxCanvas and self.ItemMaxCanvas:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.SwitcherUi = AllData.IsUseOperate and Data.bIsModNameCard and 0 or 1
  self.UUID = Data.UUID
  self.InItemID = Data.InItemID
  Valid = self.Txt_ItemName and self.Txt_ItemName:SetText(Data.itemName)
  Valid = self.Img_Item and self:SetImageByTexture2D(self.Img_Item, Data.softTexture)
  Valid = self.Img_Quality and self.Img_Quality:SetColorAndOpacity(Data.ImgQualityColor)
  self.LimitNum = Data.count
  if self.LimitNum > self.MaxNum then
    self.LimitNum = self.MaxNum
  end
  Valid = self.Txt_TotalCnt and self.Txt_TotalCnt:SetText(Data.count)
  Valid = Data.CurrencyIconItem and self.Img_Currency and self:SetImageByTexture2D(self.Img_Currency, Data.CurrencyIconItem)
  Valid = self.Txt_CurrencyCnt and self.Txt_CurrencyCnt:SetText(Data.saleParam)
  self.CurrentCurrencyPerValue = Data.saleParam
  Valid = self.Slider_OPCnt and self.Slider_OPCnt:SetMinValue(self.MinNum)
  Valid = self.Slider_OPCnt and self.Slider_OPCnt:SetMaxValue(self.LimitNum)
  Valid = self.Slider_OPB and self.Slider_OPB:SetPercent(0)
  Valid = self.Slider_OPCnt and self.Slider_OPCnt:SetValue(1)
  Valid = self.Txt_OPCnt and self.Txt_OPCnt:SetText(1)
end
function WareHouseOperatePage:BindEvent()
  Valid = self.Slider_OPCnt and self.Slider_OPCnt.OnValueChanged:Add(self, self.SlideValueChange)
  Valid = self.Btn_Inc and self.Btn_Inc.OnClicked:Add(self, self.ClickIncreaseButton)
  Valid = self.Btn_Dec and self.Btn_Dec.OnClicked:Add(self, self.ClickDecreaseButton)
  Valid = self.ButtonY and self.ButtonY.OnClickEvent:Add(self, self.ClickYButton)
  Valid = self.ButtonSave and self.ButtonSave.OnClickEvent:Add(self, self.ClickSaveButton)
  Valid = self.ButtonClose and self.ButtonClose.OnClickEvent:Add(self, self.ClickCloseOperateButton)
  Valid = self.ButtonClose_1 and self.ButtonClose_1.OnClickEvent:Add(self, self.ClickCloseOperateButton)
  Valid = self.ButtonEnterMB and self.ButtonEnterMB.OnClickEvent:Add(self, self.ClickYButton)
  Valid = self.ButtonSaveMB and self.ButtonSaveMB.OnClickEvent:Add(self, self.ClickSaveButton)
  Valid = self.ButtonCloseMB and self.ButtonCloseMB.OnClickEvent:Add(self, self.ClickCloseOperateButton)
  Valid = self.ButtonCloseMB_1 and self.ButtonCloseMB_1.OnClickEvent:Add(self, self.ClickCloseOperateButton)
end
function WareHouseOperatePage:RemoveEvent()
  Valid = self.Slider_OPCnt and self.Slider_OPCnt.OnValueChanged:Remove(self, self.SlideValueChange)
  Valid = self.Btn_Inc and self.Btn_Inc.OnClicked:Remove(self, self.ClickIncreaseButton)
  Valid = self.Btn_Dec and self.Btn_Dec.OnClicked:Remove(self, self.ClickDecreaseButton)
  Valid = self.ButtonY and self.ButtonY.OnClickEvent:Remove(self, self.ClickYButton)
  Valid = self.ButtonSave and self.ButtonSave.OnClickEvent:Remove(self, self.ClickSaveButton)
  Valid = self.ButtonClose and self.ButtonClose.OnClickEvent:Remove(self, self.ClickCloseOperateButton)
  Valid = self.ButtonClose_1 and self.ButtonClose_1.OnClickEvent:Remove(self, self.ClickCloseOperateButton)
  Valid = self.ButtonEnterMB and self.ButtonEnterMB.OnClickEvent:Remove(self, self.ClickYButton)
  Valid = self.ButtonSaveMB and self.ButtonSaveMB.OnClickEvent:Remove(self, self.ClickSaveButton)
  Valid = self.ButtonCloseMB and self.ButtonCloseMB.OnClickEvent:Remove(self, self.ClickCloseOperateButton)
  Valid = self.ButtonCloseMB_1 and self.ButtonCloseMB_1.OnClickEvent:Remove(self, self.ClickCloseOperateButton)
end
function WareHouseOperatePage:SlideValueChange(value)
  self:UpdateCurrencyValue(math.floor(value))
end
function WareHouseOperatePage:ClickIncreaseButton()
  local CurrentValue = math.modf(math.clamp(tonumber(self.Txt_OPCnt:GetText()) + 1, 1, tonumber(self.Slider_OPCnt.MaxValue)))
  self:UpdateCurrencyValue(CurrentValue)
end
function WareHouseOperatePage:ClickDecreaseButton()
  local CurrentValue = math.modf(math.clamp(tonumber(self.Txt_OPCnt:GetText()) - 1, 1, tonumber(self.Slider_OPCnt.MaxValue)))
  self:UpdateCurrencyValue(CurrentValue)
end
function WareHouseOperatePage:UpdateCurrencyValue(value)
  local CurrentCurrencyNum = tonumber(value)
  local curNum = CurrentCurrencyNum - 1
  local maxNUm = self.Slider_OPCnt.MaxValue - 1
  Valid = self.Slider_OPCnt and self.Slider_OPCnt:SetValue(CurrentCurrencyNum)
  Valid = self.Slider_OPB and self.Slider_OPB:SetPercent(curNum <= 0 and 0 or curNum / maxNUm)
  Valid = self.Txt_OPCnt and self.Txt_OPCnt:SetText(CurrentCurrencyNum)
  if CurrentCurrencyNum == self.MaxNum then
    Valid = self.Txt_OPCnt and self.Txt_OPCnt:SetColorAndOpacity(self.MaxColor)
    Valid = self.ItemMaxCanvas and self.ItemMaxCanvas:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    Valid = self.ItemMaxCanvas and self.ItemMaxCanvas:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.Txt_OPCnt and self.Txt_OPCnt:SetColorAndOpacity(self.NormalColor)
  end
  Valid = self.Txt_CurrencyCnt and self.Txt_CurrencyCnt:SetText(self.CurrentCurrencyPerValue * CurrentCurrencyNum)
end
function WareHouseOperatePage:ClickYButton()
  if self.EditableText:HasKeyboardFocus() then
    return nil
  end
  local body = {
    ItemID = self.InItemID,
    UUid = self.UUID,
    Num = tonumber(self.Txt_OPCnt:GetText())
  }
  if 0 == self.TextSwitcher:GetActiveWidgetIndex() then
    GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):ReqSellItem(body)
  else
    GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):ReqUseItem(body)
  end
end
function WareHouseOperatePage:ClickSaveButton()
  if self.EditableText:HasKeyboardFocus() then
    return nil
  end
  local TempText = self.EditableText:GetText()
  local LoginSubSystem = UE.UPMLoginSubSystem.GetInstance(self)
  local TempTextType = LoginSubSystem and LoginSubSystem:CheckPlayerNameValid(TempText)
  if 0 == TempTextType then
    GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy):ReqModName({
      UUid = self.UUID,
      NickName = TempText
    })
  elseif 1 == TempTextType then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Login_PlayerNameIsEmpty"))
  elseif 2 == TempTextType then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Login_PlayerNameLenBigger"))
  end
end
function WareHouseOperatePage:ClickCloseOperateButton()
  ViewMgr:ClosePage(self)
end
function WareHouseOperatePage:ListNeededMediators()
  return {WareHouseOperateMediator}
end
return WareHouseOperatePage
