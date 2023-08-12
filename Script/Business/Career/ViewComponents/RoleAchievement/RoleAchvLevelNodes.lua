local RoleAchvLevelNodes = class("RoleAchvLevelNodes", PureMVC.ViewComponentPanel)
function RoleAchvLevelNodes:InitializeLuaEvent()
end
function RoleAchvLevelNodes:Construct()
  print("----------- RoleAchvLevelNodes:Construct")
  self.super.Construct(self)
  self.LightColor = UE4.FLinearColor(1, 0.558341, 0.095307, 1)
  self.NormorColor = UE4.FLinearColor(0.042311, 0.042311, 0.042311, 1)
end
function RoleAchvLevelNodes:Destruct()
  self.super.Destruct(self)
end
function RoleAchvLevelNodes:UpdateLevelNodes(achvLevelNodes, progressInfo)
  local sectionNum = 0
  for i = 1, 4 do
    local sectionItem = self[string.format("ProgressSection%d", i)]
    sectionItem.ImgSeparator:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local lvNode = achvLevelNodes[i]
    if lvNode then
      sectionNum = sectionNum + 1
      sectionItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(sectionItem.HBInfo)
      canvasSlot:SetAlignment(UE4.FVector2D(0.5, 0))
      sectionItem.TxtLevel:SetText(tostring(i))
      sectionItem.TxtNum:SetText(string.format(" ( %d ) ", lvNode))
      if progressInfo.nextLv == i then
        sectionItem.TxtCurNum:SetText(tostring(progressInfo.progress))
        sectionItem.OverlayNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        sectionItem.OverlayNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      sectionItem.ImgSeparator:SetColorAndOpacity(self.NormorColor)
      ObjectUtil:SetTextColor(sectionItem.TxtLevel, self.NormorColor.R, self.NormorColor.G, self.NormorColor.B, self.NormorColor.A)
      ObjectUtil:SetTextColor(sectionItem.TxtUnit, self.NormorColor.R, self.NormorColor.G, self.NormorColor.B, self.NormorColor.A)
      ObjectUtil:SetTextColor(sectionItem.TxtNum, self.NormorColor.R, self.NormorColor.G, self.NormorColor.B, self.NormorColor.A)
      if i < progressInfo.nextLv then
        sectionItem.ProgressBarLevel:SetPercent(1)
        sectionItem.ImgSeparator:SetColorAndOpacity(self.LightColor)
        ObjectUtil:SetTextColor(sectionItem.TxtLevel, self.LightColor.R, self.LightColor.G, self.LightColor.B, self.LightColor.A)
        ObjectUtil:SetTextColor(sectionItem.TxtUnit, self.LightColor.R, self.LightColor.G, self.LightColor.B, self.LightColor.A)
        ObjectUtil:SetTextColor(sectionItem.TxtNum, self.LightColor.R, self.LightColor.G, self.LightColor.B, self.LightColor.A)
      elseif i == progressInfo.nextLv then
        local curNeed = achvLevelNodes[progressInfo.curLv] or 0
        local nextNeed = achvLevelNodes[progressInfo.nextLv]
        self.SectionPct = progressInfo.curLv == progressInfo.nextLv and 1 or (progressInfo.progress - curNeed) / (nextNeed - curNeed)
        sectionItem.ProgressBarLevel:SetPercent(self.SectionPct)
        self.NextLvSection = sectionItem
      else
        sectionItem.ProgressBarLevel:SetPercent(0)
      end
    else
      sectionItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local lastSectionItem = self[string.format("ProgressSection%d", sectionNum)]
  lastSectionItem.ImgSeparator:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(lastSectionItem.HBInfo)
  canvasSlot:SetAlignment(UE4.FVector2D(1, 0))
  TimerMgr:AddFrameTask(2, 1, 1, function()
    local sectionGeometry = self.NextLvSection:GetCachedGeometry()
    local scetionSize = UE4.USlateBlueprintLibrary.GetLocalSize(sectionGeometry)
    local ItemSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.NextLvSection.OverlayNum)
    ItemSlot:SetPosition(UE4.FVector2D(scetionSize.X * self.SectionPct, 0))
  end)
end
return RoleAchvLevelNodes
