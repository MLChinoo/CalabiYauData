local ApartmentGiftGridItem = class("ApartmentGiftGridItem", PureMVC.ViewComponentPanel)
local Valid
function ApartmentGiftGridItem:Init(Index, Data)
  self.Index = Index
  self.ItemUUID = Data.InItemID
  self.ItemId = Data.ItemCfgId
  self.ItemName = Data.desc.itemName
  self.ItemDesc = Data.desc.itemDesc
  self.ItemNum = Data.count
  self.ItemImage = Data.softTexture
  self.RedDotID = Data.redDotID
  self:ShowRedDot(self.RedDotID and 0 ~= self.RedDotID)
  Valid = self.Image_Item and self.Image_Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  Valid = self.Image_Item and self:SetImageByTexture2D(self.Image_Item, Data.softTexture)
  Valid = self.TextBlock_ItemNum and self.TextBlock_ItemNum:SetText(Data.count)
  Valid = self.TextBlock_ItemNum and self.TextBlock_ItemNum:SetVisibility(Data.count > 1 and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.Button_Clicked and self.Button_Clicked:SetVisibility(UE.ESlateVisibility.Visible)
end
function ApartmentGiftGridItem:InitNoneItem()
  Valid = self.Button_Clicked and self.Button_Clicked:SetVisibility(UE.ESlateVisibility.Hidden)
  Valid = self.Image_Item and self.Image_Item:SetVisibility(UE.ESlateVisibility.Collapsed)
  Valid = self.TextBlock_ItemNum and self.TextBlock_ItemNum:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function ApartmentGiftGridItem:InitializeLuaEvent()
  self.actionOnClickButton = LuaEvent.new()
end
function ApartmentGiftGridItem:Construct()
  ApartmentGiftGridItem.super.Construct(self)
  Valid = self.Button_Clicked and self.Button_Clicked.OnClicked:Add(self, self.OnClickButton)
end
function ApartmentGiftGridItem:Destruct()
  Valid = self.Button_Clicked and self.Button_Clicked.OnClicked:Remove(self, self.OnClickButton)
  ApartmentGiftGridItem.super.Destruct(self)
end
function ApartmentGiftGridItem:OnClickButton()
  self.actionOnClickButton(self)
end
function ApartmentGiftGridItem:ShowRedDot(bIsShow)
  Valid = self.RedDotPanel and self.RedDotPanel:SetVisibility(bIsShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
return ApartmentGiftGridItem
