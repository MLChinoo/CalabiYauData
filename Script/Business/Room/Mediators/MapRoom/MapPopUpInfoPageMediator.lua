local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local MapPopUpInfoPageMediator = class("MapPopUpInfoPageMediator", PureMVC.Mediator)
local roomDataProxy
function MapPopUpInfoPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.MapRoom.RefreshUI,
    NotificationDefines.MapRoom.ShowMapList
  }
end
function MapPopUpInfoPageMediator:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.MapRoom.RefreshUI then
    self:RefreshUI(notify:GetBody())
  elseif notify:GetName() == NotificationDefines.MapRoom.ShowMapList then
    self:ShowMapList(notify:GetBody())
  end
end
function MapPopUpInfoPageMediator:OnRegister()
  local viewComponent = self:GetViewComponent()
  viewComponent.actionLuaHandleKeyEvent:Add(self.LuaHandleKeyEvent, self)
  viewComponent.actionOnClickEsc:Add(self.OnClickEsc, self)
  viewComponent.actionOnClickChoose:Add(self.OnClickChoose, self)
  if viewComponent.actionOnClickBoomMode then
    viewComponent.actionOnClickBoomMode:Add(self.OnClickBoomMode, self)
  end
  if viewComponent.actionOnClickTeamDuelMode then
    viewComponent.actionOnClickTeamDuelMode:Add(self.OnClickTeamDuelMode, self)
  end
  if viewComponent.actionOnClickCrystalCompetitionMode then
    viewComponent.actionOnClickCrystalCompetitionMode:Add(self.OnClickCrystalCompetitionMode, self)
  end
  if viewComponent.actionOnClickTeamSportsMode then
    viewComponent.actionOnClickTeamSportsMode:Add(self.OnClickTeamSportsMode, self)
  end
  if viewComponent.actionOnClickTeamRiot3v3v3 then
    viewComponent.actionOnClickTeamRiot3v3v3:Add(self.OnClickTeamRiot3v3v3Mode, self)
  end
  viewComponent.actionSetMapInfo:Add(self.SetMapInfo, self)
  self:OnInit()
end
function MapPopUpInfoPageMediator:OnRemove()
  local viewComponent = self:GetViewComponent()
  viewComponent.actionLuaHandleKeyEvent:Remove(self.LuaHandleKeyEvent, self)
  viewComponent.actionOnClickEsc:Remove(self.OnClickEsc, self)
  viewComponent.actionOnClickChoose:Remove(self.OnClickChoose, self)
  viewComponent.actionOnClickBoomMode:Remove(self.OnClickBoomMode, self)
  if viewComponent.actionOnClickTeamDuelMode then
    viewComponent.actionOnClickTeamDuelMode:Remove(self.OnClickTeamDuelMode, self)
  end
  if viewComponent.actionOnClickCrystalCompetitionMode then
    viewComponent.actionOnClickCrystalCompetitionMode:Remove(self.OnClickCrystalCompetitionMode, self)
  end
  if viewComponent.actionOnClickTeamSportsMode then
    viewComponent.actionOnClickTeamSportsMode:Remove(self.OnClickTeamSportsMode, self)
  end
  if viewComponent.actionOnClickTeamRiot3v3v3 then
    viewComponent.actionOnClickTeamRiot3v3v3:Remove(self.OnClickTeamRiot3v3v3Mode, self)
  end
  viewComponent.actionSetMapInfo:Remove(self.SetMapInfo, self)
end
function MapPopUpInfoPageMediator:OnInit()
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    local mapId = self:GetCurrentMapId()
    local mapType = roomDataProxy:GetMapType(mapId)
    self:ShowMapList(mapType, mapId)
  end
end
function MapPopUpInfoPageMediator:GetCurrentMapId()
  local roomInfo = roomDataProxy:GetTeamInfo()
  local mapId = roomInfo.mapID
  if not mapId or 0 == mapId then
    mapId = roomDataProxy:GetDefaultMapId(RoomEnum.MapType.BlastInvasion)
  end
  return mapId
end
function MapPopUpInfoPageMediator:RefreshUI(data)
  if data.bAllowed ~= nil then
    self:AllowChooseMap(data.bAllowed)
  end
  if nil ~= data.mapId then
    local mapType = roomDataProxy:GetMapType(data.mapId)
    self:ShowMapList(mapType, data.mapId)
  end
end
function MapPopUpInfoPageMediator:OnClickEsc()
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.MapPopUpInfo)
end
function MapPopUpInfoPageMediator:OnClickChoose()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomInfo = proxy:GetTeamInfo()
  local curMapID = self.CurMapId
  if roomInfo and roomInfo.teamId and curMapID then
    proxy:ReqTeamMode(roomInfo.teamId, roomInfo.mode, curMapID)
  end
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.MapPopUpInfo)
end
function MapPopUpInfoPageMediator:OnClickBoomMode()
  self:ShowMapList(RoomEnum.MapType.BlastInvasion)
