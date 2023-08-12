local TabBasePanelMeditor = require("Business/EquipRoom/Mediators/TabBasePanel/TabBasePanelMeditor")
local RoleTabBasePanelMeditor = class("RoleTabBasePanelMeditor", TabBasePanelMeditor)
function RoleTabBasePanelMeditor:ListNotificationInterests()
  local list = RoleTabBasePanelMeditor.super.ListNotificationInterests(self)
  table.insert(list, NotificationDefines.EquipRoomUpdateRoleInfoPanel)
  table.insert(list, NotificationDefines.EquipRoomRolePanelSelectRole)
  return list
end
function RoleTabBasePanelMeditor:OnRegister()
  RoleTabBasePanelMeditor.super.OnRegister(self)
end
function RoleTabBasePanelMeditor:OnRemove()
  RoleTabBasePanelMeditor.super.OnRemove(self)
end
function RoleTabBasePanelMeditor:HandleNotification(notify)
  RoleTabBasePanelMeditor.super.HandleNotification(self, notify)
  if self.bShow == false then
    return
  end
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleInfoPanel and self:GetViewComponent().RoleInfoPanel then
    self:GetViewComponent().RoleInfoPanel:UpdatePanel(notifyBody)
  end
end
function RoleTabBasePanelMeditor:UpdatePanelBySelctRoleID(roleID)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleInfoPanelCmd, roleID)
end
function RoleTabBasePanelMeditor:OnShowPanel()
  RoleTabBasePanelMeditor.super.OnShowPanel(self)
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleInfoPanelCmd, equiproomProxy:GetSelectRoleID())
end
return RoleTabBasePanelMeditor
