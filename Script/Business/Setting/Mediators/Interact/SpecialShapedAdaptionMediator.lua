local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SpecialShapedAdaptionMediator = class("SpecialShapedAdaptionMediator", SuperClass)
function SpecialShapedAdaptionMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  self:DelayShowOptimizationPosition()
end
function SpecialShapedAdaptionMediator:SetWidgetPanelPosByPercent(widget, percent)
  local view = self:GetViewComponent()
  local barGeometry = view.ProgressBar:GetCachedGeometry()
  local barSize = UE4.USlateBlueprintLibrary.GetLocalSize(barGeometry)
  local targetX = barSize.X * percent
  local absoultePos = UE4.USlateBlueprintLibrary.LocalToAbsolute(barGeometry, UE4.FVector2D(targetX, 0))
  local ScreenPanelGeomerty = view.ScreenPanel:GetCachedGeometry()
  local localPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(ScreenPanelGeomerty, absoultePos)
  local canvasSlot = widget.Slot
  canvasSlot:SetPosition(UE4.FVector2D(localPos.X, canvasSlot:GetPosition().Y))
end
function SpecialShapedAdaptionMediator:DelayShowOptimizationPosition()
  local view = self:GetViewComponent()
  if view.NotchScreenPanel then
    view.ScreenPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return SpecialShapedAdaptionMediator
