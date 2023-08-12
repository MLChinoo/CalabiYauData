local SettingScrollTextItem = class("SettingScrollTextItem", PureMVC.ViewComponentPanel)
function SettingScrollTextItem:SetScrollText(txtItem)
  self.txtItem = txtItem
end
function SettingScrollTextItem:OnMouseEnter(MyGrometry, MouseEvent)
  if self.txtItem then
    self:BeginScroll()
  end
end
function SettingScrollTextItem:OnMouseLeave(MyGrometry)
  if self.txtItem then
    self:StopScroll()
  end
end
function SettingScrollTextItem:BeginScroll()
  local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.txtItem)
  self.initialPosition = canvasSlot:GetPosition()
  local s2 = UE4.USlateBlueprintLibrary.GetLocalSize((self:GetCachedGeometry()))
  local s3 = UE4.USlateBlueprintLibrary.GetLocalSize((self.txtItem:GetCachedGeometry()))
  if s2.X < s3.X and self.rollTimer == nil then
    self:BeginRollTimer()
  end
end
function SettingScrollTextItem:StopScroll()
  self:ReleaseRollTimer()
  local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.txtItem)
  canvasSlot:SetPosition(self.initialPosition)
end
function SettingScrollTextItem:BeginRollTimer()
  local s2 = UE4.USlateBlueprintLibrary.GetLocalSize((self:GetCachedGeometry()))
  local s3 = UE4.USlateBlueprintLibrary.GetLocalSize((self.txtItem:GetCachedGeometry()))
  local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.txtItem)
  local dx = s2.X - s3.X
  local txtPosition = canvasSlot:GetPosition()
  local beginX = txtPosition.X
  local targetX = dx
  local intervalTime = 0.05
  local curTime = 0
  local cnt = 0
  local bDelay = false
  local moveDelta = -3
  self:ReleaseRollTimer()
  self.rollTimer = TimerMgr:AddTimeTask(0.1, intervalTime, 0, function()
    if bDelay then
      curTime = curTime + intervalTime
      if curTime > 1 then
        cnt = 0
        bDelay = false
      end
    else
      local tx = cnt * moveDelta + beginX
      if tx < targetX then
        tx = targetX
      end
      canvasSlot:SetPosition(UE4.FVector2D(tx, txtPosition.Y))
      cnt = cnt + 1
      if tx == targetX then
        bDelay = true
        curTime = 0
      end
    end
  end)
end
function SettingScrollTextItem:ReleaseRollTimer()
  if self.rollTimer then
    self.rollTimer:EndTask()
    self.rollTimer = nil
  end
end
function SettingScrollTextItem:Construct()
  self.txtItem = nil
end
function SettingScrollTextItem:Destruct()
  self:ReleaseRollTimer()
  SettingScrollTextItem.super.Destruct(self)
end
return SettingScrollTextItem
