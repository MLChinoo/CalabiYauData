local ApplyPlayerInfoItemList = class("ApplyPlayerInfoItemList", PureMVC.ViewComponentPanel)
local sizeWidth = 140
local sizeHeight = 170
local offset = 0
local padOffset = 16
local extentInfoSize = 270
function ApplyPlayerInfoItemList:InitializeLuaEvent()
  self.itemArr = {}
  self.PMCustomScrollBox_2.OnUserScrolled:Add(self, self.OnScrolled)
  self.PMCustomScrollBox_2.OnMouseWheelEvent:Add(self, self.OnMouseWheelEvent)
  self.PMCustomScrollBox_2.OnTouchStartEvent:Add(self, self.OnTouchStartEvent)
  self.PMCustomScrollBox_2.OnTouchEndedEvent:Add(self, self.OnTouchEndedEvent)
  self._showSize = self.PMCustomScrollBox_2.Slot:GetSize().X
end
function ApplyPlayerInfoItemList:OnTouchStartEvent()
  self._startEventFlag = true
  self._touchFlag = true
  self.value = nil
end
function ApplyPlayerInfoItemList:SetSelectedByIndex(index)
  if self.itemArr[index] then
    self.itemArr[index]:SetSelfBeClick()
    LogInfo("ApplyPlayerInfoItemList:OnTouchEndedEvent", string.format(" select %d item", index))
  else
    LogInfo("ApplyPlayerInfoItemList:OnTouchEndedEvent", "index is nil")
  end
end
function ApplyPlayerInfoItemList:OnTouchEndedEvent()
  self._startEventFlag = false
  self._touchFlag = false
  if self.value == nil then
    LogInfo("ApplyPlayerInfoItemList:OnTouchEndedEvent", "value is nil")
    return
  end
  local index = math.clamp(math.ceil(self.value / (sizeWidth + padOffset)), 1, #self.itemArr)
  LogInfo("ApplyPlayerInfoItemList:OnTouchEndedEvent", string.format("scroll value is %f, select %d item", self.value, index))
  self:SetSelectedByIndex(index)
end
function ApplyPlayerInfoItemList:ClearSelectStatus()
  if self._selectItem then
    self._selectItem:SetSelectState(false)
    self._selectItem = nil
  end
  self.value = nil
  self:RefreshItemListSize()
end
function ApplyPlayerInfoItemList:OnSelectPlayer(item)
  self._selectItem = item
  self:RefreshItemListSize()
  self.PMCustomScrollBox_2:EndInertialScrolling()
  self.PMCustomScrollBox_2:ScrollWidgetIntoView(item, true, UE4.EDescendantScrollDestination.Center, 0)
  TimerMgr:AddTimeTask(0.2, 0, 1, function()
    self.wheeling = false
  end)
end
function ApplyPlayerInfoItemList:OnScrolled(value)
  if self._touchFlag then
    LogInfo("OnScrolled", "touching" .. tostring(value))
    if self._startEventFlag then
      self._startEventFlag = false
      self:ClearSelectStatus()
    end
    self.value = value
  else
    LogInfo("OnScrolled", "wheeling")
  end
end
function ApplyPlayerInfoItemList:OnMouseWheelEvent(geometry, mouseEvent)
  local y = UE4.UKismetInputLibrary.PointerEvent_GetWheelDelta(mouseEvent)
  if y < 0 then
    if self._selectItem then
      local index = self.PMCustomScrollBox_2:GetChildIndex(self._selectItem)
      if index < #self.itemArr then
        index = index + 1
        self:SetSelectedByIndex(index)
      end
    end
  elseif y > 0 and self._selectItem then
    local index = self.PMCustomScrollBox_2:GetChildIndex(self._selectItem)
    if index > 1 then
      index = index - 1
      self:SetSelectedByIndex(index)
    end
  end
end
function ApplyPlayerInfoItemList:RefreshItemListSize()
  local count = #self.itemArr
  local sizeBoxLength = (self._showSize - (count * sizeWidth + (count - 1) * padOffset)) / 2 + (sizeWidth * count + (count - 1) * padOffset) / 2
  self.SizeBox1:SetWidthOverride(sizeBoxLength)
  self.SizeBox2:SetWidthOverride(sizeBoxLength)
  if count <= 1 then
    self.PMCustomScrollBox_2:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.PMCustomScrollBox_2:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function ApplyPlayerInfoItemList:AddPlayerItem(applyInfoData)
  local itemClass = ObjectUtil:LoadClass(self.itemClass)
  local item = UE4.UWidgetBlueprintLibrary.Create(self, itemClass)
  self.PMCustomScrollBox_2:RemoveChild(self.SizeBox2)
  self.PMCustomScrollBox_2:AddChild(item)
  self.PMCustomScrollBox_2:AddChild(self.SizeBox2)
  self.itemArr[#self.itemArr + 1] = item
  item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:RefreshItemListSize()
  return item
end
function ApplyPlayerInfoItemList:RemovePlayerItem(item)
  local rmIndex
  for i, v in ipairs(self.itemArr) do
    if item == v then
      rmIndex = i
      break
    end
  end
  if rmIndex then
    self.PMCustomScrollBox_2:RemoveChild(item)
    table.remove(self.itemArr, rmIndex)
    self:RefreshItemListSize()
  end
end
return ApplyPlayerInfoItemList
