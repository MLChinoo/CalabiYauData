local ApartmentMemoryPage = class("ApartmentMemoryPage", PureMVC.ViewComponentPage)
local ApartmentMemoryMediator = require("Business/Apartment/Mediators/ApartmentMemoryMediator")
local Valid
function ApartmentMemoryPage:ListNeededMediators()
  return {ApartmentMemoryMediator}
end
function ApartmentMemoryPage:SetPageActive(bIsActive)
  self.bIsActivePage = bIsActive
  if not self.bIsActivePage then
    RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseItem)
    RedDotTree:Unbind(RedDotModuleDef.ModuleName.PromiseMemory)
  end
end
function ApartmentMemoryPage:GetPageIsActive()
  return self.bIsActivePage
end
function ApartmentMemoryPage:Init(PageData)
  if not self.bIsActivePage then
    return
  end
  self.CurTabIdx = -1
  if self.BtnItemTab then
    self.BtnItemTab.OnHovered:Add(self, self.OnItemTabHovered)
    self.BtnItemTab.OnUnhovered:Add(self, self.OnItemTabUnhovered)
    self.BtnItemTab.OnClicked:Add(self, self.OnItemTabClicked)
  end
  if self.BtnMemTab then
    self.BtnMemTab.OnHovered:Add(self, self.OnMemTabHovered)
    self.BtnMemTab.OnUnhovered:Add(self, self.OnMemTabUnhovered)
    self.BtnMemTab.OnClicked:Add(self, self.OnMemTabClicked)
  end
  if self.BtnStory then
    self.BtnStory.OnClicked:Add(self, self.OnPlayStoryAvgClicked)
  end
  if self.BtnMemPicture then
    self.BtnMemPicture.OnClicked:Add(self, self.OnShowMemPictureClicked)
  end
  if self.BtnMemSeq then
    self.BtnMemSeq.OnClicked:Add(self, self.OnMemAvgClicked)
  end
  self.NewUnlockQueue = {}
  if self.DynamicEntryPromiseItem then
    self.DynamicEntryPromiseItem:Reset(true)
  end
  self.PledgeItemsList = {}
  for idx, itemInfo in ipairs(PageData.PledgeItemsInfo or {}) do
    local scrollItem = self.DynamicEntryPromiseItem and self.DynamicEntryPromiseItem:BP_CreateEntry()
    if scrollItem then
      scrollItem:Init(idx, itemInfo)
      self.PledgeItemsList[idx] = scrollItem
    end
    if itemInfo.newUnlock then
      table.insert(self.NewUnlockQueue, itemInfo)
    end
  end
  if table.count(self.PledgeItemsList) > 0 then
    self.PledgeItemsModuleOpen = true
  end
  if self.DynamicEntryBox_Item then
    self.DynamicEntryBox_Item:Reset(true)
  end
  self.MemItemsList = {}
  for index, DataInfo in pairs(PageData.MemoryInfo or {}) do
    local Item = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:BP_CreateEntry()
    if Item then
      Item:Init(index, DataInfo)
      self.MemItemsList[index] = Item
    end
  end
  if table.count(self.MemItemsList) > 0 then
    self.MemoryLaungeModuleOpen = true
  end
  self.TxtStory:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BtnStory:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SzSpace:SetVisibility(UE4.ESlateVisibility.Collapsed)
  RedDotTree:Bind(RedDotModuleDef.ModuleName.PromiseItem, function(cnt)
    self:UpdateRedDotPromiseItem(cnt)
  end)
  self:UpdateRedDotPromiseItem(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.PromiseItem))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.PromiseMemory, function(cnt)
    self:UpdateRedDotPromiseMemory(cnt)
  end)
  self:UpdateRedDotPromiseMemory(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.PromiseMemory))
  if self.PledgeItemsModuleOpen then
    self:OnItemTabClicked()
  elseif self.MemoryLaungeModuleOpen then
    self:OnMemTabClicked()
  end
  self:OnPledgeScrollItemClicked(1)
  self:OnMemScrollItemClicked(1)
  self:CheckNewUnlockTips()
end
function ApartmentMemoryPage:SelectTab(tabIdx)
  self.SwitcherTab:SetActiveWidgetIndex(tabIdx)
  self.CurTabIdx = tabIdx
end
function ApartmentMemoryPage:CheckNewUnlockTips()
  if 0 == #self.NewUnlockQueue then
    return
  end
  local NewUnlockItem = table.remove(self.NewUnlockQueue, 1)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ApartmentUnlockPromiseItemPage, nil, {itemInfo = NewUnlockItem})
end
function ApartmentMemoryPage:OnPledgeScrollItemClicked(itemIdx)
  for index, scrollItem in ipairs(self.PledgeItemsList) do
    if index == itemIdx then
      self.CurScrollItem = scrollItem
      scrollItem:ShowSelectFrame()
    else
      scrollItem:SetNotBeSelected()
    end
  end
  self:UpdatePledgeDetailPanel()
