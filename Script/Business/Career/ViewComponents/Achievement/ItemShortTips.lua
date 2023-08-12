local ItemShortTipsMediator = require("Business/Career/Mediators/Achievement/ItemShortTipsMediator")
local ItemShortTips = class("ItemShortTips", PureMVC.ViewComponentPanel)
function ItemShortTips:ListNeededMediators()
  return {ItemShortTipsMediator}
end
function ItemShortTips:SetTipsContent(itemName, itemDesc)
  if self.TextBlock_Name then
    self.TextBlock_Name:SetText(itemName)
  end
  if self.TextBlock_Desc then
    self.TextBlock_Desc:SetText(itemDesc)
  end
end
return ItemShortTips
