local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local MapPopUpInfoPage = class("MapPopUpInfoPage", PureMVC.ViewComponentPage)
local MapPopUpInfoPageMediator = require("Business/Room/Mediators/MapRoom/MapPopUpInfoPageMediator")
function MapPopUpInfoPage:ListNeededMediators()
  return {MapPopUpInfoPageMediator}
end
function MapPopUpInfoPage:OnInitialized()
  MapPopUpInfoPage.super.OnInitialized(self)
end
function MapPopUpInfoPage:InitializeLuaEvent()
  self.actionLuaHandleKeyEvent = LuaEvent.new()
  self.actionOnClickEsc = LuaEvent.new()
  self.actionOnClickChoose = LuaEvent.new()
  self.actionOnClickBoomMode = LuaEvent.new()
  self.actionOnClickTeamSportsMode = LuaEvent.new()
  self.actionOnClickTeamRiot3v3v3 = LuaEvent.new()
  self.actionSetMapInfo = LuaEvent.new()
end
function MapPopUpInfoPage:Construct()
  MapPopUpInfoPage.super.Construct(self)
  self.Button_Choose.OnClicked:Add(self, self.OnClickChoose)
  self.Button_BoomMode.OnClicked:Add(self, self.OnClickBoomMode)
  self.Button_TeamSportsMode.OnClicked:Add(self, self.OnClickTeamSportsMode)
  self.Button_TeamRiotMode.OnClicked:Add(self, self.OnClickTeamRiotMode)
  self.ListView_MapList.BP_OnItemSelectionChanged:Add(self, self.OnItemSelectionChanged)
  self.Btn_ReturnToLobby.OnClickEvent:Add(self, self.OnClickEsc)
  self.Btn_ReturnToLobby:SetButtonName(ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "TipsBackText"))
end
function MapPopUpInfoPage:Destruct()
  MapPopUpInfoPage.super.Destruct(self)
  self.Button_Choose.OnClicked:Remove(self, self.OnClickChoose)
  self.Button_BoomMode.OnClicked:Remove(self, self.OnClickBoomMode)
  self.Button_TeamSportsMode.OnClicked:Remove(self, self.OnClickTeamSportsMode)
  self.Button_TeamRiotMode.OnClicked:Remove(self, self.OnClickTeamRiotMode)
  self.ListView_MapList.BP_OnItemSelectionChanged:Remove(self, self.OnItemSelectionChanged)
  self.Btn_ReturnToLobby.OnClickEvent:Remove(self, self.OnClickEsc)
end
function MapPopUpInfoPage:OnItemSelectionChanged(item)
  if nil == item then
    return
  end
  local mapId = item.data.mapId
  local sendMapData = {}
  sendMapData.mapId = mapId
  sendMapData.mapType = item.data.mapType
  sendMapData.bSelected = true
  GameFacade:SendNotification(NotificationDefines.TeamRoom.SetMapInfoSelect, sendMapData)
  self.actionSetMapInfo(mapId)
  local audio = UE4.UPMLuaAudioBlueprintLibrary
  audio.PostEvent(audio.GetID(self.bp_mapItemSelectVoice))
end
function MapPopUpInfoPage:OnClickEsc()
  self.actionOnClickEsc()
end
function MapPopUpInfoPage:OnClickChoose()
  self.actionOnClickChoose()
end
function MapPopUpInfoPage:OnClickBoomMode()
  self.actionOnClickBoomMode()
end
function MapPopUpInfoPage:OnClickTeamSportsMode()
  self.actionOnClickTeamSportsMode()
end
function MapPopUpInfoPage:OnClickTeamRiotMode()
  self.actionOnClickTeamRiot3v3v3()
end
function MapPopUpInfoPage:LuaHandleKeyEvent(key, inputEvent)
  return self.actionLuaHandleKeyEvent(key, inputEvent)
end
function MapPopUpInfoPage:AllowChooseMap(bAllowed)
  if false == bAllowed then
    self.Button_Choose:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Button_Choose:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function MapPopUpInfoPage:LuaHandleKeyEvent(key, inputEvent)
  local keyDisplayName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyDisplayName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickEsc()
    return true
  end
  return false
end
function MapPopUpInfoPage:SetWSMode(mapType)
  if mapType == RoomEnum.MapType.BlastInvasion then
    self.WidgetSwitcher_Mode:SetActiveWidgetIndex(0)
  elseif mapType == RoomEnum.MapType.TeamSports then
    self.WidgetSwitcher_Mode:SetActiveWidgetIndex(1)
  elseif mapType == RoomEnum.MapType.TeamRiot3v3v3 then
    self.WidgetSwitcher_Mode:SetActiveWidgetIndex(1)
  end
end
return MapPopUpInfoPage
