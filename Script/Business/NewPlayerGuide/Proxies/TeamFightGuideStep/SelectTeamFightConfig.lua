return {
  viewClassPath = "/Game/PaperMan/UI/BP/PC/Frontend/RoomPC/Common/WBP_GameModeSelectPage_PC.WBP_GameModeSelectPage_PC_C",
  widgetName = "WBP_GameModeSelectPage_Btn_5",
  extras = {
    sizeoffsets = UE4.FVector2D(20, 20)
  },
  clickfunc = function(view)
    GameFacade:SendNotification(NotificationDefines.GameModeSelect.ClickGameModeSelectNavBtn, 5)
  end,
  selectFunc = function(Arr)
    return Arr:GetRef(1)
  end,
  continue = true
}
