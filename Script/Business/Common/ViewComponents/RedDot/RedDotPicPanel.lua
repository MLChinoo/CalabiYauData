local RedDotPicPanel = class("RedDotPicPanel", PureMVC.ViewComponentPanel)
local redDotPicList = {}
local playAnimTask
function RedDotPicPanel:AddRedDotIns()
  table.insert(redDotPicList, self)
  if nil == playAnimTask then
    self:StartAnimLoop()
  end
end
function RedDotPicPanel:DecreaseRedDotIns()
  for key, value in pairs(redDotPicList) do
    if value == self then
      table.remove(redDotPicList, key)
      break
    end
  end
  if nil == redDotPicList[1] then
    self:StopAnimLoop()
  end
end
function RedDotPicPanel:StartAnimLoop()
  playAnimTask = TimerMgr:AddTimeTask(1, 7, 0, function()
    self:PlayAnim()
  end)
end
function RedDotPicPanel:StopAnimLoop()
  if playAnimTask then
    playAnimTask:EndTask()
    playAnimTask = nil
  end
end
function RedDotPicPanel:Construct()
  self.Overridden.Construct(self)
  if self.ScaleBox_Red and self.Image_Red then
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ScaleBox_Red)
    local defaultSize = canvasSlot:GetSize()
    local viewScale = UE4.UWidgetLayoutLibrary.GetViewportScale(LuaGetWorld())
    local desiredSize = self.Image_Red.Brush.ImageSize
    local redImageSizeScale = math.round(desiredSize.X * viewScale) / desiredSize.X
    local culSize = defaultSize * redImageSizeScale / viewScale
    canvasSlot:SetSize(culSize)
  end
  self:AddRedDotIns()
end
function RedDotPicPanel:Destruct()
  self:DecreaseRedDotIns()
  RedDotPicPanel.super.Destruct(self)
end
function RedDotPicPanel:PlayAnim()
  for key, value in pairs(redDotPicList) do
    if value.RedDot then
      value:PlayAnimation(value.RedDot)
    end
  end
end
return RedDotPicPanel
