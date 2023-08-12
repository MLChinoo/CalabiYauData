local SettingBgItem = class("SettingBgItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingBgItemMediator = require("Business/Setting/Mediators/Mobile/SettingBgItemMediator")
local TabStyle = SettingEnum.TabStyle
local lastBgItem
function SettingBgItem:ListNeededMediators()
  return {SettingBgItemMediator}
end
function SettingBgItem:OnTouchStarted()
  if lastBgItem then
    lastBgItem.Image_Bg:SetColorAndOpacity(self.LeaveColor)
  end
  self.Image_Bg:SetColorAndOpacity(self.EnterColor)
  if self.item then
    local oriData = self.item.oriData
    GameFacade:SendNotification(NotificationDefines.Setting.SettingShowTipNtf, {
      title = oriData.Name,
      tip = oriData.Tips,
      show = true
    })
  end
  lastBgItem = self
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function SettingBgItem:AddChild(item)
  self.SizeBox_Child:AddChild(item)
  self.item = item
end
function SettingBgItem:Reset()
  if lastBgItem then
    lastBgItem.Image_Bg:SetColorAndOpacity(self.LeaveColor)
    lastBgItem = nil
  end
end
function SettingBgItem:Destruct()
  SettingBgItem.super.Destruct(self)
  lastBgItem = nil
end
return SettingBgItem
