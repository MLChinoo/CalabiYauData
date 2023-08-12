local MapModeBtnItem = class("MapModeBtnItem", PureMVC.ViewComponentPanel)
local MapModeBtnItemMediator = require("Business/Room/Mediators/MapRoom/MapModeBtnItemMediator")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local MapModeEnum = {}
MapModeEnum.MapModeBtnTypeEnum = {
  Left = 0,
  Middle = 1,
  Right = 2
}
function MapModeBtnItem:ListNeededMediators()
  return {MapModeBtnItemMediator}
end
function MapModeBtnItem:Construct()
  MapModeBtnItem.super.Construct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Add(self, MapModeBtnItem.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Add(self, MapModeBtnItem.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Add(self, MapModeBtnItem.OnCheckStateChanged)
  end
  self.bIsChecked = false
  self:InitInfo()
end
function MapModeBtnItem:Destruct()
  MapModeBtnItem.super.Destruct(self)
  if self.CheckBox_Left and self.CheckBox_Middle and self.CheckBox_Right then
    self.CheckBox_Left.OnCheckStateChanged:Remove(self, MapModeBtnItem.OnCheckStateChanged)
    self.CheckBox_Middle.OnCheckStateChanged:Remove(self, MapModeBtnItem.OnCheckStateChanged)
    self.CheckBox_Right.OnCheckStateChanged:Remove(self, MapModeBtnItem.OnCheckStateChanged)
  end
end
function MapModeBtnItem:SetBtnTypeToLastType()
  if self.WS_Style then
    self.bp_btnType = MapModeEnum.MapModeBtnTypeEnum.Right
    self.WS_Style:SetActiveWidgetIndex(MapModeEnum.MapModeBtnTypeEnum.Right)
  end
end
function MapModeBtnItem:InitInfo()
  if self.Txt_ModeName_Uncheck and self.Txt_ModeName_Check then
    local btnName = ""
    if self.bp_mapPlayModeType == RoomEnum.MapType.BlastInvasion then
      btnName = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "BombMode")
    elseif self.bp_mapPlayModeType == RoomEnum.MapType.CrystalWar then
      btnName = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "CrystaScrambleMode")
    elseif self.bp_mapPlayModeType == RoomEnum.MapType.Team5V5V5 then
      btnName = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "Team5V5V5")
    end
    self.Txt_ModeName_Uncheck:SetText(btnName)
    self.Txt_ModeName_Check:SetText(btnName)
  end
  if self.WS_Style then
    self.WS_Style:SetActiveWidgetIndex(self.bp_btnType)
  end
end
function MapModeBtnItem:OnCheckStateChanged(bIsChecked)
  if not self.bIsChecked then
    self:SetBtnStyle(true)
  end
  local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
  if checkbox then
    checkbox:SetIsChecked(true)
  end
end
function MapModeBtnItem:SetBtnStyle(bIsChecked)
  self.bIsChecked = bIsChecked
  if bIsChecked then
    local ignoreMapBtn = self.bp_mapPlayModeType
    GameFacade:SendNotification(NotificationDefines.MapRoom.ClearAllMapModeBtnCheck, ignoreMapBtn)
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    audio.PostEvent(audio.GetID(self.bp_clickSound))
    if self.WS_TextStyle then
      self.WS_TextStyle:SetActiveWidgetIndex(1)
    end
    GameFacade:SendNotification(NotificationDefines.MapRoom.ShowMapList, self.bp_mapPlayModeType)
  end
end
function MapModeBtnItem:OnClearBtnStyle()
  self.bIsChecked = false
  local checkbox = self.WS_Style:GetWidgetAtIndex(self.bp_btnType)
  if checkbox then
    checkbox:SetIsChecked(self.bIsChecked)
    if self.WS_TextStyle then
      self.WS_TextStyle:SetActiveWidgetIndex(0)
    end
  end
end
return MapModeBtnItem
