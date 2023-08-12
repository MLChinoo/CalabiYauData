local InviteInfoPanelMediator = require("Business/Friend/Mediators/InviteInfoPanelMediator")
local InviteInfoPanel = class("InviteInfoPanel", PureMVC.ViewComponentPage)
function InviteInfoPanel:OnInitialized()
  InviteInfoPanel.super.OnInitialized(self)
end
function InviteInfoPanel:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function InviteInfoPanel:ListNeededMediators()
  return {InviteInfoPanelMediator}
end
function InviteInfoPanel:InitializeLuaEvent()
  self.actionOnClickIcon = LuaEvent.new()
end
function InviteInfoPanel:Construct()
  InviteInfoPanel.super.Construct(self)
  self.Image_Icon.OnMouseButtonDownEvent:Bind(self, self.OnClickIcon)
end
function InviteInfoPanel:Destruct()
  InviteInfoPanel.super.Destruct(self)
  self.Image_Icon.OnMouseButtonDownEvent:Remove(self, self.OnClickIcon)
end
function InviteInfoPanel:OnClickIcon()
  self.actionOnClickIcon()
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return InviteInfoPanel
