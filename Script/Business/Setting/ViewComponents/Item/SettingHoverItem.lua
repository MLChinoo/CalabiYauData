local SettingHoverItem = class("SettingHoverItem", PureMVC.ViewComponentPanel)
local ResolveGeometryAndMouseEvent = function(MyGeometry, MouseEvent)
  local screenSpacePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local pos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, screenSpacePosition)
  local itemSize = UE4.USlateBlueprintLibrary.GetLocalSize(MyGeometry)
  return pos, itemSize
end
function SettingHoverItem:SetDelegate(del)
  self.del = del
end
function SettingHoverItem:OnMouseEnter(MyGeometry, MouseEvent)
  local pos, itemSize = ResolveGeometryAndMouseEvent(MyGeometry, MouseEvent)
  if self.del and self.del.OnMouseEnter then
    self.del:OnMouseEnterByDel(pos, itemSize)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingHoverItem:OnMouseMove(MyGeometry, MouseEvent)
  local pos, itemSize = ResolveGeometryAndMouseEvent(MyGeometry, MouseEvent)
  if self.del and self.del.OnMouseMove then
    self.del:OnMouseMoveByDel(pos, itemSize)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingHoverItem:OnMouseLeave()
  if self.del and self.del.OnMouseLeave then
    self.del:OnMouseLeaveByDel()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingHoverItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  local pos, itemSize = ResolveGeometryAndMouseEvent(MyGeometry, MouseEvent)
  if self.del and self.del.OnMouseButtonDown then
    self.del:OnMouseButtonDownByDel(pos, itemSize)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingHoverItem:OnTouchStarted(MyGeometry, MouseEvent)
  local pos, itemSize = ResolveGeometryAndMouseEvent(MyGeometry, MouseEvent)
  if self.del and self.del.OnMouseButtonDown then
    self.del:OnMouseButtonDownByDel(pos, itemSize)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return SettingHoverItem
