local MapPopUpInfoPage = class("MapPopUpInfoPage", PureMVC.ViewComponentPage)
local MapPopUpInfoPageMediator = require("Business/Room/Mediators/MapRoom/MapPopUpInfoPageMediator")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
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
  self.actionOnClickTeamDuelMode = LuaEvent.new()
  self.actionOnClickCrystalCompetitionMode = LuaEvent.new()
  self.actionSetMapInfo = LuaEvent.new()
end
function MapPopUpInfoPage:Construct()
  MapPopUpInfoPage.super.Construct(self)
  self.Button_Choose.OnClicked:Add(self, self.OnClickChoose)
  if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    self.Btn_Esc.OnClickEvent:Add(self, self.OnClickEsc)
  elseif 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    self.Btn_Esc.OnClicked:Add(self, self.OnClickEsc)
  end
  self:SetMapModeBtnVisibility()
  self.ListView_MapList.BP_OnItemSelectionChanged:Add(self, self.OnItemSelectionChanged)
  if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    self.Btn_Esc:SetHotKeyIsEnable(true)
  end
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
function MapPopUpInfoPage:Destruct()
  MapPopUpInfoPage.super.Destruct(self)
  self.Button_Choose.OnClicked:Remove(self, self.OnClickChoose)
  if 0 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    self.Btn_Esc.OnClickEvent:Remove(self, self.OnClickEsc)
  elseif 1 == UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld()) then
    self.Btn_Esc.OnClicked:Remove(self, self.OnClickEsc)
  end
end
function MapPopUpInfoPage:OnClickEsc()
  self.actionOnClickEsc()
end
function MapPopUpInfoPage:OnClickChoose()
  self.actionOnClickChoose()
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
function MapPopUpInfoPage:SetMapModeBtnVisibility()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local modeDatas = roomDataProxy:GetModeDatas()
  if modeDatas then
    for k, value in pairs(modeDatas) do
      if value.play_mode == RoomEnum.MapType.BlastInvasion then
        local boombModeBtn = self.Btn_BoomMode
        if value.contest_open then
          boombModeBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          boombModeBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      elseif value.play_mode == RoomEnum.MapType.CrystalWar then
        local crystalCompetitionBtn = self.Btn_CrystalCompetitionMode
        if value.contest_open then
          crystalCompetitionBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          crystalCompetitionBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      elseif value.play_mode == RoomEnum.MapType.Team5V5V5 then
        local teamDuelModeBtn = self.Btn_TeamDuelMode
        if value.contest_open then
          teamDuelModeBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          if curMapType == RoomEnum.MapType.Team5V5V5 then
            teamDuelModeBtn:OnCheckStateChanged(true)
          end
        else
          teamDuelModeBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
    if self.HBox_MapModeBtnList then
      local mapModeBtnListNum = self.HBox_MapModeBtnList:GetChildrenCount()
      local visibleMapModeBtnList = {}
      for index = 0, mapModeBtnListNum do
        local mapModeBtnItem = self.HBox_MapModeBtnList:GetChildAt(index)
        if mapModeBtnItem and mapModeBtnItem:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
          table.insert(visibleMapModeBtnList, mapModeBtnItem)
        end
      end
      if #visibleMapModeBtnList > 0 then
        local lastMapModeBtn = visibleMapModeBtnList[#visibleMapModeBtnList]
        if lastMapModeBtn then
          lastMapModeBtn:SetBtnTypeToLastType()
        end
      end
    end
    local mapId = self:GetCurrentMapId()
    local curMapType = roomDataProxy:GetMapType(mapId)
    if curMapType == RoomEnum.MapType.BlastInvasion then
      self.Btn_BoomMode:OnCheckStateChanged(true)
    elseif curMapType == RoomEnum.MapType.CrystalWar then
      self.Btn_CrystalCompetitionMode:OnCheckStateChanged(true)
    elseif curMapType == RoomEnum.MapType.Team5V5V5 then
      self.Btn_TeamDuelMode:OnCheckStateChanged(true)
    end
  else
    LogInfo("SetMapModeBtnVisibility", "modeDatas is nil")
  end
end
function MapPopUpInfoPage:GetCurrentMapId()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local roomInfo = roomDataProxy:GetTeamInfo()
  local mapId = roomInfo.mapID
  if not mapId or 0 == mapId then
    mapId = roomDataProxy:GetDefaultMapId(RoomEnum.MapType.BlastInvasion)
  end
  return mapId
end
return MapPopUpInfoPage
