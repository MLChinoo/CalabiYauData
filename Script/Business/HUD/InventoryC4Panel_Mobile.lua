require("UnLua")
local InventoryC4Panel_Mobile = Class()
function InventoryC4Panel_Mobile:Construct()
  if self.Button_Drop then
    self.Button_Drop.OnPressed:Add(self, InventoryC4Panel_Mobile.OnClkDrop)
  end
end
function InventoryC4Panel_Mobile:Destruct()
  if self.Button_Drop then
    self.Button_Drop.OnPressed:Remove(self, InventoryC4Panel_Mobile.OnClkDrop)
  end
end
function InventoryC4Panel_Mobile:OnClkDrop()
  if self:GetOwningPlayer() then
    self:GetOwningPlayer():DropBomb()
  end
end
return InventoryC4Panel_Mobile
