local ApartmentRoomProxy = class("ApartmentRoomProxy", PureMVC.Proxy)
function ApartmentRoomProxy:OnRegister()
  self:SetCurrentPageType(GlobalEnumDefine.EApartmentPageType.Main)
  self.mainPageGalSequenceTableRow = {}
  self.lastMainPageSequenceID = 0
  self:InitConfig()
  self:InitAvgDelegateHandler()
end
function ApartmentRoomProxy:OnRemove()
  if self.AvgOptionSelectHandler then
    DelegateMgr:RemoveDelegate(self.AvgEventMgr.OnMultipleOptionSelected, self.AvgOptionSelectHandler)
    self.AvgOptionSelectHandler = nil
  end
  if self.DialogOptionSelectHandler then
    DelegateMgr:RemoveDelegate(self.AvgEventMgr.OnMultipleOptionSelected, self.DialogOptionSelectHandler)
    self.DialogOptionSelectHandler = nil
  end
end
function ApartmentRoomProxy:InitConfig()
  local arrRows = ConfigMgr:GetApartmentMainPageGalSequenceTableRow()
  if arrRows then
    self.mainPageGalSequenceTableRow = arrRows:ToLuaTable()
  end
end
function ApartmentRoomProxy:InitAvgDelegateHandler()
  self.AvgEventMgr = UE4.UCyAVGEventManager.Get(LuaGetWorld())
  if self.AvgEventMgr then
    self.AvgOptionSelectHandler = DelegateMgr:AddDelegate(self.AvgEventMgr.OnMultipleOptionSelected, self, ApartmentRoomProxy.OnAvgOptionSelected)
  end
  self.DialogEventMgr = UE4.UCyDialogueManager.Get(LuaGetWorld())
  if self.DialogEventMgr then
    self.DialogOptionSelectHandler = DelegateMgr:AddDelegate(self.DialogEventMgr.OnSelectDialogueNodeSelected, self, ApartmentRoomProxy.OnAvgOptionSelected)
  end
end
function ApartmentRoomProxy:GetRoleWearSkinID(roleID)
  return self:GetRoleDefaultWearSkinID(roleID)
end
function ApartmentRoomProxy:GetRoleDefaultWearSkinID(roleID)
  if nil == roleID then
    LogWarn("ApartmentRoomProxy:GetRoleWearSkinID", "roleID IS nil")
    return 0
  end
  local roleRow = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRole(roleID)
  if nil == roleRow then
    LogError("ApartmentRoomProxy:GetRoleWearSkinID", "roleRow is nil,请检查策划Role表格,roleID : " .. roleID)
    return 0
  end
  return roleRow.ApartmentRoleSkin
end
function ApartmentRoomProxy:GetPromisePageOpenState()
  return self.currentPageType == GlobalEnumDefine.EApartmentPageType.Promise
end
function ApartmentRoomProxy:SetCurrentPageType(type)
  self.currentPageType = type
end
function ApartmentRoomProxy:GetCurrentPageType()
  return self.currentPageType
end
function ApartmentRoomProxy:GetMainPageGalArray(roleID, activeArea)
  local array = {}
  for key, value in pairs(self.mainPageGalSequenceTableRow) do
    if value and value.RoleID == roleID and value.RoleActivityArea == activeArea then
      table.insert(array, value.SequenceID)
    end
  end
  return array
end
function ApartmentRoomProxy:RandomGetMainPageGalSequenceID()
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local roleID = KaNavigationProxy:GetCurrentRoleId()
  local activeArea = GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineConfigProxy):GetApartmnetCurrentActivityArea()
  local array = self:GetMainPageGalArray(roleID, activeArea)
  local newArray = {}
  for key, value in pairs(array) do
    if value ~= self.lastMainPageSequenceID then
      table.insert(newArray, value)
    end
  end
  local sequenceID = 0
  local length = table.count(newArray)
  if length > 0 then
    local index = math.random(length)
    sequenceID = newArray[index]
  end
  self.lastMainPageSequenceID = sequenceID
  return sequenceID
end
function ApartmentRoomProxy:OnAvgOptionSelected(nodeId, txtContent)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  LogInfo("ApartmentRoomProxy", "OnAvgOptionSelected, nodeId = %d", nodeId)
  KaPhoneProxy:InteractOperateReq(5, kaNavigationProxy:GetCurrentRoleId(), nodeId)
end
return ApartmentRoomProxy
