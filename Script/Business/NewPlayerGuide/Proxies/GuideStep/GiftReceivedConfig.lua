return {
  viewClassPath = "/Game/PaperMan/UI/BP/CommonWidget/RewardDisplay/WBP_RewardPage.WBP_RewardPage_C",
  widgetName = "Btn_Close",
  clickfunc = function(view)
    view:OnBtnClose()
  end,
  handleKeyFunc = function(key, inputEvent)
    if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == "Space" then
      return true
    end
    return false
  end,
  extras = {
    sizeoffsets = UE4.FVector2D(20, 20)
  },
  continue = true
}
