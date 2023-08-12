local SuperClass = require("Business/Setting/ViewComponents/Mobile/Item/SettingDragItemBase")
local MoveLineDragItem = class("MoveLineDragItem", SuperClass)
function MoveLineDragItem:InitView(name, parent)
  SuperClass.InitView(self, name, parent)
  self.LineImage = parent.line
  if self.InitSize == nil then
    if self.LineImage and self.LineImage.Slot then
      local size = self.LineImage.Slot:GetSize()
      self.InitSize = size
    else
      LogInfo("MoveLineDragItem ", "lineImage's size is nil, you need to check this!")
    end
  end
  self:Reset()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local Config = SettingConfigProxy:GetCommonConfigMap()
  self.InitPosition = self.Slot:GetPosition()
  self.minLength = Config.runLengthRange.min
  self.maxLength = Config.runLengthRange.max
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local difLength = SettingOperationProxy:RestoreDataByIndexKey(self.indexName, self.parent.abbrevIndex)
  self.currentData = SettingOperationProxy:GetTemplateData(self.indexName)
  self.currentData.difLength = difLength
end
function MoveLineDragItem:SetLastChanged()
  self:SetPositionByLineLengthOffset(self.currentData.difLength)
end
function MoveLineDragItem:CorrectMoveOffset(offsetX, offsetY)
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
  local NegLength = self.InitSize.Y + self.currentData.difLength + offsetY
  local fixedLength = math.clamp(-NegLength, self.minLength, self.maxLength)
  if fixedLength <= self.minLength then
    offsetY = 0
  elseif fixedLength >= self.maxLength then
    offsetY = 0
  end
  return offsetX, offsetY
end
function MoveLineDragItem:MoveByOffset(offsetX, offsetY)
  local pos = self.Slot:GetPosition()
  local newPowY = pos.Y + offsetY
  self.Slot:SetPosition(UE4.FVector2D(pos.X, newPowY))
  local length = self.currentData.difLength + offsetY
  self:SetPositionByLineLengthOffset(length)
end
function MoveLineDragItem:MoveByPureOffset(offsetX, offsetY)
  local pos = self.Slot:GetPosition()
  local newPowY = pos.Y + offsetY
  self.Slot:SetPosition(UE4.FVector2D(pos.X, newPowY))
end
function MoveLineDragItem:MoveByOffsetFromStart(offsetX, offsetY)
  if self.InitPosition then
    self.Slot:SetPosition(UE4.FVector2D(self.InitPosition.X + offsetX, self.InitPosition.Y + offsetY + self.currentData.difLength))
  end
end
function MoveLineDragItem:SetPositionByLineLengthOffset(lineLengthOffset)
  local targetDifLength = lineLengthOffset + self.InitSize.Y
  local difLength = lineLengthOffset
  self.LineImage.Slot:SetSize(UE4.FVector2D(self.InitSize.X, targetDifLength))
  self.currentData.difLength = difLength
end
function MoveLineDragItem:Reset(bSelf)
  if self.indexName == nil then
    return
  end
  if nil == self.currentData then
    return
  end
  if bSelf then
    self:SetPositionByLineLengthOffset(0)
    if self.currentData then
      self.currentData.difLength = 0
    end
    local movedata = self.parent.MoveDragItem.currentData
    self:MoveByOffsetFromStart(movedata.difX, movedata.difY)
  else
    self:SetPositionByLineLengthOffset(0)
    if self.currentData then
      self.currentData.difLength = 0
    end
    self.Slot:SetPosition(self.InitPosition)
  end
end
function MoveLineDragItem:SetPositionByTouchMoved(position)
  local curPos = self.Slot:GetPosition()
  local currentOffsetY = position.Y - self.startPosition.Y
  local NegLength = self.InitSize.Y + self.currentData.difLength + currentOffsetY
  if NegLength > 0 then
    return
  end
  local fixedLength = math.clamp(-NegLength, self.minLength, self.maxLength)
  local fixedOffsetY = -(self.InitSize.Y + self.currentData.difLength) - fixedLength
  local fixedPositionY = self.startPosition.Y + fixedOffsetY
  self.Slot:SetPosition(UE4.FVector2D(curPos.X, fixedPositionY))
  self.LineImage.Slot:SetSize(UE4.FVector2D(self.InitSize.X, self.InitSize.Y + self.currentData.difLength + fixedOffsetY))
  self.offsetY = fixedOffsetY
end
return MoveLineDragItem
