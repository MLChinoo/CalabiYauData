local BattlePassProgressPaginationCell = class("BattlePassProgressPaginationCell", PureMVC.ViewComponentPanel)
function BattlePassProgressPaginationCell:Construct()
  BattlePassProgressPaginationCell.super.Construct(self)
end
function BattlePassProgressPaginationCell:Destruct()
  BattlePassProgressPaginationCell.super.Destruct(self)
end
function BattlePassProgressPaginationCell:SwitchIndex(index)
  if self.WidgetSwitcher_Cell then
    self.WidgetSwitcher_Cell:SetActiveWidgetIndex(index)
    if 1 == index then
      self:PlayAnimation(self.Anim_Select)
    end
  end
end
return BattlePassProgressPaginationCell