end
function MapPopUpInfoPageMediator:OnClickTeamSportsMode()
  self:ShowMapList(RoomEnum.MapType.TeamSports)
end
function MapPopUpInfoPageMediator:OnClickCrystalCompetitionMode()
  self:ShowMapList(RoomEnum.MapType.CrystalWar)
end
function MapPopUpInfoPageMediator:OnClickTeamDuelMode()
  self:ShowMapList(RoomEnum.MapType.Team5V5V5)
end
function MapPopUpInfoPageMediator:OnClickTeamRiot3v3v3Mode()
  self:ShowMapList(RoomEnum.MapType.TeamRiot3v3v3)
end
function MapPopUpInfoPageMediator:ShowMapList(mapType, mapId)
  local viewComponent = self:GetViewComponent()
  viewComponent.ListView_MapList:ClearListItems()
  self.mapItemList = {}
  local bShowFirst = false
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local mapTableRows = roomProxy:GetMapListFromMapCfg()
  local mapList = roomProxy:GetMapList()
  for key, value in pairs(mapTableRows) do
    for k, v in pairs(mapList) do
      if value.Id == v and value.Type == mapType then
        local mapData = {}
        mapData.paremtMediator = self
        mapData.mapId = value.Id
        mapData.mapType = value.Type
        mapData.mapName = value.Name
        mapData.mapTexture = value.IconMapMini2
        mapData.bIsCurrentSelected = false
        if not bShowFirst then
          self:SetMapInfo(value.Id)
          mapData.bIsCurrentSelected = true
          bShowFirst = true
        end
        local obj = ObjectUtil:CreateLuaUObject(viewComponent)
        obj.data = mapData
        viewComponent.ListView_MapList:AddItem(obj)
        self.mapItemList[value.Id] = obj
      end
    end
  end
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    viewComponent:SetWSMode(mapType)
  end
end
function MapPopUpInfoPageMediator:AllowChooseMap(bAllowed)
  local viewComponent = self:GetViewComponent()
  if false == bAllowed then
    viewComponent.Button_Choose:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    viewComponent.Button_Choose:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function MapPopUpInfoPageMediator:SetMapInfo(mapId)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local mapData = roomDataProxy:GetMapByMapId(mapId)
  if nil == mapData then
    return
  end
  local viewComponent = self:GetViewComponent()
  self.CurMapId = mapId
  if viewComponent.ConfigurableMapPanel then
    viewComponent.ConfigurableMapPanel:InitMapInfo(mapId)
  end
  local ModeIndex, DescIndex
  if tonumber(mapData.Type) == RoomEnum.MapType.TeamSport then
    ModeIndex, DescIndex = 6901, 6902
  elseif tonumber(mapData.Type) == RoomEnum.MapType.BlastInvasion then
    ModeIndex, DescIndex = 6903, 6904
  elseif tonumber(mapData.Type) == RoomEnum.MapType.CrystalWar then
    ModeIndex, DescIndex = 6905, 6906
  elseif tonumber(mapData.Type) == RoomEnum.MapType.Team5V5V5 then
    ModeIndex, DescIndex = 6909, 6910
  elseif tonumber(mapData.Type) == RoomEnum.MapType.TeamRiot3v3v3 then
    ModeIndex, DescIndex = 6911, 6912
  else
    LogInfo("not find the mapType", "modeIndex, descIndex is nil, to aviod report err, so we give the var default value")
    ModeIndex, DescIndex = 6901, 6902
  end
  local ModeIndexText = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(ModeIndex).ParaValue
  local DescIndexText = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(DescIndex).ParaValue
  if viewComponent.Text_MapMode then
    viewComponent.Text_MapMode:SetText(ModeIndexText)
  end
  viewComponent.Text_Mode:SetText(ModeIndexText)
  viewComponent.Text_ModeDesc:SetText(DescIndexText)
  viewComponent.Text_WorldViewDesc:SetText(mapData.WorldViewDesc)
  viewComponent.Text_Thumb3Title:SetText(mapData.Thumb3Title)
  viewComponent.Text_Thumb3Desc:SetText(mapData.Thumb3Desc)
  viewComponent.Text_MapName:SetText(mapData.Name)
  for key, value in pairs(self.mapItemList) do
    if mapId == key then
      value.data.bIsCurrentSelected = true
    else
      value.data.bIsCurrentSelected = false
    end
  end
end
return MapPopUpInfoPageMediator
