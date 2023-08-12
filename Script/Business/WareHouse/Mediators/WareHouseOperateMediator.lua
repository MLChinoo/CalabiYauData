local WareHouseOperateMediator = class("WareHouseOperateMediator", PureMVC.Mediator)
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
function WareHouseOperateMediator:ListNotificationInterests()
  return {
    NotificationDefines.NtfWareHouseOperatePanel,
    NotificationDefines.OnResWareHouseCloseOperate
  }
end
function WareHouseOperateMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  local Type = notification:GetType()
  local WareHouseOperatePage = self:GetViewComponent()
  if Name == NotificationDefines.NtfWareHouseOperatePanel then
    WareHouseOperatePage:UpdatePanel(Body)
  elseif Name == NotificationDefines.OnResWareHouseCloseOperate then
    ViewMgr:ClosePage(WareHouseOperatePage)
  end
end
function WareHouseOperateMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseOperatePanel, luaData)
end
return WareHouseOperateMediator
