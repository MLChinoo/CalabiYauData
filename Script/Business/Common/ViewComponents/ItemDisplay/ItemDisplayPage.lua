local ItemDisplayPage = class("ItemDisplayPage", PureMVC.ViewComponentPage)
local ItemDisplayPageMediator = require("Business/Common/Mediators/ItemDisplay/ItemDisplayPageMediator")
local Valid
function ItemDisplayPage:ListNeededMediators()
  return {ItemDisplayPageMediator}
end
function ItemDisplayPage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.ClosePage, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStartPreview:Add(self.OnClickStartPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStopPreview:Add(self.OnClickStopPreview, self)
  self.IsPreview = false
  self.bIsDuringSwitch = false
  self:PlayOpenOrCloseAnimation(true)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:SetSwitchBtnName(self.SwitchBtnName)
end
function ItemDisplayPage:Init(itemsData)
  self.bIsDuringSwitch = false
  if self.GoodsGridsPanel then
    self.GoodsGridsPanel:Update(itemsData)
  end
end
function ItemDisplayPage:UpdatePanel(ItemId)
  self.CurClickedItemId = ItemId
  self.bIsDuringSwitch = false
  if self.ItemDescWithHeadPanel then
    self.ItemDescWithHeadPanel:Update(ItemId)
  end
  local data = {}
  data.itemId = ItemId
  data.show3DBackground = true
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys:SetItemDisplayed(data)
    self.ItemDisplayKeys:ShowSwitch(false)
  end
end
function ItemDisplayPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function ItemDisplayPage:OnClose()
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.ClosePage, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStartPreview:Remove(self.OnClickStartPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStopPreview:Remove(self.OnClickStopPreview, self)
  self.bIsDuringSwitch = false
end
function ItemDisplayPage:ClosePage()
  ViewMgr:ClosePage(self)
end
function ItemDisplayPage:OnClickStartPreview(is3DModel)
  self:PlayOpenOrCloseAnimation(false)
end
function ItemDisplayPage:OnClickStopPreview(is3DModel)
  self:PlayOpenOrCloseAnimation(true)
end
function ItemDisplayPage:PlayOpenOrCloseAnimation(Open)
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys:ShowSwitch(false)
  end
  if self.SwitchAnimation == nil then
    return nil
  end
  if Open then
    if self.IsPreview == false then
      self.SwitchAnimation:PlayOpenAnimation()
      self.IsPreview = true
    end
  else
    if self.IsPreview then
      self.SwitchAnimation:PlayCloseAnimation()
    end
    self.IsPreview = false
  end
end
return ItemDisplayPage
