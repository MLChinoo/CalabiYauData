local SettingComInteractItem = require("Business/Setting/ViewComponents/Item/SettingComInteractItem")
local SettingDescItem = class("SettingDescItem", SettingComInteractItem)
function SettingDescItem:InitView(oriData)
  self.oriData = oriData
end
return SettingDescItem
