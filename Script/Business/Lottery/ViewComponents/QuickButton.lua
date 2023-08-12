local OperationButton = require("Business/Lottery/ViewComponents/OperateButton")
local QuickButton = class("QuickButton", OperationButton)
function QuickButton:OnHover()
  QuickButton.super.OnHover(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Hovered)
  end
end
function QuickButton:OnUnhover()
  QuickButton.super.OnUnhover(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonName, UE4.EFXButtonState.Hovered)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Normal)
  end
end
function QuickButton:OnPress()
  QuickButton.super.OnPress(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Pressed, true)
  end
end
function QuickButton:OnRelease()
  QuickButton.super.OnRelease(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Released)
  end
end
return QuickButton
