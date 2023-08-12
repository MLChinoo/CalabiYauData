local BattlePassPaginationPanel = class("BattlePassPaginationPanel", PureMVC.ViewComponentPanel)
function BattlePassPaginationPanel:InitView(inParent, cnt, choose)
  self.cells = {}
  self.parent = inParent
  if self.DynamicEntryBox_Pagination then
    for index = 1, cnt do
      local cell = self.DynamicEntryBox_Pagination:BP_CreateEntry()
      if cell then
        cell.onClickEvent:Add(self.OnCellClick, self)
        table.insert(self.cells, cell)
      end
    end
  end
  self:SwitchActive(choose)
end
function BattlePassPaginationPanel:OnCellClick(clickCell)
  for index = 1, #self.cells do
    local cell = self.cells[index]
    if cell == clickCell then
      self.parent:PaginationClick(index)
      break
    end
  end
end
function BattlePassPaginationPanel:SwitchActive(choose)
  for index = 1, #self.cells do
    local cell = self.cells[index]
    cell:SwitchIndex(index == choose and 1 or 0)
  end
end
return BattlePassPaginationPanel
