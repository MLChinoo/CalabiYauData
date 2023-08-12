local ApartmentPromiseMediator = class("ApartmentPromiseMediator", PureMVC.Mediator)
local ApartmentPromisePage
function ApartmentPromiseMediator:OnRegister()
  ApartmentPromisePage = self:GetViewComponent()
end
function ApartmentPromiseMediator:OnRemove()
  self.super:OnRemove()
end
function ApartmentPromiseMediator:ListNotificationInterests()
  return {
    NotificationDefines.SetApartmentPromisePageData,
    NotificationDefines.RcvGetRewardAnimationFinish,
    NotificationDefines.RcvGetRewardSequencerFinish,
    NotificationDefines.PromiseTaskUnlockTipsRead
  }
end
function ApartmentPromiseMediator:HandleNotification(notification)
  if not ApartmentPromisePage:GetPageIsActive() then
    return
  end
  local Name = notification:GetName()
  local Body = notification:GetBody()
  if Name == NotificationDefines.SetApartmentPromisePageData then
    ApartmentPromisePage:Init(Body)
  elseif Name == NotificationDefines.RcvGetRewardAnimationFinish then
    ApartmentPromisePage:ReqGetReward()
  elseif Name == NotificationDefines.RcvGetRewardSequencerFinish then
    ApartmentPromisePage:ReqGetTaskReward()
  elseif Name == NotificationDefines.PromiseTaskUnlockTipsRead then
    self:NewTaskTipsRead(Body)
  end
end
function ApartmentPromiseMediator:NewTaskTipsRead(params)
  local curRoleId = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetCurrentRoleId()
  GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):InteractOperateReq(1, curRoleId, params.taskInfo)
end
return ApartmentPromiseMediator
