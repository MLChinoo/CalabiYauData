local ActivityReBatePage = class("ActivityReBatePage", PureMVC.ViewComponentPage)
local ActivityReBateMediator = require("Business/Activities/RechargeBate/Mediators/ActivityReBateMediator")
local Valid
function ActivityReBatePage:ListNeededMediators()
  return {ActivityReBateMediator}
end
function ActivityReBatePage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function ActivityReBatePage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.OnClickClose, self)
  Valid = self.Button_GetMoney and self.Button_GetMoney.OnClickEvent:Add(self, self.OnClickGetMoney)
  Valid = self.Btn_Tips and self.Btn_Tips.OnClicked:Add(self, self.OnClickTip)
end
function ActivityReBatePage:OnClose()
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.OnClickClose, self)
  Valid = self.Button_GetMoney and self.Button_GetMoney.OnClickEvent:Remove(self, self.OnClickGetMoney)
  Valid = self.Btn_Tips and self.Btn_Tips.OnClicked:Remove(self, self.OnClickTip)
end
function ActivityReBatePage:Init(PageData)
  if PageData then
    Valid = PageData.ChargeNum and self.Text_RMB and self.Text_RMB:SetText(PageData.ChargeNum)
    Valid = PageData.RebateNum and self.Text_ReBeta and self.Text_ReBeta:SetText(PageData.RebateNum)
    Valid = PageData.LeftTimeText and self.Text_LeftTime and self.Text_LeftTime:SetText(PageData.LeftTimeText)
    Valid = PageData.OpenTimeText and self.Text_OpenTime and self.Text_OpenTime:SetText(PageData.OpenTimeText)
    Valid = PageData.bHasTaken and self:SetButtonDisable()
    self.OpenTimeText = PageData.OpenTimeText
  end
end
function ActivityReBatePage:SetButtonDisable()
  Valid = self.Button_GetMoney and self.Button_GetMoney:SetIsEnabled(false)
end
function ActivityReBatePage:OnClickClose()
  ViewMgr:ClosePage(self)
end
function ActivityReBatePage:OnClickGetMoney()
  GameFacade:RetrieveProxy(ProxyNames.RechargeBateProxy):ReqReChargeTake()
end
function ActivityReBatePage:OnClickTip()
  ViewMgr:OpenPage(self, UIPageNameDefine.ActivityRechargeTipPage, nil, self.OpenTimeText)
end
return ActivityReBatePage
