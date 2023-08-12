local LotteryResultPage = class("LotteryResultPage", PureMVC.ViewComponentPage)
local LotteryResultMediator = require("Business/Lottery/Mediators/LotteryResultMediator")
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function LotteryResultPage:ListNeededMediators()
  return {LotteryResultMediator}
end
function LotteryResultPage:InitView(itemsInfo)
  self:UpdateResultItems(itemsInfo)
  local itemNum = table.count(self.itemArray)
  if itemNum <= 0 then
    return
  end
  self.resultCnt = 0
  for _, itemInfo in pairsByKeys(itemsInfo, function(a, b)
    if itemsInfo[a].item_id == itemsInfo[b].item_id then
      return table.count(itemsInfo[a]) < table.count(itemsInfo[b])
    elseif itemsInfo[a].quality == itemsInfo[b].quality then
      return itemsInfo[a].item_id > itemsInfo[b].item_id
    else
      return itemsInfo[a].quality > itemsInfo[b].quality
    end
  end) do
    self.resultCnt = self.resultCnt + 1
    if itemNum >= self.resultCnt then
      self.itemArray[self.resultCnt]:Init(itemInfo)
      self.itemArray[self.resultCnt].actionOnClickItem:Add(self.DisplayItem, self)
    end
    self.itemArray[self.resultCnt]:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if self.resultCnt > 0 then
    self.bCanEnterPreview = false
    self.animPlayTask = TimerMgr:AddTimeTask(0, 0.1, self.resultCnt, function()
      self:ResultDisplayAnim()
    end)
    if self.Anim_ShowButton then
      self.showButtonTask = TimerMgr:AddTimeTask(0.1 * self.resultCnt, 0, self.resultCnt, function()
        self:PlayAnimation(self.Anim_ShowButton)
        self.bCanEnterPreview = true
      end)
    end
  end
end
function LotteryResultPage:ResultDisplayAnim()
  if self.animFinishCnt == nil then
    self.animFinishCnt = 0
  else
    self.animFinishCnt = self.animFinishCnt + 1
  end
  if self.itemArray and self.resultCnt and self.animFinishCnt < self.resultCnt then
    self.itemArray[self.animFinishCnt + 1]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.itemArray[self.animFinishCnt + 1]:StartPlayAnim()
    return
  end
  self.animFinishCnt = nil
end
function LotteryResultPage:DisplayItem(itemId)
  if not self.bCanEnterPreview then
    return
  end
  self.isPreviewing = false
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Add(self.DisplayResult, self)
    self.HotKeyButton_Esc.actionOnStartPreview:Add(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopPreview:Add(self.StopPreview, self)
    self.HotKeyButton_Esc.actionOnStartDrag:Add(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopDrag:Add(self.StopPreview, self)
  end
  if itemId and self.Button_Equip then
    self.curDisplayItemId = itemId
    self.Button_Equip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
    local bItemUsed = false
    if itemType == UE4.EItemIdIntervalType.RoleSkin then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):IsRoleSkinUsed(itemId)
    elseif itemType == UE4.EItemIdIntervalType.Weapon then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.EquipRoomPrepareProxy):IsWeaponUsed(itemId)
    elseif itemType == UE4.EItemIdIntervalType.VCardAvatar then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID) == itemId
    elseif itemType == UE4.EItemIdIntervalType.VCardBg then
      bItemUsed = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId) == itemId
    else
      self.Button_Equip:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if bItemUsed then
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Equipped")
      self.Button_Equip:SetPanelName(text)
      self.Button_Equip:SetButtonIsEnabled(false)
    else
      local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipBtnName")
      self.Button_Equip:SetPanelName(text)
      self.Button_Equip:SetButtonIsEnabled(true)
    end
  end
  if self.ItemDescPanel then
    self.ItemDescPanel:Update(itemId)
  end
  if self.HotKeyButton_Esc then
    local data = {}
    data.itemId = itemId
    data.show3DBackground = true
    self.HotKeyButton_Esc:SetItemDisplayed(data)
  end
  if self.WidgetSwitcher_ContentType then
    self.WidgetSwitcher_ContentType:SetActiveWidgetIndex(1)
  end
