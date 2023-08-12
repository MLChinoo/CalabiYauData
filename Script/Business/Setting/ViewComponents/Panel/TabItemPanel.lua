local TabItemPanel = class("TabItemPanel", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local TabStyle = SettingEnum.TabStyle
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
function TabItemPanel:ListNeededMediators()
  return {}
end
function TabItemPanel:InitializeLuaEvent()
end
function TabItemPanel:InitView(data, extras)
  local horizontalBox = self.HorizontalBox_Tab
  self.tabArray = {}
  local isSub = false
  for i, v in ipairs(data) do
    local item
    if extras and extras.isSub then
      isSub = true
    else
      isSub = false
    end
    if isSub then
      item = SettingHelper.CreateSubTabItem({
        text = v.text,
        callfunc = function(bIsChecked)
          self:OnCheckTabItem(i, bIsChecked)
        end
      })
    else
      item = SettingHelper.CreateTabItem({
        text = v.text,
        callfunc = function(bIsChecked)
          self:OnCheckTabItem(i, bIsChecked)
        end
      })
    end
    local itemSlot = horizontalBox:AddChild(item)
    local margin = UE4.FMargin()
    if isSub then
      margin.Right = 5
    else
      margin.Right = -32
    end
    itemSlot:SetPadding(margin)
    self.tabArray[i] = item
  end
  local totalCnt = #self.tabArray
  for i = 1, totalCnt do
    local itemTab = self.tabArray[i]
    if 1 == i then
      itemTab:SetTabStyle(TabStyle.Left)
    elseif i == totalCnt then
      itemTab:SetTabStyle(TabStyle.Right)
    else
      itemTab:SetTabStyle(TabStyle.Middle)
    end
  end
  self.data = data
end
function TabItemPanel:OnCheckTabItem(index, bIsChecked)
  if self.currentIndex ~= index and bIsChecked then
    self:SwitchTab(index)
  else
    self.tabArray[index]:SetIsChecked(true)
  end
end
function TabItemPanel:SwitchTab(index, subIndex)
  local horizontalBox = self.HorizontalBox_Tab
  if self.currentIndex and self.tabArray[self.currentIndex] then
    self.tabArray[self.currentIndex]:SetIsChecked(false)
  end
  self.tabArray[index]:SetIsChecked(true)
  self.currentIndex = index
  if self.data[index].callfunc then
    self.data[index].callfunc(index, subIndex)
  end
end
return TabItemPanel
