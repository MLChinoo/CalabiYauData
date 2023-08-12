local DragItem = class("DragItem", PureMVC.ViewComponentPanel)
function DragItem:SetDragItemIcon(texture, bIcon)
  local activeIndex = 0
  if bIcon then
    activeIndex = 1
    if self.Img_Item and texture then
      self.Img_Item:SetBrushFromTexture(texture, false)
    end
  end
  self.WidgetSwitcher_Item:SetActiveWidgetIndex(activeIndex)
end
return DragItem
