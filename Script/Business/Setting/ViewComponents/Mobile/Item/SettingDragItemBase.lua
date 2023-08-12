local SettingDragItemBase = class("SettingDragItemBase")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingDragItemMediator = require("Business/Setting/Mediators/Mobile/SettingDragItemMediator")
function SettingDragItemBase:InitView(name, parent)
  self.name = name
  self.parent = parent
  self.TopY = 0
end
function SettingDragItemBase:SetLastChanged()
  LogInfo("MoveDragItem:SetLastChanged", "you need override it!")
end
function SettingDragItemBase:CorrectMoveOffset(offsetX, offsetY)
  local geometry = self:GetCachedGeometry()
  local itemTopLeft = UE4.USlateBlueprintLibrary.GetLocalTopLeft(geometry)
  local itemSize = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
  local renderScale = self.RenderTransform.Scale
  self.startGeometry = {
    itemSize = {
      X = itemSize.X * renderScale.X,
      Y = itemSize.Y * renderScale.Y
    },
    itemTopLeft = {
      X = itemTopLeft.X - itemSize.X * (renderScale.X - 1) / 2,
      Y = itemTopLeft.Y - itemSize.Y * (renderScale.Y - 1) / 2
    }
  }
  local tpfX = self.startGeometry.itemTopLeft.X + offsetX
  local tpfY = self.startGeometry.itemTopLeft.Y + offsetY
  local parentGeometry = self.parent:GetCachedGeometry()
  local localsize = UE4.USlateBlueprintLibrary.GetLocalSize(parentGeometry)
  if tpfY < self.TopY - self.startGeometry.itemSize.Y / 2 then
    offsetY = self.TopY - self.startGeometry.itemTopLeft.Y - self.startGeometry.itemSize.Y / 2
  elseif tpfY > localsize.Y - self.startGeometry.itemSize.Y / 2 then
    offsetY = localsize.Y - self.startGeometry.itemSize.Y / 2 - self.startGeometry.itemTopLeft.Y
  end
  if tpfX < -self.parent.adaptionValue - self.startGeometry.itemSize.X / 2 then
    offsetX = 0 - self.startGeometry.itemTopLeft.X - self.startGeometry.itemSize.X / 2 - self.parent.adaptionValue
  elseif tpfX > localsize.X - self.startGeometry.itemSize.X / 2 + self.parent.adaptionValue then
    offsetX = localsize.X - self.startGeometry.itemSize.X / 2 - self.startGeometry.itemTopLeft.X + self.parent.adaptionValue
  end
  return offsetX, offsetY
end
function SettingDragItemBase:MoveByOffset(offsetX, offsetY)
  local pos = self.Slot:GetPosition()
  local newPowX = pos.X + offsetX
  local newPowY = pos.Y + offsetY
  self:SetPosition(UE4.FVector2D(newPowX, newPowY))
end
function SettingDragItemBase:SetPosition(position)
  LogInfo("MoveDragItem:SetPosition", "you need override it!")
end
function SettingDragItemBase:OnBtnClick(MyGeometry, MouseEvent)
  GameFacade:SendNotification(NotificationDefines.Setting.MBSetDragIndex, {
    indexName = self.indexName
  })
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingDragItemBase:CheckCanAdjustPercent()
  return true
end
function SettingDragItemBase:SetPositionByTouchStart()
end
function SettingDragItemBase:BindEvent()
  self.ImageCapture.OnMouseButtonDownEvent:Unbind()
  self.ImageCapture.OnMouseButtonDownEvent:Bind(self, self.OnBtnClick)
end
function SettingDragItemBase:SetOrder(zOrder)
  self.Slot:SetZOrder(zOrder)
end
function SettingDragItemBase:SetSelected(bSelected)
  if bSelected then
    self.SelectNamedSlot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SelectNamedSlot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return SettingDragItemBase
