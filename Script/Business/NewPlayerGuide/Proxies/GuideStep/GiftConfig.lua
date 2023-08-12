local WidgetSwitcher_PreviewVis, ViewpageVis
local Revertfunc = function(view)
  view.WidgetSwitcher_Preview:SetVisibility(WidgetSwitcher_PreviewVis)
  view:SetVisibility(ViewpageVis)
end
local ShowFunc = function(view)
  WidgetSwitcher_PreviewVis = view.WidgetSwitcher_Preview:GetVisibility()
  ViewpageVis = view:GetVisibility()
  view.WidgetSwitcher_Preview:SetVisibility(UE4.ESlateVisibility.Collapsed)
  view:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
return {
  viewClassPath = "/Game/PaperMan/UI/BP/PC/Frontend/Apartment/WBP_ApartmentPage_PC.WBP_ApartmentPage_PC_C",
  widgetName = "Gift_Btn",
  extras = {
    sizeoffsets = UE4.FVector2D(20, 20)
  },
  clickfunc = function(view)
    Revertfunc(view)
    view:OnClickGiftBtn()
  end,
  selectFunc = function(Arr)
    return Arr:GetRef(1)
  end,
  revertFunc = function(view)
    Revertfunc(view)
  end,
  showfunc = ShowFunc,
  continue = true
}