end
function LotteryResultPage:DisplayResult()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Remove(self.DisplayResult, self)
    self.HotKeyButton_Esc.actionOnStartPreview:Remove(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopPreview:Remove(self.StopPreview, self)
    self.HotKeyButton_Esc.actionOnStartDrag:Remove(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopDrag:Remove(self.StopPreview, self)
  end
  if self.WidgetSwitcher_ContentType then
    self.WidgetSwitcher_ContentType:SetActiveWidgetIndex(0)
  end
  self.curDisplayItemId = nil
end
function LotteryResultPage:ItemUseSucceed()
  if self.Button_Equip then
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Equipped")
    self.Button_Equip:SetPanelName(text)
    self.Button_Equip:SetButtonIsEnabled(false)
  end
end
function LotteryResultPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("LotteryResultPage", "Lua implement OnOpen")
  local itemsObtained = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryObtained()
  if nil == itemsObtained then
    return
  end
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):ClearObtains()
  self.bToNextStep = false
  self.bCanEnterPreview = false
  if self.Button_Equip then
    self.Button_Equip.OnClickEvent:Add(self, self.OnClickEquip)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  end
  if self.Button_OnceMore then
    self.Button_OnceMore.OnPMButtonClicked:Add(self, self.OnClickMore)
    self.Button_OnceMore.OnPMButtonHovered:Add(self, self.OnHoverMore)
    self.Button_OnceMore.OnPMButtonUnHovered:Add(self, self.OnUnhoverMore)
    self.Button_OnceMore.OnPressed:Add(self, self.OnPressMore)
    self.Button_OnceMore.OnReleased:Add(self, self.OnReleaseMore)
  end
  if self.Button_Share then
    self.Button_Share.OnClickEvent:Add(self, self.OnClickShare)
  end
  self.itemArray = {}
  self:PlayWidgetAnimationWithCallBack("Anim_Open", {
    self,
    function()
      self:InitView(itemsObtained)
    end
  })
  self.ScreenPrintSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self, "OnScreenPrintSuccess")
  if self.HorizontalBox_Mappingitem then
    self.ballItems = self.HorizontalBox_Mappingitem:GetAllChildren()
  end
  self:DisplayResultList()
  self:SetTimeText()
  self:SetTicketInfo()
  self:SetStatisticsText(itemsObtained)
end
function LotteryResultPage:OnClose()
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Remove(self.DisplayResult, self)
    self.HotKeyButton_Esc.actionOnStartPreview:Remove(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopPreview:Remove(self.StopPreview, self)
    self.HotKeyButton_Esc.actionOnStartDrag:Remove(self.StartPreview, self)
    self.HotKeyButton_Esc.actionOnStopDrag:Remove(self.StopPreview, self)
  end
  if self.animPlayTask then
    self.animPlayTask:EndTask()
    self.animPlayTask = nil
  end
  if self.showButtonTask then
    self.showButtonTask:EndTask()
    self.showButtonTask = nil
  end
  if self.Button_Equip then
    self.Button_Equip.OnClickEvent:Remove(self, self.OnClickEquip)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  end
  if self.Button_OnceMore then
    self.Button_OnceMore.OnPMButtonClicked:Remove(self, self.OnClickMore)
    self.Button_OnceMore.OnPMButtonHovered:Remove(self, self.OnHoverMore)
    self.Button_OnceMore.OnPMButtonUnHovered:Remove(self, self.OnUnhoverMore)
    self.Button_OnceMore.OnPressed:Remove(self, self.OnPressMore)
    self.Button_OnceMore.OnReleased:Remove(self, self.OnReleaseMore)
  end
  if self.Button_Share then
    self.Button_Share.OnClickEvent:Remove(self, self.OnClickShare)
  end
  if self.ScreenPrintSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self.ScreenPrintSuccessHandler)
    self.ScreenPrintSuccessHandler = nil
  end
