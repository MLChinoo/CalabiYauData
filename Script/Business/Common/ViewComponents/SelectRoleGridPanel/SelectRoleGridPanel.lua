local PMUWCommonGoodsBasePanel = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBasePanel")
local SelectRoleGridPanel = class("SelectRoleGridPanel", PMUWCommonGoodsBasePanel)
function SelectRoleGridPanel:UpdateItemInfoInDifferentPanel(itemWidget, goodItemInfo)
  itemWidget:SetEmptyState(false)
  itemWidget:SetItemImage(goodItemInfo.softTexture)
  itemWidget:SetProfessionIcon(goodItemInfo.professSoftTexture)
  itemWidget:SetProfessionIconColor(goodItemInfo.professColor)
  itemWidget:SeRoleName(goodItemInfo.itemName)
  itemWidget:SetRoleTeamColor(goodItemInfo.teamColor)
end
function SelectRoleGridPanel:InitializeLuaEvent()
  SelectRoleGridPanel.super.InitializeLuaEvent(self)
  self:SetTiTleVisble()
  self:SetBar()
end
function SelectRoleGridPanel:SetTiTleVisble()
  if self.ShowTitle == true then
    self:ShowUWidget(self.Canvas_Collect)
    self:SetPanelName()
  else
    self:HideCollectPanel()
  end
end
function SelectRoleGridPanel:SetBar()
  if self.bChangBar then
    local Scale = UE4.FVector2D(-1, 1)
    local Margin = UE4.FMargin()
    Margin.Left = 14
    Margin.Right = -20
    if self.ScrollBox_Item then
      self.ScrollBox_Item:SetRenderScale(Scale)
      self.ScrollBox_Item:SetScrollbarPadding(Margin)
    end
    if self.DynamicEntryBox_Item then
      self.DynamicEntryBox_Item:SetRenderScale(Scale)
    end
  end
end
function SelectRoleGridPanel:CheckDynamicEntryNum(GoodDataNum)
  if 0 == GoodDataNum then
    return
  end
  local needItemNum = 0
  if GoodDataNum < self.ColumnNum then
    needItemNum = self.ColumnNum
  else
    needItemNum = self.ColumnNum * math.ceil(GoodDataNum / self.ColumnNum)
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
  LogDebug("SelectRoleGridPanel", "Items Create Complete EntryNum:%s ,GoodDataNum:%s", self.DynamicEntryBox_Item:GetNumEntries(), GoodDataNum)
  return self.goodItems
end
function SelectRoleGridPanel:UpdateRedDotByRoleIDList(roleIDList)
  if self.goodItems then
    for key, item in pairs(self.goodItems) do
      if item then
        local itemID = item:GetItemID()
        item:SetRedDotVisible(false)
        if roleIDList then
          for key, value in pairs(roleIDList) do
            if key == itemID then
              item:SetRedDotVisible(true)
              break
            end
          end
        end
      end
    end
  end
end
return SelectRoleGridPanel
