local KaChatPanelMobile = class("KaChatPanelMobile", PureMVC.ViewComponentPanel)
local KaChatMediator = require("Business/KaPhone/Mediators/KaChatMediator")
function KaChatPanelMobile:GetIsActive()
  return self.IsActive
end
function KaChatPanelMobile:SetIsActive(IsActive)
  self.IsActive = IsActive
end
function KaChatPanelMobile:ListNeededMediators()
  return {KaChatMediator}
end
function KaChatPanelMobile:Construct()
  KaChatPanelMobile.super.Construct(self)
end
function KaChatPanelMobile:Destruct()
  KaChatPanelMobile.super.Destruct(self)
end
return KaChatPanelMobile
