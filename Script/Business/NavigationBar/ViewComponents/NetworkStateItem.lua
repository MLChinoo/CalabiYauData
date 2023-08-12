local NetworkStateItem = class("NetworkStateItem", PureMVC.ViewComponentPanel)
function NetworkStateItem:InitializeLuaEvent()
  NetworkStateItem.super.InitializeLuaEvent()
  self.OnItemSelectedEvent = LuaEvent.new()
  self.Id = 0
  self.NetworkAddress = ""
  self.Ping = 0
  self.LossPercentage = 0
  self.NetworkStateImage = nil
  if self.Button_Item then
    self.Button_Item.OnClicked:Add(self, self.OnNetworkSelected)
  end
end
function NetworkStateItem:OnNetworkSelected()
  self.OnItemSelectedEvent(self.Id)
end
function NetworkStateItem:SetItemData(Index, Id, NetworkAddress, Ping, LossPercentage, NetworkStateImage)
  self.Id = Id
  self.NetworkAddress = NetworkAddress
  if self.TextBlock_Address then
    self.TextBlock_Address:SetText(NetworkAddress)
  end
  self:UpdateNetworkState(Ping, LossPercentage, NetworkStateImage)
end
function NetworkStateItem:UpdateNetworkState(Ping, LossPercentage, NetworkStateImage)
  self.Ping = Ping
  self.LossPercentage = LossPercentage
  self.NetworkStateImage = NetworkStateImage
  if self.TextBlock_Delay then
    local DelayStr = "0ms"
    if Ping > 300 then
      DelayStr = ">300" .. "ms"
    else
      DelayStr = tostring(Ping) .. "ms"
    end
    self.TextBlock_Delay:SetText(DelayStr)
  end
  if self.TextBlock_LossPercentage then
    local LossPercentageText = UE4.UKismetTextLibrary.AsPercent_Float(LossPercentage, UE4.ERoundingMode.HalfToEven, false, false, 1, 3, 0, 0)
    self.TextBlock_LossPercentage:SetText(LossPercentageText)
  end
  if self.Image_DelayState then
    self:SetImageByPaperSprite_MatchSize(self.Image_DelayState, NetworkStateImage)
  end
end
function NetworkStateItem:SetNetworkSelected(IsSelected)
  if IsSelected then
    if self.Image_Selected then
      self.Image_Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.Image_Selected then
    self.Image_Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return NetworkStateItem
