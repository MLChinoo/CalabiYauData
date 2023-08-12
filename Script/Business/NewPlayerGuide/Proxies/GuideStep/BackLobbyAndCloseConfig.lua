return {
  clickfunc = function(view)
    view:OnClickBackBtn()
  end,
  continue = true,
  viewClassPath = "/Game/PaperMan/UI/BP/PC/Frontend/Apartment/WBP_ApartmentMainPage_PC.WBP_ApartmentMainPage_PC_C",
  widgetName = {
    "ItemDisplayKeys",
    "SizeBox_Esc"
  },
  extras = {
    sizeoffsets = UE4.FVector2D(20, 20)
  },
  handleKeyFunc = function(key, inputEvent)
    if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Escape" then
      return true
    end
    return false
  end
}
