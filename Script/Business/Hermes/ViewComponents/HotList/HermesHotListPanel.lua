local HermesHotListPanel = class("HermesHotListPanel", PureMVC.ViewComponentPage)
local Valid
local Margin = UE4.FMargin()
Margin.Bottom, Margin.Left, Margin.Right, Margin.Top = 5, 5, 5, 5
function HermesHotListPanel:Update(Data)
  if self.SingleProductPanelClass then
    local SingleProductClass = ObjectUtil:LoadClass(self.SingleProductPanelClass)
    if self.GridPanel then
      self.GridPanel:ClearChildren()
      local ProductPanel, GridSlot
      for index, value in pairs(Data) do
        ProductPanel = UE4.UWidgetBlueprintLibrary.Create(self, SingleProductClass)
        if not ProductPanel then
          break
        end
        ProductPanel:Init(value)
        GridSlot = self.GridPanel:AddChildToGrid(ProductPanel, value.Row, value.Column)
        if GridSlot then
          GridSlot:SetPadding(Margin)
          GridSlot:SetColumnSpan(value.SizeWidth)
          GridSlot:SetRowSpan(value.SizeHeight)
        end
        ProductPanel = nil
      end
    end
  end
end
return HermesHotListPanel
