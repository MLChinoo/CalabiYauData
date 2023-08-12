local BorderItem = class("BorderItem", PureMVC.ViewComponentPanel)
function BorderItem:ListNeededMediators()
  return {}
end
function BorderItem:InitializeLuaEvent()
  self.color = {
    1,
    1,
    0
  }
  self.lastBorderOpactiy = 1
  self.curBorderOpacity = 1
  self.curContentOpacity = 1
  self.bSwtich = false
  self.curContentLength = 0
  self.curContentWidth = 0
  self.oriSize = self.Border_33.Slot:GetSize()
  self.curThicknessPixel = self.Image_154.Slot.Padding.Top
end
function BorderItem:RefreshItem()
end
function BorderItem:SetColor(color)
  self.color = color
  self:SetContentOpacity(self.curContentOpacity)
end
function BorderItem:SetBorderOpacity(opacity)
  self.curBorderOpacity = opacity
  self.Border_33:SetBrushColor(UE4.FLinearColor(0, 0, 0, opacity))
end
function BorderItem:SetContentOpacity(opacity)
  self.curContentOpacity = opacity
  self.Border_33:SetContentColorAndOpacity(UE4.FLinearColor(self.color[1], self.color[2], self.color[3], opacity))
end
function BorderItem:SetBorderSwitch(bSwitch)
  if bSwitch then
    self:SetBorderOpacity(self.lastBorderOpactiy)
    self.lastBorderOpactiy = nil
  else
    self.lastBorderOpactiy = self.curBorderOpacity
    self:SetBorderOpacity(0)
  end
end
function BorderItem:SetBorderThickness(pixel)
  if self.curThicknessPixel == pixel then
    return
  end
  local lastSize = self.Border_33.Slot:GetSize()
  self.Border_33.Slot:SetSize(UE4.FVector2D(lastSize.X + 2 * (pixel - self.curThicknessPixel), lastSize.Y + 2 * (pixel - self.curThicknessPixel)))
  self.curThicknessPixel = pixel
  local margin = UE4.FMargin()
  margin.Top = pixel
  margin.Bottom = pixel
  margin.Left = pixel
  margin.Right = pixel
  self.Image_154.Slot:SetPadding(margin)
end
function BorderItem:SetContentLength(length)
  local lastSize = self.Border_33.Slot:GetSize()
  self.Border_33.Slot:SetSize(UE4.FVector2D(lastSize.X - self.curContentLength + length, lastSize.Y))
  self.curContentLength = length
end
function BorderItem:SetContentWidth(width)
  local lastSize = self.Border_33.Slot:GetSize()
  self.Border_33.Slot:SetSize(UE4.FVector2D(lastSize.X, lastSize.Y - self.curContentWidth + width))
  self.curContentWidth = width
end
return BorderItem
