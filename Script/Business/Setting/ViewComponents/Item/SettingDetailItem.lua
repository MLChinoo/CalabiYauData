local SettingDetailItem = class("SettingDetailItem", PureMVC.ViewComponentPanel)
local SettingDetailItemMediator = require("Business/Setting/Mediators/Item/SettingDetailItemMediator")
function SettingDetailItem:ListNeededMediators()
  return {SettingDetailItemMediator}
end
function SettingDetailItem:SetContent(body)
  if body.show then
    self.Title:SetText(body.title)
    self.Content:SetText(body.tip)
  else
    self.Title:SetText("")
    self.Content:SetText("")
  end
end
return SettingDetailItem
