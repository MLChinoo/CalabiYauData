local BattlePassProgressPaginationPanel = class("BattlePassProgressPaginationPanel", PureMVC.ViewComponentPanel)
function BattlePassProgressPaginationPanel:Construct()
  BattlePassProgressPaginationPanel.super.Construct(self)
  if self.Button_Sub then
    self.Button_Sub.OnClicked:Add(self, BattlePassProgressPaginationPanel.OnButtonSub)
  end
  if self.Button_Add then
    self.Button_Add.OnClicked:Add(self, BattlePassProgressPaginationPanel.OnButtonAdd)
  end
end
function BattlePassProgressPaginationPanel:Destruct()
  BattlePassProgressPaginationPanel.super.Destruct(self)
  if self.Button_Sub then
    self.Button_Sub.OnClicked:Remove(self, BattlePassProgressPaginationPanel.OnButtonSub)
  end
  if self.Button_Add then
    self.Button_Add.OnClicked:Remove(self, BattlePassProgressPaginationPanel.OnButtonAdd)
  end
end
function BattlePassProgressPaginationPanel:OnButtonSub()
  self.parent:PaginationClick(-1)
end
function BattlePassProgressPaginationPanel:OnButtonAdd()
  self.parent:PaginationClick(1)
end
function BattlePassProgressPaginationPanel:InitView(inParent, cnt, choose, str)
  self.cells = {}
  self.parent = inParent
  if self.DynamicEntryBox_Pagination then
    for index = 1, cnt do
      local cell = self.DynamicEntryBox_Pagination:BP_CreateEntry()
      if cell then
        table.insert(self.cells, cell)
      end
    end
  end
  self:UpdateButtonVisible(choose, cnt)
  if self.TextBlock_Level then
    self.TextBlock_Level:SetText(str)
  end
end
function BattlePassProgressPaginationPanel:SwitchActive(choose)
  for index = 1, #self.cells do
    local cell = self.cells[index]
    cell:SwitchIndex(index == choose and 1 or 0)
  end
end
function BattlePassProgressPaginationPanel:UpdateButtonVisible(currentPage, maxPage, str)
  if self.Button_Sub then
    self.Button_Sub:SetVisibility(1 == currentPage and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  end
  if self.Button_Add then
    self.Button_Add:SetVisibility(currentPage == maxPage and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  end
  self:SwitchActive(currentPage)
  if self.TextBlock_Level then
    self.TextBlock_Level:SetText(str)
  end
end
return BattlePassProgressPaginationPanel
