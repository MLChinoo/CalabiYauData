local RankScoreProgress = class("RankScoreProgress", PureMVC.ViewComponentPanel)
function RankScoreProgress:ListNeededMediators()
  return {}
end
function RankScoreProgress:InitView(dividCount)
  self.divisions = {}
  if self.ProgressDivid and self.HorizontalBox_Progress then
    self.HorizontalBox_Progress:ClearChildren()
    local PanelClass = ObjectUtil:LoadClass(self.ProgressDivid)
    if PanelClass then
      for index = 1, dividCount do
        local divid = UE4.UWidgetBlueprintLibrary.Create(self, PanelClass)
        if divid then
          self.HorizontalBox_Progress:AddChild(divid)
          local horizontalSlot = UE4.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(divid)
          local inSize = UE4.FSlateChildSize()
          horizontalSlot:SetSize(inSize)
          table.insert(self.divisions, divid)
        else
          LogError("RankScoreProgress", "Panel create failed")
        end
      end
    else
      LogError("RankScoreProgress", "Panel class load failed")
    end
  end
end
function RankScoreProgress:SetPercent(newPercent)
  if self.HorizontalBox_Progress then
    local interger = math.floor(newPercent * table.count(self.divisions))
    local decimal = newPercent * table.count(self.divisions) - interger
    for index = 1, interger do
      if self.divisions[index] then
        self.divisions[index]:SetPercent(1)
      end
    end
    if self.divisions[interger + 1] then
      self.divisions[interger + 1]:SetPercent(decimal)
    end
  end
end
return RankScoreProgress
