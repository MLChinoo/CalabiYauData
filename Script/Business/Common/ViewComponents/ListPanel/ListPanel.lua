local PMUWCommonGoodsBasePanel = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBasePanel")
local ListPanel = class("ListPanel", PMUWCommonGoodsBasePanel)
function ListPanel:UpdateItemInfoInDifferentPanel(itemWidget, goodItemInfo)
  itemWidget:SetItemName(goodItemInfo.itemName)
  itemWidget:SetQualityName(goodItemInfo.qulityName)
  itemWidget:SetQualityImgColor(goodItemInfo.qulityColor)
end
function ListPanel:InitializeLuaEvent()
  ListPanel.super.InitializeLuaEvent(self)
  self:SetPanelName()
end
function ListPanel:OnItemClick(clickItem)
  ListPanel.super.OnItemClick(self, clickItem)
end
return ListPanel
