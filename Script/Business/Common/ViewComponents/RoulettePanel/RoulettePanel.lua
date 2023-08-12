local RoulettePanel = class("RoulettePanel", PureMVC.ViewComponentPanel)
function RoulettePanel:InitializeLuaEvent()
  self.onItemClickEvent = LuaEvent.new()
  self.onItemDropEvent = LuaEvent.new()
  self.onItemDropInRoulettePanelEvent = LuaEvent.new()
  self.onItemDragCancelledEvent = LuaEvent.new()
  self.itemMap = {}
  local allChild = self.Roulette:GetAllChildren()
  local childNum = allChild:Length()
  for i = 1, childNum do
    local item = allChild:Get(i)
    if item then
      item:RestItem()
      item:SetItemIndex(i)
      item.OnItemClicked:Add(self, self.OnItemClick)
      item.OnItemDrop:Add(self, self.OnItemDrop)
      item.OnItemDropInRoulettePanel:Add(self, self.OnItemDropInRoulettePanel)
      item.OnItemDragCancelled:Add(self, self.OnItemDragCancelled)
      self.itemMap[i] = item
    end
  end
  self.selectRoateAngle = 360 / childNum
  if self.Img_Select then
    self.Img_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Img_Select:SetRenderTransformAngle(0)
  end
end
function RoulettePanel:UpdateItemSelectState(item)
  if self.lastItem then
    self.lastItem:SetSelectState(false)
  end
  self.lastItem = item
  self.lastItem:SetSelectState(true)
  self:SetSelectImgAngle(self.lastItem:GetItemIndex())
end
function RoulettePanel:OnItemClick(item)
  self:UpdateItemSelectState(item)
  self.onItemClickEvent(item)
end
function RoulettePanel:OnItemDragCancelled(item)
  self.onItemDragCancelledEvent(item)
end
function RoulettePanel:OnItemDrop(item)
  self:UpdateItemSelectState(item)
  self.onItemDropEvent(item)
end
function RoulettePanel:OnItemDropInRoulettePanel(dragItem, dropItem)
  self:UpdateItemSelectState(dropItem)
  self.onItemDropInRoulettePanelEvent(dragItem, dropItem)
end
function RoulettePanel:GetCurrentItem()
  return self.lastItem
end
function RoulettePanel:UpdatePanel(data)
  if self.itemMap == nil then
    return
  end
  for key, value in pairs(self.itemMap) do
    if value then
      value:RestItem()
    end
  end
  for key, value in pairs(data) do
    local item = self.itemMap[key]
    if item and value.itemID and 0 ~= value.itemID then
      item:SetItemID(value.itemID)
      item:SetItemIntervalType(value.ItemIdIntervalType)
      if value.itemName then
        item:SetItemName(value.itemName)
      else
        item:SetItemImg(value.sortTexture)
      end
    end
  end
end
function RoulettePanel:ClearSelectState()
  if self.lastItem then
    self.lastItem:SetSelectState(false)
  end
end
function RoulettePanel:SetKeyTips(tips)
  if self.Tex_KeyTips then
    self.Tex_KeyTips:SetText(tips)
  end
end
function RoulettePanel:SetSelectImgAngle(idenx)
  if self.Img_Select then
    self.Img_Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Select:SetRenderTransformAngle(self.selectRoateAngle * (idenx - 1))
  end
end
function RoulettePanel:SetDefaultSelectItemByIndex(index)
  if nil == index then
    return
  end
  local item = self.itemMap[index]
  if item then
    self:UpdateItemSelectState(item)
  end
end
return RoulettePanel
