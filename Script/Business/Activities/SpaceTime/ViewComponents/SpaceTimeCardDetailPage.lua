local SpaceTimeCardDetailPage = class("SpaceTimeCardDetailPage", PureMVC.ViewComponentPage)
function SpaceTimeCardDetailPage:OnOpen(luaOpenData, nativeOpenData)
  local itemId = luaOpenData.itemId
  if itemId then
    if self.ItemDesc then
      self.ItemDesc:Update(itemId)
    end
    if self.ItemDisplayKeys then
      local data = {}
      data.itemId = itemId
      data.show3DBackground = true
      self.ItemDisplayKeys:SetItemDisplayed(data)
    end
  end
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys.actionOnReturn:Add(self.ClosePage, self)
    self.ItemDisplayKeys.actionOnStartPreview:Add(self.OnClickStartPreview, self)
    self.ItemDisplayKeys.actionOnStopPreview:Add(self.OnClickStopPreview, self)
  end
end
function SpaceTimeCardDetailPage:OnClose()
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys.actionOnReturn:Remove(self.ClosePage, self)
    self.ItemDisplayKeys.actionOnStartPreview:Remove(self.OnClickStartPreview, self)
    self.ItemDisplayKeys.actionOnStopPreview:Remove(self.OnClickStopPreview, self)
  end
end
function SpaceTimeCardDetailPage:OnClickStartPreview()
  if self.ItemDesc then
    self.ItemDesc:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimeCardDetailPage:OnClickStopPreview()
  if self.ItemDesc then
    self.ItemDesc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SpaceTimeCardDetailPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function SpaceTimeCardDetailPage:ClosePage()
  ViewMgr:ClosePage(self)
end
return SpaceTimeCardDetailPage
