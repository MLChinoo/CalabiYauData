local MapPopUpInfoItem = class("MapPopUpInfoItem", PureMVC.ViewComponentPage)
local MapPopUpInfoItemMediator = require("Business/Room/Mediators/MapRoom/MapPopUpInfoItemMediator")
function MapPopUpInfoItem:ListNeededMediators()
  return {MapPopUpInfoItemMediator}
end
function MapPopUpInfoItem:OnInitialized()
  MapPopUpInfoItem.super.OnInitialized(self)
end
function MapPopUpInfoItem:InitializeLuaEvent()
  self.actionOnClickMap = LuaEvent.new()
  self.actionOnHoverMap = LuaEvent.new()
  self.actionSetSelected = LuaEvent.new()
end
function MapPopUpInfoItem:Construct()
  MapPopUpInfoItem.super.Construct(self)
  self.mapId = nil
  self.mapType = nil
  self:OnInit()
end
function MapPopUpInfoItem:Destruct()
  MapPopUpInfoItem.super.Destruct(self)
  self.parentMediator = nil
  self.mapId = nil
  self.mapType = nil
end
function MapPopUpInfoItem:OnInit()
  self.Button_Map.OnClicked:Add(self, self.OnClickMap)
  self.Button_Map.OnHovered:Add(self, self.OnHoverMap)
  self.Button_Map.OnUnhovered:Add(self, self.OnHoverMap)
  self.Image_Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Image_Hover:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function MapPopUpInfoItem:OnListItemObjectSet(listItemObject)
  self.parentMediator = listItemObject.data.paremtMediator
  self.mapId = listItemObject.data.mapId
  self.mapType = listItemObject.data.mapType
  self:SetImageByTexture2D(self.Image_Map, listItemObject.data.mapTexture)
  self.Text_MapName_Selected:SetText(listItemObject.data.mapName)
  self.Text_MapName_Unselected:SetText(listItemObject.data.mapName)
  self:SetSelected(listItemObject.data.bIsCurrentSelected)
end
function MapPopUpInfoItem:OnClickMap()
  self.actionOnClickMap()
end
function MapPopUpInfoItem:OnHoverMap()
  self.actionOnHoverMap()
end
function MapPopUpInfoItem:SetSelected(bSelected)
  self.actionSetSelected(bSelected)
end
return MapPopUpInfoItem
