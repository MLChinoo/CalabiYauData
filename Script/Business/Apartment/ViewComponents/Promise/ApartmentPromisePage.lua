local ApartmentPromisePage = class("ApartmentPromisePage", PureMVC.ViewComponentPage)
local ApartmentPromiseMediator = require("Business/Apartment/Mediators/Promise/ApartmentPromiseMediator")
local Valid
function ApartmentPromisePage:SetPageActive(bIsActive)
  self.bIsActivePage = bIsActive
end
function ApartmentPromisePage:GetPageIsActive()
  return self.bIsActivePage
end
function ApartmentPromisePage:Init(PageData)
  if not self.bIsActivePage or not PageData then
    return
  end
  Valid = self.ProgressBar_Level and self.ProgressBar_Level:SetPercent(PageData.ProgressLevel)
  Valid = self.TextBlock_ExpNow and self.TextBlock_ExpNow:SetText(PageData.TextExpNow)
  Valid = self.TextBlock_Level and self.TextBlock_Level:SetText(PageData.TextLevel)
  Valid = self.TextBlock_LevelName and self.TextBlock_LevelName:SetText(PageData.TextLevelName)
  Valid = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:Reset(true)
  for index, value in pairs(self.ListItem or {}) do
    value.actionOnClickButton:Remove(self.OnClickedItem, self)
  end
  self.ListItem = {}
  local Item
  for index, DataInfo in pairs(PageData.GiftList or {}) do
    Item = self.DynamicEntryBox_Item and self.DynamicEntryBox_Item:BP_CreateEntry()
    Valid = Item and Item:Init(index, DataInfo)
    self.ListItem[index] = Item
    Item.actionOnClickButton:Add(self.OnClickedItem, self)
  end
  local bIsClearText = true
  for i, InItem in pairs(self.ListItem or {}) do
    if not InItem.bIsUnlock and not InItem.bIsPromiseTask then
      Valid = InItem and self:OnClickedItem(InItem, true)
      bIsClearText = false
      break
    end
  end
  if bIsClearText then
    Valid = self.TextBlock_ItemTypeName and self.TextBlock_ItemTypeName:SetText("")
    Valid = self.TextBlock_ItemDesc and self.TextBlock_ItemDesc:SetText("")
    Valid = self.TextBlock_TaskCurNum and self.TextBlock_TaskCurNum:SetText("")
    Valid = self.ProgressBar_Task and self.ProgressBar_Task:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.BtnPreview then
    self.BtnPreview.OnClicked:Add(self, self.OnPreviewRewardClicked)
  end
  if self.TaskUnlockPage then
    self.TaskUnlockPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TaskUnlockPage.img_touch.OnMouseButtonDownEvent:Bind(self, self.OnTaskTipsClicked)
  end
  self.newTaskQueue = PageData.NewUnlockTask
  self:CheckNewTaskTips()
end
function ApartmentPromisePage:OnClickedItem(Item, OnlyChose)
  self.RecordItem = Item
  self.SpecialDeal = false
  Valid = self.TextBlock_ItemTypeName and self.TextBlock_ItemTypeName:SetText(Item.ItemTypeName)
  Valid = self.TextBlock_ItemDesc and self.TextBlock_ItemDesc:SetText(Item.ItemDesc)
  Valid = self.TextBlock_TaskCurNum and self.TextBlock_TaskCurNum:SetText(Item.TaskProgress)
  Valid = self.ProgressBar_Task and self.ProgressBar_Task:SetVisibility(Item.ProgressLevel and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.ProgressBar_Task and self.ProgressBar_Task:SetPercent(Item.ProgressLevel or 0)
  for index, value in pairs(self.ListItem or {}) do
    Valid = value.Button_Clicked and value.Button_Clicked:SetIsEnabled(value.Index ~= Item.Index)
  end
  if not Item.bIsGet and Item.bIsShowRewardTip and Item.bIsUnlock and not OnlyChose then
    if Item.bIsPromiseTask then
      if 5 == Item.Level then
        self.SpecialDeal = true
      end
      if Item.AVGEventId and 0 ~= Item.AVGEventId then
        Item:SetIsClicked()
        GameFacade:SendNotification(NotificationDefines.PromisePlayAVGEvent, Item.AVGEventId)
        local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
        GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):InteractOperateReq(3, kaNavigationProxy:GetCurrentRoleId(), Item.AVGEventId, {1, 0})
        RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.PromiseMemory, -1)
      elseif Item.AVGSequenceId and 0 ~= Item.AVGSequenceId then
        Item:SetIsClicked()
        GameFacade:SendNotification(NotificationDefines.PromisePlayAVGSequence, Item.AVGSequenceId)
      else
        Item:SetIsClicked()
        self:ReqGetTaskReward()
      end
    else
      local Body = {
        Level = Item.Level,
        bIsPromiseTask = Item.bIsPromiseTask
      }
      GameFacade:SendNotification(NotificationDefines.PlayApartmentGetRewardAnimation, Body)
    end
  end
