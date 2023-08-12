local AccountUpgradePage = class("AccountUpgradePage", PureMVC.ViewComponentPage)
function AccountUpgradePage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("AccountUpgradePage", "OnOpen %s", luaOpenData)
  self:PlayAnimation(self.Anim_In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self:SetLevel(luaOpenData)
  GameFacade:SendNotification(NotificationDefines.LevelUpGrade.LevelUpPageOpen)
  if self.Button_Close then
    self.Button_Close.OnClicked:Add(self, self.OnButtonClose)
  end
  self.TimerCloseUpgrade = TimerMgr:AddTimeTask(4, 0, 1, function()
    ViewMgr:ClosePage(self, UIPageNameDefine.UpgradePage)
  end)
end
function AccountUpgradePage:OnClose()
  LogDebug("AccountUpgradePage", "OnClose")
  GameFacade:SendNotification(NotificationDefines.LevelUpGrade.LevelUpPageClose)
  if self.TimerCloseUpgrade then
    self.TimerCloseUpgrade:EndTask()
    self.TimerCloseUpgrade = nil
  end
end
function AccountUpgradePage:OnButtonClose()
  LogDebug("close upgrade page")
  self:K2_PostAkEvent(self.AK_Map:Find("Next"), true)
  ViewMgr:ClosePage(self, UIPageNameDefine.UpgradePage)
end
function AccountUpgradePage:LuaHandleKeyEvent(key, inputEvent)
  LogDebug("KeyName", key.KeyName)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  if self:GetAnimationCurrentTime(self.Anim_In) < 1.5 and self:GetAnimationCurrentTime(self.Anim_In) > 0 then
    LogDebug("Animation is Playing, return ture", "%s", self:GetAnimationCurrentTime(self.Anim_In))
    return true
  end
  if key.KeyName == "LeftMouseButton" or key.KeyName == "SpaceBar" or key.KeyName == "Escape" then
    LogDebug("close upgrade page")
    ViewMgr:ClosePage(self, UIPageNameDefine.UpgradePage)
    return true
  end
  return false
end
function AccountUpgradePage:SetLevel(InLevel)
  local NumDigit = {}
  while InLevel > 0 do
    table.insert(NumDigit, InLevel % 10)
    InLevel = math.floor(InLevel / 10)
  end
  local WidgetNum = self.HorizontalBox_Level:GetChildrenCount()
  if WidgetNum < table.count(NumDigit) then
    return
  end
  for Index = 1, WidgetNum do
    local DigitImg = self["Image_Level_" .. Index]
    if Index <= table.count(NumDigit) then
      DigitImg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      LogDebug("SetLevel", "Index=%s, NumDigit[Index]=%s", Index, NumDigit[Index])
      DigitImg:SetBrush(self.BlushNums:Get(NumDigit[Index] + 1))
    else
      DigitImg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
return AccountUpgradePage
