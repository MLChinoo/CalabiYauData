return {
  viewClassPath = "/Game/PaperMan/UI/BP/PC/Frontend/NavigationBar/WBP_NavigationPage_PC.WBP_NavigationPage_PC_C",
  widgetName = "NavBP_Play",
  extras = {
    sizeoffsets = UE4.FVector2D(20, 20)
  },
  clickfunc = function(view)
    view:NavigationBarClick(UE4.EPMFunctionTypes.Play, 1)
  end,
  selectFunc = function(Arr)
    return Arr:GetRef(1)
  end,
  continue = true
}