end
function ApartmentPromisePage:ReqGetReward()
  if self.RecordItem then
    if self.RecordItem.bIsPromiseTask then
      GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):ReqGetTaskReward(self.RecordItem.TaskId)
    else
      local CurrentRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
      local roleApartmentInfo = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(CurrentRoleId)
      GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):ReqGetRoleIntimacyReward(CurrentRoleId, roleApartmentInfo.intimacy_lv)
    end
  end
end
function ApartmentPromisePage:ReqGetTaskReward()
  if self.RecordItem then
    if self.SpecialDeal then
      local Body = {
        Level = self.RecordItem.Level,
        bIsPromiseTask = self.RecordItem.bIsPromiseTask
      }
      GameFacade:SendNotification(NotificationDefines.PlayApartmentGetRewardAnimation, Body)
    else
      GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):ReqGetTaskReward(self.RecordItem.TaskId)
    end
  end
end
function ApartmentPromisePage:OnPreviewRewardClicked()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    local TipsText = ConfigMgr:FromStringTable(StringTablePath.ST_Apartment, "TempTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipsText)
    return
  end
  if not self.RecordItem then
    return
  end
  GameFacade:SendNotification(NotificationDefines.ApartmentMainPageVisibility, false)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PromiseRewardDetailPage, nil, {
    RewardItemArray = self.RecordItem.ItemArray
  })
end
function ApartmentPromisePage:CheckNewTaskTips()
  if 0 == #self.newTaskQueue then
    return
  end
  self.NewTaskToTip = table.remove(self.newTaskQueue, 1)
  if self.NewTaskToTip and self.TaskUnlockPage then
    self.TaskUnlockPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TaskUnlockPage:PlayAnimation(self.TaskUnlockPage.Level_Up, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    local BattlePassProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    local taskCfg = BattlePassProxy:GetPromiseTaskCfg(self.NewTaskToTip)
    if taskCfg and taskCfg.MissionName then
      self.TaskUnlockPage.Text_Tile:SetText(taskCfg.MissionName)
    end
    self.TaskTipTimer = TimerMgr:AddTimeTask(2, 0, 1, FuncSlot(ApartmentPromisePage.OnTaskTipsClicked, self))
  end
end
function ApartmentPromisePage:ClearTaskTipTimer()
  if self.TaskTipTimer then
    self.TaskTipTimer:EndTask()
    self.TaskTipTimer = nil
  end
end
function ApartmentPromisePage:OnTaskTipsClicked()
  self:ClearTaskTipTimer()
  GameFacade:SendNotification(NotificationDefines.PromiseTaskUnlockTipsRead, {
    taskInfo = self.NewTaskToTip
  })
  self.TaskUnlockPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:CheckNewTaskTips()
end
function ApartmentPromisePage:ListNeededMediators()
  return {ApartmentPromiseMediator}
end
function ApartmentPromisePage:InitializeLuaEvent()
end
function ApartmentPromisePage:OnClose()
  self:ClearTaskTipTimer()
end
return ApartmentPromisePage
