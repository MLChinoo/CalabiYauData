local GrowthPage = class("GrowthPage", PureMVC.ViewComponentPage)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthPage:OnShow(luaOpenData, nativeOpenData)
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function GrowthPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  ViewMgr:HidePage(self, UIPageNameDefine.GrowthDowngradeDialog)
end
function GrowthPage:LuaHandleKeyEvent(key, inputEvent)
  GamePlayGlobal:LuaHandleKeyEvent(self, key, inputEvent)
  if self:OnHandleMiniMapKeyEvent(key, inputEvent) then
    return true
  end
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName("Growth", arr)
  local keyNames = {}
  for i = 1, arr:Length() do
    local ele = arr:Get(i)
    if ele then
      table.insert(keyNames, UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
    end
  end
  local inputKeyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == inputKeyName or table.index(keyNames, inputKeyName) then
    ViewMgr:HidePage(self, UIPageNameDefine.GrowthPage)
    return true
  end
  return false
end
function GrowthPage:OnHandleMiniMapKeyEvent(key, inputEvent)
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName("ToggleMiniMap", arr)
  local keyNames = {}
  for i = 1, arr:Length() do
    local ele = arr:Get(i)
    if ele then
      table.insert(keyNames, UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
    end
  end
  local inputKeyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if table.index(keyNames, inputKeyName) then
    if inputEvent == UE4.EInputEvent.IE_Pressed then
    elseif inputEvent == UE4.EInputEvent.IE_Released then
      local MyPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
      if MyPlayerController then
        MyPlayerController:ToggleMiniMap()
      end
    end
    return true
  end
end
return GrowthPage
