local CommunicationNavigationBar = class("CommunicationNavigationBar", PureMVC.ViewComponentPanel)
function CommunicationNavigationBar:InitializeLuaEvent()
  CommunicationNavigationBar.super.InitializeLuaEvent(self)
  self.onItemClickEvent = LuaEvent.new()
  self.barItemMap = {}
  self:SetBarIndex()
end
function CommunicationNavigationBar:SetBarIndex()
  local allChild = self.HorizontalBox_Item:GetAllChildren()
  local childNum = allChild:Length()
  for i = 1, childNum do
    local item = allChild:Get(i)
    if item then
      self.barItemMap[i] = item
      item:SetCustomType(i - 1)
      item.onClickEvent:Add(self.OnItemClick, self)
    end
  end
end
function CommunicationNavigationBar:OnItemClick(item)
  if item == self.lastItem then
    return
  end
  if self.lastItem then
    self.lastItem:SetSelectState(false)
  end
  self.lastItem = item
  self.lastItem:SetSelectState(true)
  self.onItemClickEvent(item:GetCustomType())
end
function CommunicationNavigationBar:SelectBarByCustomType(customType)
  for key, value in pairs(self.barItemMap) do
    if value and value:GetCustomType() == customType then
      value:SetSlefBeSelect()
      break
    end
  end
end
function CommunicationNavigationBar:SetBarSelectState(customType)
  for key, value in pairs(self.barItemMap) do
    if value and value:GetCustomType() == customType then
      value:SetSelectState(true)
      if self.lastItem then
        self.lastItem:SetSelectState(false)
      end
      self.lastItem = value
      break
    end
  end
end
function CommunicationNavigationBar:ClearPanel()
  if self.lastItem then
    self.lastItem:SetSelectState(false)
    self.lastItem = nil
  end
end
function CommunicationNavigationBar:GetBarByCustomType(customType)
  return self.barItemMap[customType]
end
return CommunicationNavigationBar
