local RoleTeamProxy = class("RoleTeamProxy", PureMVC.Proxy)
function RoleTeamProxy:OnRegister()
  local rows = ConfigMgr:GetRoleTeamTableRows()
  if rows then
    self.roleTeamTableRows = rows:ToLuaTable()
  end
end
function RoleTeamProxy:OnRemove()
end
function RoleTeamProxy:GetTeamTableRow(teamID)
  return self.roleTeamTableRows[tostring(teamID)]
end
return RoleTeamProxy
