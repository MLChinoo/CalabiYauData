local SelectRoleListPC = class("SelectRoleListPC", PureMVC.ViewComponentPage)
function SelectRoleListPC:GetIsCafeFree(RoleId)
  return GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy):IsCafeItem(RoleId)
end
return SelectRoleListPC
