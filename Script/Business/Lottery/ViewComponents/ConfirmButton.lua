local OperationButton = require("Business/Lottery/ViewComponents/OperateButton")
local ConfirmButton = class("ConfirmButton", OperationButton)
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function ConfirmButton:UpdateButtonState(ballNum)
  if self.buttonStatus == nil then
    return
  end
  if 0 == ballNum then
    if self.buttonStatus ~= LotteryEnum.buttonActiveStatus.Null then
      if self.ButtonActiveName then
        GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Disabled)
      end
      if self.ButtonSuperName then
        GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Disabled)
      end
      self.buttonStatus = LotteryEnum.buttonActiveStatus.Null
    end
  elseif ballNum < 10 then
    if self.buttonStatus ~= LotteryEnum.buttonActiveStatus.Active then
      if self.ButtonSuperName then
        GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Disabled)
      end
      if self.ButtonActiveName then
        GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Normal)
      end
      self.buttonStatus = LotteryEnum.buttonActiveStatus.Active
    end
  elseif self.buttonStatus ~= LotteryEnum.buttonActiveStatus.Super then
    if self.ButtonActiveName then
      GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Disabled)
    end
    if self.ButtonSuperName then
      GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Normal)
    end
    self.buttonStatus = LotteryEnum.buttonActiveStatus.Super
  end
end
function ConfirmButton:Construct()
  ConfirmButton.super.Construct(self)
  self.buttonStatus = LotteryEnum.buttonActiveStatus.Null
end
function ConfirmButton:OnHover()
  ConfirmButton.super.OnHover(self)
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Null and self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Hovered)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Active and self.ButtonActiveName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Hovered)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Super and self.ButtonSuperName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Hovered)
  end
end
function ConfirmButton:OnUnhover()
  ConfirmButton.super.OnUnhover(self)
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Null and self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonName, UE4.EFXButtonState.Hovered)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Normal)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Active and self.ButtonActiveName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonActiveName, UE4.EFXButtonState.Hovered)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Normal)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Super and self.ButtonSuperName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):StopPlayParticle(self.ButtonSuperName, UE4.EFXButtonState.Hovered)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Normal)
  end
end
function ConfirmButton:OnPress()
  ConfirmButton.super.OnPress(self)
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Null and self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Pressed, true)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Active and self.ButtonActiveName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Pressed, true)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Super and self.ButtonSuperName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Pressed, true)
  end
end
function ConfirmButton:OnRelease()
  ConfirmButton.super.OnRelease(self)
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Null and self.ButtonName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Released)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Active and self.ButtonActiveName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonActiveName, UE4.EFXButtonState.Released)
  end
  if self.buttonStatus == LotteryEnum.buttonActiveStatus.Super and self.ButtonSuperName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonSuperName, UE4.EFXButtonState.Released)
  end
end
return ConfirmButton
