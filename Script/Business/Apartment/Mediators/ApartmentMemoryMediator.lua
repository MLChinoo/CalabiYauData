local ApartmentMemoryMediator = class("ApartmentMemoryMediator", PureMVC.Mediator)
local ApartmentMemoryPage
function ApartmentMemoryMediator:OnRegister()
  ApartmentMemoryPage = self:GetViewComponent()
end
function ApartmentMemoryMediator:OnRemove()
end
function ApartmentMemoryMediator:ListNotificationInterests()
  return {
    NotificationDefines.SetApartmentMemoryPageData,
    NotificationDefines.ApartmentUnlockPromiseItemTipClose,
    NotificationDefines.ApartmentPromiseScrollItemClicked,
    NotificationDefines.ApartmentMemScrollItemClicked,
    NotificationDefines.ApartmentAvgStoryFinish
  }
end
function ApartmentMemoryMediator:HandleNotification(notification)
  if not ApartmentMemoryPage:GetPageIsActive() then
    return
  end
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.SetApartmentMemoryPageData then
    ApartmentMemoryPage:Init(Body)
  elseif Name == NotificationDefines.ApartmentUnlockPromiseItemTipClose then
    self:OnNewUnlockItemTipsClose(Body)
  elseif Name == NotificationDefines.ApartmentPromiseScrollItemClicked then
    ApartmentMemoryPage:OnPledgeScrollItemClicked(Body)
  elseif Name == NotificationDefines.ApartmentMemScrollItemClicked then
    ApartmentMemoryPage:OnMemScrollItemClicked(Body)
  elseif Name == NotificationDefines.ApartmentAvgStoryFinish then
    self:OnCheckedNewStory(Body)
    self:OnCheckedMemStory(Body)
  end
end
function ApartmentMemoryMediator:OnNewUnlockItemTipsClose(itemInfo)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  if KaPhoneProxy and KaNavigationProxy then
    KaPhoneProxy:InteractOperateReq(4, KaNavigationProxy:GetCurrentRoleId(), itemInfo.id, {1})
  end
  ApartmentMemoryPage:CheckNewUnlockTips()
end
function ApartmentMemoryMediator:OnCheckedNewStory(storyAvgId)
  if not storyAvgId or storyAvgId ~= ApartmentMemoryPage.CurItemAvgOrSeqId then
    return
  end
  local curSelectItem = ApartmentMemoryPage.CurScrollItem
  if not (curSelectItem and curSelectItem.ItemInfo) or not curSelectItem.ItemInfo.unCheckedStory then
    return
  end
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local itemId = curSelectItem.ItemInfo.id
  if itemId then
    KaPhoneProxy:InteractOperateReq(4, kaNavigationProxy:GetCurrentRoleId(), itemId, {2})
    ApartmentMemoryPage.CanvasCheckReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    curSelectItem.ItemInfo.unCheckedStory = false
  end
end
function ApartmentMemoryMediator:OnCheckedMemStory(AvgId)
  if not AvgId or AvgId ~= ApartmentMemoryPage.CurMemAvgId then
    return
  end
  local curSelectItem = ApartmentMemoryPage.CurMemItem
  ApartmentMemoryPage:OnMemItemSelected(curSelectItem)
end
return ApartmentMemoryMediator
