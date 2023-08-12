local NetworkStatePanel = class("NetworkStatePanel", PureMVC.ViewComponentPanel)
function NetworkStatePanel:InitializeLuaEvent()
  NetworkStatePanel.super.InitializeLuaEvent()
  self.NetworkItemList = {}
end
function NetworkStatePanel:OnOpen()
  if self.PMButton_Network then
    self.PMButton_Network.OnPMButtonClicked:Add(self, self.OnClickNetworkBtn)
  end
  if self.RefreshBtn then
    self.RefreshBtn.OnClicked:Add(self, self.OnClickRefreshBtn)
  end
  self:UpdateNetworkDataList()
end
function NetworkStatePanel:OnShow()
  if self.Image_Arrow then
    self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
  end
  if self.NetworkPanel then
    self.NetworkPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function NetworkStatePanel:OnClose()
  if self.PMButton_Network then
    self.PMButton_Network.OnPMButtonClicked:Remove(self, self.OnClickNetworkBtn)
  end
  if self.NetworkListPanel then
    self.NetworkListPanel:ClearChildren()
  end
  if self.RefreshBtn then
    self.RefreshBtn.OnClicked:Remove(self, self.OnClickRefreshBtn)
  end
  self.NetworkItemList = nil
end
function NetworkStatePanel:UpdateNetworkDataList()
  if self.NetworkListPanel == nil then
    return
  end
  local NetworkStateSubSystem = UE4.UPMDsNetworkStateSubSystem.Get(LuaGetWorld())
  if nil == NetworkStateSubSystem then
    return
  end
  self.NetworkItemList = {}
  self.NetworkListPanel:ClearChildren()
  local DsClusterDatas = NetworkStateSubSystem:GetDsClusterDatas()
  if DsClusterDatas then
    for i = 1, DsClusterDatas:Length() do
      local data = DsClusterDatas:Get(i)
      self:AddNetworkItem(i, data.Id, data.DsClusterName, data.Ping, data.LossPercentage)
    end
    self:SetSelectNetworkItem(NetworkStateSubSystem:GetSelectedDsServerId())
  end
end
function NetworkStatePanel:AddNetworkItem(index, Id, NetworkAddress, Ping, NetworkLossPercentage)
  if self.NetworkListPanel and self.NetworkStateItemClass then
    local ItemClass = ObjectUtil:LoadClass(self.NetworkStateItemClass)
    if ItemClass then
      local NetworkItem = UE4.UWidgetBlueprintLibrary.Create(self, ItemClass)
      if NetworkItem then
        local NetworkStateImg = self:GetNetworkStateImg(Ping)
        NetworkItem:SetItemData(index, Id, NetworkAddress, Ping, NetworkLossPercentage, NetworkStateImg)
        NetworkItem.OnItemSelectedEvent:Add(self.SetSelectNetworkItem, self)
        self.NetworkListPanel:AddChildToVerticalBox(NetworkItem)
        table.insert(self.NetworkItemList, NetworkItem)
      end
    end
  end
end
function NetworkStatePanel:GetNetworkStateImg(Ping)
  local NetworkStateImg
  if self.NetworkStateImgList and self.NetworkStateImgList:Length() > 0 then
    NetworkStateImg = self.NetworkStateImgList:Get(1)
    if Ping > 100 then
      if self.NetworkStateImgList:IsValidIndex(3) then
        NetworkStateImg = self.NetworkStateImgList:Get(3)
      end
    elseif Ping > 50 then
      if self.NetworkStateImgList:IsValidIndex(2) then
        NetworkStateImg = self.NetworkStateImgList:Get(2)
      end
    elseif self.NetworkStateImgList:IsValidIndex(1) then
      NetworkStateImg = self.NetworkStateImgList:Get(1)
    end
  end
  return NetworkStateImg
end
function NetworkStatePanel:OnClickNetworkBtn()
  if self.NetworkPanel then
    if self.NetworkPanel:IsVisible() then
      self.NetworkPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if self.Image_Arrow then
        self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
      end
    else
      self.NetworkPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self.Image_Arrow then
        self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, 1))
      end
    end
  end
end
function NetworkStatePanel:SetSelectNetworkItem(Id)
  for k, v in pairs(self.NetworkItemList) do
    if v.Id == Id then
      v:SetNetworkSelected(true)
      if self.TextBlock_Address then
        self.TextBlock_Address:SetText(v.NetworkAddress)
      end
      if self.Image_NetworkDelay then
        self:SetImageByPaperSprite_MatchSize(self.Image_NetworkDelay, v.NetworkStateImage)
      end
    else
      v:SetNetworkSelected(false)
    end
  end
  local NetworkStateSubSystem = UE4.UPMDsNetworkStateSubSystem.Get(LuaGetWorld())
  if NetworkStateSubSystem then
    NetworkStateSubSystem:SetSelectedDsServerId(Id)
  end
end
function NetworkStatePanel:OnClickRefreshBtn()
  if self.IsCDTimer then
    return
  end
  local NetworkStateSubSystem = UE4.UPMDsNetworkStateSubSystem.Get(LuaGetWorld())
  if NetworkStateSubSystem then
    NetworkStateSubSystem:RefreshSeversPing()
    self.IsCDTimer = true
  end
  if self.RefreshBtn then
    self.RefreshBtn:ShowDisabledImage(true)
  end
  TimerMgr:AddTimeTask(3, 0, 1, function()
    if self.RefreshBtn then
      self.RefreshBtn:ShowDisabledImage(false)
    end
    self.IsCDTimer = false
  end)
end
return NetworkStatePanel
