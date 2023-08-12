local ApartmentUnlockPromiseItemPage = class("ApartmentUnlockPromiseItemPage", PureMVC.ViewComponentPage)
function ApartmentUnlockPromiseItemPage:OnOpen(luaOpenData, nativeOpenData)
  self.PromiseItemInfo = luaOpenData.itemInfo
  if self.PromiseItemInfo and self.PromiseItemInfo.itemCfg then
    self.TxtItemName:SetText(self.PromiseItemInfo.itemCfg.Name)
    if not self.PromiseItemInfo.itemCfg.ItemPicture:IsNull() then
      self.ImgItem:SetBrushFromSoftTexture(self.PromiseItemInfo.itemCfg.ItemPicture, true)
    end
  end
  self.ImgTouch.OnMouseButtonDownEvent:Bind(self, self.OnBgClicked)
  self:PlayAnimation(self.AnimEnter, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function ApartmentUnlockPromiseItemPage:OnClose()
  if self.AutoCloseTimer then
    self.AutoCloseTimer:EndTask()
    self.AutoCloseTimer = nil
  end
end
function ApartmentUnlockPromiseItemPage:OnBgClicked()
  self.AutoCloseTimer = nil
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.ApartmentUnlockPromiseItemPage)
  GameFacade:SendNotification(NotificationDefines.ApartmentUnlockPromiseItemTipClose, self.PromiseItemInfo)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function ApartmentUnlockPromiseItemPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnBgClicked()
    return true
  end
  return false
end
return ApartmentUnlockPromiseItemPage
