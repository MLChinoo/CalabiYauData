local ApartmentCheatPage = class("ApartmentCheatPage", PureMVC.ViewComponentPage)
function ApartmentCheatPage:Construct()
  ApartmentCheatPage.super.Construct(self)
  self:InitTool()
  self:UpdateStateList()
end
function ApartmentCheatPage:Destruct()
  ApartmentCheatPage.super.Destruct(self)
  self:ClearTool()
end
function ApartmentCheatPage:InitTool()
  local handler = function(obj, method)
    return function(...)
      method(obj, ...)
    end
  end
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GameUtil:IsBuildShipingOrTest() == false then
    if GlobalDelegateManager and DelegateMgr then
      self.OnOpenApartmentTestPage = DelegateMgr:AddDelegate(GlobalDelegateManager.OnOpenApartmentTestPage, self, "OnOpenApartmentTestPageCallBack")
      self.OnSequenceStartGlobalDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnSequenceStartGlobalDelegate, self, "OnSequenceStartCallBack")
    end
    if self.SwitchStateBtn then
      self.SwitchStateBtn.OnClicked:Add(self, handler(self, self.OnClickSwitchState))
    end
    if self.Btn_RoleSkin then
      self.Btn_RoleSkin.OnClicked:Add(self, handler(self, self.OnToolChangRole))
    end
  end
end
function ApartmentCheatPage:ClearTool()
  if GameUtil:IsBuildShipingOrTest() == false then
    local GlobalDelegateManager = GetGlobalDelegateManager()
    if GlobalDelegateManager and DelegateMgr then
      DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnOpenApartmentTestPage, self.OnOpenApartmentTestPage)
      DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnSequenceStartGlobalDelegate, self.OnSequenceStartGlobalDelegate)
    end
  end
end
function ApartmentCheatPage:OnOpenApartmentTestPageCallBack()
  if self.Info_panel then
    if self.Info_panel:IsVisible() == true then
      self.Info_panel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Info_panel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function ApartmentCheatPage:OnSequenceStartCallBack(sequenceID)
  if self.Info_panel and self.Info_panel:IsVisible() == true then
    self.Tex_SequenceID:SetText(sequenceID)
  end
end
function ApartmentCheatPage:UpdateStateList()
  local stateMap = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy).StateMap
  if stateMap and self.SelectAssetComboBox then
    for key, value in pairs(stateMap) do
      self.SelectAssetComboBox:AddOption(key)
    end
  end
end
function ApartmentCheatPage:OnClickSwitchState()
  if self.SelectAssetComboBox then
    local option = self.SelectAssetComboBox:GetSelectedOption()
    if option then
      local ApartmentStateMachineProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy)
      ApartmentStateMachineProxy:SwitchState(option)
    end
  end
end
function ApartmentCheatPage:OnToolChangRole()
  if self.Txt_RoleSkinId then
    local skinID = self.Txt_RoleSkinId:GetText()
    if nil == skinID or "" == skinID then
      return
    end
    GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):StopStateMachine()
    UE4.UPMApartmentSubsystem.Get(self:GetWorld()):SetApartmentCurRoleId(tonumber(skinID), 0)
    UE4.UPMApartmentSubsystem.Get(self:GetWorld()):SpawnApartmentCharacter(tonumber(skinID), 0)
  end
end
return ApartmentCheatPage
