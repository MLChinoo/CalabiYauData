local BorderItemEx = class("BorderItemEx", PureMVC.ViewComponentPanel)
function BorderItemEx:ListNeededMediators()
  return {}
end
function BorderItemEx:InitializeLuaEvent()
  self.color = {
    1,
    1,
    0
  }
  self.lastBorderOpactiy = 1
  self.curBorderOpacity = 1
  self.curContentOpacity = 1
  self.bSwtich = true
  self.curContentLength = 0
  self.curContentWidth = 0
  self.curThicknessPixel = 1
  self.borderItemList = {
    self.ImageUp,
    self.ImageLeft,
    self.ImageRight,
    self.ImageDown
  }
  self.bInner = false
end
function BorderItemEx:SetColor(color)
  self.color = color
  self:SetContentOpacity(self.curContentOpacity)
end
function BorderItemEx:SetIsCenter(bCenter)
  self.bCenter = bCenter
  self:RefreshView()
end
function BorderItemEx:SetBorderOpacity(opacity)
  self.curBorderOpacity = opacity
  for i, item in ipairs(self.borderItemList) do
    item:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, opacity))
  end
end
function BorderItemEx:SetContentOpacity(opacity)
  self.curContentOpacity = opacity
  self.ImageCenter:SetColorAndOpacity(UE4.FLinearColor(self.color[1], self.color[2], self.color[3], opacity))
end
function BorderItemEx:SetBorderSwitch(bSwitch)
  for i, item in ipairs(self.borderItemList) do
    if bSwitch then
      item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      item:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function BorderItemEx:SetBorderThickness(pixel)
  if self.curThicknessPixel == pixel then
    return
  end
  self.curThicknessPixel = pixel
  self:RefreshView()
end
function BorderItemEx:SetContentLength(length)
  print("SetContentLength >>>>>> ", length)
  if self.curContentLength == length then
    return
  end
  self.curContentLength = length
  self:RefreshView()
end
function BorderItemEx:SetContentWidth(width)
  if self.curContentWidth == width then
    return
  end
  self.curContentWidth = width
  self:RefreshView()
end
function BorderItemEx:SetVisible(bVis)
  self.bSwtich = bVis
  self:RefreshView()
end
function BorderItemEx:RefreshView()
  local thickness = self.curThicknessPixel
  local height = self.curContentLength
  local width = self.curContentWidth
  local x, y
  if self.bCenter then
    x, y = -width / 2, -height / 2
  else
    x, y = -width / 2, 0
  end
  if self.bSwtich then
    if 0 == height or 0 == width then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.bInner then
    print("x, y", x, y)
  end
  self.ImageCenter.Slot:SetSize(UE4.FVector2D(width, height))
  self.ImageCenter.Slot:SetPosition(UE4.FVector2D(x, y))
  self.ImageUp.Slot:SetSize(UE4.FVector2D(width + thickness, thickness))
  self.ImageUp.Slot:SetPosition(UE4.FVector2D(x, y - thickness))
  self.ImageDown.Slot:SetSize(UE4.FVector2D(width + thickness, thickness))
  self.ImageDown.Slot:SetPosition(UE4.FVector2D(x - thickness, y + height))
  self.ImageLeft.Slot:SetSize(UE4.FVector2D(thickness, height + thickness))
  self.ImageLeft.Slot:SetPosition(UE4.FVector2D(x - thickness, y - thickness))
  self.ImageRight.Slot:SetSize(UE4.FVector2D(thickness, height + thickness))
  self.ImageRight.Slot:SetPosition(UE4.FVector2D(x + width, y))
end
function BorderItemEx:PrintLog()
  print(self.curThicknessPixel, self.curContentLength, self.curContentWidth)
  print(self.ImageCenter.Slot:GetPosition())
end
function BorderItemEx:GetCenterPosition(parent)
  local cachedGeometry = self.ImageCenter:GetCachedGeometry()
  print("GetCenterPosition >>>>>>>>>>>>>>>")
  local lt = UE4.USlateBlueprintLibrary.GetLocalTopLeft(cachedGeometry)
  local ls = UE4.USlateBlueprintLibrary.GetLocalSize(cachedGeometry)
  local CenterPos = UE4.FVector2D(lt.X + ls.X / 2, lt.Y + ls.Y / 2)
  cachedGeometry = self:GetCachedGeometry()
  local tt = UE4.USlateBlueprintLibrary.LocalToAbsolute(cachedGeometry, CenterPos)
  print(tt)
  return tt
end
return BorderItemEx
