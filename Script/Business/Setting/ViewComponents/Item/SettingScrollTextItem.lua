local SettingScrollTextItem = class("SettingScrollTextItem", PureMVC.ViewComponentPanel)
function SettingScrollTextItem:SetScrollText(txtItem)
  self.txtItem = txtItem
end
function SettingScrollTextItem:OnLuaShow()
  print("OnLuaShow !!!")
end
function SettingScrollTextItem:OnLuaHide()
  print("OnLuaHide !!!")
end
function SettingScrollTextItem:BeginScroll()
  local s2 = UE4.USlateBlueprintLibrary.GetLocalSize((self:GetCachedGeometry()))
  local s3 = UE4.USlateBlueprintLibrary.GetLocalSize((self.txtItem:GetCachedGeometry()))
  if s2.X >= s3.X then
    if self.rollTimer ~= nil then
      self:ReleaseRollTimer()
      local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.txtItem)
      canvasSlot:SetPosition(UE4.FVector2D(0, 0))
    end
  elseif self.rollTimer == nil then
    self:BeginRollTimer()
  end
end
function SettingScrollTextItem:BeginRollTimer()
  local s2 = UE4.USlateBlueprintLibrary.GetLocalSize((self:GetCachedGeometry()))
  local s3 = UE4.USlateBlueprintLibrary.GetLocalSize((self.txtItem:GetCachedGeometry()))
  local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.txtItem)
  local dx = s2.X - s3.X
  local txtPosition = canvasSlot:GetPosition()
  local beginX = txtPosition.X - dx / 2 + 100
  local targetX = dx - dx / 2 - 100
  local intervalTime = 0.05
  local showTotalTime = 1
  local curTime = 0
  local cnt = 0
  local bDelay = false
  self:ReleaseRollTimer()
  self.rollTimer = TimerMgr:AddTimeTask(0.1, intervalTime, 0, function()
    if bDelay then
      curTime = curTime + intervalTime
      if curTime > 1 then
        cnt = 0
        bDelay = false
      end
    else
      local tx = cnt * -15 + beginX
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
function SettingScrollTextItem:Destruct()
  self:ReleaseRollTimer()
  SettingScrollTextItem.super.Destruct(self)
end
return SettingScrollTextItem
