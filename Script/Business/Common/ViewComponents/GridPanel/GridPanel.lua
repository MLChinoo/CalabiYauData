local PMUWCommonGoodsBasePanel = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBasePanel")
local GridPanel = class("GridPanel", PMUWCommonGoodsBasePanel)
function GridPanel:UpdateItemInfoInDifferentPanel(itemWidget, goodItemInfo)
  itemWidget:SetEmptyState(false)
  itemWidget:SetItemImage(goodItemInfo.softTexture)
  itemWidget:SetItemQuality(goodItemInfo.quality)
  itemWidget:SetItemCount(goodItemInfo.count)
end
function GridPanel:InitializeLuaEvent()
  GridPanel.super.InitializeLuaEvent(self)
  self:SetPanelName()
end
function GridPanel:SetShowGridByDataNum(bShow)
  self.bShowGridByDataNum = bShow
end
function GridPanel:CheckDynamicEntryNum(goodsDataNum)
  if 0 == goodsDataNum then
    return
  end
  local needItemNum = goodsDataNum
  if self.bShowGridByDataNum == nil or self.bShowGridByDataNum == false then
    needItemNum = self:GetCreateGridNumAndEmptyGird(goodsDataNum)
  end
  local EntryNum = self.DynamicEntryBox_Item:GetNumEntries()
  local SurplusNum = needItemNum - EntryNum
  if SurplusNum >= 0 then
    for i = 1, SurplusNum do
      local Widget = self:GenerateItem()
      self.goodItems[EntryNum + i] = Widget
    end
  end
  self:HandleSurplusItem(needItemNum)
  LogDebug("GridPanel", "Items Create Complete EntryNum:%s ,GoodDataNum:%s", self.DynamicEntryBox_Item:GetNumEntries(), GoodsDataNum)
  return self.goodItems
end
function GridPanel:GetCreateGridNumAndEmptyGird(GoodsDataNum)
  local needItemNum = 0
  if GoodsDataNum < self.ColumnNum then
    needItemNum = self.ColumnNum
  else
    needItemNum = self.ColumnNum * math.ceil(GoodsDataNum / self.ColumnNum)
  end
  return needItemNum
end
function GridPanel:GenerateItemByInitItemNum()
  self.DynamicEntryBox_Item:Reset()
  local InitNum = self.InitItemNum
  for i = 1, InitNum do
    local Widget = self:GenerateItem()
    self.goodItems[i] = Widget
  end
  LogDebug("GridPanel:GenerateItemByInitItemNum", "Init GenerateItem num:%s", self.DynamicEntryBox_Item:GetNumEntries())
end
return GridPanel
