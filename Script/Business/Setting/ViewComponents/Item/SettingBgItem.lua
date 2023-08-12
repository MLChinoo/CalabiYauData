local SettingBgItem = class("SettingBgItem", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local TabStyle = SettingEnum.TabStyle
function SettingBgItem:OnMouseEnter()
  self.Image_Bg:SetColorAndOpacity(self.EnterColor)
  if self.item then
    local oriData = self.item.oriData
    GameFacade:SendNotification(NotificationDefines.Setting.SettingShowTipNtf, {
      title = oriData.Name,
      tip = oriData.Tips,
      show = true
    })
  end
end
function SettingBgItem:OnMouseLeave()
  self.Image_Bg:SetColorAndOpacity(self.LeaveColor)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingShowTipNtf, {show = false})
end
function SettingBgItem:AddChild(item)
  self.SizeBox_Child:AddChild(item)
  self.item = item
end
return SettingBgItem