end
function LotteryResultPage:StartPreview(is3DModel)
  if self.SwtichAnimation and not self.isPreviewing then
    self.SwtichAnimation:PlayCloseAnimation()
    if self.Anim_MoveOut then
      self:PlayAnimationForward(self.Anim_MoveOut, 1)
    end
    self.isPreviewing = true
  end
end
function LotteryResultPage:StopPreview(is3DModel)
  if self.SwtichAnimation and self.isPreviewing then
    self.SwtichAnimation:PlayOpenAnimation()
    if self.Anim_MoveOut then
      self:PlayAnimationReverse(self.Anim_MoveOut, 1)
    end
    self.isPreviewing = false
  end
end
function LotteryResultPage:LuaHandleKeyEvent(key, inputEvent)
  if self.HotKeyButton_Esc then
    return self.HotKeyButton_Esc:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function LotteryResultPage:OnClickReturn()
  ViewMgr:ClosePage(self)
  GameFacade:SendNotification(NotificationDefines.Lottery.InitSceneViews)
  ViewMgr:OpenPage(self, UIPageNameDefine.LotterySettingPage)
end
function LotteryResultPage:OnClickMore()
  LogDebug("LotteryResultPage", "Click once more")
  if self.bToNextStep then
    return
  end
  self.bToNextStep = true
  GameFacade:SendNotification(NotificationDefines.Lottery.TryLotteryCmd)
end
function LotteryResultPage:OnHoverMore()
  if self.bToNextStep then
    return
  end
  if self.WidgetSwitcher_TicketNum then
    self.WidgetSwitcher_TicketNum:SetActiveWidgetIndex(1)
  end
end
function LotteryResultPage:OnUnhoverMore()
  if self.bToNextStep then
    return
  end
  if self.WidgetSwitcher_TicketNum then
    self.WidgetSwitcher_TicketNum:SetActiveWidgetIndex(0)
  end
end
function LotteryResultPage:OnPressMore()
  if self.bToNextStep then
    return
  end
  if self.WidgetSwitcher_TicketNum then
    self.WidgetSwitcher_TicketNum:SetActiveWidgetIndex(2)
  end
end
function LotteryResultPage:OnReleaseMore()
  if self.bToNextStep then
    return
  end
  if self.WidgetSwitcher_TicketNum then
    local activeIndex = self.WidgetSwitcher_TicketNum:GetActiveWidgetIndex()
    self.WidgetSwitcher_TicketNum:SetActiveWidgetIndex(activeIndex > 0 and 1 or 0)
  end
end
function LotteryResultPage:SetIsBuyingTicket()
  LogDebug("LotteryResultPage", "Buy ticket")
  self.bToNextStep = false
end
function LotteryResultPage:OnClickShare()
  if self.Button_Return then
    self.Button_Return:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Overlay_OnceMore then
    self.Overlay_OnceMore:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_Share then
    self.Button_Share:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.Rewards)
end
function LotteryResultPage:OnClickEquip()
  if self.curDisplayItemId then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):EquipLotteryResultItem(self.curDisplayItemId)
  end
end
function LotteryResultPage:OnScreenPrintSuccess()
  if self.Button_Return then
    self.Button_Return:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if self.Overlay_OnceMore then
    self.Overlay_OnceMore:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if self.Button_Share then
    self.Button_Share:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function LotteryResultPage:SetTimeText()
  if self.Txt_Time then
    self.Txt_Time:SetText(string.reverse(os.date("%y%m%d%M%H")))
  end
end
function LotteryResultPage:SetStatisticsText(datas)
  if nil == datas then
    return
  end
  local redCout = 0
  local orangeCount = 0
  local purpleCount = 0
  local blueCount = 0
  for key, value in pairs(datas) do
    if value.quality == UE4.ECyItemQualityType.Red then
      redCout = redCout + 1
    elseif value.quality == UE4.ECyItemQualityType.Orange then
      orangeCount = orangeCount + 1
    elseif value.quality == UE4.ECyItemQualityType.Purple then
      purpleCount = purpleCount + 1
    elseif value.quality == UE4.ECyItemQualityType.Blue then
      blueCount = blueCount + 1
    end
  end
  local text = tostring(blueCount) .. tostring(purpleCount) .. tostring(orangeCount) .. tostring(redCout)
  if self.Txt_Statistics then
    self.Txt_Statistics:SetText(text)
  end
