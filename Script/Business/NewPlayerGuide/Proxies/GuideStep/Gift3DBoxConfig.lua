return {
  continue = false,
  getTargetFunc = function()
    local class = LoadClass("/Script/Engine.StaticMeshActor")
    local world = LuaGetWorld()
    local Arr = UE4.UGameplayStatics.GetAllActorsOfClass(world, class)
    for i = 1, Arr:Length() do
      local item = Arr:Get(i)
      local objName = UE4.UKismetSystemLibrary.GetObjectName(item)
      if "Gift_Blur_Mask" == objName then
        return item
      end
    end
  end,
  getPositionAndSize = function(actor)
    local world = LuaGetWorld()
    local worldLocation = actor.RootComponent:K2_GetComponentLocation()
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(world, 0)
    local ScreenPosition = UE4.FVector2D(0, 0)
    local bNormalShow = UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PlayerController, worldLocation, ScreenPosition, false)
    local size = UE4.FVector2D(400, 400)
    ScreenPosition.Y = ScreenPosition.Y - size.Y + 50
    ScreenPosition.X = ScreenPosition.X - size.X / 2
    return ScreenPosition, size
  end,
  clickfunc = function()
    GameFacade:SendNotification(NotificationDefines.NewPlayerGuideGetGift)
  end
}
