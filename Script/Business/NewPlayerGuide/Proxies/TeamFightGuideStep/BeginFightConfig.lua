return {
  viewClassPath = "/Game/PaperMan/UI/BP/PC/Frontend/RoomPC/MatchRoom/WBP_MatchRoom_PC.WBP_MatchRoom_PC_C",
  widgetName = "Button_Type1",
  extras = {
    sizeoffsets = UE4.FVector2D(20, 20)
  },
  clickfunc = function(view)
    view:OnClickButtonStart()
  end,
  selectFunc = function(Arr)
    return Arr:GetRef(1)
  end,
  continue = true
}
