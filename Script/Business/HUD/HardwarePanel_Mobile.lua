require("UnLua")
local HardwarePanel_Mobile = Class()
function HardwarePanel_Mobile:UpdateBattery(BatteryLevel, bCharging)
  if self.Image_Battery then
    if BatteryLevel >= 90 then
      self.Image_Battery:SelectAlternativeColorAndOpacity("Green")
    elseif BatteryLevel >= 60 then
      self.Image_Battery:SelectAlternativeColorAndOpacity("Yellow")
    elseif BatteryLevel >= 20 then
      self.Image_Battery:SelectAlternativeColorAndOpacity("Orange")
    else
      self.Image_Battery:SelectAlternativeColorAndOpacity("Red")
    end
  end
  if self.Image_Charging then
    if bCharging then
      self.Image_Charging:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Image_Charging:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function HardwarePanel_Mobile:UpdateBattery(SignalStrength, bWifi)
  if self.WidgetSwitcher_Signal then
    if bWifi then
      self.WidgetSwitcher_Signal:SetActiveWidgetIndex(0)
    else
      self.WidgetSwitcher_Signal:SetActiveWidgetIndex(1)
    end
  end
end
return HardwarePanel_Mobile
