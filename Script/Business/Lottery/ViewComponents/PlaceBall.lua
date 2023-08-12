local OperationButton = require("Business/Lottery/ViewComponents/OperateButton")
local PlaceBallButton = class("PlaceBallButton", OperationButton)
function PlaceBallButton:OnHover()
  PlaceBallButton.super.OnHover(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonName, UE4.EFXButtonState.Normal)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Hovered)
  end
end
function PlaceBallButton:OnUnhover()
  PlaceBallButton.super.OnUnhover(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonName, UE4.EFXButtonState.Hovered)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Normal)
  end
end
function PlaceBallButton:OnPress()
  PlaceBallButton.super.OnPress(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonName, UE4.EFXButtonState.Hovered)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Pressed)
  end
end
function PlaceBallButton:OnRelease()
  PlaceBallButton.super.OnRelease(self)
  if self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, self.isHovered and UE4.EFXButtonState.Hovered or UE4.EFXButtonState.Normal)
  end
end
return PlaceBallButton
