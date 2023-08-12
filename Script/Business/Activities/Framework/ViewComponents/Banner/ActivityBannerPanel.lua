local ActivityBannerPanel = class("ActivityBannerPanel", PureMVC.ViewComponentPanel)
local ActivityBannerMediator = require("Business/Activities/Framework/Mediators/Banner/ActivityBannerMediator")
function ActivityBannerPanel:ListNeededMediators()
  return {ActivityBannerMediator}
end
function ActivityBannerPanel:InitializeLuaEvent()
  self.updateViewEvent = LuaEvent.new()
  self.cells = {}
  self.apartmentVisible = false
end
function ActivityBannerPanel:Construct()
  ActivityBannerPanel.super.Construct(self)
  self.updateViewEvent()
end
function ActivityBannerPanel:Destruct()
  ActivityBannerPanel.super.Destruct(self)
end
function ActivityBannerPanel:UpdateView(data)
  if self.DynamicEntryBox_Activities then
    local widgetNum = self.DynamicEntryBox_Activities:GetNumEntries()
    local activityNum = #data
    if widgetNum < activityNum then
      local extraEntryNum = activityNum - widgetNum
      for exIndex = 1, extraEntryNum do
        local widget = self.DynamicEntryBox_Activities:BP_CreateEntry()
        table.insert(self.cells, widget)
      end
    end
    local found
    for activityIndex = 1, activityNum do
      if self.cells[activityIndex] then
        self.cells[activityIndex]:InitInfo(data[activityIndex])
      end
      found = activityIndex
    end
    for closeIndex = found + 1, #self.cells do
      if self.cells[closeIndex] then
        self.cells[closeIndex]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.apartmentVisible and activityNum > 0 then
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function ActivityBannerPanel:SetViewVisible(visible)
  self.apartmentVisible = visible
  if self.cells and #self.cells > 0 then
    self:SetVisibility(visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ActivityBannerPanel:UpdateRedDot(activityId, num)
  for index, value in ipairs(self.cells) do
    if tostring(activityId) == tostring(value.activityId) then
      value:SetRedDot(num)
    end
  end
end
return ActivityBannerPanel
