local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SuperClass = require("Business/Setting/ViewComponents/Mobile/Item/SettingDragItem")
local MoveDragItem = class("MoveDragItem", SuperClass)
function MoveDragItem:InitView(name, parent)
  if parent.SprintDragItem then
    self.MoveLineDragItem = parent.SprintDragItem
  else
    LogInfo("MoveDragItem", "MoveLineDragItem is nil, you need check this, becasuse the MoveLineDragItem is related to the MoveDragItem")
  end
  SuperClass.InitView(self, name, parent)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  self.bOpenLeftJoyStick = SettingSaveDataProxy:GetTemplateValueByKey("SmartAutoInWall") == UE4.ESmartAutoInWall.LeftJoyStick + 1
end
function MoveDragItem:MoveByOffset(offsetX, offsetY)
  SuperClass.MoveByOffset(self, offsetX, offsetY)
  self.MoveLineDragItem:MoveByPureOffset(offsetX, offsetY)
end
function MoveDragItem:SetLastChanged()
  SuperClass.SetLastChanged(self)
  self.MoveLineDragItem:MoveByOffsetFromStart(self.currentData.difX, self.currentData.difY)
end
function MoveDragItem:SetPosition(position)
  SuperClass.SetPosition(self, position)
  self.MoveLineDragItem:MoveByOffsetFromStart(self.currentData.difX, self.currentData.difY)
end
function MoveDragItem:SetPositionByTouchStart()
  self.MoveLineDragItem:SetPositionByTouchStart()
end
function MoveDragItem:Reset(bSelf)
  SuperClass.Reset(self)
  if bSelf then
    if self.currentData then
      self.MoveLineDragItem:MoveByOffsetFromStart(self.currentData.difX, self.currentData.difY)
    end
  elseif self.currentData then
    self.MoveLineDragItem:MoveByOffset(self.currentData.difX, self.currentData.difY)
  end
end
function MoveDragItem:CorrectMoveOffset(offsetX, offsetY)
  if self.bOpenLeftJoyStick then
    local geometry = self:GetCachedGeometry()
    local itemSize = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
    local renderScale = self.RenderTransform.Scale
    local sprintSize = UE4.USlateBlueprintLibrary.GetLocalSize(self.parent.SprintDragItem:GetCachedGeometry())
    self.TopY = math.abs(self.parent.line.Slot:GetSize().Y) - itemSize.Y * (renderScale.Y - 1) / 2 + itemSize.Y / 2 + sprintSize.Y / 2
    offsetX, offsetY = SuperClass.CorrectMoveOffset(self, offsetX, offsetY)
  else
    offsetX, offsetY = SuperClass.CorrectMoveOffset(self, offsetX, offsetY)
  end
  return offsetX, offsetY
end
function MoveDragItem:SetOrder(zOrder)
  self.Slot:SetZOrder(zOrder)
  self.MoveLineDragItem:SetOrder(zOrder)
end
return MoveDragItem
