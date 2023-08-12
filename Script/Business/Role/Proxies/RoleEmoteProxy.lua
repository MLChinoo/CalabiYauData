local RoleEmoteProxy = class("RoleEmoteProxy", PureMVC.Proxy)
function RoleEmoteProxy:OnRegister()
  RoleEmoteProxy.super.OnRegister(self)
  self.roleEmoteTableRows = {}
  self.ownEmoteSeverData = {}
  local rows = ConfigMgr:GetRoleEmoteTableRow()
  if rows then
    local temp = rows:ToLuaTable()
    for key, value in pairs(temp) do
      self.roleEmoteTableRows[value.Id] = value
    end
  end
end
function RoleEmoteProxy:OnRemove()
end
function RoleEmoteProxy:GetRoleEmoteTableRow(emoteID)
  return self.roleEmoteTableRows[emoteID]
end
function RoleEmoteProxy:GetAllRoleEmoteTableRows()
  return self.roleEmoteTableRows
end
function RoleEmoteProxy:UpdateOwnEmoteSeverData(emoteList)
  if emoteList then
    for key, value in pairs(emoteList) do
      self.ownEmoteSeverData[value.item_id] = value
    end
  end
end
function RoleEmoteProxy:IsUnlockEmote(emoteID)
  return self.ownEmoteSeverData[emoteID] ~= nil
end
return RoleEmoteProxy
