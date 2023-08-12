local PMUWCommonGoodsBasePanel = require("Business/Common/ViewComponents/GoodsBasePanel/GoodsBasePanel")
local SelectRoleGridPanel = class("SelectRoleGridPanel", PMUWCommonGoodsBasePanel)
function SelectRoleGridPanel:InitializeLuaEvent()
  SelectRoleGridPanel.super.InitializeLuaEvent(self)
  local roleData = self:GetRolesData()
  self.roleItems = {}
  self:CheckDynamicEntryNum(table.count(roleData))
  for key, value in pairs(roleData) do
    self:UpdateItemInfo(key, value)
  end
end
function SelectRoleGridPanel:GetRolesData()
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleTeamProxy = GameFacade:RetrieveProxy(ProxyNames.RoleTeamProxy)
  local roleTableDatas = roleProxy:GetAllRoleCfgs()
  local roleData = {}
  for k, v in pairs(roleTableDatas) do
    if v.Available then
      local itemData = {}
      itemData.InItemID = v.RoleId
      itemData.SortId = v.SortId
      itemData.bUnlock = roleProxy:IsUnlockRole(v.RoleId)
      local roleSkin = roleProxy:GetRoleSkin(roleProxy:GetRoleCurrentWearAdvancedSkinID(v.RoleId))
      if roleSkin then
        itemData.softTexture = roleSkin.IconRoleSelect
      end
      local roleProfileTableData = roleProxy:GetRoleProfile(v.RoleId)
      if roleProfileTableData then
        itemData.itemName = roleProfileTableData.NameEn
        local roleProfessionData = roleProxy:GetRoleProfession(roleProfileTableData.Profession)
        if roleProfessionData then
          itemData.professSoftTexture = roleProfessionData.IconProfession
          itemData.professColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(roleProfessionData.Color2))
          local roleTeamData = roleTeamProxy:GetTeamTableRow(roleProfileTableData.Team)
          if roleTeamData then
            itemData.teamColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(roleTeamData.Color))
          end
        end
      end
      table.insert(roleData, itemData)
    end
  end
  return roleData
end
function SelectRoleGridPanel:CheckDynamicEntryNum(rolesDataNum)
  if 0 == rolesDataNum then
    return
  end
  local needItemNum = 0
  if rolesDataNum < self.ColumnNum then
    needItemNum = self.ColumnNum
  else
    needItemNum = self.ColumnNum * math.ceil(rolesDataNum / self.ColumnNum)
  end
  local EntryNum = self.DynamicEntryBox_Item:GetNumEntries()
  local SurplusNum = needItemNum - EntryNum
  if SurplusNum >= 0 then
    for i = 1, SurplusNum do
      local Widget = self:GenerateItem()
      self.roleItems[EntryNum + i] = Widget
    end
  end
  return self.roleItems
end
function SelectRoleGridPanel:UpdateItemInfoInDifferentPanel(itemWidget, goodItemInfo)
  itemWidget:SetEmptyState(false)
  itemWidget:SetItemImage(goodItemInfo.softTexture)
  itemWidget:SetProfessionIcon(goodItemInfo.professSoftTexture)
  itemWidget:SetProfessionIconColor(goodItemInfo.professColor)
  itemWidget:SeRoleName(goodItemInfo.itemName)
  itemWidget:SetRoleTeamColor(goodItemInfo.teamColor)
end
function SelectRoleGridPanel:UpdateItemInfo(dataIndex, roleItemInfo)
  if dataIndex <= #self.roleItems then
    local itemWidget = self.roleItems[dataIndex]
    if itemWidget then
      itemWidget:SetItemID(roleItemInfo.InItemID)
      itemWidget:SetEquipState(roleItemInfo.bEquip)
      itemWidget:SetItemUnlockState(roleItemInfo.bUnlock)
      itemWidget:SetRedDotVisible(roleItemInfo.bShowRedDot)
      itemWidget:SetDargState(roleItemInfo.bCanDrag)
      itemWidget:SetRedDotID(roleItemInfo.redDotID)
      self:UpdateItemInfoInDifferentPanel(itemWidget, roleItemInfo)
    else
      LogDebug("SelectRoleGridPanel:UpdateItemInfo", "itemWidget is null")
    end
  end
end
return SelectRoleGridPanel
