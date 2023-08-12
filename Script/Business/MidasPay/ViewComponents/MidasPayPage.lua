local MidasPayPageMediator = require("Business/MidasPay/Mediators/MidasPayPageMediator")
local MidasPayPage = class("MidasPayPage", PureMVC.ViewComponentPage)
function MidasPayPage:ListNeededMediators()
  return {MidasPayPageMediator}
end
function MidasPayPage:InitializeLuaEvent()
end
function MidasPayPage:OnOpen(luaOpenData, nativeOpenData)
  if self.CloseBtn then
    self.CloseBtn.OnClicked:Add(self, self.OnClickGoBack)
  end
  if self.PayWebView then
    local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
    self.PayWebView:BindWebUObject("ueobj", midasSys, true)
    self.PayWebView:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PayWebView:LoadURL("https://kq.calatopia.com/MidasPay.html")
  end
end
function MidasPayPage:OnClose()
  if self.CloseBtn then
    self.CloseBtn.OnClicked:Remove(self, self.OnClickGoBack)
  end
end
function MidasPayPage:OnClickGoBack()
  ViewMgr:ClosePage(self)
end
return MidasPayPage
