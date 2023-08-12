local SuperClass = require("Business/Setting/ViewComponents/Mobile/Item/SettingDragItemBase")
local SettingDragItem = class("SettingDragItem", SuperClass)
function SettingDragItem:InitView(name, parent)
  SuperClass.InitView(self, name, parent)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local difX, difY, opa, scale = SettingOperationProxy:RestoreDataByIndexKey(self.indexName, self.parent.abbrevIndex)
  self:Reset()
  self.InitPosition = self.Slot:GetPosition()
  self.InitOpacity = self:GetRenderOpacity()
  self.InitScale = self.RenderTransform.Scale.X
  self.currentData = SettingOperationProxy:GetTemplateData(self.indexName)
  self.currentData.opa = opa
  self.currentData.scale = scale
  self.currentData.difX = difX
  self.currentData.difY = difY
end
function SettingDragItem:SetLastChanged()
  self.Slot:SetPosition(UE4.FVector2D(self.InitPosition.X + self.currentData.difX, self.InitPosition.Y + self.currentData.difY))
  self:SetRenderOpacity(self.currentData.opa)
  self:SetRenderScaleEx(UE4.FVector2D(self.currentData.scale * self.InitScale, self.currentData.scale * self.InitScale))
end
function SettingDragItem:SetRenderScaleEx(scale)
  self:SetRenderScale(scale)
end
function SettingDragItem:SetPosition(position)
  self.Slot:SetPosition(position)
  self.currentData.difX = position.X - self.InitPosition.X
  self.currentData.difY = position.Y - self.InitPosition.Y
end
function SettingDragItem:Reset()
  if self.indexName == nil then
    return
  end
  if nil == self.InitPosition or nil == self.InitOpacity or nil == self.InitScale then
    return
  end
  self.Slot:SetPosition(self.InitPosition)
  self:SetRenderOpacity(self.InitOpacity)
  self:SetRenderScaleEx(UE4.FVector2D(self.InitScale, self.InitScale))
  if self.currentData then
    self.currentData.opa = self.InitOpacity
    self.currentData.scale = 1
    self.currentData.difX = 0
    self.currentData.difY = 0
  end
end
function SettingDragItem:SetPercent(percent, name)
  if "ButtonAlpha" == name then
    self:SetRenderOpacity(percent / 100)
    self.currentData.opa = percent / 100
  elseif "ButtonSize" == name then
    local scale = self.InitScale * percent / 100
    self:SetRenderScaleEx(UE4.FVector2D(scale, scale))
    self.currentData.scale = percent / 100
  end
end
return SettingDragItem
