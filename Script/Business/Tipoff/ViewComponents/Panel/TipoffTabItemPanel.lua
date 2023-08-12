local TipoffPlayerMediator = require("Business/Tipoff/Mediators/TipoffPlayerMediator")
local TipoffTabItemPanel = class("TipoffTabItemPanel", PureMVC.ViewComponentPanel)
function TipoffTabItemPanel:Construct()
  TipoffTabItemPanel.super.Construct(self)
  if self.CheckBox_Item then
    self.CheckBox_Item.OnCheckStateChanged:Add(self, self.OnHandleTabChange)
  end
  self.CachedItemData = nil
end
function TipoffTabItemPanel:Destruct()
  TipoffTabItemPanel.super.Destruct(self)
  if self.CheckBox_Item then
    self.CheckBox_Item.OnCheckStateChanged:Remove(self, self.OnHandleTabChange)
  end
  self.CachedItemData = nil
end
function TipoffTabItemPanel:InitView(itemData)
  self.CachedItemData = itemData
end
function TipoffTabItemPanel:OnRefreshItem()
  if not self.CachedItemData then
    UE4.UPMWidgetBlueprintLibrary.SetWidgetVisible(self, UE4.ESlateVisibility.Collapsed)
    return
  end
  UE4.UPMWidgetBlueprintLibrary.SetWidgetVisible(self, UE4.ESlateVisibility.Visible)
  self:SetDescText(self.CachedItemData.CategoryDescType)
end
function TipoffTabItemPanel:SetItemSelected(bSelected)
  if self.CheckBox_Item then
    self.CheckBox_Item:SetIsChecked(bSelected)
  end
end
function TipoffTabItemPanel:OnHandleTabChange(bChoose)
  LogDebug("TipoffTabItemPanel", "OnHandleTabChange bChoose :" .. tostring(bChoose))
  local data = {
    CategoryType = self.CachedItemData.CategoryType,
    bChoose = bChoose
  }
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffCategoryChooseCmd, data)
end
function TipoffTabItemPanel:SetIsChecked(bSelected)
  if not self.CheckBox_Item then
    return
  end
  if bSelected then
    self.CheckBox_Item:SetCheckedState(UE4.ECheckBoxState.Checked)
  else
    self.CheckBox_Item:SetCheckedState(UE4.ECheckBoxState.Unchecked)
  end
end
function TipoffTabItemPanel:SetDescText(desc)
  if self.Text_TabDesc then
    self.Text_TabDesc:SetText(desc)
  end
end
function TipoffTabItemPanel:GetCurCategoryType()
  if self.CachedItemData then
    return self.CachedItemData.CategoryType
  end
  return -1
end
return TipoffTabItemPanel
