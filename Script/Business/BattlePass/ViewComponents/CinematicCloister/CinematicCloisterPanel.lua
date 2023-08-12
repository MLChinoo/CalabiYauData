local CinematicCloisterPanel = class("CinematicCloisterPanel", PureMVC.ViewComponentPanel)
function CinematicCloisterPanel:InitializeLuaEvent()
  self.SeasonId = 0
end
function CinematicCloisterPanel:SetSeasonInfo(SeasonId, SeasonTitle)
  self.SeasonId = SeasonId
  if self.TitleText then
    self.TitleText:SetText(SeasonTitle)
  end
end
function CinematicCloisterPanel:AddCinematicCloisterItem(index, data)
  if self.ChapterPanel and self.CinematicCloisterItemClass then
    local ItemClass = ObjectUtil:LoadClass(self.CinematicCloisterItemClass)
    if ItemClass then
      local CinematicCloisterItemIns = UE4.UWidgetBlueprintLibrary.Create(self, ItemClass)
      CinematicCloisterItemIns:InitCinematicCloisterItemData(index, data)
      self.ChapterPanel:AddChildToVerticalBox(CinematicCloisterItemIns)
      local VerticalSlot = UE4.UWidgetLayoutLibrary.SlotAsVerticalBoxSlot(CinematicCloisterItemIns)
      local margin = UE4.FMargin()
      margin.Top = 15
      VerticalSlot:SetPadding(margin)
      return CinematicCloisterItemIns
    else
      LogDebug("CinematicCloisterPanel:AddCinematicCloisterItem", "CinematicCloisterItem class load failed")
    end
  end
end
return CinematicCloisterPanel
