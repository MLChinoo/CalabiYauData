local ResultBallItem = class("ResultBallItem", PureMVC.ViewComponentPanel)
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function ResultBallItem:ListNeededMediators()
  return {}
end
function ResultBallItem:SetItemType(itemType)
  local index = itemType == LotteryEnum.ballItemType.Line and 1 or 0
  self:SetItemShown(index)
end
function ResultBallItem:SetItemQuality(itemQuality)
  local index = 0
  if itemQuality == UE4.ECyItemQualityType.Purple then
    index = 3
  elseif itemQuality == UE4.ECyItemQualityType.Orange then
    index = 4
  elseif itemQuality == UE4.ECyItemQualityType.Red then
    index = 5
  else
    index = 2
  end
  self:SetItemShown(index)
end
function ResultBallItem:SetItemShown(index)
  if self.WidgetSwitcher_Type then
    self.WidgetSwitcher_Type:SetActiveWidgetIndex(index)
  end
end
return ResultBallItem
