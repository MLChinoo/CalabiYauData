local WareHouseMediator = class("WareHouseMediator", PureMVC.Mediator)
local WareHouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
function WareHouseMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfWareHouseGridPanel,
    NotificationDefines.NtfWareHouseDescPanel,
    NotificationDefines.NtfWareHouseOperatePanel,
    NotificationDefines.OnResWareHouseCloseOperate
  }
end
function WareHouseMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local NtfBody = notification:GetBody()
  if NtfName == NotificationDefines.NtfWareHouseGridPanel then
    self:GetViewComponent():UpdateGridPanel(NtfBody)
  elseif NtfName == NotificationDefines.NtfWareHouseDescPanel then
    self:GetViewComponent():UpdateDescPanel(NtfBody)
  elseif NtfName == NotificationDefines.NtfWareHouseOperatePanel then
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.WareHouseOperatePage, nil, NtfBody)
  elseif NtfName == NotificationDefines.OnResWareHouseCloseOperate then
    self:GetViewComponent():OnResCloseOperate()
  end
end
function WareHouseMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseGridPanel)
end
return WareHouseMediator
