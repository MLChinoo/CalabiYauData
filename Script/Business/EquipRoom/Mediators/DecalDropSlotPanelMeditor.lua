local DecalDropSlotPanelMeditor = class("DecalDropSlotPanelMeditor", PureMVC.Mediator)
function DecalDropSlotPanelMeditor:OnRegister()
  self.super:OnRegister()
  self:GetViewComponent().clickItemEvent:Add(self.UpdateSlotName, self)
end
function DecalDropSlotPanelMeditor:ListNotificationInterests()
  return {}
end
function DecalDropSlotPanelMeditor:UpdateSlotName(useState)
  local printUseStateName = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PaintUseStateName_" .. useState)
  self:GetViewComponent():UpdateCurrentSelectSlotName(printUseStateName)
end
return DecalDropSlotPanelMeditor