end
function ApartmentMemoryPage:UpdatePledgeDetailPanel()
  local curItem = self.CurScrollItem
  if curItem.ItemInfo.unlocked then
    self.TxtStory:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtStory:SetText(curItem.ItemInfo.itemCfg.ItemStory)
    self.BtnStory:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CanvasUnlockTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local rewardCfg = curItem.ItemInfo.itemCfg.CheckReward
    if curItem.ItemInfo.unCheckedStory and rewardCfg and rewardCfg:Length() > 0 then
      self.CanvasCheckReward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local rewardId = rewardCfg:Get(1).ItemId
      local rewardNum = rewardCfg:Get(1).ItemAmount
      if rewardId then
        local rewardIcon = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemImg(rewardId)
        self.ImgCheckReward:SetBrushFromSoftTexture(rewardIcon)
        self.TxtRewardAmount:SetText(string.format("x%d", rewardNum))
      else
        self.CanvasCheckReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.CanvasCheckReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.TxtStory:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BtnStory:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasUnlockTips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasCheckReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ApartmentMemoryPage:OnPlayStoryAvgClicked()
  if not self.CurScrollItem then
    return
  end
  if self.CurScrollItem.ItemInfo.storyAvg > 0 then
    GameFacade:SendNotification(NotificationDefines.PromisePlayAVGEvent, self.CurScrollItem.ItemInfo.storyAvg)
    self.CurItemAvgOrSeqId = self.CurScrollItem.ItemInfo.storyAvg
  elseif self.CurScrollItem.ItemInfo.storySequence > 0 then
    GameFacade:SendNotification(NotificationDefines.PromisePlayAVGSequence, self.CurScrollItem.ItemInfo.storySequence)
    self.CurItemAvgOrSeqId = self.CurScrollItem.ItemInfo.storySequence
  end
end
function ApartmentMemoryPage:OnMemScrollItemClicked(itemIdx)
  self.RedDot_Avg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RedDot_Picture:SetVisibility(UE4.ESlateVisibility.Collapsed)
  for index, scrollItem in ipairs(self.MemItemsList) do
    if index == itemIdx then
      self.CurMemItem = scrollItem
      self:OnMemItemSelected(scrollItem)
    else
      scrollItem:SetNotBeSelected()
    end
  end
end
function ApartmentMemoryPage:OnMemItemSelected(memItem)
  memItem:ShowSelectFrame()
  if memItem.MemInfo.bIsUnLock then
    local havePicture = not memItem.MemInfo.MemoryPicture:IsNull()
    if havePicture then
      self.SzBtnPicture:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.SzSpace:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.SzBtnPicture:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SzSpace:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    local readState = memItem.MemInfo.ReadState
    if readState then
      local avgUnreadMark = 0 == readState.main_status
      self.RedDot_Avg:SetVisibility(avgUnreadMark and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
      local pictureUnreadMark = havePicture and readState.main_status > 0 and 0 == readState.picture_status
      self.RedDot_Picture:SetVisibility(pictureUnreadMark and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    end
    self.BtnMemSeq:SetIsEnabled(true)
    local canReadPic = havePicture and readState and readState.main_status > 0
    self.BtnMemPicture:SetIsEnabled(canReadPic)
  else
    self.SzBtnPicture:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SzSpace:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BtnMemSeq:SetIsEnabled(false)
  end
end
function ApartmentMemoryPage:OnMemAvgClicked()
  if not self.CurMemItem or not self.CurMemItem.MemInfo.bIsUnLock then
    return
  end
  local avgOrSeqId = 0
  if self.CurMemItem.MemInfo.AvgId > 0 then
    avgOrSeqId = self.CurMemItem.MemInfo.AvgId
    GameFacade:SendNotification(NotificationDefines.PromisePlayAVGEvent, avgOrSeqId)
  elseif self.CurMemItem.MemInfo.SequenceId > 0 then
    avgOrSeqId = self.CurMemItem.MemInfo.SequenceId
    GameFacade:SendNotification(NotificationDefines.PromisePlayAVGSequence, avgOrSeqId)
  end
  self.CurMemAvgId = avgOrSeqId
  if 0 == self.CurMemItem.MemInfo.ReadState.main_status then
    self.CurMemItem.MemInfo.ReadState.main_status = 1
    self.RedDot_Avg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local retdotDelta = -1
    if not self.CurMemItem.MemInfo.MemoryPicture:IsNull() then
      self.RedDot_Picture:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      retdotDelta = retdotDelta + 1
    end
    local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
    GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):InteractOperateReq(3, kaNavigationProxy:GetCurrentRoleId(), avgOrSeqId, {1, 0})
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseMemory, retdotDelta)
  end