end
function LotteryResultPage:DisplayResultList()
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  local itemDatas = lotteryProxy:GetLotteryBallSet()
  if nil == itemDatas then
    return
  end
  local dataCount = table.count(itemDatas)
  for index = 1, self.ballItems:Length() do
    local ball = self.ballItems:Get(index)
    if ball then
      ball:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if index <= dataCount then
        local activeIndex = 0
        if itemDatas[index] == LotteryEnum.ballItemType.Line then
          if itemDatas[index - 1] == LotteryEnum.ballItemType.Circle then
            activeIndex = 4
          else
            activeIndex = 1
          end
        elseif itemDatas[index] == LotteryEnum.ballItemType.Circle then
          if itemDatas[index - 1] == LotteryEnum.ballItemType.Line then
            activeIndex = 2
          else
            activeIndex = 3
          end
        end
        ball:SetActiveWidgetIndex(activeIndex)
        ball:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function LotteryResultPage:SetTicketInfo()
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  local lotteryId = lotteryProxy:GetLotterySelected()
  local count = table.count(lotteryProxy:GetLotteryBallSet())
  if self.Image_Ticket then
    local ticketIcon = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemImg(lotteryProxy:GetLotteryInfo(lotteryId).ticketId)
    self:SetImageByTexture2D(self.Image_Ticket, ticketIcon)
  end
  if self.Text_NeedNum_Normal then
    self.Text_NeedNum_Normal:SetText("x" .. count)
  end
  if self.Text_NeedNum_Hover then
    self.Text_NeedNum_Hover:SetText("x" .. count)
  end
  if self.Text_NeedNum_Press then
    self.Text_NeedNum_Press:SetText("x" .. count)
  end
  if self.WidgetSwitcher_TicketNum then
    self.WidgetSwitcher_TicketNum:SetActiveWidgetIndex(0)
  end
end
function LotteryResultPage:UpdateResultItems(datas)
  local dataCount = table.count(datas)
  if 6 == dataCount then
    self:GetTopItemList(3)
    self:GetBottomItemList(3)
  elseif 7 == dataCount then
    self:GetTopItemList(4)
    self:GetBottomItemList(3)
  elseif 8 == dataCount then
    self:GetTopItemList(4)
    self:GetBottomItemList(4)
  elseif 9 == dataCount then
    self:GetTopItemList(5)
    self:GetBottomItemList(4)
  else
    self:GetTopItemList(5)
    self:GetBottomItemList(5)
  end
end
function LotteryResultPage:GetTopItemList(getNum)
  if self.HorizontalBox_TopItemList == nil then
    LogError("LotteryResultPage:GetTopItemList", "HorizontalBox_TopItemList is nil")
    return
  end
  local topItemList = self.HorizontalBox_TopItemList:GetAllChildren()
  local itemNum = topItemList:Length()
  for i = 1, itemNum do
    topItemList:Get(i):SetVisibility(UE4.ESlateVisibility.Collapsed)
    if i <= getNum then
      table.insert(self.itemArray, topItemList:Get(i))
    end
  end
end
function LotteryResultPage:GetBottomItemList(getNum)
  if self.HorizontalBox_BottomItemList == nil then
    LogError("LotteryResultPage:GetTopItemList", "HorizontalBox_BottomItemList is nil")
    return
  end
  local topItemList = self.HorizontalBox_BottomItemList:GetAllChildren()
  local itemNum = topItemList:Length()
  for i = 1, itemNum do
    topItemList:Get(i):SetVisibility(UE4.ESlateVisibility.Collapsed)
    if i <= getNum then
      table.insert(self.itemArray, topItemList:Get(i))
    end
  end
end
return LotteryResultPage
