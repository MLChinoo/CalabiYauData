local ShowPlayerGuideCmd = class("ShowPlayerGuideCmd", PureMVC.Command)
function ShowPlayerGuideCmd:GetRealData(data)
  local retData = {}
  retData.context = data.context or LuaGetWorld()
  local geometry
  if data.widget then
    geometry = data.widget:GetCachedGeometry()
  else
    geometry = data.geometry
  end
  retData.geometry = geometry
  retData.widget = data.widget
  if geometry then
    local position = UE4.FVector2D()
    UE4.USlateBlueprintLibrary.LocalToViewport(retData.context, geometry, UE4.FVector2D(0, 0), UE4.FVector2D(), position)
    local size = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
    retData.position = position
    retData.size = size
  else
    if data.position then
      retData.position = data.position
    end
    if data.size then
      retData.size = data.size
    end
  end
  retData.callfunc = data.callfunc
  retData.extras = data.extras
  retData.handleKeyFunc = data.handleKeyFunc
  return retData
end
function ShowPlayerGuideCmd:Execute(notification)
  if notification.body then
    local data = notification.body
    local realData = self:GetRealData(data)
    local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
    if NewPlayerGuideProxy:GetGuideUIExistFlag() then
      GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideShow, realData)
    else
      ViewMgr:OpenPage(realData.context, UIPageNameDefine.NewGuidePage, false, realData)
    end
  else
    LogDebug("ShowPlayerGuideCmd", "notification.body is nil")
  end
end
return ShowPlayerGuideCmd