end
function ApartmentMemoryPage:OnShowMemPictureClicked()
  if not self.CurMemItem or self.CurMemItem.MemInfo.MemoryPicture:IsNull() or 0 == self.CurMemItem.MemInfo.ReadState.main_status then
    return
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MemoryPictureDisplay, nil, self.CurMemItem.MemInfo)
  if 0 == self.CurMemItem.MemInfo.ReadState.picture_status then
    self.CurMemItem.MemInfo.ReadState.picture_status = 1
    self.RedDot_Picture:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local avgOrSeqId = 0
    if self.CurMemItem.MemInfo.AvgId > 0 then
      avgOrSeqId = self.CurMemItem.MemInfo.AvgId
    elseif self.CurMemItem.MemInfo.SequenceId > 0 then
      avgOrSeqId = self.CurMemItem.MemInfo.SequenceId
    end
    local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
    GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):InteractOperateReq(3, kaNavigationProxy:GetCurrentRoleId(), avgOrSeqId, {1, 1})
    RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseMemory, -1)
  end
end
function ApartmentMemoryPage:UpdateRedDotPromiseItem(cnt)
  self.ReddotItemTab:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentMemoryPage:UpdateRedDotPromiseMemory(cnt)
  self.ReddotMemTab:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function ApartmentMemoryPage:ChangeWidgetZOrder(widget, zorder)
  local slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
  if slot then
    slot:SetZOrder(zorder)
  end
end
function ApartmentMemoryPage:OnItemTabHovered()
  if 0 == self.CurTabIdx then
    return
  end
  self.SwitherItemBtn:SetActiveWidgetIndex(1)
  self.TxtPromiseItem:SetColorAndOpacity(self.ColorTextSelect)
  self.ImgPromiseItem:SetColorAndOpacity(self.ColorImgSelect)
end
function ApartmentMemoryPage:OnItemTabUnhovered()
  if 0 == self.CurTabIdx then
    return
  end
  self.SwitherItemBtn:SetActiveWidgetIndex(0)
  self.TxtPromiseItem:SetColorAndOpacity(self.ColorTextNormal)
  self.ImgPromiseItem:SetColorAndOpacity(self.ColorImgNormal)
end
function ApartmentMemoryPage:OnItemTabClicked()
  if not self.PledgeItemsModuleOpen then
    local TipsText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "TempTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipsText)
    return
  end
  if 0 == self.CurTabIdx then
    return
  end
  self.SwitherItemBtn:SetActiveWidgetIndex(2)
  self:ChangeWidgetZOrder(self.SbItemTab, 1)
  self.SwitherMemBtn:SetActiveWidgetIndex(0)
  self:ChangeWidgetZOrder(self.SbMemTab, 0)
  self:SelectTab(0)
  self.TxtPromiseItem:SetColorAndOpacity(self.ColorTextSelect)
  self.ImgPromiseItem:SetColorAndOpacity(self.ColorImgSelect)
  self.TxtMemory:SetColorAndOpacity(self.ColorTextNormal)
  self.ImgMemory:SetColorAndOpacity(self.ColorImgNormal)
end
function ApartmentMemoryPage:OnMemTabHovered()
  if 1 == self.CurTabIdx then
    return
  end
  self.SwitherMemBtn:SetActiveWidgetIndex(1)
  self.TxtMemory:SetColorAndOpacity(self.ColorTextSelect)
  self.ImgMemory:SetColorAndOpacity(self.ColorImgSelect)
end
function ApartmentMemoryPage:OnMemTabUnhovered()
  if 1 == self.CurTabIdx then
    return
  end
  self.SwitherMemBtn:SetActiveWidgetIndex(0)
  self.TxtMemory:SetColorAndOpacity(self.ColorTextNormal)
  self.ImgMemory:SetColorAndOpacity(self.ColorImgNormal)
end
function ApartmentMemoryPage:OnMemTabClicked()
  if not self.MemoryLaungeModuleOpen then
    local TipsText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "TempTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipsText)
    return
  end
  if 1 == self.CurTabIdx then
    return
  end
  self.SwitherItemBtn:SetActiveWidgetIndex(0)
  self:ChangeWidgetZOrder(self.SbItemTab, 0)
  self.SwitherMemBtn:SetActiveWidgetIndex(2)
  self:ChangeWidgetZOrder(self.SbMemTab, 1)
  self:SelectTab(1)
  self.TxtPromiseItem:SetColorAndOpacity(self.ColorTextNormal)
  self.ImgPromiseItem:SetColorAndOpacity(self.ColorImgNormal)
  self.TxtMemory:SetColorAndOpacity(self.ColorTextSelect)
  self.ImgMemory:SetColorAndOpacity(self.ColorImgSelect)
end
return ApartmentMemoryPage
