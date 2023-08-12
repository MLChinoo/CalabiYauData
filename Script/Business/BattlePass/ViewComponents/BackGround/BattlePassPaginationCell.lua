local BattlePassPaginationCell = class("BattlePassPaginationCell", PureMVC.ViewComponentPanel)
function BattlePassPaginationCell:Construct()
  BattlePassPaginationCell.super.Construct(self)
  if self.Btn_Select then
    self.Btn_Select.OnClicked:Add(self, self.OnBtnSelectClick)
  end
  self.onClickEvent = LuaEvent.new()
end
function BattlePassPaginationCell:Destruct()
  BattlePassPaginationCell.super.Destruct(self)
  if self.Btn_Select then
    self.Btn_Select.OnClicked:Remove(self, self.OnBtnSelectClick)
  end
end
function BattlePassPaginationCell:OnBtnSelectClick()
  if self.WidgetSwitcher_Cell and 0 == self.WidgetSwitcher_Cell:GetActiveWidgetIndex() then
    self.onClickEvent(self)
  end
end
function BattlePassPaginationCell:SwitchIndex(index)
  if self.WidgetSwitcher_Cell then
    self.WidgetSwitcher_Cell:SetActiveWidgetIndex(index)
  end
end
return BattlePassPaginationCell
